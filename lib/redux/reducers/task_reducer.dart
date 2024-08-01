import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';

import '../../models/models.dart';
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
  var updatedList = state.taskItems.rebuild((tasks) => tasks.add(action.taskItem));
  return state.rebuild((s) => s..taskItems = ListBuilder(updatedList));
}

ReduxAppState _deleteTaskItem(ReduxAppState state, DeleteTaskItemAction action) {
  return taskItems.where((taskItem) => taskItem.id != action.id).toList();
}

ReduxAppState _updateTaskItem(ReduxAppState state, UpdateTaskItemAction action) {
  return taskItems
      .map((taskItem) => taskItem.id == action.id ? action.updatedTaskItem : taskItem)
      .toList();
}

ReduxAppState _setLoadedTaskItems(ReduxAppState state, TaskItemsLoadedAction action) {
  return state.rebuild((s) => s..taskItems = ListBuilder(action.taskItems));
}

ReduxAppState _setNoTaskItems(ReduxAppState state, TaskItemsNotLoadedAction action) {
  return state.rebuild((s) => s..taskItems = ListBuilder());
}
