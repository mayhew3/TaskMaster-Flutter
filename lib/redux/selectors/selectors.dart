import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/redux/redux_app_state.dart';

import '../../models/models.dart';

bool isLoadingSelector(ReduxAppState state) => state.isLoading;
BuiltList<TaskItem> taskItemsSelector(ReduxAppState state) => state.taskItems;
BuiltList<Sprint> sprintsSelector(ReduxAppState state) => state.sprints;
BuiltList<TaskRecurrence> recurrencesSelector(ReduxAppState state) => state.taskRecurrences;
AppTab activeTabSelector(ReduxAppState state) => state.activeTab;
VisibilityFilter sprintFilterSelector(ReduxAppState state) => state.sprintListFilter;
VisibilityFilter taskFilterSelector(ReduxAppState state) => state.taskListFilter;

List<TaskItem> tasksForRecurrenceSelector(ReduxAppState state, TaskRecurrence taskRecurrence) {
  return state.taskItems.where((taskItem) {
    return taskItem.recurrenceId == taskRecurrence.id;
  }).toList();
}

int numActiveSelector(List<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate == null ? ++sum : sum);

int numCompletedSelector(List<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate != null ? ++sum : sum);

List<TaskItem> filteredTaskItemsSelector(List<TaskItem> taskItems, VisibilityFilter visibilityFilter) {
  return taskItems.where((taskItem) {
    var startDate = taskItem.startDate;
    
    var completedPredicate = taskItem.completionDate == null || visibilityFilter.showCompleted;
    var scheduledPredicate = startDate == null || startDate.isBefore(DateTime.now()) || visibilityFilter.showScheduled;
    // todo: active predicate, when sprint getter is complete
    
    return completedPredicate && scheduledPredicate;
  }).toList();
}

TaskItem? taskItemSelector(List<TaskItem> taskItems, int id) {
  try {
    return taskItems.firstWhere((taskItem) => taskItem.id == id);
  } catch (e) {
    return null;
  }
}
