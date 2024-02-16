import 'package:redux/redux.dart';

import '../../models/models.dart';
import '../actions/actions.dart';

final taskItemsReducer = combineReducers<List<TaskItem>>([
  TypedReducer<List<TaskItem>, AddTaskItemAction>(_addTaskItem),
  TypedReducer<List<TaskItem>, DeleteTaskItemAction>(_deleteTaskItem),
  TypedReducer<List<TaskItem>, UpdateTaskItemAction>(_updateTaskItem),
  TypedReducer<List<TaskItem>, TaskItemsLoadedAction>(_setLoadedTaskItems),
  TypedReducer<List<TaskItem>, TaskItemsNotLoadedAction>(_setNoTaskItems),
]);

List<TaskItem> _addTaskItem(List<TaskItem> taskItems, AddTaskItemAction action) {
  return List.from(taskItems)..add(action.taskItem);
}

List<TaskItem> _deleteTaskItem(List<TaskItem> taskItems, DeleteTaskItemAction action) {
  return taskItems.where((taskItem) => taskItem.id != action.id).toList();
}

List<TaskItem> _updateTaskItem(List<TaskItem> taskItems, UpdateTaskItemAction action) {
  return taskItems
      .map((taskItem) => taskItem.id == action.id ? action.updatedTaskItem : taskItem)
      .toList();
}

List<TaskItem> _setLoadedTaskItems(List<TaskItem> taskItems, TaskItemsLoadedAction action) {
  return action.taskItems;
}

List<TaskItem> _setNoTaskItems(List<TaskItem> taskItems, TaskItemsNotLoadedAction action) {
  return [];
}
