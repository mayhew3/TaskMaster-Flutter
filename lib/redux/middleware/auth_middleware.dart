

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

List<Middleware<AppState>> createAuthenticationMiddleware() {
  return [
    TypedMiddleware<AppState, TryToSilentlySignIn>(_tryToSilentlySignIn())
  ];
}

void Function(
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
    ) _tryToSilentlySignIn() {
  return (store, action, next) async {
    next(action);
    await Firebase.initializeApp();
    store.state.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      if (account == null) {
        store.dispatch(OnLogoutSuccess());
      } else {
        var authentication = await account.authentication;

        if (authentication.idToken == null) {
          store.dispatch(OnLoginFail("No idToken returned."));
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );

        var firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
        String? idToken = await firebaseUser.user!.getIdToken();
        store.dispatch(OnAuthenticated(account, firebaseUser, idToken));
      }
    });
  };
}