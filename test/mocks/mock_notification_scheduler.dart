
import 'package:mockito/mockito.dart';
import 'package:taskmaster/notification_scheduler.dart';

class MockNotificationScheduler extends Fake implements NotificationScheduler {

  Future<void> cancelAllNotifications() async {
  }

  void updateBadge() {
  }

}