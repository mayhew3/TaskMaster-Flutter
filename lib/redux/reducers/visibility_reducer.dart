import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../redux_app_state.dart';

final sprintVisibilityReducer = <ReduxAppState Function(ReduxAppState, dynamic)>[
  TypedReducer<ReduxAppState, UpdateSprintFilterAction>(_sprintFilterReducer),
];

ReduxAppState _sprintFilterReducer(
    ReduxAppState state, UpdateSprintFilterAction action) {
  return state.rebuild((s) => s..sprintListFilter = action.newFilter.toBuilder());
}

final taskVisibilityReducer = <ReduxAppState Function(ReduxAppState, dynamic)>[
  TypedReducer<ReduxAppState, UpdateTaskFilterAction>(_taskFilterReducer),
];

ReduxAppState _taskFilterReducer(
    ReduxAppState state, UpdateTaskFilterAction action) {
  return state.rebuild((s) => s..taskListFilter = action.newFilter.toBuilder());
}
