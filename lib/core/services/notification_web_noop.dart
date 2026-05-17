import '../../models/sprint.dart';
import '../../models/task_item.dart';
import 'notification_helper_impl.dart' show NotificationHelper;

/// Web no-op notification helper. flutter_local_notifications has no
/// web support; scheduling is silently skipped. App code keeps calling
/// `notificationHelperProvider` unchanged.
class NotificationHelperWebNoop implements NotificationHelper {
  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> cancelNotificationsForTaskId(String taskId) async {}

  @override
  Future<void> syncNotificationForSprint(Sprint sprint) async {}

  @override
  Future<void> syncNotificationForTasksAndSprint(
      List<TaskItem> taskItems, Sprint? sprint) async {}

  @override
  Future<void> updateNotificationForTask(TaskItem taskItem) async {}

  @override
  Future<void> updateNotificationsForTasks(List<TaskItem> taskItems) async {}
}
