import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:taskmaster/typedefs.dart';

class TaskMasterAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ]
  );
  final UserUpdater updateCurrentUser;
  final IdTokenUpdater updateIdToken;

  TaskMasterAuth({
    @required this.updateCurrentUser,
    @required this.updateIdToken,
  });

  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error, stackTrace) {
      print("Login Errored!");
      print(error);
      print(stackTrace);
    }
  }

  Future<void> handleSignOut() async {
    _googleSignIn.disconnect();
  }

  void addGoogleListener() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) async {
      GoogleSignInAuthentication authentication = await account.authentication;
      updateIdToken(authentication.idToken);
      updateCurrentUser(account);
      if (account == null) {
        print("Login failed! No SignInAccount returned.");
      } else if (authentication.idToken == null) {
        print("Login failed! No IdToken returned.");
      } else {
        print("Login success!");
      }
    });
    _googleSignIn.signInSilently();
  }
}