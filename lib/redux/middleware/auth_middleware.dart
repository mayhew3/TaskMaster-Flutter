

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/routes.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

List<Middleware<AppState>> createAuthenticationMiddleware(
    GlobalKey<NavigatorState> navigatorKey,
    ) {
  return [
    TypedMiddleware<AppState, TryToSilentlySignInAction>(_tryToSilentlySignIn(navigatorKey)).call,
    TypedMiddleware<AppState, LogInAction>(_manualLogin(navigatorKey)).call,
    TypedMiddleware<AppState, LogOutAction>(_manualLogout(navigatorKey)).call,
    TypedMiddleware<AppState, InitTimezoneHelperAction>(_initTimezoneHelper(navigatorKey)).call,
    TypedMiddleware<AppState, OnPersonRejectedAction>(_onPersonRejected(navigatorKey)).call,
  ];
}

void Function(
    Store<AppState> store,
    LogInAction action,
    NextDispatcher next,
    ) _manualLogin(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print('_manualLogin!');
    next(action);
    try {
      await store.state.googleSignIn.signIn();
      await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.home);
    } catch (error, stackTrace) {
      print('Error signing in: $error');
      print(stackTrace);
      store.dispatch(OnLoginFailAction(error));
    }
  };
}

void Function(
    Store<AppState> store,
    LogOutAction action,
    NextDispatcher next,
    ) _manualLogout(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print('_manualLogout!');
    navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.logout);
    try {
      await store.state.googleSignIn.disconnect();
    } catch (error) {
      store.dispatch(OnLogoutFailAction(error));
    }
    next(action);
  };
}

void Function(
    Store<AppState> store,
    InitTimezoneHelperAction action,
    NextDispatcher next,
    ) _initTimezoneHelper(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print('_initTimezoneHelper!');
    next(action);
    await store.state.timezoneHelper.configureLocalTimeZone();
  };
}

void Function(
    Store<AppState> store,
    OnPersonRejectedAction action,
    NextDispatcher next,
    ) _onPersonRejected(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print('_onPersonRejected!');
    next(action);
    await store.state.googleSignIn.disconnect();
  };
}

void Function(
    Store<AppState> store,
    TryToSilentlySignInAction action,
    NextDispatcher next,
    ) _tryToSilentlySignIn(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    next(action);
    print('_tryToSilentlySignIn called.');
    store.state.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      print('onCurrentUserChanged.');
      if (account == null) {
        print('onCurrentUserChanged: account null.');
        store.dispatch(OnLogoutSuccessAction());
        await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
      } else {
        print('onCurrentUserChanged: account exists!');
        var authentication = await account.authentication;

        if (authentication.idToken == null) {
          store.dispatch(OnLoginFailAction('No idToken returned.'));
          await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );

        var firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);

        store.dispatch(OnAuthenticatedAction(account, firebaseUser));
        store.dispatch(VerifyPersonAction(account.email));
      }
    });
    var account = await store.state.googleSignIn.signInSilently();
    if (account == null) {
      print('Sign in silently failed. Returning to login screen.');
      await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
    }
  };
}
