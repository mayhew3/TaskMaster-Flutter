
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';

import 'package:taskmaster/keys.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/widgets/header_list_item.dart';


class PlanTaskList extends StatefulWidget {
  final AppState appState;
  final TaskHelper taskHelper;
  final TaskListGetter taskListGetter;
  final int numUnits;
  final String unitName;
  final DateTime startDate;

  PlanTaskList({
    @required this.appState,
    @required this.taskHelper,
    @required this.taskListGetter,
    this.numUnits,
    this.unitName,
    this.startDate,
  }) : super(key: TaskMasterKeys.planTaskList);

  @override
  State<StatefulWidget> createState() => PlanTaskListState();
}

class PlanTaskListState extends State<PlanTaskList> {

  List<TaskItem> sprintQueued = [];

  List<TaskItem> _moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  EditableTaskItemWidget _createWidget(TaskItem taskItem, BuildContext context) {
    return EditableTaskItemWidget(
      taskItem: taskItem,
      addMode: true,
      onTaskAssignmentToggle: (checkState) {
        var alreadyQueued = sprintQueued.contains(taskItem);
        if (alreadyQueued) {
          setState(() {
            sprintQueued.remove(taskItem);
          });
          return Future.value(CheckState.inactive);
        } else {
          setState(() {
            sprintQueued.add(taskItem);
          });
          return Future.value(CheckState.checked);
        }
      },
    );
  }

  List<TaskItem> getFilteredTasks(List<TaskItem> taskItems) {
    DateTime endDate = getEndDate();
    List<TaskItem> filtered = taskItems.where((taskItem) {
      return !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted();
    }).toList();
    return filtered;
  }

  ListView _buildListView(BuildContext context) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> allTasks = widget.taskListGetter();
    final List<TaskItem> otherTasks = getFilteredTasks(allTasks);

    DateTime endDate = getEndDate();

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted());
    final List<TaskItem> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isDueBefore(endDate));
    final List<TaskItem> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgentBefore(endDate));
    final List<TaskItem> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduledAfter(endDate));

    List<StatelessWidget> tiles = [];

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Due Soon'));
      dueTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent Soon'));
      urgentTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (scheduledTasks.isNotEmpty) {
      tiles.add(HeadingItem('Starting Later'));
      scheduledTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 54),
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  DateTime getEndDate() {
    return DateUtil.adjustToDate(widget.startDate, widget.numUnits, widget.unitName);
  }

  void submit() async {
    DateTime endDate = getEndDate();
    Sprint sprint = Sprint();
    sprint.startDate.value = widget.startDate;
    sprint.endDate.value = endDate;
    sprint.personId.value = widget.appState.personId;
    for (TaskItem taskItem in sprintQueued) {
      sprint.addToTasks(taskItem);
    }
    await widget.taskHelper.addSprintAndTasks(sprint, sprintQueued);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('Select Tasks'),
        ),
        body: _buildListView(context),
        floatingActionButton: Visibility(
          visible: sprintQueued.isNotEmpty,
          child: FloatingActionButton.extended(
            onPressed: submit,
            label: Text('Submit')
          ),
        ),
      );

  }

}