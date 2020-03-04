import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmaster/models/task_item.dart';

import 'mock_google_sign_in_account.dart';
import 'mock_id_token_result.dart';

class MockAppState extends Mock implements AppState {
  GoogleSignInAccount currentUser = MockGoogleSignInAccount();
  int get personId => 1;
  List<TaskItem> taskItems;

  MockAppState({
    this.taskItems
  });

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