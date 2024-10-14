
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TryToSilentlySignInAction {
}

class LogInAction {}

class OnAuthenticatedAction {
  final GoogleSignInAccount account;
  final UserCredential userCredential;
  final String? idToken;

  OnAuthenticatedAction(this.account, this.userCredential, this.idToken);

  @override
  String toString() {
    return "OnAuthenticated{account: ${account.displayName}";
  }
}

class LogOutAction {}

class OnLogoutSuccessAction {
  OnLogoutSuccessAction();

  @override
  String toString() {
    return "LogOut{user: null}";
  }
}

class OnLoginFailAction {
  final dynamic error;

  OnLoginFailAction(this.error);

  @override
  String toString() {
    return "OnLoginFail{There was an error logging in: $error}";
  }
}

class OnLogoutFailAction {
  final dynamic error;

  OnLogoutFailAction(this.error);

  @override
  String toString() {
    return "OnLogoutFail{There was an error logging out: $error}";
  }
}

class VerifyPersonAction {
  final String email;

  VerifyPersonAction(this.email);
}

class OnPersonVerifiedAction {
  final int personId;

  OnPersonVerifiedAction(this.personId);
}

class OnPersonVerifiedFirestoreAction {
  final String personDocId;

  OnPersonVerifiedFirestoreAction(this.personDocId);
}

class OnPersonRejectedAction {}