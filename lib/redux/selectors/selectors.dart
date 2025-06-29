import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/app_state.dart';

import '../../models/models.dart';
import '../../models/sprint_display_task.dart';

bool isLoadingSelector(AppState state) => state.isLoading;
bool loadFailedSelector(AppState state) => state.loadFailed;
BuiltList<TaskItem> taskItemsSelector(AppState state) => state.taskItems;
BuiltList<Sprint> sprintsSelector(AppState state) => state.sprints;
BuiltList<TaskRecurrence> recurrencesSelector(AppState state) => state.taskRecurrences;
VisibilityFilter sprintFilterSelector(AppState state) => state.sprintListFilter;
VisibilityFilter taskFilterSelector(AppState state) => state.taskListFilter;

BuiltList<TaskItem> tasksForRecurrenceSelector(AppState state, TaskRecurrence taskRecurrence) {
  return ListBuilder<TaskItem>(state.taskItems.where((taskItem) {
    return taskItem.recurrenceDocId == taskRecurrence.docId;
  })).build();
}

int numActiveSelector(BuiltList<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate == null ? ++sum : sum);

int numCompletedSelector(BuiltList<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate != null ? ++sum : sum);

ListBuilder<TaskItem> filteredTaskItemsSelector(BuiltList<TaskItem> taskItems, BuiltList<TaskItem> recentlyCompleted, Sprint? sprint, VisibilityFilter visibilityFilter) {
  var filteredTasks = taskItems.where((taskItem) {
    if (taskItem.retired != null) {
      return false;
    }

    var startDate = taskItem.startDate;

    var completedPredicate = taskItem.completionDate == null || visibilityFilter.showCompleted;
    var scheduledPredicate = startDate == null || startDate.isBefore(DateTime.now()) || visibilityFilter.showScheduled;
    var isRecentlyCompleted = recentlyCompleted.map((t) => t.docId).contains(taskItem.docId);

    var withoutSprint = (completedPredicate && scheduledPredicate) || isRecentlyCompleted;

    if (sprint != null) {
      var taskItemsForSprint = taskItemsForSprintSelector(taskItems, sprint);
      var sprintPredicate = taskItemsForSprint.map((t) => t.docId).contains(taskItem.docId);
      return withoutSprint && sprintPredicate;
    } else {
      return withoutSprint;
    }
  });
  return ListBuilder<TaskItem>(filteredTasks);
}

TaskItem? taskItemSelector(BuiltList<TaskItem> taskItems, String id) {
  try {
    return taskItems.firstWhere((taskItem) => taskItem.docId == id);
  } catch (e) {
    return null;
  }
}

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

Sprint? activeSprintSelector(BuiltList<Sprint> sprints) {
  DateTime now = DateTime.timestamp();
  Iterable<Sprint> matching = sprints.where((sprint) =>
  sprint.startDate.isBefore(now) &&
      sprint.endDate.isAfter(now) &&
      sprint.closeDate == null);
  return matching.isEmpty ? null : matching.last;
}

Sprint? lastCompletedSprintSelector(BuiltList<Sprint> sprints) {
  List<Sprint> matching = sprints.where((sprint) {
    return DateTime.now().isAfter(sprint.endDate);
  }).toList();
  matching.sort((a, b) => a.endDate.compareTo(b.endDate));
  return matching.isEmpty ? null : matching.last;
}

BuiltList<Sprint> sprintsForTaskItemSelector(BuiltList<Sprint> sprints, TaskItem taskItem) {
  return sprints.where((s) => s.sprintAssignments.where((sa) => sa.taskDocId == taskItem.docId).isNotEmpty).toBuiltList();
}

BuiltList<TaskItem> taskItemsForSprintSelector(BuiltList<TaskItem> taskItems, Sprint sprint) {
  return taskItems.where((t) => sprint.sprintAssignments.where((sa) => sa.taskDocId == t.docId).isNotEmpty).toBuiltList();
}

BuiltList<TaskItem> nonRetiredTaskItems(BuiltList<TaskItem> allTaskItems) {
  return allTaskItems.where((t) => t.retired == null).toBuiltList();
}

BuiltList<TaskItem> taskItemsForPlacingOnNewSprint(BuiltList<TaskItem> allTaskItems, DateTime endDate) {
  var taskItems = allTaskItems.toList();
  var taskItemsNotUtc = taskItems.where((t) => t.startDate != null && !t.startDate!.isUtc);
  print('[taskItemsForPlacingOnNewSprint]: ${taskItemsNotUtc.length} of all task items that are not utc.');
  var forScheduling = taskItems.where((taskItem) => !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted());
  var taskItemsScheduleNotUtc = forScheduling.where((t) => t.startDate != null && !t.startDate!.isUtc);
  print('[taskItemsForPlacingOnNewSprint]: ${taskItemsScheduleNotUtc.length} of scheduled task items that are not utc.');
  return forScheduling.toBuiltList();
}

BuiltList<TaskItem> taskItemsForPlacingOnExistingSprint(BuiltList<TaskItem> allTaskItems, Sprint sprint) {
  var taskItems = allTaskItems.toList();
  return taskItems.where((taskItem) {
    return !taskItem.isScheduledAfter(sprint.endDate) && !taskItem.isCompleted() && !taskItemIsInSprint(taskItem, sprint);
  }).toBuiltList();
}

bool taskItemIsInSprint(SprintDisplayTask taskItem, Sprint? sprint) {
  return sprint != null && sprint.sprintAssignments.where((sa) => sa.taskDocId == taskItem.getSprintDisplayTaskKey()).isNotEmpty;
}

Future<({String personDocId})> getRequiredInputs(Store<AppState> store, String actionDesc) async {

  var personDocId = store.state.personDocId;
  if (personDocId == null) {
    throw Exception('Cannot $actionDesc without person id.');
  }

  return (personDocId: personDocId);
}

TaskRecurrence? recurrenceForTaskItem(BuiltList<TaskRecurrence> recurrences, TaskItem taskItem) {
  return recurrences.where((r) => r.docId == taskItem.recurrenceDocId).singleOrNull;
}