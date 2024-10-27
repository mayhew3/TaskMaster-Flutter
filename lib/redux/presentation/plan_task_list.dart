import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/plan_task_item.dart';
import 'package:taskmaster/redux/presentation/plan_task_list_viewmodel.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../date_util.dart';
import '../../keys.dart';
import '../../models/sprint.dart';
import '../../models/task_colors.dart';
import '../../models/task_display_grouping.dart';
import '../../models/task_item.dart';
import '../../models/task_item_recur_preview.dart';
import '../actions/sprint_actions.dart';
import 'delayed_checkbox.dart';
import 'header_list_item.dart';

class PlanTaskList extends StatefulWidget {
  final int? numUnits;
  final String? unitName;
  final DateTime? startDate;

  PlanTaskList({
    this.numUnits,
    this.unitName,
    this.startDate,
  }) : super(key: TaskMasterKeys.planTaskList);

  @override
  State<StatefulWidget> createState() => PlanTaskListState();
}

class PlanTaskListState extends State<PlanTaskList> {

  bool initialized = false;
  bool submitting = false;

  late final Sprint? activeSprint;

  // three queues for the selected task items
  List<TaskItem> taskItemQueue = [];
  List<TaskItemRecurPreview> taskItemRecurPreviewQueue = [];
  List<SprintDisplayTask> sprintDisplayTaskQueue = [];

  // ALL preview items to be displayed (existing task item list is dynamically created)
  List<TaskItemRecurPreview> tempIterations = [];

  bool hasTiles = false;

  late final DateTime endDate;

  void validateState() {
    if (activeSprint != null &&
        (widget.numUnits != null || widget.unitName != null || widget.startDate != null)) {
      throw Exception(
          "Expected all of numUnits, unitName, and startDate to be null if there is an active sprint.");
    }
  }

  void preSelectUrgentAndDueAndPreviousSprint(PlanTaskListViewModel viewModel) {
    BuiltList<TaskItem> baseList = getBaseList(viewModel);

    final Iterable<TaskItem> dueOrUrgentTasks = baseList.where((taskItem) =>
        taskItem.isDueBefore(endDate) ||
        taskItem.isUrgentBefore(endDate) ||
        taskItemIsInSprint(taskItem, viewModel.lastSprint)
    );
    taskItemQueue.addAll(dueOrUrgentTasks);
    sprintDisplayTaskQueue.addAll(dueOrUrgentTasks);
  }

  PlanTaskItemWidget _createWidget({required SprintDisplayTask taskItem, required PlanTaskListViewModel viewModel}) {
    return PlanTaskItemWidget(
      sprintDisplayTask: taskItem,
      endDate: endDate,
      sprint: null,
      highlightSprint: highlightSprint(taskItem, viewModel),
      initialCheckState: sprintDisplayTaskQueue.contains(taskItem) ? CheckState.checked : CheckState.inactive,
      onTaskAssignmentToggle: (checkState) {
        var alreadyQueued = sprintDisplayTaskQueue.contains(taskItem);
        if (alreadyQueued) {
          setState(() {
            if (taskItem is TaskItem) {
              taskItemQueue.remove(taskItem);
            } else if (taskItem is TaskItemRecurPreview) {
              taskItemRecurPreviewQueue.remove(taskItem);
            }
            sprintDisplayTaskQueue.remove(taskItem);
          });
          return CheckState.inactive;
        } else {
          setState(() {
            if (taskItem is TaskItem) {
              taskItemQueue.add(taskItem);
            } else if (taskItem is TaskItemRecurPreview) {
              taskItemRecurPreviewQueue.add(taskItem);
            }
            sprintDisplayTaskQueue.add(taskItem);
          });
          return CheckState.checked;
        }
      },
    );
  }

  List<TaskItem> getFilteredTasks(List<TaskItem> taskItems) {
    List<TaskItem> filtered = taskItems.where((taskItem) {
      return !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted() &&
          (activeSprint == null || !taskItemIsInSprint(taskItem, activeSprint));
    }).toList();
    return filtered;
  }

  BuiltList<TaskItem> getBaseList(PlanTaskListViewModel viewModel) {
    var sprint = activeSprint;
    if (sprint == null) {
      return taskItemsForPlacingOnNewSprint(viewModel.allTaskItems, endDate);
    } else {
      return taskItemsForPlacingOnExistingSprint(viewModel.allTaskItems, sprint);
    }
  }

