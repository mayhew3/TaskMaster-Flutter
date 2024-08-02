import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/redux/app_state.dart';

import '../../models/models.dart';

bool isLoadingSelector(AppState state) => state.isLoading;
BuiltList<TaskItem> taskItemsSelector(AppState state) => state.taskItems;
BuiltList<Sprint> sprintsSelector(AppState state) => state.sprints;
BuiltList<TaskRecurrence> recurrencesSelector(AppState state) => state.taskRecurrences;
AppTab activeTabSelector(AppState state) => state.activeTab;
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

BuiltList<TaskItem> filteredTaskItemsSelector(BuiltList<TaskItem> taskItems, VisibilityFilter visibilityFilter) {
  var filteredTasks = taskItems.where((taskItem) {
    var startDate = taskItem.startDate;

    var completedPredicate = taskItem.completionDate == null || visibilityFilter.showCompleted;
    var scheduledPredicate = startDate == null || startDate.isBefore(DateTime.now()) || visibilityFilter.showScheduled;
    // todo: active predicate, when sprint getter is complete

    return completedPredicate && scheduledPredicate;
  });
  return ListBuilder<TaskItem>(filteredTasks).build();
}

TaskItem? taskItemSelector(BuiltList<TaskItem> taskItems, int id) {
  try {
    return taskItems.firstWhere((taskItem) => taskItem.id == id);
  } catch (e) {
    return null;
  }
}
