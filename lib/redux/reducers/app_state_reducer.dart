import '../redux_app_state.dart';
import 'loading_reducer.dart';
import 'tabs_reducer.dart';
import 'task_reducer.dart';
import 'visibility_reducer.dart';

// We create the State reducer by combining many smaller reducers into one!
ReduxAppState appReducer(ReduxAppState state, action) {
  return ReduxAppState(
    isLoading: loadingReducer(state.isLoading, action),
    taskItems: taskItemsReducer(state.taskItems, action),
    sprintListFilter: sprintVisibilityReducer(state.sprintListFilter, action),
    taskListFilter: taskVisibilityReducer(state.taskListFilter, action),
    activeTab: tabsReducer(state.activeTab, action),
  );
}