  bool highlightSprint(SprintDisplayTask taskItem, PlanTaskListViewModel viewModel) {
    return taskItemIsInSprint(taskItem, viewModel.lastSprint);
  }

  bool wasInEarlierSprint(SprintDisplayTask taskItem, PlanTaskListViewModel viewModel) {
    if (taskItem is TaskItem) {
      var sprints = sprintsForTaskItemSelector(viewModel.allSprints, taskItem).where((sprint) => sprint != viewModel.lastSprint);
      return sprints.isNotEmpty;
    } else {
      return false;
    }
  }

  void createTemporaryIterations(PlanTaskListViewModel viewModel) {
    List<TaskItem> eligibleItems = [];
    eligibleItems.addAll(getBaseList(viewModel));
    var sprint = activeSprint;
    if (sprint != null) {
      eligibleItems.addAll(taskItemsForSprintSelector(viewModel.allTaskItems, sprint));
    }
    Set<String> recurIDs = new HashSet();

    for (var taskItem in eligibleItems) {
      if (taskItem.recurrenceDocId != null) {
        recurIDs.add(taskItem.recurrenceDocId!);
      }
    }

    for (var recurID in recurIDs) {
      Iterable<TaskItem> recurItems = eligibleItems.where((var taskItem) => taskItem.recurrenceDocId == recurID);
      List<TaskItem> sortedItems = recurItems.sorted((TaskItem t1, TaskItem t2) => t1.recurIteration!.compareTo(t2.recurIteration!));
      TaskItem newest = sortedItems.last;
      List<TaskItemRecurPreview> futureIterations = [];
      if (newest.startDate != null && !newest.startDate!.isUtc) {
        print("[createTemporaryIterations]: Task '${newest.name}' has non-UTC start date! ID: ${newest.docId}");
      }
      if (newest.recurWait == false) {
        addNextIterations(newest, endDate, futureIterations);
      }
    }

  }


  void addNextIterations(SprintDisplayTask newest, DateTime endDate, List<TaskItemRecurPreview> collector) {
    if (newest.startDate != null && !newest.startDate!.isUtc) {
      print("[addNextIterations]: Task '${newest.name}' has non-UTC start date! ID: ${newest.docId}");
    }
    TaskItemRecurPreview nextIteration = RecurrenceHelper.createNextIteration(newest, DateTime.now());
    var willBeUrgentOrDue = nextIteration.isDueBefore(endDate) || nextIteration.isUrgentBefore(endDate);
    var willBeTargetOrStart = nextIteration.isTargetBefore(endDate) || nextIteration.isScheduledBefore(endDate);

    if (willBeUrgentOrDue || willBeTargetOrStart) {
      if (willBeUrgentOrDue) {
        taskItemRecurPreviewQueue.add(nextIteration);
        sprintDisplayTaskQueue.add(nextIteration);
      }
      tempIterations.add(nextIteration);
      collector.add(nextIteration);
      addNextIterations(nextIteration, endDate, collector);
    }
  }

  void _addTaskTile({required List<StatelessWidget> tiles, required SprintDisplayTask task, required PlanTaskListViewModel viewModel}) {
    tiles.add(_createWidget(taskItem: task, viewModel: viewModel));
    hasTiles = true;
  }

