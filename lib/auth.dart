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
    print("Handling sign in!");
    try {
      await _googleSignIn.signIn();
      print("Finished google signIn call.");
    } catch (error, stackTrace) {
      print("Login Errored!");
      print(error);
      print(stackTrace);
    }
  }

  void addGoogleListener() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      print("Current User Changed!");
      updateCurrentUser(account);
      if (account != null) {
        print("Login success!");
      } else {
        print("Login failed!");
      }
    });
    await _googleSignIn.signInSilently();
  }
}