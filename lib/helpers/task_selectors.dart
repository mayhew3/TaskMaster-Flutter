import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/sprint_display_task.dart';

/// Pure selector functions for tasks and sprints.
/// These are stateless functions that filter and search collections.

/// Find a task item by ID
TaskItem? taskItemSelector(BuiltList<TaskItem> taskItems, String id) {
  try {
    return taskItems.firstWhere((taskItem) => taskItem.docId == id);
  } catch (e) {
    return null;
  }
}

/// Find a task recurrence by ID
TaskRecurrence? taskRecurrenceSelector(BuiltList<TaskRecurrence> taskRecurrences, String? id) {
  if (id == null) {
    return null;
  }
  try {
    return taskRecurrences.firstWhere((recurrence) => recurrence.docId == id);
  } catch (e) {
    return null;
  }
}

/// Find the currently active sprint (started but not ended/closed)
Sprint? activeSprintSelector(BuiltList<Sprint> sprints) {
  DateTime now = DateTime.timestamp();
  Iterable<Sprint> matching = sprints.where((sprint) =>
      sprint.startDate.isBefore(now) &&
      sprint.endDate.isAfter(now) &&
      sprint.closeDate == null);
  return matching.isEmpty ? null : matching.last;
}

/// Find the most recently completed sprint
Sprint? lastCompletedSprintSelector(BuiltList<Sprint> sprints) {
  List<Sprint> matching = sprints.where((sprint) {
    return DateTime.now().isAfter(sprint.endDate);
  }).toList();
  matching.sort((a, b) => a.endDate.compareTo(b.endDate));
  return matching.isEmpty ? null : matching.last;
}

/// Get all sprints that contain a specific task
BuiltList<Sprint> sprintsForTaskItemSelector(BuiltList<Sprint> sprints, TaskItem taskItem) {
  return sprints.where((s) => s.sprintAssignments.where((sa) => sa.taskDocId == taskItem.docId).isNotEmpty).toBuiltList();
}

/// Get all tasks assigned to a specific sprint
BuiltList<TaskItem> taskItemsForSprintSelector(BuiltList<TaskItem> taskItems, Sprint sprint) {
  return taskItems.where((t) => sprint.sprintAssignments.where((sa) => sa.taskDocId == t.docId).isNotEmpty).toBuiltList();
}

/// Tasks already assigned to [sprint] from which the planning popups generate
/// future recurrence-iteration previews (TM-348). Excludes family-shared
/// tasks: a legacy family-shared recurring task that was added to a personal
/// sprint (before the TM-348 base-list filter) would otherwise still leak its
/// next iteration into the picker via [TaskItem.createNextRecurPreview],
/// which preserves `familyDocId`. The picker is personal-only, so we cut the
/// chain here at the seed list rather than scattering the filter through
/// every preview step.
BuiltList<TaskItem> recurrencePreviewSeedTasksForSprint(
    BuiltList<TaskItem> taskItems, Sprint sprint) {
  return taskItemsForSprintSelector(taskItems, sprint)
      .where((t) => t.familyDocId == null)
      .toBuiltList();
}

/// Seed pool for the planning popups' recurrence-preview generator
/// (`createTemporaryIterations`, TM-348). The picker's directly-displayed
/// candidate rows come from a separate path inside the screens
/// (`getBaseList`); this aggregator's only consumer is the preview-iteration
/// pass, which scans this set for `recurrenceDocId`s and projects future
/// iterations from each.
///
/// The set is composed of:
///   1. Eligible base tasks — sourced from [taskItemsForPlacingOnNewSprint]
///      (no active sprint) or [taskItemsForPlacingOnExistingSprint] (active
///      sprint). These are the recurring tasks not yet in the sprint whose
///      next iterations should appear as previews.
///   2. Tasks already in the sprint — sourced from
///      [recurrencePreviewSeedTasksForSprint] when there's an active sprint.
///      These cover legacy assignments whose next iteration must still
///      appear as a preview.
///
/// All three component selectors exclude family-shared tasks; this aggregator
/// inherits that. **Do not bypass this aggregator at call sites** — the
/// preview seed step is what stops legacy family-shared recurring tasks
/// already in a sprint from leaking their next iteration into the picker.
BuiltList<TaskItem> eligibleItemsForPlanningPicker({
  required BuiltList<TaskItem> allTaskItems,
  required Sprint? activeSprint,
  required DateTime endDate,
}) {
  final builder = ListBuilder<TaskItem>();
  if (activeSprint == null) {
    builder.addAll(taskItemsForPlacingOnNewSprint(allTaskItems, endDate));
  } else {
    builder.addAll(taskItemsForPlacingOnExistingSprint(allTaskItems, activeSprint));
    builder.addAll(recurrencePreviewSeedTasksForSprint(allTaskItems, activeSprint));
  }
  return builder.build();
}

/// Get tasks eligible for placing on a new sprint: personal (non-family-shared)
/// tasks that are not scheduled after the sprint's end date and not completed.
/// Family-shared tasks (TM-348) are excluded — sprints are personal queues
/// and the family tab is the home for shared tasks.
BuiltList<TaskItem> taskItemsForPlacingOnNewSprint(BuiltList<TaskItem> allTaskItems, DateTime endDate) {
  var taskItems = allTaskItems.toList();
  var forScheduling = taskItems.where((taskItem) =>
      taskItem.familyDocId == null &&
      !taskItem.isScheduledAfter(endDate) &&
      !taskItem.isCompleted());
  return forScheduling.toBuiltList();
}

/// Get tasks eligible for placing on an existing sprint. Same family-shared
/// exclusion as [taskItemsForPlacingOnNewSprint] (TM-348).
BuiltList<TaskItem> taskItemsForPlacingOnExistingSprint(BuiltList<TaskItem> allTaskItems, Sprint sprint) {
  var taskItems = allTaskItems.toList();
  return taskItems.where((taskItem) {
    return taskItem.familyDocId == null &&
        !taskItem.isScheduledAfter(sprint.endDate) &&
        !taskItem.isCompleted() &&
        !taskItemIsInSprint(taskItem, sprint);
  }).toBuiltList();
}

/// Check if a task is assigned to a sprint
bool taskItemIsInSprint(SprintDisplayTask taskItem, Sprint? sprint) {
  return sprint != null && sprint.sprintAssignments.where((sa) => sa.taskDocId == taskItem.getSprintDisplayTaskKey()).isNotEmpty;
}

/// Get all non-retired task items
BuiltList<TaskItem> nonRetiredTaskItems(BuiltList<TaskItem> allTaskItems) {
  return allTaskItems.where((t) => t.retired == null).toBuiltList();
}

/// Get the recurrence associated with a task item
TaskRecurrence? recurrenceForTaskItem(BuiltList<TaskRecurrence> recurrences, TaskItem taskItem) {
  return recurrences.where((r) => r.docId == taskItem.recurrenceDocId).singleOrNull;
}
