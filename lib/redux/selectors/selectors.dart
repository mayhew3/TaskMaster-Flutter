import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/app_state.dart';

import '../../models/models.dart';

bool isLoadingSelector(AppState state) => state.isLoading;
bool loadFailedSelector(AppState state) => state.loadFailed;
BuiltList<TaskItem> taskItemsSelector(AppState state) => state.taskItems;
BuiltList<Sprint> sprintsSelector(AppState state) => state.sprints;
BuiltList<TaskRecurrence> recurrencesSelector(AppState state) => state.taskRecurrences;
VisibilityFilter sprintFilterSelector(AppState state) => state.sprintListFilter;
VisibilityFilter taskFilterSelector(AppState state) => state.taskListFilter;

BuiltList<TaskItem> tasksForRecurrenceSelector(AppState state, TaskRecurrence taskRecurrence) {
  return ListBuilder<TaskItem>(state.taskItems.where((taskItem) {
    return taskItem.recurrenceId == taskRecurrence.id;
  })).build();
}

int numActiveSelector(BuiltList<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate == null ? ++sum : sum);

int numCompletedSelector(BuiltList<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate != null ? ++sum : sum);

ListBuilder<TaskItem> filteredTaskItemsSelector(BuiltList<TaskItem> taskItems, BuiltList<TaskItem> recentlyCompleted, Sprint? sprint, VisibilityFilter visibilityFilter) {
  var filteredTasks = taskItems.where((taskItem) {
    var startDate = taskItem.startDate;

    var completedPredicate = taskItem.completionDate == null || visibilityFilter.showCompleted;
    var scheduledPredicate = startDate == null || startDate.isBefore(DateTime.now()) || visibilityFilter.showScheduled;
    var isRecentlyCompleted = recentlyCompleted.map((t) => t.id).contains(taskItem.id);

    var withoutSprint = (completedPredicate && scheduledPredicate) || isRecentlyCompleted;

    if (sprint != null) {
      var taskItemsForSprint = taskItemsForSprintSelector(taskItems, sprint);
      var sprintPredicate = taskItemsForSprint.map((t) => t.id).contains(taskItem.id);
      return withoutSprint && sprintPredicate;
    } else {
      return withoutSprint;
    }
  });
  return ListBuilder<TaskItem>(filteredTasks);
}

TaskItem? taskItemSelector(BuiltList<TaskItem> taskItems, int id) {
  try {
    return taskItems.firstWhere((taskItem) => taskItem.id == id);
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
  return sprints.where((s) => taskItem.sprintAssignments.where((sa) => sa.sprintId == s.id).isNotEmpty).toBuiltList();
}

BuiltList<TaskItem> taskItemsForSprintSelector(BuiltList<TaskItem> taskItems, Sprint sprint) {
  return taskItems.where((t) => t.sprintAssignments.where((sa) => sa.sprintId == sprint.id).isNotEmpty).toBuiltList();
}

BuiltList<TaskItem> taskItemsForPlacingOnNewSprint(BuiltList<TaskItem> allTaskItems, DateTime endDate) {
  var taskItems = allTaskItems.toList();
  return taskItems.where((taskItem) {
    return !taskItem.isScheduledAfter(endDate) && !taskItem.isCompleted();
  }).toBuiltList();
}

BuiltList<TaskItem> taskItemsForPlacingOnExistingSprint(BuiltList<TaskItem> allTaskItems, Sprint sprint) {
  var taskItems = allTaskItems.toList();
  return taskItems.where((taskItem) {
    return !taskItem.isScheduledAfter(sprint.endDate) && !taskItem.isCompleted() && taskItemIsInSprint(taskItem, sprint);
  }).toBuiltList();
}

bool taskItemIsInSprint(TaskItem taskItem, Sprint? sprint) {
  return sprint != null && taskItem.sprintAssignments.where((sa) => sa.sprintId == sprint.id).isEmpty;
}

Future<({int personId, String idToken})> getRequiredInputs(Store<AppState> store, String actionDesc) async {

  var personId = store.state.personId;
  if (personId == null) {
    throw new Exception("Cannot $actionDesc without person id.");
  }

  var idToken = await store.state.getIdToken();
  if (idToken == null) {
    throw new Exception("Cannot $actionDesc without id token.");
  }

  return (personId: personId, idToken: idToken);
}

TaskRecurrence? recurrenceForTaskItem(BuiltList<TaskRecurrence> recurrences, TaskItem taskItem) {
  return recurrences.where((r) => r.id == taskItem.recurrenceId).singleOrNull;
}