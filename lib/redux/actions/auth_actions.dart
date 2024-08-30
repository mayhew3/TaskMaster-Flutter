
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TryToSilentlySignIn {
}

class LogIn {}

class OnAuthenticated {
  final GoogleSignInAccount account;
  final UserCredential userCredential;
  final String? idToken;

  OnAuthenticated(this.account, this.userCredential, this.idToken);

  @override
  String toString() {
    return "OnAuthenticated{account: ${account.displayName}";
  }
}

class LogOutAction {}

class OnLogoutSuccess {
  OnLogoutSuccess();

  @override
  String toString() {
    return "LogOut{user: null}";
  }
}

class OnLoginFail {
  final dynamic error;

  OnLoginFail(this.error);

  @override
  String toString() {
    return "OnLoginFail{There was an error logging in: $error}";
  }
}
class OnLogoutFail {
  final dynamic error;

  OnLogoutFail(this.error);

  @override
  String toString() {
    return "OnLogoutFail{There was an error logging out: $error}";
  }
}