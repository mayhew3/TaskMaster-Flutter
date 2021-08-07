import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/task_item.dart';

import 'mock_pending_notification_request.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {
  List<MockPendingNotificationRequest> pendings = [];
  SelectNotificationCallback onSelect;
  DidReceiveLocalNotificationCallback onNotification;

  @override
  Future<bool> initialize(InitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    onSelect = onSelectNotification;
    onNotification = initializationSettings.iOS.onDidReceiveLocalNotification;
    return Future.value(true);
  }

  @override
  Future<void> schedule(int id, String title, String body,
      DateTime scheduledDate, NotificationDetails notificationDetails,
      {String payload, bool androidAllowWhileIdle = false}) async {
    MockPendingNotificationRequest request = new MockPendingNotificationRequest(id, payload, title, scheduledDate);
    pendings.add(request);
  }

  MockPendingNotificationRequest findRequestFor(TaskItem taskItem, {bool due}) {
    String dueStr = due == null || due ? 'due' : 'urgent';
    String payload = 'task:${taskItem.id.value}:$dueStr';
    var matching = pendings.where((notification) => notification.payload == payload).iterator;
    if (matching.moveNext()) {
      var goodOne = matching.current;
      if (matching.moveNext()) {
        throw Exception("Multiple matches found for task item ${taskItem.id.value} and date $dueStr");
      }
      return goodOne;
    } else {
      return null;
    }
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    var copy = List<PendingNotificationRequest>.from(pendings);
    return Future.value(copy);
  }

  @override
  Future<void> cancel(int id, {String tag}) async {
    pendings.removeWhere((request) => request.id == id);
  }

  @override
  Future<void> cancelAll() async {
    pendings = [];
  }

}