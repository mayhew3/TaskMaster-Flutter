import 'dart:collection';
import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../helpers/recurrence_helper.dart';
import '../../../models/sprint_blueprint.dart';
import '../../../models/sprint_display_task.dart';
import '../../../models/task_colors.dart';
import '../../../models/task_display_grouping.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/sprint.dart';
import '../../../date_util.dart';
import '../../../keys.dart';
import '../../../redux/presentation/plan_task_item.dart';
import '../../../redux/presentation/delayed_checkbox.dart';
import '../../../redux/presentation/header_list_item.dart';
import '../../../redux/selectors/selectors.dart';
import '../../../core/providers/auth_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/sprint_providers.dart';
import '../services/sprint_service.dart';

class SprintPlanningScreen extends ConsumerStatefulWidget {
  final int? numUnits;
  final String? unitName;
  final DateTime? startDate;
  final Sprint? sprint; // For adding to existing sprint

  const SprintPlanningScreen({
    super.key,
    this.numUnits,
    this.unitName,
    this.startDate,
    this.sprint,
  });

  @override
  ConsumerState<SprintPlanningScreen> createState() =>
      _SprintPlanningScreenState();
}

class _SprintPlanningScreenState extends ConsumerState<SprintPlanningScreen> {
  bool initialized = false;
  bool popped = false;

  late final Sprint? activeSprint;
  late final DateTime endDate;

  // Three queues for the selected task items
  List<TaskItem> taskItemQueue = [];
  List<TaskItemRecurPreview> taskItemRecurPreviewQueue = [];
  List<SprintDisplayTask> sprintDisplayTaskQueue = [];

  // ALL preview items to be displayed
  List<TaskItemRecurPreview> tempIterations = [];

  bool hasTiles = false;

  @override
  void initState() {
    super.initState();
    // activeSprint will be set in first build
  }

  void validateState() {
    if (activeSprint != null &&
        (widget.numUnits != null ||
            widget.unitName != null ||
            widget.startDate != null)) {
      throw Exception(
          'Expected all of numUnits, unitName, and startDate to be null if there is an active sprint.');
    }
  }

  void preSelectUrgentAndDueAndPreviousSprint() {
    final allTasks = ref.read(tasksProvider).value ?? [];
    final lastSprint = ref.read(lastCompletedSprintProvider);

    BuiltList<TaskItem> baseList = _getBaseList(allTasks);

    final Iterable<TaskItem> dueOrUrgentTasks = baseList.where((taskItem) =>
        taskItem.isDueBefore(endDate) ||
        taskItem.isUrgentBefore(endDate) ||
        _taskItemIsInSprint(taskItem, lastSprint));

    taskItemQueue.addAll(dueOrUrgentTasks);
    sprintDisplayTaskQueue.addAll(dueOrUrgentTasks);
  }

  bool _taskItemIsInSprint(SprintDisplayTask taskItem, Sprint? sprint) {
    if (sprint == null) return false;
    if (taskItem is! TaskItem) return false;
    return sprint.sprintAssignments
        .any((sa) => sa.taskDocId == taskItem.docId);
  }

