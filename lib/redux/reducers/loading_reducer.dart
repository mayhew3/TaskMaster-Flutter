import 'package:redux/redux.dart';
import 'package:taskmaster/redux/app_state.dart';
import '../actions/actions.dart';

final loadingReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, TaskItemsLoadedAction>(_setLoaded),
  TypedReducer<AppState, TaskItemsNotLoadedAction>(_setLoaded),
];

AppState _setLoaded(AppState state, action) {
  return state.rebuild((s) => s..isLoading = false);
}
