

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    TypedMiddleware<AppState, TryToSilentlySignIn>(_tryToSilentlySignIn(navigatorKey)),
    TypedMiddleware<AppState, LogIn>(_manualLogin(navigatorKey)),
    TypedMiddleware<AppState, LogOutAction>(_manualLogout(navigatorKey)),
    TypedMiddleware<AppState, InitTimezoneHelper>(_initTimezoneHelper(navigatorKey)),
    TypedMiddleware<AppState, OnPersonVerified>(_onPersonVerified(navigatorKey)),
    TypedMiddleware<AppState, OnPersonRejected>(_onPersonRejected(navigatorKey)),
  ];
}

void Function(
    Store<AppState> store,
    LogIn action,
    NextDispatcher next,
    ) _manualLogin(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print("_manualLogin!");
    next(action);
    try {
      await store.state.googleSignIn.signIn();
      await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.splash);
    } catch (error) {
      store.dispatch(OnLoginFail(error));
    }
  };
}

void Function(
    Store<AppState> store,
    LogOutAction action,
    NextDispatcher next,
    ) _manualLogout(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print("_manualLogout!");
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
    InitTimezoneHelper action,
    NextDispatcher next,
    ) _initTimezoneHelper(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print("_initTimezoneHelper!");
    next(action);
    await store.state.timezoneHelper.configureLocalTimeZone();
    if (store.state.appIsReady()) {
      await navigatorKey.currentState!.pushReplacementNamed(
          TaskMasterRoutes.home);
    }
  };
}

void Function(
    Store<AppState> store,
    OnPersonRejected action,
    NextDispatcher next,
    ) _onPersonRejected(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    print("_onPersonRejected!");
    next(action);
    await store.state.googleSignIn.disconnect();
  };
}

void Function(
    Store<AppState> store,
    TryToSilentlySignIn action,
    NextDispatcher next,
    ) _tryToSilentlySignIn(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    next(action);
    await Firebase.initializeApp();
    print("_tryToSilentlySignIn called.");
    store.state.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      print("onCurrentUserChanged.");
      if (account == null) {
        print("onCurrentUserChanged: account null.");
        store.dispatch(OnLogoutSuccess());
        await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
      } else {
        print("onCurrentUserChanged: account exists!");
        var authentication = await account.authentication;

        if (authentication.idToken == null) {
          store.dispatch(OnLoginFail("No idToken returned."));
          await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );

        var firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
        String? idToken = await firebaseUser.user!.getIdToken();

        store.dispatch(OnAuthenticated(account, firebaseUser, idToken));
        store.dispatch(VerifyPerson(account.email));
        if (store.state.appIsReady()) {
          await navigatorKey.currentState!.pushReplacementNamed(
              TaskMasterRoutes.home);
        }
      }
    });
    var account = await store.state.googleSignIn.signInSilently();
    if (account == null) {
      await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
    }
  };
}

void Function(
    Store<AppState> store,
    OnPersonVerified action,
    NextDispatcher next,
    ) _onPersonVerified(GlobalKey<NavigatorState> navigatorKey,) {
  return (store, action, next) async {
    next(action);

    if (store.state.appIsReady()) {
      await navigatorKey.currentState!.pushReplacementNamed(
          TaskMasterRoutes.home);
    }
  };
}