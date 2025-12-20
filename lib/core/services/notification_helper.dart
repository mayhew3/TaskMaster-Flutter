import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/sprint.dart';
import '../../models/task_item.dart';
import '../../timezone_helper.dart';

/// Abstract interface for notification management
///
/// This interface allows for different implementations:
/// - Production: Full notification functionality
/// - Testing: Mock implementation that does nothing
abstract class NotificationHelper {
  int get nextId;
  set nextId(int value);

  FlutterLocalNotificationsPlugin get plugin;
  TimezoneHelper get timezoneHelper;

  Future<void> cancelAllNotifications();
  Future<void> cancelNotificationsForTaskId(String taskId);
  Future<void> syncNotificationForSprint(Sprint sprint);
  Future<void> syncNotificationForTasksAndSprint(
    List<TaskItem> tasks,
    Sprint? sprint,
  );
  Future<void> updateNotificationForTask(TaskItem task);
}
