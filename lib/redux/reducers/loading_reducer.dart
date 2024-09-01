import 'package:redux/redux.dart';
import 'package:taskmaster/redux/app_state.dart';
import '../actions/actions.dart';

final loadingReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, TaskItemsLoadedAction>(_setLoadSucceeded),
  TypedReducer<AppState, TaskItemsNotLoadedAction>(_setLoadFailed),
];

AppState _setLoadSucceeded(AppState state, action) {
  return state.rebuild((s) => s
    ..loadFailed = false
    ..isLoading = false);
}
AppState _setLoadFailed(AppState state, action) {
  return state.rebuild((s) => s
    ..loadFailed = true
    ..isLoading = false);
}