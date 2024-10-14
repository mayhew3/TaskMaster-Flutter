

import 'package:redux/redux.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

final authReducers = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, OnAuthenticatedAction>(_onAuthenticated),
  TypedReducer<AppState, OnLogoutSuccessAction>(_onLogout),
  TypedReducer<AppState, OnLogoutFailAction>(_onLogoutFail),
  TypedReducer<AppState, OnPersonVerifiedAction>(_onPersonVerified),
  TypedReducer<AppState, OnPersonVerifiedFirestoreAction>(_onPersonVerifiedFirestore),
];

AppState _onAuthenticated(AppState state, OnAuthenticatedAction action) {
  return state.rebuild((a) => {
    a..firebaseUser = action.userCredential
      ..currentUser = action.account
      ..tokenRetrieved = action.idToken != null
  });
}

AppState _onPersonVerifiedFirestore(AppState state, OnPersonVerifiedFirestoreAction action) {
  return state.rebuild((a) => {
    a..personDocId = action.personDocId
  });
}

AppState _onPersonVerified(AppState state, OnPersonVerifiedAction action) {
  return state.rebuild((a) => {
    a..personId = action.personId
  });
}

AppState _onLogout(AppState state, OnLogoutSuccessAction action) {
  return state.rebuild((a) => {
    a..firebaseUser = null
      ..currentUser = null
      ..tokenRetrieved = false
      ..personId = null
      ..googleSignIn?.disconnect()
  });
}

AppState _onLogoutFail(AppState state, OnLogoutFailAction action) {
  print('Failed to disconnect: ' + action.error);
  return state;
}