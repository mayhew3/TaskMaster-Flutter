import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';

import 'mock_pending_notification_request.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {
  List<MockPendingNotificationRequest> pendings = [];

  @override
  Future<void> schedule(int id, String title, String body,
      DateTime scheduledDate, NotificationDetails notificationDetails,
      {String payload, bool androidAllowWhileIdle = false}) async {
    MockPendingNotificationRequest request = new MockPendingNotificationRequest(id, payload);
    pendings.add(request);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    var copy = List<PendingNotificationRequest>.from(pendings);
    return Future.value(copy);
  }

  @override
  Future<void> cancel(int id) async {
    pendings.removeWhere((request) => request.id == id);
  }

  @override
  Future<void> cancelAll() async {
    pendings = [];
  }

}