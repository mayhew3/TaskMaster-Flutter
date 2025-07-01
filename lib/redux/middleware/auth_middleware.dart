

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
      await signInWithGoogleFirebase(store, navigatorKey, false);
      await navigatorKey.currentState!.pushReplacementNamed(
          TaskMasterRoutes.home);
    } on GoogleSignInException catch (e) {
      print('Google Sign In error: code: ${e.code.name} description:${e.description} details:${e.details}');
      store.dispatch(OnLoginFailAction(e));
      rethrow;
    } catch (error, stackTrace) {
      print('Unexpected error signing in: $error');
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
      store.dispatch(OnLogoutSuccessAction());
      await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
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

    await signInWithGoogleFirebase(store, navigatorKey, true);
  };
}

Future<void> signInWithGoogleFirebase(Store<AppState> store, GlobalKey<NavigatorState> navigatorKey, bool silent) async {
  var account = await signInAndGetAccount(store.state, silent);
  if (account == null) {
    print('Sign in failed. Returning to login screen.');
    await navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.login);
  } else {
    print('Signed in.');
    var authClient = store.state.googleSignIn.authorizationClient;
    var authorization = await authClient.authorizationForScopes(['email']);

    if (authorization == null) {
      store.dispatch(OnLoginFailAction('No authorization returned.'));
      await navigatorKey.currentState!.pushReplacementNamed(
          TaskMasterRoutes.login);
      return;
    }

    var authentication = account.authentication;

    var idToken = authentication.idToken;
    if (idToken == null) {
      store.dispatch(OnLoginFailAction('No idToken returned.'));
      await navigatorKey.currentState!.pushReplacementNamed(
          TaskMasterRoutes.login);
      return;
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    var firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);

    store.dispatch(OnAuthenticatedAction(account, firebaseUser));
    store.dispatch(VerifyPersonAction(account.email));
  }
}

Future<GoogleSignInAccount?> signInAndGetAccount(AppState state, bool silent) async {
  print('signInAndGetAccount called with silent: $silent.');

  if (!state.googleInitialized) {
    print('Unable to sign in to google because google is not initialized.');
    return null;
  }

  try {
    var result = silent ? state.googleSignIn.attemptLightweightAuthentication()
        : state.googleSignIn.authenticate(scopeHint: ['email']);

    if (result is Future<GoogleSignInAccount?>) {
      print('Successful authenticate! Returning Future...');
      var googleSignInAccount = await result;
      print('Account: ${googleSignInAccount?.displayName}');
      return googleSignInAccount;
    } else {
      print('result is not a future: $result}');
      return result as GoogleSignInAccount?;
    }
  } on GoogleSignInException catch (e) {
    print('Google Sign In error: code: ${e.code.name} description: ${e.description} details: ${e.details}');
    return null;
  } catch (error) {
    print('Unexpected error signing in: $error');
    return null;
  }
}