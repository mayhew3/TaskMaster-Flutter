import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_edit.dart';
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

  List<TaskItemEdit> sprintQueued = [];
  List<TaskItemEdit> tempIterations = [];
  Sprint? lastSprint;
  Sprint? activeSprint;

  @override
  void initState() {
    super.initState();

    DateTime endDate = getEndDate();
    List<TaskItem> baseList = getBaseList();
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

  List<TaskItemEdit> _moveSublist(List<TaskItemEdit> superList, bool Function(TaskItemEdit) condition) {
    List<TaskItemEdit> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  EditableTaskItemWidget _createWidget({required TaskItemEdit taskItem}) {
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

  bool wasInEarlierSprint(TaskItemEdit taskItem) {
    var sprints = taskItem.sprints.where((sprint) => sprint != lastSprint);
    return sprints.isNotEmpty;
  }

  void createTemporaryIterations() {
    List<TaskItemEdit> eligibleItems = getBaseList();
    if (widget.sprint != null) {
      eligibleItems.addAll(widget.sprint!.taskItems);
    }
    DateTime endDate = getEndDate();
    Iterable<TaskItemEdit> recurItems = eligibleItems.where((TaskItemEdit taskItem) => taskItem.recurrenceId != null);
    Map<int, Iterable<TaskItemEdit>> groupedByRecurrence = groupBy(recurItems, (TaskItemEdit taskItem) => taskItem.recurrenceId!);
    groupedByRecurrence.forEach((int recurrenceId, Iterable<TaskItemEdit> taskItems) {
      List<TaskItemEdit> sortedItems = taskItems.sorted((TaskItemEdit t1, TaskItemEdit t2) => t1.recurIteration!.compareTo(t2.recurIteration!));
      TaskItemEdit newest = sortedItems.last;
      if (newest.recurWait == false) {
        addNextIterations(newest, endDate, eligibleItems);
      }
    });
  }

  void addNextIterations(TaskItemEdit newest, DateTime endDate, List<TaskItemEdit> collector) {
    TaskItemEdit nextIteration = widget.taskHelper.createNextIteration(newest, DateTime.now());
    var willBeUrgentOrDue = nextIteration.isDueBefore(endDate) || nextIteration.isUrgentBefore(endDate);
    var willBeTargetOrStart = nextIteration.isTargetBefore(endDate) || nextIteration.isScheduledBefore(endDate);

    if (willBeUrgentOrDue || willBeTargetOrStart) {
      if (willBeUrgentOrDue) {
        sprintQueued.add(nextIteration);
      }
      tempIterations.add(nextIteration);
      collector.add(nextIteration);
      addNextIterations(nextIteration, endDate, collector);
    }
  }
  
  ListView _buildListView(BuildContext context) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItemEdit> otherTasks = [];
    otherTasks.addAll(getBaseList());
    otherTasks.addAll(tempIterations);

    DateTime endDate = getEndDate();

    Sprint? lastCompletedSprint = widget.appState.getLastCompletedSprint();

    final List<TaskItemEdit> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted());
    final List<TaskItemEdit> lastSprintTasks = _moveSublist(otherTasks, (taskItem) => taskItem.sprints.contains(lastCompletedSprint));
    final List<TaskItemEdit> otherSprintTasks = _moveSublist(otherTasks, (taskItem) => wasInEarlierSprint(taskItem));
    final List<TaskItemEdit> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isDueBefore(endDate));
    final List<TaskItemEdit> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgentBefore(endDate));
    final List<TaskItemEdit> targetTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isTargetBefore(endDate));
    final List<TaskItemEdit> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduledAfter(endDate));

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
        widget.sprint!.endDate;
  }

  TaskItemEdit? findMatching(TaskItemEdit taskItem) {
    return sprintQueued.firstWhere((TaskItemEdit other) {
      return matchesId(taskItem, other) || tempMatches(taskItem, other);
    });
  }

  bool isChecked(TaskItemEdit taskItem) {
    var matching = findMatching(taskItem);
    return matching != null;
  }

  bool matchesId(TaskItemEdit a, TaskItemEdit b) {
    return a.id != null && b.id != null && a.id == b.id;
  }

  bool tempMatches(TaskItemEdit a, TaskItemEdit b) {
    return a.id == null && b.id == null &&
        a.recurrenceId == b.recurrenceId &&
        a.recurIteration == b.recurIteration;
  }

  Future<void> createSelectedIterations() async {
    print('${tempIterations.length} temp items created.');
    var toAdd = tempIterations.where((TaskItemEdit taskItem) {
      var matching = sprintQueued.where((TaskItemEdit other) => tempMatches(taskItem, other));
      return matching.isNotEmpty;
    });
    print('${toAdd.length} checked temp items kept.');

    for (TaskItemEdit taskItem in toAdd) {
      TaskItemEdit addedTask = await widget.taskHelper.addTask(taskItem);
      print('Adding (${taskItem.recurrenceId}, ${taskItem.recurIteration})');
      sprintQueued.remove(taskItem);
      sprintQueued.add(addedTask);
      idCheck();
    }

    idCheck();
  }

  void idCheck() {
    var withoutId = sprintQueued.where((TaskItemEdit taskItem) => taskItem.id == null);
    print('${withoutId.length} items still remain without an ID!');
    for (var item in withoutId) {
      print('Item: (${item.recurrenceId}, ${item.recurIteration})');
    }
  }

  void submit() async {
    await createSelectedIterations();

    if (widget.sprint == null) {
      DateTime endDate = getEndDate();
      Sprint sprint = Sprint(
        startDate: widget.startDate!,
        endDate: endDate,
        numUnits: widget.numUnits!,
        unitName: widget.unitName!,
        personId: widget.appState.personId
      );
      idCheck();
      await widget.taskHelper.addSprintAndTasks(sprint, sprintQueued);
    } else if (activeSprint != null) {
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