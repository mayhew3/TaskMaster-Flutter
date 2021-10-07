import "package:collection/collection.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/widgets/header_list_item.dart';


class PlanTaskList extends StatefulWidget {
  final AppState appState;
  final TaskHelper taskHelper;
  final TaskListGetter taskListGetter;
  final int? numUnits;
  final String? unitName;
  final DateTime? startDate;
  final Sprint? sprint;

  PlanTaskList({
    required this.appState,
    required this.taskHelper,
    required this.taskListGetter,
    this.numUnits,
    this.unitName,
    this.startDate,
    this.sprint,
  }) : super(key: TaskMasterKeys.planTaskList);

  @override
  State<StatefulWidget> createState() => PlanTaskListState();
}

class PlanTaskListState extends State<PlanTaskList> {

  List<TaskItem> sprintQueued = [];
  List<TaskItem> tempIterations = [];
  Sprint? lastSprint;
  Sprint? activeSprint;

  @override
  void initState() {
    super.initState();

    DateTime endDate = getEndDate();
    var baseList = getBaseList();
    lastSprint = widget.appState.getLastCompletedSprint();
    activeSprint = widget.appState.getActiveSprint();

    if (widget.sprint == null) {
      final Iterable<TaskItem> dueOrUrgentTasks = baseList.where((taskItem) =>
          taskItem.isDueBefore(endDate) ||
          taskItem.isUrgentBefore(endDate) ||
          taskItem.sprints.contains(lastSprint)
      );
      sprintQueued.addAll(dueOrUrgentTasks);
    }

    createTemporaryIterations();
  }

