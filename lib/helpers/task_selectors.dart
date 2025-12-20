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

/// Get tasks eligible for placing on a new sprint (not scheduled after end date, not completed)
BuiltList<TaskItem> taskItemsForPlacingOnNewSprint(BuiltList<TaskItem> allTaskItems, DateTime endDate) {
  var taskItems = allTaskItems.toList();
  var forScheduling = taskItems.where((taskItem) => !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted());
  return forScheduling.toBuiltList();
}

/// Get tasks eligible for placing on an existing sprint
BuiltList<TaskItem> taskItemsForPlacingOnExistingSprint(BuiltList<TaskItem> allTaskItems, Sprint sprint) {
  var taskItems = allTaskItems.toList();
  return taskItems.where((taskItem) {
    return !taskItem.isScheduledAfter(sprint.endDate) && !taskItem.isCompleted() && !taskItemIsInSprint(taskItem, sprint);
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
