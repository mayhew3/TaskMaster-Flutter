import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/redux/containers/filtered_task_items.dart';
import 'package:taskmaster/redux/containers/sprint_task_items.dart';
import 'package:taskmaster/redux/presentation/stats_counter.dart';

import '../models/models.dart';
import '../timezone_helper.dart';

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
  TopNavItem get activeTab;
  BuiltList<TopNavItem> get allNavItems;
  VisibilityFilter get sprintListFilter;
  VisibilityFilter get taskListFilter;

  // auth
  int? get personId;
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

  // date-time
  TimezoneHelper get timezoneHelper;

  AppState._();
  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  factory AppState.init({bool loading = false}) => AppState((appState) async {
    var allNavItems = [
      TopNavItem.init(
          label: 'Plan',
          icon: Icons.assignment,
          widgetGetter: () => SprintTaskItems()),
      TopNavItem.init(
          label: 'Tasks',
          icon: Icons.list,
          widgetGetter: () => FilteredTaskItems()),
      TopNavItem.init(
          label: 'Stats',
          icon: Icons.show_chart,
          widgetGetter: () => StatsCounter()),
    ];
    return appState
      ..isLoading = loading
      ..loadFailed = false
      ..taskItems = ListBuilder()
      ..sprints = ListBuilder()
      ..taskRecurrences = ListBuilder()
      ..activeTab = allNavItems[0].toBuilder()
      ..sprintListFilter = VisibilityFilter.init(
          showScheduled: true, showCompleted: true, showActiveSprint: true)
          .toBuilder()
      ..taskListFilter = VisibilityFilter.init().toBuilder()
      ..recentlyCompleted = ListBuilder()
      ..tokenRetrieved = false
      ..googleSignIn = GoogleSignIn(
          scopes: [
            'email',
          ]
      )
      ..timezoneHelper = TimezoneHelper()
      ..allNavItems = ListBuilder(allNavItems);
  }

  );

  bool appIsReady() {
    return isAuthenticated() && personId != null && timezoneHelper.timezoneInitialized;
  }
}