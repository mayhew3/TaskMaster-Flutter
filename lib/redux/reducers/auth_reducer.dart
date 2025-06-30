

import 'package:redux/redux.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

final authReducers = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, GoogleInitializedAction>(_onGoogleInitialized).call,
  TypedReducer<AppState, OnAuthenticatedAction>(_onAuthenticated).call,
  TypedReducer<AppState, OnLogoutSuccessAction>(_onLogout).call,
  TypedReducer<AppState, OnLogoutFailAction>(_onLogoutFail).call,
  TypedReducer<AppState, OnPersonVerifiedFirestoreAction>(_onPersonVerifiedFirestore).call,
];

AppState _onGoogleInitialized(AppState state, GoogleInitializedAction action) {
  return state.rebuild((a) => {
    a..googleInitialized = true
  });
}

AppState _onAuthenticated(AppState state, OnAuthenticatedAction action) {
  return state.rebuild((a) => {
    a..firebaseUser = action.userCredential
      ..currentUser = action.account
  });
}

AppState _onPersonVerifiedFirestore(AppState state, OnPersonVerifiedFirestoreAction action) {
  return state.rebuild((a) => {
    a..personDocId = action.personDocId
  });
}

AppState _onLogout(AppState state, OnLogoutSuccessAction action) {
  return state.rebuild((a) => {
    a..firebaseUser = null
      ..currentUser = null
      ..personDocId = null
      ..googleSignIn?.disconnect()
  });
}

AppState _onLogoutFail(AppState state, OnLogoutFailAction action) {
  print('Failed to disconnect: ' + action.error);
  return state;
}