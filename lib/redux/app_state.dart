import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/redux/containers/filtered_task_items.dart';
import 'package:taskmaster/redux/containers/planning_home.dart';
import 'package:taskmaster/redux/presentation/stats_counter.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

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
  bool get updating;
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

  // notifications
  int get nextId;
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin;

  AppState._();
  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  factory AppState.init({bool loading = false}) => AppState((appState) async {
    var navItemBuilder = initializeNavItems();
    return appState
      ..isLoading = loading
      ..loadFailed = false
      ..updating = false
      ..taskItems = ListBuilder()
      ..sprints = ListBuilder()
      ..taskRecurrences = ListBuilder()
      ..activeTab = navItemBuilder[0].toBuilder()
      ..sprintListFilter = VisibilityFilter.init(showScheduled: true, showCompleted: true, showActiveSprint: true).toBuilder()
      ..taskListFilter = VisibilityFilter.init().toBuilder()
      ..recentlyCompleted = ListBuilder()
      ..tokenRetrieved = false
      ..googleSignIn = GoogleSignIn(scopes: ['email'])
      ..timezoneHelper = TimezoneHelper()
      ..allNavItems = navItemBuilder
      ..nextId = 0
      ..flutterLocalNotificationsPlugin = initializeNotificationPlugin()
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

  static FlutterLocalNotificationsPlugin initializeNotificationPlugin() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
        // onDidReceiveLocalNotification: _onDidReceiveLocalNotification
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );
    var plugin = FlutterLocalNotificationsPlugin();
    plugin.initialize(initializationSettings,
      // onDidReceiveNotificationResponse: (response) => {}
    );
    // plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    return plugin;
  }

  bool appIsReady() {
    return isAuthenticated() && personId != null && timezoneHelper.timezoneInitialized;
  }
}