import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'MockGoogleSignInAccount.dart';
import 'MockIdTokenResult.dart';

class MockAppState extends Mock implements AppState {
  GoogleSignInAccount currentUser = MockGoogleSignInAccount();
  int get personId => 1;


  @override
  bool isAuthenticated() {
    return true;
  }

  @override
  Future<IdTokenResult> getIdToken() async {
    IdTokenResult idTokenResult = MockIdTokenResult();
    return Future<IdTokenResult>.value(idTokenResult);
  }
}