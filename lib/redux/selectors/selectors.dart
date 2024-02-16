import 'package:taskmaster/redux/redux_app_state.dart';

import '../../models/models.dart';

bool isLoadingSelector(ReduxAppState state) => state.isLoading;
List<ReduxTaskItem> tasksSelector(ReduxAppState state) => state.taskItems;
List<Sprint> sprintsSelector(ReduxAppState state) => state.sprints;
List<TaskRecurrence> recurrencesSelector(ReduxAppState state) => state.taskRecurrences;
AppTab activeTabSelector(ReduxAppState state) => state.activeTab;
VisibilityFilter sprintFilterSelector(ReduxAppState state) => state.sprintListFilter;
VisibilityFilter taskFilterSelector(ReduxAppState state) => state.taskListFilter;

int numActiveSelector(List<ReduxTaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => !taskItem.isCompleted() ? ++sum : sum);

int numCompletedSelector(List<ReduxTaskItem> taskItems) =>
    taskItems.fold(0, (sum, taskItem) => taskItem.isCompleted() ? ++sum : sum);

ReduxTaskItem? taskSelector(List<ReduxTaskItem> todos, int id) {
  try {
    return todos.firstWhere((todo) => todo.id == id);
  } catch (e) {
    return null;
  }
}
