

import 'package:redux/redux.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

final authReducers = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, OnAuthenticated>(_onAuthenticated),
  TypedReducer<AppState, OnLogoutSuccess>(_onLogout),
  TypedReducer<AppState, OnLogoutFail>(_onLogoutFail),
];

AppState _onAuthenticated(AppState state, OnAuthenticated action) {
  return state.rebuild((a) => {
    a..firebaseUser = action.userCredential
      ..currentUser = action.account
      ..tokenRetrieved = action.idToken != null
  });
}

AppState _onLogout(AppState state, OnLogoutSuccess action) {
  return state.rebuild((a) => {
    a..firebaseUser = null
      ..currentUser = null
      ..tokenRetrieved = false
      ..googleSignIn?.disconnect()
  });
}

AppState _onLogoutFail(AppState state, OnLogoutFail action) {
  print('Failed to disconnect: ' + action.error);
  return state;
}