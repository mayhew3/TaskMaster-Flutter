import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/task_item.dart';

import 'package:timezone/timezone.dart';
import 'mock_pending_notification_request.dart';

class MockFlutterLocalNotificationsPlugin extends Fake implements FlutterLocalNotificationsPlugin {
  List<MockPendingNotificationRequest> pendings = [];
  late DidReceiveNotificationResponseCallback? onDidReceiveNotification;

  @override
  Future<bool?> initialize(
      InitializationSettings initializationSettings,
      {
        DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
        DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse,
      } ) async {
    onDidReceiveNotification = onDidReceiveNotificationResponse;
    return Future.value(true);
  }

  @override
  Future<void> zonedSchedule(
      int id,
      String? title,
      String? body,
      TZDateTime scheduledDate,
      NotificationDetails notificationDetails, {
        bool androidAllowWhileIdle = false,
        AndroidScheduleMode? androidScheduleMode,
        String? payload,
        DateTimeComponents? matchDateTimeComponents,
      }) async {
    MockPendingNotificationRequest request = MockPendingNotificationRequest(id, payload, title, scheduledDate);
    pendings.add(request);
  }

  MockPendingNotificationRequest? findRequestFor(TaskItem taskItem, {bool? due}) {
    String dueStr = due == null || due ? 'due' : 'urgent';
    String payload = 'task:${taskItem.docId}:$dueStr';
    var matching = pendings.where((notification) => notification.payload == payload).iterator;
    if (matching.moveNext()) {
      var goodOne = matching.current;
      if (matching.moveNext()) {
        throw Exception('Multiple matches found for task item ${taskItem.docId} and date $dueStr');
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
  Future<void> cancel(int id, {String? tag}) async {
    pendings.removeWhere((request) => request.id == id);
  }

  @override
  Future<void> cancelAll() async {
    pendings = [];
  }

}