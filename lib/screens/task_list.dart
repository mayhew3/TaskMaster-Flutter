import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/widgets/filter_button.dart';
import 'package:taskmaster/widgets/header_list_item.dart';
import 'package:taskmaster/widgets/nullable_dropdown.dart';

class TaskListScreen extends StatefulWidget {
  final AppState appState;
  final BottomNavigationBar bottomNavigationBar;
  final TaskHelper taskHelper;

  TaskListScreen({
    @required this.appState,
    @required this.bottomNavigationBar,
    @required this.taskHelper,
  }) : super(key: TaskMasterKeys.taskList);

  @override
  State<StatefulWidget> createState() => TaskListScreenState();

}

class TaskListScreenState extends State<TaskListScreen> {
  bool showScheduled;
  bool showCompleted;

  List<TaskItem> recentlyCompleted = [];

  @override
  void initState() {
    super.initState();
    this.showScheduled = false;
    this.showCompleted = false;
  }

  void _displaySnackBar(String msg, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void _toggleShowScheduled() {
    setState(() {
      this.showScheduled = !this.showScheduled;
    });
  }

  void _toggleShowCompleted() {
    setState(() {
      this.showCompleted = !this.showCompleted;
    });
  }

  Future<TaskItem> toggleAndUpdateCompleted(TaskItem taskItem, bool complete) {
    recentlyCompleted.add(taskItem);
    var future = widget.taskHelper.completeTask(taskItem, complete);
    setState(() {});
    return future;
  }

  List<TaskItem> _moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  EditableTaskItemWidget _createWidget(TaskItem taskItem, BuildContext context) {
    List<String> possibleRecurUnits = [
      'Days',
      'Weeks',
      'Months',
      'Years',
    ];

    List<String> possibleDateTypes = [
      'Start',
      'Target',
      'Urgent',
      'Due'
    ];

    var snoozeDialog = (TaskItem taskItem) {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();

      int numUnits = 3;
      String unitName = 'Days';
      String taskDateType = 'Urgent';

      showDialog<void>(context: context, builder: (context) => AlertDialog(
        title: Text('Snooze Task'),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 80.0,
                        child: EditableTaskField(
                          initialText: numUnits.toString(),
                          labelText: 'Num',
                          fieldSetter: (value) => numUnits = _parseValue(value),
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: NullableDropdown(
                      initialValue: unitName,
                      labelText: 'Unit',
                      possibleValues: possibleRecurUnits,
                      valueSetter: (value) => unitName = value,
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              NullableDropdown(
                initialValue: taskDateType,
                labelText: 'For Date',
                possibleValues: possibleDateTypes,
                valueSetter: (value) => taskDateType = value,
                validator: (value) {
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FlatButton(
            onPressed: () async {
              final form = formKey.currentState;

              if (form.validate()) {
                // need this to trigger valueSetters for any fields still in focus
                form.save();
              }

              await widget.taskHelper.snoozeTask(taskItem, numUnits, unitName, taskDateType);
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      ));
    };

    return EditableTaskItemWidget(
      taskItem: taskItem,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return DetailScreen(
              taskItem: taskItem,
              taskHelper: widget.taskHelper,
            );
          }),
        );
      },
      onLongPress: () => snoozeDialog(taskItem),
      onForcePress: (ForcePressDetails forcePressDetails) => snoozeDialog(taskItem),
      onCheckboxChanged: (complete) {
        toggleAndUpdateCompleted(taskItem, complete);
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          try {
            await widget.taskHelper.deleteTask(taskItem);
            _displaySnackBar("Task Deleted!", context);
            return true;
          } catch(err) {
            return false;
          }
        }
        return false;
      },
    );
  }

  ListView _buildListView(BuildContext context) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> otherTasks = widget.appState.getFilteredTasks(showScheduled, showCompleted, recentlyCompleted);

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted() && !recentlyCompleted.contains(taskItem));
    final List<TaskItem> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isPastDue());
    final List<TaskItem> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgent());
    final List<TaskItem> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduled());

    List<StatelessWidget> tiles = [];

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Past Due'));
      dueTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent'));
      urgentTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (scheduledTasks.isNotEmpty) {
      tiles.add(HeadingItem('Scheduled'));
      scheduledTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    return ListView.builder(
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(widget.appState.title),
          actions: <Widget>[
            FilterButton(
              scheduledGetter: () => showScheduled,
              completedGetter: () => showCompleted,
              toggleScheduled: _toggleShowScheduled,
              toggleCompleted: _toggleShowCompleted,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                widget.taskHelper.reloadTasks();
              },
            ),
          ],
        ),
        body:  Container(
          child: widget.appState.isLoading
              ?
          Center(
              child: CircularProgressIndicator(
                key: TaskMasterKeys.tasksLoading,
              )
          )
              : _buildListView(context),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditScreen(
                taskItem: TaskItem(),
                taskHelper: widget.taskHelper,
                isEditing: false,
              )),
            );
          },
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: widget.bottomNavigationBar,
      );

  }

  int _parseValue(String str) {
    var cleanString = _cleanString(str);
    return cleanString == null ? null : int.parse(str);
  }

  String _cleanString(String str) {
    if (str == null) {
      return null;
    } else {
      var trimmed = str.trim();
      if (trimmed.isEmpty) {
        return null;
      } else {
        return trimmed;
      }
    }
  }

}