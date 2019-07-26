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

  TaskMasterAuth({@required this.updateCurrentUser});

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
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      updateCurrentUser(account);
      if (account != null) {
        print("Login success!");
      } else {
        print("Login failed!");
      }
    });
    _googleSignIn.signInSilently();
  }
}