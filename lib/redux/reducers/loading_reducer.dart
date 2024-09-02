import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import '../actions/actions.dart';

final loadingReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, LogOutAction>(_setLogoutStarted),
  TypedReducer<AppState, LoadTaskItemsAction>(_setLoadStarted),
  TypedReducer<AppState, TaskItemsNotLoadedAction>(_setLoadFailed),
  TypedReducer<AppState, TaskItemsLoadedAction>(_setLoadSucceeded),
];

AppState _setLogoutStarted(AppState state, LogOutAction action) {
  return state.rebuild((s) => s
    ..loadFailed = false
    ..isLoading = true);
}
AppState _setLoadStarted(AppState state, LoadTaskItemsAction action) {
  return state.rebuild((s) => s
    ..loadFailed = false
    ..isLoading = true);
}
AppState _setLoadFailed(AppState state, action) {
  return state.rebuild((s) => s
    ..loadFailed = true
    ..isLoading = false);
}
AppState _setLoadSucceeded(AppState state, action) {
  return state.rebuild((s) => s
    ..loadFailed = false
    ..isLoading = false);
}