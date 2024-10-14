import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/redux/containers/filtered_task_items.dart';
import 'package:taskmaster/redux/containers/planning_home.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
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
  String? get personDocId;
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

  // notifications
  int get nextId;
  NotificationHelper get notificationHelper;

  AppState._();
  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  factory AppState.init({bool loading = false}) => AppState((appState) async {
    var navItemBuilder = initializeNavItems();
    var timezoneHelper = TimezoneHelper();
    return appState
      ..isLoading = loading
      ..loadFailed = false
      ..taskItems = ListBuilder()
      ..sprints = ListBuilder()
      ..taskRecurrences = ListBuilder()
      ..activeTab = navItemBuilder[0].toBuilder()
      ..sprintListFilter = VisibilityFilter.init(showScheduled: true, showCompleted: true, showActiveSprint: true).toBuilder()
      ..taskListFilter = VisibilityFilter.init().toBuilder()
      ..recentlyCompleted = ListBuilder()
      ..tokenRetrieved = false
      ..googleSignIn = GoogleSignIn(scopes: ['email'])
      ..timezoneHelper = timezoneHelper
      ..allNavItems = navItemBuilder
      ..nextId = 0
      ..notificationHelper = new NotificationHelper(plugin: NotificationHelper.initializeNotificationPlugin(), timezoneHelper: timezoneHelper)
    ;
  }
  );

  static ListBuilder<TopNavItem> initializeNavItems() {
    return ListBuilder<TopNavItem>([
      TopNavItem.init(
          label: 'Plan',
          icon: Icons.assignment,
          widgetGetter: () => PlanningHome()),
      TopNavItem.init(
          label: 'Tasks',
          icon: Icons.list,
          widgetGetter: () => FilteredTaskItems()),
      TopNavItem.init(
          label: 'Stats',
          icon: Icons.show_chart,
          widgetGetter: () => StatsCounter()),
    ]);
  }

  bool appIsReady() {
    return isAuthenticated() && personDocId != null && timezoneHelper.timezoneInitialized;
  }
}