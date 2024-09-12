import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/redux/presentation/plan_task_list_viewmodel.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import "package:collection/collection.dart";

import '../../date_util.dart';
import '../../keys.dart';
import '../../models/sprint.dart';
import '../../models/task_colors.dart';
import '../../models/task_item.dart';
import 'delayed_checkbox.dart';
import 'editable_task_item.dart';
import 'header_list_item.dart';

class PlanTaskList extends StatefulWidget {
  final int? numUnits;
  final String? unitName;
  final DateTime? startDate;
  final Sprint? sprint;

  PlanTaskList({
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

  bool hasTiles = false;

  @override
  void initState() {
    super.initState();

    createTemporaryIterations();
  }

  void preSelectUrgentAndDueAndPreviousSprint(PlanTaskListViewModel viewModel) {
    BuiltList<TaskItem> baseList = getBaseList(viewModel);
    DateTime endDate = getEndDate();

    final Iterable<TaskItem> dueOrUrgentTasks = baseList.where((taskItem) =>
        taskItem.isDueBefore(endDate) ||
        taskItem.isUrgentBefore(endDate) ||
        taskItemIsInSprint(taskItem, viewModel.lastSprint)
    );
    sprintQueued.addAll(dueOrUrgentTasks);
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
      addMode: true,
      highlightSprint: highlightSprint(taskItem),
      initialCheckState: sprintQueued.contains(taskItem) ? CheckState.checked : CheckState.inactive,
      onTaskAssignmentToggle: (checkState) {
        var alreadyQueued = sprintQueued.contains(taskItem);
        if (alreadyQueued) {
          setState(() {
            sprintQueued.remove(taskItem);
          });
          return CheckState.inactive;
        } else {
          setState(() {
            sprintQueued.add(taskItem);
          });
          return CheckState.checked;
        }
      },
    );
  }

  List<TaskItem> getFilteredTasks(List<TaskItem> taskItems) {
    DateTime endDate = getEndDate();
    List<TaskItem> filtered = taskItems.where((taskItem) {
      return !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted() &&
          (widget.sprint == null || !taskItemIsInSprint(taskItem, widget.sprint));
    }).toList();
    return filtered;
  }

  BuiltList<TaskItem> getBaseList(PlanTaskListViewModel viewModel) {
    var sprint = widget.sprint;
    if (sprint == null) {
      return taskItemsForPlacingOnNewSprint(viewModel.allTaskItems, getEndDate());
    } else {
      return taskItemsForPlacingOnExistingSprint(viewModel.allTaskItems, sprint);
    }
  }

  bool highlightSprint(TaskItem taskItem) {
    return (taskItem is TaskItem) ? taskItem.sprints.contains(lastSprint) : false;
  }

  bool wasInEarlierSprint(TaskItem taskItem) {
    if (taskItem is TaskItem) {
      var sprints = taskItem.sprints.where((sprint) => sprint != lastSprint);
      return sprints.isNotEmpty;
    } else {
      return false;
    }
  }

  void createTemporaryIterations() {
    List<TaskItem> eligibleItems = [];
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
      Iterable<TaskItem> recurItems = eligibleItems.where((var taskItem) => taskItem.recurrenceId == recurID);
      List<TaskItem> sortedItems = recurItems.sorted((TaskItem t1, TaskItem t2) => t1.recurIteration!.compareTo(t2.recurIteration!));
      TaskItem newest = sortedItems.last;
      if (newest.recurWait == false) {
        addNextIterations(newest, endDate, eligibleItems);
      }
    }

  }

  void addNextIterations(TaskItem newest, DateTime endDate, List<TaskItem> collector) {
    TaskItem nextIteration = widget.taskHelper.createNextIteration(newest, DateTime.now());
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

  void _addTaskTile({required List<StatelessWidget> tiles, required TaskItem task}) {
    tiles.add(_createWidget(taskItem: task));
    hasTiles = true;
  }

  ListView _buildListView(BuildContext context, PlanTaskListViewModel viewModel) {
    widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> otherTasks = [];
    otherTasks.addAll(getBaseList(viewModel));
    otherTasks.addAll(tempIterations);

    DateTime endDate = getEndDate();

    Sprint? lastCompletedSprint = widget.appState.getLastCompletedSprint();

    final List<TaskItem> completedTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isCompleted());
    final List<TaskItem> lastSprintTasks = _moveSublist(otherTasks, (taskItem) => (taskItem is TaskItem) && taskItem.sprints.contains(lastCompletedSprint));
    final List<TaskItem> otherSprintTasks = _moveSublist(otherTasks, (taskItem) => wasInEarlierSprint(taskItem));
    final List<TaskItem> dueTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isDueBefore(endDate));
    final List<TaskItem> urgentTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isUrgentBefore(endDate));
    final List<TaskItem> targetTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isTargetBefore(endDate));
    final List<TaskItem> scheduledTasks = _moveSublist(otherTasks, (taskItem) => taskItem.isScheduledAfter(endDate));

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
    return a is TaskItem && b is TaskItem && a.id == b.id;
  }

  bool tempMatches(TaskItem a, TaskItem b) {
    return a is TaskItem && b is TaskItem &&
        a.recurrenceId == b.recurrenceId &&
        a.recurIteration == b.recurIteration;
  }

  Future<void> createSelectedIterations() async {
    print('${tempIterations.length} temp items created.');

    // todo: need to save the recurrences to hand in to addTaskIteration()
    var toAdd = tempIterations.where((TaskItem taskItem) => !(taskItem is TaskItem));
    print('${toAdd.length} checked temp items kept.');

    for (var taskItem in toAdd) {
      TaskItem addedTask = await widget.taskHelper.addTaskIteration(taskItem, null, widget.appState.personId, (callback) => setState(() => callback()));
      print('Adding (Recurrence ID ${taskItem.recurrenceId}, TaskItem ID ${taskItem.recurIteration})');
      sprintQueued.add(addedTask);
    }

    sprintQueued.removeWhere((element) => !(element is TaskItem));
    idCheck();
  }

  List<TaskItem> idCheck() {
    var withoutId = sprintQueued.where((TaskItem taskItem) => !(taskItem is TaskItem));
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

    Navigator.pop(context, 'Added');
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