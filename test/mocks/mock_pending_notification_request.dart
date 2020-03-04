import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';

class MockPendingNotificationRequest extends Mock implements PendingNotificationRequest {
  final int id;
  final String payload;
  final DateTime notificationDate;

  MockPendingNotificationRequest(this.id, this.payload, this.notificationDate);
}