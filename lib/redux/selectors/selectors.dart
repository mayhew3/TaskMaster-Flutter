import 'package:taskmaster/redux/redux_app_state.dart';

import '../../models/models.dart';

bool isLoadingSelector(ReduxAppState state) => state.isLoading;
List<TaskItem> tasksSelector(ReduxAppState state) => state.taskItems;
List<Sprint> sprintsSelector(ReduxAppState state) => state.sprints;
List<TaskRecurrence> recurrencesSelector(ReduxAppState state) => state.taskRecurrences;
AppTab activeTabSelector(ReduxAppState state) => state.activeTab;
VisibilityFilter sprintFilterSelector(ReduxAppState state) => state.sprintListFilter;
VisibilityFilter taskFilterSelector(ReduxAppState state) => state.taskListFilter;

int numActiveSelector(List<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate == null ? ++sum : sum);

int numCompletedSelector(List<TaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.completionDate != null ? ++sum : sum);

TaskItem? taskSelector(List<TaskItem> todos, int id) {
  try {
    return todos.firstWhere((todo) => todo.id == id);
  } catch (e) {
    return null;
  }
}
