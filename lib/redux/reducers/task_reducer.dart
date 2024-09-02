import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';

import '../actions/actions.dart';
import '../app_state.dart';

final taskItemsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, AddTaskItemAction>(_addTaskItem),
  TypedReducer<AppState, DeleteTaskItemAction>(_deleteTaskItem),
  TypedReducer<AppState, UpdateTaskItemAction>(_updateTaskItem),
  TypedReducer<AppState, TaskItemUpdated>(_onUpdateTaskItem),
  TypedReducer<AppState, TaskItemsLoadedAction>(_setLoadedTaskItems),
  TypedReducer<AppState, TaskItemsNotLoadedAction>(_setNoTaskItems),
  TypedReducer<AppState, LogOutAction>(_setNoTaskItems),
];

AppState _addTaskItem(AppState state, AddTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()..add(action.taskItem);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

AppState _deleteTaskItem(AppState state, DeleteTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()..removeWhere((taskItem) => taskItem.id == action.id);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

AppState _updateTaskItem(AppState state, UpdateTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.id == action.updatedTaskItem.id ? taskItem.rebuild((t) => t..pendingCompletion = true) : taskItem);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

AppState _onUpdateTaskItem(AppState state, TaskItemUpdated action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.id == action.updatedTaskItem.id ? action.updatedTaskItem.rebuild((t) => t..pendingCompletion = false) : taskItem);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

AppState _setLoadedTaskItems(AppState state, TaskItemsLoadedAction action) {
  return state.rebuild((s) => s..taskItems = ListBuilder(action.taskItems));
}

AppState _setNoTaskItems(AppState state, dynamic action) {
  return state.rebuild((s) => s..taskItems = ListBuilder());
}
