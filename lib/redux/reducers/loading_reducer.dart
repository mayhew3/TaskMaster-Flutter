import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import '../actions/task_item_actions.dart';

final loadingReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, LogOutAction>(_setLogoutStarted).call,
  TypedReducer<AppState, LoadDataAction>(_setLoadStarted).call,
  TypedReducer<AppState, DataNotLoadedAction>(_setLoadFailed).call,
  TypedReducer<AppState, DataLoadedAction>(_setLoadSucceeded).call,
];

AppState _setLogoutStarted(AppState state, LogOutAction action) {
  return state.rebuild((s) => s
    ..loadFailed = false
    ..isLoading = true);
}
AppState _setLoadStarted(AppState state, LoadDataAction action) {
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