  List<TaskItem> _moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  EditableTaskItemWidget _createWidget({required TaskItem taskItem}) {
    return EditableTaskItemWidget(
      taskItem: taskItem,
      endDate: getEndDate(),
      sprint: null,
      stateSetter: (callback) => setState(() => callback()),
      addMode: true,
      highlightSprint: taskItem.sprints.contains(lastSprint),
      initialCheckState: sprintQueued.contains(taskItem) ? CheckState.checked : CheckState.inactive,
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
      return !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted() &&
          (widget.sprint == null || !taskItem.sprints.contains(widget.sprint));
    }).toList();
    return filtered;
  }

  List<TaskItem> getBaseList() {
    final List<TaskItem> allTasks = widget.taskListGetter();
    return getFilteredTasks(allTasks);
  }

  bool wasInEarlierSprint(TaskItem taskItem) {
    var sprints = taskItem.sprints.where((sprint) => sprint != lastSprint);
    return sprints.isNotEmpty;
  }

  void createTemporaryIterations() {
    List<TaskItem> eligibleItems = getBaseList();
    if (widget.sprint != null) {
      eligibleItems.addAll(widget.sprint!.taskItems);
    }
    DateTime endDate = getEndDate();
    Iterable<TaskItem> recurItems = eligibleItems.where((TaskItem taskItem) => taskItem.recurrenceId.value != null);
    Map<int, Iterable<TaskItem>> groupedByRecurrence = groupBy(recurItems, (TaskItem taskItem) => taskItem.recurrenceId.value!);
    groupedByRecurrence.forEach((int recurrenceId, Iterable<TaskItem> taskItems) {
      List<TaskItem> sortedItems = taskItems.sorted((TaskItem t1, TaskItem t2) => t1.recurIteration.value!.compareTo(t2.recurIteration.value!));
      TaskItem newest = sortedItems.last;
      if (newest.recurWait.value == false) {
        addNextIterations(newest, endDate, eligibleItems);
      }
    });
  }

  void addNextIterations(TaskItem newest, DateTime endDate, List<TaskItem> collector) {
    TaskItem nextIteration = widget.taskHelper.createNextIteration(newest, DateTime.now());
    if (nextIteration.isDueBefore(endDate) || nextIteration.isUrgentBefore(endDate)) {
      sprintQueued.add(nextIteration);
      tempIterations.add(nextIteration);
      collector.add(nextIteration);
      addNextIterations(nextIteration, endDate, collector);
    }
  }
  
  ListView _buildListView(BuildContext context) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> otherTasks = getBaseList();
    otherTasks.addAll(tempIterations);

    DateTime endDate = getEndDate();

    Sprint? lastCompletedSprint = widget.appState.getLastCompletedSprint();

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted());
    final List<TaskItem> lastSprintTasks = _moveSublist(otherTasks, (taskItem) => taskItem.sprints.contains(lastCompletedSprint));
    final List<TaskItem> otherSprintTasks = _moveSublist(otherTasks, (taskItem) => wasInEarlierSprint(taskItem));
    final List<TaskItem> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isDueBefore(endDate));
    final List<TaskItem> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgentBefore(endDate));
    final List<TaskItem> targetTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isTargetBefore(endDate));
    final List<TaskItem> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduledAfter(endDate));

    List<StatelessWidget> tiles = [];

    if (lastSprintTasks.isNotEmpty) {
      tiles.add(HeadingItem('Last Sprint'));
      lastSprintTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (otherSprintTasks.isNotEmpty) {
      tiles.add(HeadingItem('Older Sprints'));
      otherSprintTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Due Soon'));
      dueTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent Soon'));
      urgentTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (targetTasks.isNotEmpty) {
      tiles.add(HeadingItem('Target Soon'));
      targetTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (scheduledTasks.isNotEmpty) {
      tiles.add(HeadingItem('Starting Later'));
      scheduledTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => tiles.add(_createWidget(taskItem: task)));
    }

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 54),
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  DateTime getEndDate() {
    return widget.sprint == null ?
        DateUtil.adjustToDate(widget.startDate!, widget.numUnits!, widget.unitName!) :
        widget.sprint!.endDate.value!;
  }

  TaskItem? findMatching(TaskItem taskItem) {
    return sprintQueued.firstWhere((TaskItem other) {
      return matchesId(taskItem, other) || tempMatches(taskItem, other);
    });
  }

  bool isChecked(TaskItem taskItem) {
    var matching = findMatching(taskItem);
    return matching != null;
  }

  bool matchesId(TaskItem a, TaskItem b) {
    return a.id.value != null && b.id.value != null && a.id.value == b.id.value;
  }

  bool tempMatches(TaskItem a, TaskItem b) {
    return a.id.value == null && b.id.value == null &&
        a.recurrenceId.value == b.recurrenceId.value &&
        a.recurIteration.value == b.recurIteration.value;
  }

  Future<void> createSelectedIterations() async {
    print('${tempIterations.length} temp items created.');
    var toAdd = tempIterations.where((TaskItem taskItem) {
      var matching = sprintQueued.where((TaskItem other) => tempMatches(taskItem, other));
      return matching.isNotEmpty;
    });
    print('${toAdd.length} checked temp items kept.');

    for (TaskItem taskItem in toAdd) {
      TaskItem addedTask = await widget.taskHelper.addTask(taskItem);
      print('Adding (${taskItem.recurrenceId.value}, ${taskItem.recurIteration.value})');
      sprintQueued.remove(taskItem);
      sprintQueued.add(addedTask);
      idCheck();
    }

    idCheck();
  }

  void idCheck() {
    var withoutId = sprintQueued.where((TaskItem taskItem) => taskItem.id.value == null);
    print('${withoutId.length} items still remain without an ID!');
    for (var item in withoutId) {
      print('Item: (${item.recurrenceId.value}, ${item.recurIteration.value})');
    }
  }

  void submit() async {
    await createSelectedIterations();

    if (widget.sprint == null) {
      DateTime endDate = getEndDate();
      Sprint sprint = Sprint();
      sprint.startDate.value = widget.startDate;
      sprint.endDate.value = endDate;
      sprint.numUnits.value = widget.numUnits;
      sprint.unitName.value = widget.unitName;
      sprint.personId.value = widget.appState.personId;
      idCheck();
      for (TaskItem taskItem in sprintQueued) {
        sprint.addToTasks(taskItem);
      }
      await widget.taskHelper.addSprintAndTasks(sprint, sprintQueued);
    } else if (activeSprint != null) {
      for (TaskItem taskItem in sprintQueued) {
        activeSprint!.addToTasks(taskItem);
      }
      await widget.taskHelper.addTasksToSprint(activeSprint!, sprintQueued);
    }

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