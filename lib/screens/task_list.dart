import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/widgets/filter_button.dart';
import 'package:taskmaster/widgets/header_list_item.dart';

class TaskListScreen extends StatefulWidget {
  final AppState appState;
  final TaskAdder taskAdder;
  final TaskCompleter taskCompleter;
  final TaskUpdater taskUpdater;
  final TaskDeleter taskDeleter;
  final TaskListReloader taskListReloader;
  final BottomNavigationBar bottomNavigationBar;

  TaskListScreen({
    @required this.appState,
    @required this.taskCompleter,
    @required this.taskUpdater,
    @required this.taskDeleter,
    @required this.bottomNavigationBar,
    @required this.taskAdder,
    @required this.taskListReloader,
  }) : super(key: TaskMasterKeys.taskList);

  @override
  State<StatefulWidget> createState() => TaskListScreenState();

}

class TaskListScreenState extends State<TaskListScreen> {
  bool showScheduled;
  bool showCompleted;

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

  List<TaskItem> _moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  EditableTaskItemWidget _createWidget(TaskItem taskItem, BuildContext context) {
    return EditableTaskItemWidget(
      taskItem: taskItem,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return DetailScreen(
              taskItem: taskItem,
              taskUpdater: widget.taskUpdater,
              taskCompleter: widget.taskCompleter,
            );
          }),
        );
      },
      onCheckboxChanged: (complete) {
        widget.taskCompleter(taskItem, complete);
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          try {
            await widget.taskDeleter(taskItem);
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
    final List<TaskItem> otherTasks = widget.appState.getFilteredTasks(showScheduled, showCompleted);

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.wasCompletedMoreThanASecondAgo());
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
                widget.taskListReloader();
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
                taskAdder: widget.taskAdder,
                taskItem: TaskItem(),
                isEditing: false,
              )),
            );
          },
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: widget.bottomNavigationBar,
      );

  }

}