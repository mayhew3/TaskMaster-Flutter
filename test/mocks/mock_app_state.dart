import 'package:built_collection/src/list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/src/flutter_local_notifications_plugin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/models/visibility_filter.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/timezone_helper.dart';
/*

class MockAppState extends AppState {
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final BuiltList<Sprint> sprints;
  @override
  final BuiltList<TaskRecurrence> taskRecurrences;
  @override
  final bool isLoading;
  @override
  final bool loadFailed;
  @override
  final BuiltList<TaskItem> recentlyCompleted;
  @override
  final TopNavItem activeTab;
  @override
  final BuiltList<TopNavItem> allNavItems;
  @override
  final VisibilityFilter sprintListFilter;
  @override
  final VisibilityFilter taskListFilter;
  @override
  final int? personId;
  @override
  final GoogleSignIn googleSignIn;
  @override
  final UserCredential? firebaseUser;
  @override
  final GoogleSignInAccount? currentUser;
  @override
  final bool tokenRetrieved;
  @override
  final TimezoneHelper timezoneHelper;
  @override
  final int nextId;
  @override
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  factory MockAppState([void Function(AppStateBuilder)? updates]) =>
      (new AppStateBuilder()..update(updates)).build();
}*/
