import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/screens/plan_task_list.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/widgets/filter_button.dart';
import 'package:taskmaster/widgets/header_list_item.dart';
import 'package:taskmaster/widgets/snooze_dialog.dart';
import 'package:taskmaster/widgets/task_main_menu.dart';

class TaskListScreen extends StatefulWidget {
  final AppState appState;
  final BottomNavigationBarGetter bottomNavigationBarGetter;
  final TaskHelper taskHelper;
  final TaskListGetter taskListGetter;
  final Sprint sprint;
  final String title;
  final String subHeader;
  final String subSubHeader;

  TaskListScreen({
    @required this.appState,
    @required this.bottomNavigationBarGetter,
    @required this.taskHelper,
    @required this.taskListGetter,
    @required this.title,
    this.sprint,
    this.subHeader,
    this.subSubHeader,
  }) : super(key: TaskMasterKeys.taskList);

  @override
  State<StatefulWidget> createState() => TaskListScreenState();

}

class TaskListScreenState extends State<TaskListScreen> {
  bool showScheduled;
  bool showCompleted;
  bool showActive;

  Sprint activeSprint;

  List<TaskItem> recentlyCompleted = [];

  @override
  void initState() {
    super.initState();
    this.showScheduled = (widget.sprint != null);
    this.showCompleted = (widget.sprint != null);
    this.showActive = (widget.sprint != null);
    this.activeSprint = widget.appState.getActiveSprint();
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

  Future<TaskItem> toggleAndUpdateCompleted(TaskItem taskItem, bool complete) async {
    recentlyCompleted.add(taskItem);
    var future = await widget.taskHelper.completeTask(taskItem, complete, (callback) => setState(() => callback()));
    setState(() {});
    return future;
  }

  List<TaskItem> _moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  Card _createSummaryWidget(Sprint sprint, BuildContext context) {
    var currentDay = DateTime.now().difference(sprint.startDate.value).inDays + 1;
    var totalDays = sprint.endDate.value.difference(sprint.startDate.value).inDays;
    var sprintStr = "Active Sprint - Day " + currentDay.toString() + " of " + totalDays.toString();

    var completed = sprint.taskItems.where((taskItem) => taskItem.completionDate.value != null);
    var taskStr = completed.length.toString() + "/" + sprint.taskItems.length.toString() + " Tasks Complete";

    return Card(
      color: Color.fromARGB(100, 100, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
        side: BorderSide(
          color: TaskColors.sprintColor,
          width: 1.0,
        ),
      ),
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            )
        ),
        child: Container(
          padding: EdgeInsets.all(13.5),
          child: Row(
            children: <Widget>[
              Container(
                child: Icon(Icons.assignment, color: TaskColors.sprintColor),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          sprintStr,
                          style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      Text(
                          taskStr,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: TaskColors.sprintColor
                          )
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () => setState(() => showActive = !showActive),
                  child: Text(
                    showActive ? "Hide Tasks" : "Show Tasks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  EditableTaskItemWidget _createTaskCard({TaskItem taskItem, BuildContext context}) {

    var snoozeDialog = (TaskItem taskItem) {
      HapticFeedback.mediumImpact();
      showDialog<void>(context: context, builder: (context) => SnoozeDialog(
        taskItem: taskItem,
        taskHelper: widget.taskHelper,
      ));
    };

    return EditableTaskItemWidget(
      taskItem: taskItem,
      stateSetter: (callback) => setState(() => callback()),
      addMode: false,
      sprint: widget.sprint,
      highlightSprint: (widget.sprint == null && activeSprint != null && taskItem.sprints.contains(activeSprint)),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return DetailScreen(
              taskItem: taskItem,
              taskHelper: widget.taskHelper,
            );
          }),
        );
        setState(() {});
      },
      onLongPress: () => snoozeDialog(taskItem),
      onForcePress: (ForcePressDetails forcePressDetails) => snoozeDialog(taskItem),
      onTaskCompleteToggle: (checkState) async {
        var updatedItem = await toggleAndUpdateCompleted(taskItem, CheckState.inactive == checkState);
        return updatedItem.isCompleted() ? CheckState.checked : CheckState.inactive;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          try {
            await widget.taskHelper.deleteTask(taskItem, (callback) => setState(() => callback()));
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

  List<TaskItem> getFilteredTasks(List<TaskItem> taskItems) {
    var activeSprint = widget.appState.getActiveSprint();
    List<TaskItem> filtered = taskItems.where((taskItem) {
      bool passesScheduleFilter = showScheduled || !taskItem.isScheduled();
      bool passesCompletedFilter = showCompleted || !(taskItem.isCompleted() && !recentlyCompleted.contains(taskItem));
      bool passesActiveFilter = showActive || !(taskItem.sprints.contains(activeSprint));
      return passesScheduleFilter && passesCompletedFilter && passesActiveFilter;
    }).toList();
    return filtered;
  }

  ListView _buildListView(BuildContext context) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> allTasks = widget.taskListGetter();
    final List<TaskItem> otherTasks = getFilteredTasks(allTasks);

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted() && !recentlyCompleted.contains(taskItem));
    final List<TaskItem> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isPastDue());
    final List<TaskItem> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgent());

    List<TaskItem> targetTasks = [];
    if (widget.sprint == null) {
      targetTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isTarget());
    }

    final List<TaskItem> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduled());

