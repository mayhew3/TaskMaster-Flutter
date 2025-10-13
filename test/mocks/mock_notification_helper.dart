import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
import 'package:taskmaster/timezone_helper.dart';

/// Mock NotificationHelper for testing
/// This prevents notification platform initialization errors in tests
class MockNotificationHelper implements NotificationHelper {
  @override
  int nextId = 0;

  @override
  FlutterLocalNotificationsPlugin get plugin => _MockPlugin();

  @override
  TimezoneHelper get timezoneHelper => _MockTimezoneHelper();

  @override
  Future<void> cancelAllNotifications() async {
    // No-op in tests
  }

  @override
  Future<void> cancelNotificationsForTaskId(String taskId) async {
    // No-op in tests
  }

  @override
  Future<void> syncNotificationForSprint(Sprint sprint) async {
    // No-op in tests
  }

  @override
  Future<void> syncNotificationForTasksAndSprint(
    List<TaskItem> tasks,
    Sprint? sprint,
  ) async {
    // No-op in tests
  }

  @override
  Future<void> updateNotificationForTask(TaskItem task) async {
    // No-op in tests
  }
}

/// Mock plugin for testing
class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

/// Mock timezone helper for testing
class _MockTimezoneHelper extends Mock implements TimezoneHelper {}
