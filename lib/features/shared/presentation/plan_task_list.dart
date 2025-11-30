import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../../date_util.dart';
import '../../../keys.dart';
import '../../../models/sprint.dart';
import '../../../models/task_colors.dart';
import '../../../models/task_display_grouping.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../core/providers/auth_providers.dart';
import '../../sprints/providers/sprint_providers.dart';
import '../../sprints/services/sprint_service.dart';
import '../../tasks/providers/task_providers.dart';
import '../../../redux/presentation/plan_task_item.dart';
import '../../../redux/presentation/header_list_item.dart';
import '../../../models/check_state.dart';

/// Riverpod version of PlanTaskList
///
/// Displays tasks that can be selected for inclusion in a sprint
class PlanTaskList extends ConsumerStatefulWidget {
  final int? numUnits;
  final String? unitName;
  final DateTime? startDate;

  const PlanTaskList({
    super.key,
    this.numUnits,
    this.unitName,
    this.startDate,
  });

  @override
  ConsumerState<PlanTaskList> createState() => _PlanTaskListState();
}

class _PlanTaskListState extends ConsumerState<PlanTaskList> {
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

  bool popped = false;

  late final DateTime endDate;

  void validateState() {
    if (activeSprint != null &&
        (widget.numUnits != null || widget.unitName != null || widget.startDate != null)) {
      throw Exception(
          'Expected all of numUnits, unitName, and startDate to be null if there is an active sprint.');
    }
  }

  void preSelectUrgentAndDueAndPreviousSprint(
      BuiltList<TaskItem> allTaskItems, Sprint? lastSprint) {
    BuiltList<TaskItem> baseList = getBaseList(allTaskItems);

    final Iterable<TaskItem> dueOrUrgentTasks = baseList.where((taskItem) =>
        taskItem.isDueBefore(endDate) ||
        taskItem.isUrgentBefore(endDate) ||
        taskItemIsInSprint(taskItem, lastSprint)
    );
    taskItemQueue.addAll(dueOrUrgentTasks);
    sprintDisplayTaskQueue.addAll(dueOrUrgentTasks);
  }

