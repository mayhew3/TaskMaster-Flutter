

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/routes.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

List<Middleware<AppState>> createAuthenticationMiddleware(GlobalKey<NavigatorState> navigatorKey,) {
  return [
    TypedMiddleware<AppState, TryToSilentlySignIn>(_tryToSilentlySignIn(navigatorKey)),
    TypedMiddleware<AppState, LogIn>(_manualLogin(navigatorKey)),
    TypedMiddleware<AppState, LogOutAction>(_manualLogout(navigatorKey)),
  ];
}

void Function(
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
    ) _manualLogin(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    next(action);
    try {
      await store.state.googleSignIn.signIn();
    } catch (error) {
      store.dispatch(OnLoginFail(error));
    }
  };
}

void Function(
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
    ) _manualLogout(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    next(action);
    try {
      await store.state.googleSignIn.disconnect();
    } catch (error) {
      store.dispatch(OnLogoutFail(error));
    }
  };
}

void Function(
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
    ) _tryToSilentlySignIn(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    next(action);
    await Firebase.initializeApp();
    store.state.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      if (account == null) {
        store.dispatch(OnLogoutSuccess());
        await navigatorKey.currentState?.pushReplacementNamed(TaskMasterRoutes.login);
      } else {
        var authentication = await account.authentication;

        if (authentication.idToken == null) {
          store.dispatch(OnLoginFail("No idToken returned."));
          await navigatorKey.currentState?.pushReplacementNamed(TaskMasterRoutes.login);
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );

        var firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
        String? idToken = await firebaseUser.user!.getIdToken();
        store.dispatch(OnAuthenticated(account, firebaseUser, idToken));
        await navigatorKey.currentState?.pushReplacementNamed(TaskMasterRoutes.home);
        // action.completer.complete(); // enable if needed later
      }
    });
    store.state.googleSignIn.signInSilently();
  };
}