import 'package:redux/redux.dart';

import '../actions/actions.dart';
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
];

AppState _taskFilterReducer(
    AppState state, UpdateTaskFilterAction action) {
  return state.rebuild((s) => s..taskListFilter = action.newFilter.toBuilder());
}
