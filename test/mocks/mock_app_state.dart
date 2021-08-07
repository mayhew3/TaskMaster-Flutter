import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/notification_scheduler.dart';

import 'mock_notification_scheduler.dart';

class MockAppState extends Mock implements AppState {
  GoogleSignInAccount currentUser = MockGoogleSignInAccount();
  NotificationScheduler notificationScheduler = MockNotificationScheduler();

  int get personId => 1;
  List<TaskItem> taskItems;
  List<Sprint> sprints;

  MockAppState({
    this.taskItems,
    this.sprints,
  });

  @override
  bool isAuthenticated() {
    return true;
  }

  @override
  Future<String> getIdToken() async {
    return Future<String>.value('asdbhjsfd');
  }
}


class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
