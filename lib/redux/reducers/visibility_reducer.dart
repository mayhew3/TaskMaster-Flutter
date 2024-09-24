import 'package:redux/redux.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';

final sprintVisibilityReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, UpdateSprintFilterAction>(_sprintFilterReducer),
  TypedReducer<AppState, ToggleSprintListShowScheduledAction>(_toggleSprintListShowScheduled),
  TypedReducer<AppState, ToggleSprintListShowCompletedAction>(_toggleSprintListShowCompleted),
];

AppState _sprintFilterReducer(
    AppState state, UpdateSprintFilterAction action) {
  return state.rebuild((s) => s..sprintListFilter = action.newFilter.toBuilder());
}

AppState _toggleSprintListShowScheduled(AppState state, ToggleSprintListShowScheduledAction action) {
  return state.rebuild((s) => s..sprintListFilter.showScheduled = !s.sprintListFilter.showScheduled!);
}

AppState _toggleSprintListShowCompleted(AppState state, ToggleSprintListShowCompletedAction action) {
  return state.rebuild((s) => s..sprintListFilter.showCompleted = !s.sprintListFilter.showCompleted!);
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