import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../redux_app_state.dart';

final taskItemsReducer = <ReduxAppState Function(ReduxAppState, dynamic)>[
  TypedReducer<ReduxAppState, AddTaskItemAction>(_addTaskItem),
  TypedReducer<ReduxAppState, DeleteTaskItemAction>(_deleteTaskItem),
  TypedReducer<ReduxAppState, UpdateTaskItemAction>(_updateTaskItem),
  TypedReducer<ReduxAppState, TaskItemsLoadedAction>(_setLoadedTaskItems),
  TypedReducer<ReduxAppState, TaskItemsNotLoadedAction>(_setNoTaskItems),
];

ReduxAppState _addTaskItem(ReduxAppState state, AddTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()..add(action.taskItem);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

ReduxAppState _deleteTaskItem(ReduxAppState state, DeleteTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()..removeWhere((taskItem) => taskItem.id == action.id);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

ReduxAppState _updateTaskItem(ReduxAppState state, UpdateTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.id == action.id ? action.updatedTaskItem : taskItem);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

ReduxAppState _setLoadedTaskItems(ReduxAppState state, TaskItemsLoadedAction action) {
  return state.rebuild((s) => s..taskItems = ListBuilder(action.taskItems));
}

ReduxAppState _setNoTaskItems(ReduxAppState state, TaskItemsNotLoadedAction action) {
  return state.rebuild((s) => s..taskItems = ListBuilder());
}