  PlanTaskItemWidget _createWidget({
    required SprintDisplayTask taskItem,
  }) {
    final lastSprint = ref.read(lastCompletedSprintProvider);
    final allSprints = ref.read(sprintsProvider).value ?? [];

    return PlanTaskItemWidget(
      sprintDisplayTask: taskItem,
      endDate: endDate,
      sprint: null,
      highlightSprint: _taskItemIsInSprint(taskItem, lastSprint),
      initialCheckState: sprintDisplayTaskQueue.contains(taskItem)
          ? CheckState.checked
          : CheckState.inactive,
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

  BuiltList<TaskItem> _getBaseList(List<TaskItem> allTaskItems) {
    var sprint = activeSprint;
    if (sprint == null) {
      return taskItemsForPlacingOnNewSprint(
              allTaskItems.toBuiltList(), endDate)
          .toBuiltList();
    } else {
      return taskItemsForPlacingOnExistingSprint(
              allTaskItems.toBuiltList(), sprint)
          .toBuiltList();
    }
  }

  bool _wasInEarlierSprint(SprintDisplayTask taskItem) {
    final lastSprint = ref.read(lastCompletedSprintProvider);
    final allSprints = ref.read(sprintsProvider).value ?? [];

    if (taskItem is TaskItem) {
      var sprints = sprintsForTaskItemSelector(
              allSprints.toBuiltList(), taskItem)
          .where((sprint) => sprint != lastSprint);
      return sprints.isNotEmpty;
    } else {
      return false;
    }
  }

  void createTemporaryIterations() {
    final allTasks = ref.read(tasksProvider).value ?? [];
    List<TaskItem> eligibleItems = [];
    eligibleItems.addAll(_getBaseList(allTasks));

    var sprint = activeSprint;
    if (sprint != null) {
      eligibleItems.addAll(
        taskItemsForSprintSelector(allTasks.toBuiltList(), sprint),
      );
    }

    Set<String> recurIDs = HashSet();

    for (var taskItem in eligibleItems) {
      if (taskItem.recurrenceDocId != null) {
        recurIDs.add(taskItem.recurrenceDocId!);
      }
    }

    for (var recurID in recurIDs) {
      Iterable<TaskItem> recurItems =
          eligibleItems.where((var taskItem) => taskItem.recurrenceDocId == recurID);
      List<TaskItem> sortedItems = recurItems
          .sorted((TaskItem t1, TaskItem t2) =>
              t1.recurIteration!.compareTo(t2.recurIteration!));
      TaskItem newest = sortedItems.last;
      List<TaskItemRecurPreview> futureIterations = [];

      if (newest.recurWait == false) {
        _addNextIterations(newest, endDate, futureIterations);
      }
    }
  }

  void _addNextIterations(
    SprintDisplayTask newest,
    DateTime endDate,
    List<TaskItemRecurPreview> collector,
  ) {
    TaskItemRecurPreview nextIteration =
        RecurrenceHelper.createNextIteration(newest, DateTime.now());
    var willBeUrgentOrDue = nextIteration.isDueBefore(endDate) ||
        nextIteration.isUrgentBefore(endDate);
    var willBeTargetOrStart = nextIteration.isTargetBefore(endDate) ||
        nextIteration.isScheduledBefore(endDate);

    if (willBeUrgentOrDue || willBeTargetOrStart) {
      if (willBeUrgentOrDue) {
        taskItemRecurPreviewQueue.add(nextIteration);
        sprintDisplayTaskQueue.add(nextIteration);
      }
      tempIterations.add(nextIteration);
      collector.add(nextIteration);
      _addNextIterations(nextIteration, endDate, collector);
    }
  }

  void _addTaskTile({
    required List<StatelessWidget> tiles,
    required SprintDisplayTask task,
  }) {
    tiles.add(_createWidget(taskItem: task));
    hasTiles = true;
  }

  ListView _buildListView(BuildContext context) {
    final allTasks = ref.watch(tasksProvider).value ?? [];
    final lastSprint = ref.watch(lastCompletedSprintProvider);
    final recentlyCompleted = allTasks
        .where((t) =>
            t.completionDate != null &&
            t.completionDate!
                .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    final List<SprintDisplayTask> otherTasks = [];
    otherTasks.addAll(_getBaseList(allTasks));
    otherTasks.addAll(tempIterations);

    startDateSort(SprintDisplayTask a, SprintDisplayTask b) =>
        a.startDate!.compareTo(b.startDate!);
    completionDateSort(SprintDisplayTask a, SprintDisplayTask b) =>
        a.completionDate!.compareTo(b.completionDate!);

    final List<TaskDisplayGrouping> groupings = [
      TaskDisplayGrouping(
        displayName: 'Last Sprint',
        displayOrder: 1,
        filter: (taskItem) =>
            (taskItem is TaskItem) && _taskItemIsInSprint(taskItem, lastSprint),
      ),
      TaskDisplayGrouping(
        displayName: 'Older Sprints',
        displayOrder: 2,
        filter: (taskItem) => _wasInEarlierSprint(taskItem),
      ),
      TaskDisplayGrouping(
        displayName: 'Due Soon',
        displayOrder: 3,
        filter: (taskItem) => taskItem.isDueBefore(endDate),
      ),
      TaskDisplayGrouping(
        displayName: 'Urgent Soon',
        displayOrder: 4,
        filter: (taskItem) => taskItem.isUrgentBefore(endDate),
      ),
      TaskDisplayGrouping(
        displayName: 'Target Soon',
        displayOrder: 5,
        filter: (taskItem) => taskItem.isTargetBefore(endDate),
      ),
      TaskDisplayGrouping(
        displayName: 'Starting Later',
        displayOrder: 7,
        filter: (taskItem) => taskItem.isScheduledAfter(endDate),
        ordering: startDateSort,
      ),
      TaskDisplayGrouping(
        displayName: 'Completed',
        displayOrder: 8,
        filter: (taskItem) =>
            taskItem.isCompleted() &&
            !recentlyCompleted
                .any((t) => t.docId == taskItem.getSprintDisplayTaskKey()),
        ordering: completionDateSort,
      ),
      // must come last to take all the other tasks
      TaskDisplayGrouping(
        displayName: 'Tasks',
        displayOrder: 6,
        filter: (_) => true,
      ),
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
          _addTaskTile(tiles: tiles, task: task);
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
      },
    );
  }

  Card _createNoTasksFoundCard() {
    return Card(
      shadowColor: TaskColors.invisible,
      color: TaskColors.backgroundColor,
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
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
    return activeSprint == null
        ? DateUtil.adjustToDate(widget.startDate!, widget.numUnits!, widget.unitName!)
        : activeSprint!.endDate;
  }

  bool addMode() {
    return activeSprint == null;
  }

  Future<void> submit(BuildContext context) async {
    final personDocId = await ref.read(personDocIdProvider.future);
    if (personDocId == null) return;

    if (addMode()) {
      SprintBlueprint sprint = SprintBlueprint(
        startDate: widget.startDate!,
        endDate: endDate,
        numUnits: widget.numUnits!,
        unitName: widget.unitName!,
        personDocId: personDocId,
      );

      await ref.read(createSprintProvider.notifier).call(
            sprintBlueprint: sprint,
            taskItems: taskItemQueue,
            taskItemRecurPreviews: taskItemRecurPreviewQueue,
          );
    } else {
      await ref.read(addTasksToSprintProvider.notifier).call(
            sprint: activeSprint!,
            taskItems: taskItemQueue,
            taskItemRecurPreviews: taskItemRecurPreviewQueue,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for sprint creation/update to auto-close
    ref.listen(sprintsProvider, (previous, next) {
      if (!popped && previous != null && next.hasValue) {
        final prevSprints = previous.value ?? [];
        final nextSprints = next.value ?? [];

        if (addMode()) {
          // Check if active sprint was created
          final prevActiveSprint = ref.read(activeSprintProvider);
          final nowActiveSprint = _findActiveSprint(nextSprints);

          if (prevActiveSprint == null && nowActiveSprint != null) {
            popped = true;
            Navigator.pop(context);
          }
        } else {
          // Check if tasks were added to existing sprint
          final prevCount = _countTasksForSprint(prevSprints, activeSprint!);
          final nextCount = _countTasksForSprint(nextSprints, activeSprint!);

          if (nextCount > prevCount) {
            popped = true;
            Navigator.pop(context);
          }
        }
      }
    });

    if (!initialized) {
      activeSprint = widget.sprint ?? ref.read(activeSprintProvider);
      validateState();
      endDate = getEndDate();
      preSelectUrgentAndDueAndPreviousSprint();
      createTemporaryIterations();
      initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Tasks'),
      ),
      body: _buildListView(context),
      floatingActionButton: Visibility(
        visible: sprintDisplayTaskQueue.isNotEmpty,
        child: FloatingActionButton.extended(
          onPressed: () => submit(context),
          label: const Text('Submit'),
        ),
      ),
    );
  }

  Sprint? _findActiveSprint(List<Sprint> sprints) {
    final now = DateTime.timestamp();
    final matching = sprints.where((sprint) =>
        sprint.startDate.isBefore(now) &&
        sprint.endDate.isAfter(now) &&
        sprint.closeDate == null);
    return matching.isEmpty ? null : matching.last;
  }

  int _countTasksForSprint(List<Sprint> sprints, Sprint targetSprint) {
    final sprint = sprints.firstWhereOrNull((s) => s.docId == targetSprint.docId);
    if (sprint == null) return 0;
    return sprint.sprintAssignments.length;
  }
}
