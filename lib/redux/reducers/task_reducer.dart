import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';

final taskItemsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, TaskItemAddedAction>(_taskItemAdded),
  TypedReducer<AppState, DeleteTaskItemAction>(_deleteTaskItem),
  TypedReducer<AppState, TaskItemUpdatedAction>(_onUpdateTaskItem),
  TypedReducer<AppState, CompleteTaskItemAction>(_completeTaskItem),
  TypedReducer<AppState, TaskItemCompletedAction>(_onCompleteTaskItem),
  TypedReducer<AppState, DataLoadedAction>(_onDataLoaded),
  TypedReducer<AppState, DataNotLoadedAction>(_onDataUnloaded),
  TypedReducer<AppState, LogOutAction>(_onDataUnloaded),
  TypedReducer<AppState, ClearRecentlyCompletedAction>(_clearRecentlyCompleted),
];

AppState _taskItemAdded(AppState state, TaskItemAddedAction action) {
  var taskRecurrence = action.taskRecurrence;
  return state.rebuild((s) {
    s.taskItems = state.taskItems.toBuilder()..add(action.taskItem);
    if (taskRecurrence != null) {
      s.taskRecurrences = state.taskRecurrences.toBuilder()..add(taskRecurrence);
    }
    return s;
  });
}

AppState _clearRecentlyCompleted(AppState state, ClearRecentlyCompletedAction action) {
  return state.rebuild((s) => s..recentlyCompleted = ListBuilder());
}

AppState _deleteTaskItem(AppState state, DeleteTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()..removeWhere((taskItem) => taskItem.id == action.id);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

AppState _onUpdateTaskItem(AppState state, TaskItemUpdatedAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.id == action.updatedTaskItem.id ? action.updatedTaskItem.rebuild((t) => t
      ..pendingCompletion = false
      ..sprintAssignments = taskItem.sprintAssignments.toBuilder()
    ) : taskItem);
  return state.rebuild((s) => s..taskItems = listBuilder);
}

AppState _completeTaskItem(AppState state, CompleteTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.id == action.taskItem.id ? action.taskItem.rebuild((t) => t..pendingCompletion = true) : taskItem);
  return state.rebuild((s) => s
    ..taskItems = listBuilder
  );
}

AppState _onCompleteTaskItem(AppState state, TaskItemCompletedAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.id == action.taskItem.id ? taskItem.rebuild((t) => t
      ..pendingCompletion = false
      ..completionDate = action.taskItem.completionDate
    ) : taskItem);
  var recentListBuilder = state.recentlyCompleted.toBuilder()..add(listBuilder.build().where((t) => t.id == action.taskItem.id).first);
  return state.rebuild((s) => s
    ..taskItems = listBuilder
    ..recentlyCompleted = recentListBuilder
  );
}

AppState _onDataLoaded(AppState state, DataLoadedAction action) {
  return state.rebuild((s) => s
    ..taskItems = ListBuilder(action.dataPayload.taskItems)
    ..sprints = ListBuilder(action.dataPayload.sprints)
    ..taskRecurrences = ListBuilder(action.dataPayload.taskRecurrences)
  );
}

AppState _onDataUnloaded(AppState state, dynamic action) {
  return state.rebuild((s) => s
    ..taskItems = ListBuilder()
    ..sprints = ListBuilder()
    ..taskRecurrences = ListBuilder()
    ..recentlyCompleted = ListBuilder()
  );
}
