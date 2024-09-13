import 'package:redux/redux.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';

final sprintVisibilityReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, UpdateSprintFilterAction>(_sprintFilterReducer),
];

AppState _sprintFilterReducer(
    AppState state, UpdateSprintFilterAction action) {
  return state.rebuild((s) => s..sprintListFilter = action.newFilter.toBuilder());
}

final taskVisibilityReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, UpdateTaskFilterAction>(_taskFilterReducer),
  TypedReducer<AppState, ToggleTaskListShowScheduledAction>(_toggleTaskListShowScheduled),
  TypedReducer<AppState, ToggleTaskListShowCompletedAction>(_toggleTaskListShowCompleted),
];

AppState _taskFilterReducer(
    AppState state, UpdateTaskFilterAction action) {
  return state.rebuild((s) => s..taskListFilter = action.newFilter.toBuilder());
}

AppState _toggleTaskListShowScheduled(AppState state, ToggleTaskListShowScheduledAction action) {
  return state.rebuild((s) => s..taskListFilter.showScheduled = !s.taskListFilter.showScheduled!);
}

AppState _toggleTaskListShowCompleted(AppState state, ToggleTaskListShowCompletedAction action) {
  return state.rebuild((s) => s..taskListFilter.showCompleted = !s.taskListFilter.showCompleted!);
}