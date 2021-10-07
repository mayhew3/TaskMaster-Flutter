import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/notification_scheduler.dart';

import 'mock_notification_scheduler.dart';

class MockAppStateOld extends Fake implements AppState {
  bool isLoading = true;
  GoogleSignInAccount? currentUser = MockGoogleSignInAccount();
  NotificationScheduler notificationScheduler = MockNotificationScheduler();

  int get personId => 1;
  List<TaskItem> taskItems;
  List<Sprint> sprints;

  MockAppStateOld({
    this.taskItems = const [],
    this.sprints = const [],
  });

  @override
  bool isAuthenticated() {
    return true;
  }

  void finishedLoading() {
    isLoading = false;
  }

  Future<void> syncAllNotifications() async {
  }

  @override
  Future<String> getIdToken() async {
    return Future<String>.value('asdbhjsfd');
  }
}


class MockGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInAccount) return false;
    final GoogleSignInAccount otherAccount = other;
    return displayName == otherAccount.displayName &&
        email == otherAccount.email &&
        id == otherAccount.id &&
        photoUrl == otherAccount.photoUrl;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}
