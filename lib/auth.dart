import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/typedefs.dart';

class TaskMasterAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ]
  );
  UserCredential? _firebaseUser;
  final UserUpdater updateCurrentUser;
  final IdTokenUpdater updateIdToken;

  TaskMasterAuth({
    required this.updateCurrentUser,
    required this.updateIdToken,
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
    await _googleSignIn.disconnect();
  }

  Future<String?> getIdToken() async {
    return await _firebaseUser!.user!.getIdToken();
  }

  void clearFields() {
    _firebaseUser = null;
    updateCurrentUser(null);
    updateIdToken(null);
  }

  Future<GoogleSignInAccount?> addGoogleListener() async {
    await Firebase.initializeApp();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {

      if (account == null) {
        clearFields();
        print('Signed out!');
        return;
      }

      GoogleSignInAuthentication authentication = await account
          .authentication;

      if (authentication.idToken == null) {
        clearFields();
        print("Login failed! No IdToken returned.");
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );
      _firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
      String? idToken = await _firebaseUser!.user!.getIdToken();
      updateIdToken(idToken);
      updateCurrentUser(account);
      print("Login success!");

    });
    return _googleSignIn.signInSilently();
  }
}