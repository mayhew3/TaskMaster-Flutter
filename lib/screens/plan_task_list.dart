import 'dart:collection';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_edit.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/widgets/header_list_item.dart';

import '../models/task_colors.dart';


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

  List<TaskItemBlueprint> sprintQueued = [];
  List<TaskItemBlueprint> tempIterations = [];
  Sprint? lastSprint;
  Sprint? activeSprint;

  bool hasTiles = false;

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

  List<TaskItemBlueprint> _moveSublist(List<TaskItemBlueprint> superList, bool Function(TaskItemBlueprint) condition) {
    List<TaskItemBlueprint> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  EditableTaskItemWidget _createWidget({required TaskItemBlueprint taskItem}) {
    return EditableTaskItemWidget(
      taskItem: taskItem,
      endDate: getEndDate(),
      sprint: null,
      stateSetter: (callback) => setState(() => callback()),
      addMode: true,
      highlightSprint: highlightSprint(taskItem),
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

  bool highlightSprint(TaskItemBlueprint taskItem) {
    return (taskItem is TaskItemEdit) ? taskItem.sprints.contains(lastSprint) : false;
  }

  bool wasInEarlierSprint(TaskItemBlueprint taskItem) {
    if (taskItem is TaskItemEdit) {
      var sprints = taskItem.sprints.where((sprint) => sprint != lastSprint);
      return sprints.isNotEmpty;
    } else {
      return false;
    }
  }

  void createTemporaryIterations() {
    List<TaskItemBlueprint> eligibleItems = [];
    eligibleItems.addAll(getBaseList());
    if (widget.sprint != null) {
      eligibleItems.addAll(widget.sprint!.taskItems);
    }
    DateTime endDate = getEndDate();
    Set<int> recurIDs = new HashSet();

    for (var taskItem in eligibleItems) {
      if (taskItem.recurrenceId != null) {
        recurIDs.add(taskItem.recurrenceId!);
      }
    }

    for (var recurID in recurIDs) {
      Iterable<TaskItemBlueprint> recurItems = eligibleItems.where((var taskItem) => taskItem.recurrenceId == recurID);
      List<TaskItemBlueprint> sortedItems = recurItems.sorted((TaskItemBlueprint t1, TaskItemBlueprint t2) => t1.recurIteration!.compareTo(t2.recurIteration!));
      TaskItemBlueprint newest = sortedItems.last;
      if (newest.recurWait == false) {
        addNextIterations(newest, endDate, eligibleItems);
      }
    }

  }

  void addNextIterations(TaskItemBlueprint newest, DateTime endDate, List<TaskItemBlueprint> collector) {
    TaskItemBlueprint nextIteration = widget.taskHelper.createNextIteration(newest, DateTime.now());
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
  
  void _addTaskTile({required List<StatelessWidget> tiles, required TaskItemBlueprint task}) {
    tiles.add(_createWidget(taskItem: task));
    hasTiles = true;
  }

  ListView _buildListView(BuildContext context) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItemBlueprint> otherTasks = [];
    otherTasks.addAll(getBaseList());
    otherTasks.addAll(tempIterations);

    DateTime endDate = getEndDate();

    Sprint? lastCompletedSprint = widget.appState.getLastCompletedSprint();

    final List<TaskItemBlueprint> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted());
    final List<TaskItemBlueprint> lastSprintTasks = _moveSublist(otherTasks, (taskItem) => (taskItem is TaskItemEdit) && taskItem.sprints.contains(lastCompletedSprint));
    final List<TaskItemBlueprint> otherSprintTasks = _moveSublist(otherTasks, (taskItem) => wasInEarlierSprint(taskItem));
    final List<TaskItemBlueprint> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isDueBefore(endDate));
    final List<TaskItemBlueprint> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgentBefore(endDate));
    final List<TaskItemBlueprint> targetTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isTargetBefore(endDate));
    final List<TaskItemBlueprint> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduledAfter(endDate));

    List<StatelessWidget> tiles = [];

    if (lastSprintTasks.isNotEmpty) {
      tiles.add(HeadingItem('Last Sprint'));
      lastSprintTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (otherSprintTasks.isNotEmpty) {
      tiles.add(HeadingItem('Older Sprints'));
      otherSprintTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Due Soon'));
      dueTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent Soon'));
      urgentTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (targetTasks.isNotEmpty) {
      tiles.add(HeadingItem('Target Soon'));
      targetTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (scheduledTasks.isNotEmpty) {
      tiles.add(HeadingItem('Starting Later'));
      scheduledTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => _addTaskTile(tiles: tiles, task: task));
    }

    if (!hasTiles) {
      tiles.add(_createNoTasksFoundCard());
    }

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 54),
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  Card _createNoTasksFoundCard() {
    return Card(
      shadowColor: TaskColors.invisible,
      color: TaskColors.backgroundColor,
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'No eligible tasks found.',
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime getEndDate() {
    return widget.sprint == null ?
        DateUtil.adjustToDate(widget.startDate!, widget.numUnits!, widget.unitName!) :
        widget.sprint!.endDate;
  }

  TaskItemBlueprint? findMatching(TaskItemBlueprint taskItem) {
    return sprintQueued.firstWhere((TaskItemBlueprint other) {
      return matchesId(taskItem, other) || tempMatches(taskItem, other);
    });
  }

  bool isChecked(TaskItemEdit taskItem) {
    var matching = findMatching(taskItem);
    return matching != null;
  }

  bool matchesId(TaskItemBlueprint a, TaskItemBlueprint b) {
    return a is TaskItemEdit && b is TaskItemEdit && a.id == b.id;
  }

  bool tempMatches(TaskItemBlueprint a, TaskItemBlueprint b) {
    return a is TaskItemEdit && b is TaskItemEdit &&
        a.recurrenceId == b.recurrenceId &&
        a.recurIteration == b.recurIteration;
  }

  Future<void> createSelectedIterations() async {
    print('${tempIterations.length} temp items created.');
    var toAdd = tempIterations.where((TaskItemBlueprint taskItem) => !(taskItem is TaskItem));
    print('${toAdd.length} checked temp items kept.');

    for (var taskItem in toAdd) {
      TaskItemEdit addedTask = await widget.taskHelper.addTask(taskItem);
      print('Adding (Recurrence ID ${taskItem.recurrenceId}, TaskItem ID ${taskItem.recurIteration})');
      sprintQueued.add(addedTask);
    }

    sprintQueued.removeWhere((element) => !(element is TaskItem));
    idCheck();
  }

  List<TaskItem> idCheck() {
    var withoutId = sprintQueued.where((TaskItemBlueprint taskItem) => !(taskItem is TaskItem));
    if (withoutId.isNotEmpty) {
      print('${withoutId.length} items still remain without an ID!');
      for (var item in withoutId) {
        print('Item: (${item.recurrenceId}, ${item.recurIteration})');
      }
    }
    return sprintQueued.cast<TaskItem>();
  }

  void submit() async {
    await createSelectedIterations();
    List<TaskItem> verified = idCheck();

    if (widget.sprint == null) {
      DateTime endDate = getEndDate();
      Sprint sprint = Sprint(
        startDate: widget.startDate!,
        endDate: endDate,
        numUnits: widget.numUnits!,
        unitName: widget.unitName!,
        personId: widget.appState.personId
      );
      await widget.taskHelper.addSprintAndTasks(sprint, verified);
    } else if (activeSprint != null) {
      await widget.taskHelper.addTasksToSprint(activeSprint!, verified);
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