  PlanTaskItemWidget _createWidget({
    required SprintDisplayTask taskItem,
    required BuiltList<Sprint> allSprints,
    required Sprint? lastSprint,
  }) {
    return PlanTaskItemWidget(
      sprintDisplayTask: taskItem,
      endDate: endDate,
      sprint: null,
      highlightSprint: highlightSprint(taskItem, lastSprint),
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

  BuiltList<TaskItem> getBaseList(BuiltList<TaskItem> allTaskItems) {
    var sprint = activeSprint;
    if (sprint == null) {
      return taskItemsForPlacingOnNewSprint(allTaskItems, endDate);
    } else {
      return taskItemsForPlacingOnExistingSprint(allTaskItems, sprint);
    }
  }

  bool highlightSprint(SprintDisplayTask taskItem, Sprint? lastSprint) {
    return taskItemIsInSprint(taskItem, lastSprint);
  }

  bool wasInEarlierSprint(SprintDisplayTask taskItem, BuiltList<Sprint> allSprints, Sprint? lastSprint) {
    if (taskItem is TaskItem) {
      var sprints = sprintsForTaskItemSelector(allSprints, taskItem).where((sprint) => sprint != lastSprint);
      return sprints.isNotEmpty;
    } else {
      return false;
    }
  }

  void createTemporaryIterations(BuiltList<TaskItem> allTaskItems) {
    List<TaskItem> eligibleItems = [];
    eligibleItems.addAll(getBaseList(allTaskItems));
    var sprint = activeSprint;
    if (sprint != null) {
      eligibleItems.addAll(taskItemsForSprintSelector(allTaskItems, sprint));
    }
    Set<String> recurIDs = HashSet();

    for (var taskItem in eligibleItems) {
      if (taskItem.recurrenceDocId != null) {
        recurIDs.add(taskItem.recurrenceDocId!);
      }
    }

    // Get all recurrences to populate tasks
    final allRecurrences = ref.read(taskRecurrencesProvider).value ?? [];

    for (var recurID in recurIDs) {
      Iterable<TaskItem> recurItems = eligibleItems.where((var taskItem) => taskItem.recurrenceDocId == recurID);
      List<TaskItem> sortedItems = recurItems.sorted((TaskItem t1, TaskItem t2) => t1.recurIteration!.compareTo(t2.recurIteration!));
      TaskItem newest = sortedItems.last;

      // Populate recurrence on the task if not already populated
      if (newest.recurrence == null && newest.recurrenceDocId != null) {
        final recurrence = allRecurrences.firstWhereOrNull((r) => r.docId == newest.recurrenceDocId);
        if (recurrence != null) {
          newest = newest.rebuild((b) => b..recurrence = recurrence.toBuilder());
        } else {
          // Skip this task if recurrence not found
          print('[TM-304] Skipping task ${newest.docId} - recurrence ${newest.recurrenceDocId} not found');
          continue;
        }
      }

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
      print("[addNextIterations]: Task '${newest.name}' has non-UTC start date! Iteration: ${newest.recurIteration}");
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

  void _addTaskTile({
    required List<StatelessWidget> tiles,
    required SprintDisplayTask task,
    required BuiltList<Sprint> allSprints,
    required Sprint? lastSprint,
  }) {
    tiles.add(_createWidget(
      taskItem: task,
      allSprints: allSprints,
      lastSprint: lastSprint,
    ));
    hasTiles = true;
  }

  ListView _buildListView(BuildContext context, BuiltList<TaskItem> allTaskItems, BuiltList<Sprint> allSprints,
      Sprint? lastSprint, BuiltList<TaskItem> recentlyCompleted) {
    final List<SprintDisplayTask> otherTasks = [];
    otherTasks.addAll(getBaseList(allTaskItems));
    otherTasks.addAll(tempIterations);

    startDateSort(SprintDisplayTask a, SprintDisplayTask b) => a.startDate!.compareTo(b.startDate!);
    completionDateSort(SprintDisplayTask a, SprintDisplayTask b) => a.completionDate!.compareTo(b.completionDate!);

    final List<TaskDisplayGrouping> groupings = [
      TaskDisplayGrouping(displayName: 'Last Sprint', displayOrder: 1, filter: (taskItem) => (taskItem is TaskItem) && taskItemIsInSprint(taskItem, lastSprint)),
      TaskDisplayGrouping(displayName: 'Older Sprints', displayOrder: 2, filter: (taskItem) => wasInEarlierSprint(taskItem, allSprints, lastSprint)),
      TaskDisplayGrouping(displayName: 'Due Soon', displayOrder: 3, filter: (taskItem) => taskItem.isDueBefore(endDate)),
      TaskDisplayGrouping(displayName: 'Urgent Soon', displayOrder: 4, filter: (taskItem) => taskItem.isUrgentBefore(endDate)),
      TaskDisplayGrouping(displayName: 'Target Soon', displayOrder: 5, filter: (taskItem) => taskItem.isTargetBefore(endDate)),
      TaskDisplayGrouping(displayName: 'Starting Later', displayOrder: 7, filter: (taskItem) => taskItem.isScheduledAfter(endDate), ordering: startDateSort),
      TaskDisplayGrouping(displayName: 'Completed', displayOrder: 8, filter: (taskItem) => taskItem.isCompleted() &&
              !recentlyCompleted.any((t) => t.docId == taskItem.getSprintDisplayTaskKey()), ordering: completionDateSort),
      // must come last to take all the other tasks
      TaskDisplayGrouping(displayName: 'Tasks', displayOrder: 6, filter: (_) => true),
    ];

    List<StatelessWidget> tiles = [];

    for (var g in groupings) {
      g.stealItemsThatMatch(otherTasks);
    }
    groupings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    for (var grouping in groupings) {
      if (grouping.taskItems.isNotEmpty) {
        tiles.add(HeadingItem(grouping.displayName));
        for (var task in grouping.taskItems) {
          _addTaskTile(
            tiles: tiles,
            task: task,
            allSprints: allSprints,
            lastSprint: lastSprint,
          );
        }
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

  bool addMode() {
    return activeSprint == null;
  }

  void submit(BuildContext context, String personDocId) async {
    if (submitting) {
      print('[TM-306] Submit already in progress, ignoring duplicate call');
      return;
    }

    submitting = true;

    if (addMode()) {
      SprintBlueprint sprint = SprintBlueprint(
          startDate: widget.startDate!,
          endDate: endDate,
          numUnits: widget.numUnits!,
          unitName: widget.unitName!,
          personDocId: personDocId
      );
      print('[TM-306] Submitting new sprint');
      await ref.read(createSprintProvider.notifier).call(
        sprintBlueprint: sprint,
        taskItems: taskItemQueue,
        taskItemRecurPreviews: taskItemRecurPreviewQueue,
      );
    } else {
      print('[TM-306] Adding ${taskItemQueue.length} tasks to sprint ${activeSprint!.docId}');
      await ref.read(addTasksToSprintProvider.notifier).call(
        sprint: activeSprint!,
        taskItems: taskItemQueue,
        taskItemRecurPreviews: taskItemRecurPreviewQueue,
      );

      // Pop after successful submit
      print('[TM-306] Submit complete, popping navigation');
      if (context.mounted && !popped) {
        popped = true;
        Navigator.pop(context);
      }
    }

    submitting = false;
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final allTasksAsync = ref.watch(tasksWithRecurrencesProvider);
    final allSprintsAsync = ref.watch(sprintsProvider);
    final recentlyCompletedList = ref.watch(recentlyCompletedTasksProvider);
    final personDocId = ref.watch(personDocIdProvider);

    // Handle loading/error states
    if (allTasksAsync.isLoading || allSprintsAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Select Tasks')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (allTasksAsync.hasError || allSprintsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text('Select Tasks')),
        body: Center(child: Text('Error loading data')),
      );
    }

    final allTasks = allTasksAsync.value ?? [];
    final allSprints = allSprintsAsync.value ?? [];
    final allTasksBuilt = BuiltList<TaskItem>(allTasks);
    final allSprintsBuilt = BuiltList<Sprint>(allSprints);
    final recentlyCompleted = BuiltList<TaskItem>(recentlyCompletedList);

    // Initialize on first build
    if (!initialized) {
      activeSprint = activeSprintSelector(allSprintsBuilt);
      validateState();
      endDate = getEndDate();
      final lastSprint = lastCompletedSprintSelector(allSprintsBuilt);
      preSelectUrgentAndDueAndPreviousSprint(allTasksBuilt, lastSprint);
      createTemporaryIterations(allTasksBuilt);
      initialized = true;

      // Set up listeners after initialization (so activeSprint is set)
      // Auto-pop when sprint is created (matches Redux onWillChange behavior)
      ref.listen(sprintsProvider, (previous, next) {
        if (!popped && activeSprint == null) {
          // In "add mode" - pop when a new active sprint appears
          final prevSprints = previous?.value ?? [];
          final nextSprints = next.value ?? [];
          final prevActiveSprint = activeSprintSelector(BuiltList<Sprint>(prevSprints));
          final nextActiveSprint = activeSprintSelector(BuiltList<Sprint>(nextSprints));

          if (prevActiveSprint == null && nextActiveSprint != null) {
            popped = true;
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        }
      });

      // Auto-pop when tasks are added to existing sprint
      if (activeSprint != null) {
        print('[TM-306] Setting up listener for sprint ${activeSprint!.docId}');
        ref.listen(sprintsProvider, (previous, next) {
          print('[TM-306] Sprints provider changed!');
          if (!popped) {
            // Find the current sprint in the updated list
            final prevSprints = previous?.value ?? [];
            final nextSprints = next.value ?? [];

            final prevSprint = prevSprints.firstWhereOrNull((s) => s.docId == activeSprint!.docId);
            final nextSprint = nextSprints.firstWhereOrNull((s) => s.docId == activeSprint!.docId);

            final prevCount = prevSprint?.sprintAssignments.length ?? 0;
            final nextCount = nextSprint?.sprintAssignments.length ?? 0;

            print('[TM-306] Sprint assignment count changed: $prevCount -> $nextCount');

            if (nextCount > prevCount) {
              print('[TM-306] Popping navigation!');
              popped = true;
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          }
        });
      }
    }

    final lastSprint = lastCompletedSprintSelector(allSprintsBuilt);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Tasks'),
      ),
      body: _buildListView(context, allTasksBuilt, allSprintsBuilt, lastSprint, recentlyCompleted),
      floatingActionButton: Visibility(
        visible: sprintDisplayTaskQueue.isNotEmpty,
        child: FloatingActionButton.extended(
            onPressed: () => submit(context, personDocId ?? ''),
            label: Text('Submit')
        ),
      ),
    );
  }
}