    List<StatelessWidget> tiles = [];

    if (widget.sprint == null) {
      var activeSprint = widget.appState.getActiveSprint();
      if (activeSprint != null) {
        tiles.add(_createSummaryWidget(activeSprint, context));
      }
    }

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Past Due'));
      dueTasks.forEach((task) => tiles.add(_createTaskCard(taskItem: task, context: context)));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent'));
      urgentTasks.forEach((task) => tiles.add(_createTaskCard(taskItem: task, context: context)));
    }

    if (targetTasks.isNotEmpty) {
      tiles.add(HeadingItem('Target'));
      targetTasks.forEach((task) => tiles.add(_createTaskCard(taskItem: task, context: context)));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => tiles.add(_createTaskCard(taskItem: task, context: context)));
    }

    if (scheduledTasks.isNotEmpty) {
      tiles.add(HeadingItem('Scheduled'));
      scheduledTasks.sort((t1, t2) => t1.startDate.value?.compareTo(t2.startDate.value));
      scheduledTasks.forEach((task) => tiles.add(_createTaskCard(taskItem: task, context: context)));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => tiles.add(_createTaskCard(taskItem: task, context: context)));
    }

    if (widget.sprint != null) {
      tiles.add(_createAddMoreButton());
    }

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 54),
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  void _openPlanning(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PlanTaskList(
            appState: widget.appState,
            taskHelper: widget.taskHelper,
            taskListGetter: widget.appState.getAllTasks,
            sprint: widget.sprint,
          );
        },
        )
    );
    setState(() {
    });
  }

  Widget _createAddMoreButton() {
    return Container(
        padding: EdgeInsets.all(25.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child:
            Center(
                child:
                GestureDetector(
                  onTap: () => _openPlanning(context),
                  child: Text(
                      "Add More...",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
                  ),
                )
            ),
            ),
          ],
        )
    );
  }

  Widget getLoadingBody() {
    return Center(
        child: CircularProgressIndicator(
          key: TaskMasterKeys.tasksLoading,
        )
    );
  }

  Widget getTaskListBody(BuildContext context) {
    List<Widget> elements = [];
    if (widget.subHeader != null) {
      elements.add(
        Container(
          padding: EdgeInsets.only(left: 12.0, top: 12.0),
          child: Text(
            widget.subHeader,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        )
      );
    }
    if (widget.subSubHeader != null) {
      elements.add(
        Container(
          padding: EdgeInsets.only(left: 12.0, bottom: 12.0),
          child: Text(
            widget.subSubHeader,
            style: TextStyle(fontSize: 18),
          ),
        )
      );
    }
    ListView listView = _buildListView(context);
    Widget expanded = Expanded(child: listView);
    elements.add(expanded);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elements,
    );
  }

  Widget getBody() {
    return Builder(
      builder: (context) => Container(
          padding: EdgeInsets.only(top: 7.0),
          child: widget.appState.isLoading ? getLoadingBody() : getTaskListBody(context)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
        body: getBody(),
        drawer: TaskMainMenu(appState: widget.appState,),
        floatingActionButton: Visibility(
          visible: widget.sprint == null,
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditScreen(
                  taskItem: TaskItem(),
                  taskHelper: widget.taskHelper,
                  isEditing: false,
                )),
              );
              setState(() {});
            },
            child: Icon(Icons.add),
          ),
        ),
        bottomNavigationBar: widget.bottomNavigationBarGetter(),
      );

  }

}