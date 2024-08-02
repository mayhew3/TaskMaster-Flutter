import 'package:redux/redux.dart';
import 'package:taskmaster/redux/redux_app_state.dart';
import '../actions/actions.dart';

final loadingReducer = <ReduxAppState Function(ReduxAppState, dynamic)>[
  TypedReducer<ReduxAppState, TaskItemsLoadedAction>(_setLoaded),
  TypedReducer<ReduxAppState, TaskItemsNotLoadedAction>(_setLoaded),
];

ReduxAppState _setLoaded(ReduxAppState state, action) {
  return state.rebuild((s) => s..isLoading = false);
}