  ListView _buildListView(BuildContext context, PlanTaskListViewModel viewModel) {
    // widget.appState.notificationScheduler.updateHomeScreenContext(context);
    final List<SprintDisplayTask> otherTasks = [];
    otherTasks.addAll(getBaseList(viewModel));
    otherTasks.addAll(tempIterations);

    Sprint? lastCompletedSprint = viewModel.lastSprint;

    var startDateSort = (SprintDisplayTask a, SprintDisplayTask b) => a.startDate!.compareTo(b.startDate!);
    var completionDateSort = (SprintDisplayTask a, SprintDisplayTask b) => a.completionDate!.compareTo(b.completionDate!);

    final List<TaskDisplayGrouping> groupings = [
      new TaskDisplayGrouping(displayName: "Last Sprint", displayOrder: 1, filter: (taskItem) => (taskItem is TaskItem) && taskItemIsInSprint(taskItem, lastCompletedSprint)),
      new TaskDisplayGrouping(displayName: "Older Sprints", displayOrder: 2, filter: (taskItem) => wasInEarlierSprint(taskItem, viewModel)),
      new TaskDisplayGrouping(displayName: "Due Soon", displayOrder: 3, filter: (taskItem) => taskItem.isDueBefore(endDate)),
      new TaskDisplayGrouping(displayName: "Urgent Soon", displayOrder: 4, filter: (taskItem) => taskItem.isUrgentBefore(endDate)),
      new TaskDisplayGrouping(displayName: "Target Soon", displayOrder: 5, filter: (taskItem) => taskItem.isTargetBefore(endDate)),
      new TaskDisplayGrouping(displayName: "Starting Later", displayOrder: 7, filter: (taskItem) => taskItem.isScheduledAfter(endDate), ordering: startDateSort),
      new TaskDisplayGrouping(displayName: "Completed", displayOrder: 8, filter: (taskItem) => taskItem.isCompleted() &&
              !viewModel.recentlyCompleted.any((t) => t.docId == taskItem.docId), ordering: completionDateSort),
      // must come last to take all the other tasks
      new TaskDisplayGrouping(displayName: "Tasks", displayOrder: 6, filter: (_) => true),
    ];

    List<StatelessWidget> tiles = [];

    groupings.forEach((g) => g.stealItemsThatMatch(otherTasks));
    groupings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    for (var grouping in groupings) {
      if (grouping.taskItems.isNotEmpty) {
        tiles.add(HeadingItem(grouping.displayName));
        grouping.taskItems.forEach((task) => _addTaskTile(tiles: tiles, task: task, viewModel: viewModel));
      }
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
    return activeSprint == null ?
    DateUtil.adjustToDate(widget.startDate!, widget.numUnits!, widget.unitName!) :
    activeSprint!.endDate;
  }

  bool addMode(PlanTaskListViewModel viewModel) {
    return activeSprint == null;
  }

  void submit(BuildContext context, PlanTaskListViewModel viewModel) async {
    var store = StoreProvider.of<AppState>(context);
    if (addMode(viewModel)) {
      SprintBlueprint sprint = SprintBlueprint(
          startDate: widget.startDate!,
          endDate: endDate,
          numUnits: widget.numUnits!,
          unitName: widget.unitName!,
          personDocId: viewModel.personDocId
      );
      print("Submitting");
      store.dispatch(CreateSprintWithTaskItems(sprintBlueprint: sprint,
          taskItems: taskItemQueue.toBuiltList(),
          taskItemRecurPreviews: taskItemRecurPreviewQueue.toBuiltList()));
    } else {
      store.dispatch(AddTaskItemsToExistingSprint(
          sprint: activeSprint!,
          taskItems: taskItemQueue.toBuiltList(),
          taskItemRecurPreviews: taskItemRecurPreviewQueue.toBuiltList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PlanTaskListViewModel>(
        onWillChange: (prev, current) {
          if (activeSprint == null) {
            if (prev != null && current.activeSprint != null) {
              Navigator.pop(context);
            }
          } else {
            if (prev != null) {
              var currentCount = taskItemsForSprintSelector(current.allTaskItems, current.activeSprint!).length;
              var prevCount = taskItemsForSprintSelector(prev.allTaskItems, prev.activeSprint!).length;
              if (currentCount > prevCount) {
                Navigator.pop(context);
              }
            }
          }

        },
        builder: (context, viewModel) {
          if (!initialized) {
            activeSprint = viewModel.activeSprint == null ? null : viewModel.activeSprint;
            validateState();
            endDate = getEndDate();
            preSelectUrgentAndDueAndPreviousSprint(viewModel);
            createTemporaryIterations(viewModel);
            initialized = true;
          }
          return
            Scaffold(
              appBar: AppBar(
                title: Text('Select Tasks'),
              ),
              body: _buildListView(context, viewModel),
              floatingActionButton: Visibility(
                visible: sprintDisplayTaskQueue.isNotEmpty,
                child: FloatingActionButton.extended(
                    onPressed: () => submit(context, viewModel),
                    label: Text('Submit')
                ),
              ),
            );
        },
        converter: PlanTaskListViewModel.fromStore
    );


  }

}