import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/models.dart';

part 'app_state.g.dart';

abstract class AppState implements Built<AppState, AppStateBuilder> {
  // core data
  BuiltList<TaskItem> get taskItems;
  BuiltList<Sprint> get sprints;
  BuiltList<TaskRecurrence> get taskRecurrences;

  // task item state
  bool get isLoading;
  bool get loadFailed;
  BuiltList<TaskItem> get recentlyCompleted;

  // ui
  AppTab get activeTab;
  VisibilityFilter get sprintListFilter;
  VisibilityFilter get taskListFilter;

  // auth
  GoogleSignIn get googleSignIn;
  UserCredential? get firebaseUser;
  GoogleSignInAccount? get currentUser;
  bool get tokenRetrieved;

  Future<String?> getIdToken() async {
    return await firebaseUser?.user?.getIdToken();
  }

  bool isAuthenticated() {
    return currentUser != null && tokenRetrieved;
  }

  AppState._();
  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  factory AppState.init({bool loading = false}) => AppState((appState) async => appState
    ..isLoading = loading
    ..loadFailed = false
    ..taskItems = ListBuilder()
    ..sprints = ListBuilder()
    ..taskRecurrences = ListBuilder()
    ..activeTab = AppTab.tasks
    ..sprintListFilter = VisibilityFilter.init(showScheduled: true, showCompleted: true, showActiveSprint: true).toBuilder()
    ..taskListFilter = VisibilityFilter.init().toBuilder()
    ..recentlyCompleted = ListBuilder()
    ..tokenRetrieved = false
    ..googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ]
    )
  );

}