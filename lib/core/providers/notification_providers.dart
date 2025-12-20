import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/core/services/notification_helper_impl.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/helpers/task_selectors.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:built_collection/built_collection.dart';

/// Provider for the notification helper singleton
final notificationHelperProvider = Provider<NotificationHelperImpl>((ref) {
  final plugin = NotificationHelperImpl.initializeNotificationPlugin();
  return NotificationHelperImpl(plugin: plugin);
});

/// Provider that syncs notifications when tasks or sprints change
/// This should be watched in the app to trigger notification updates
final notificationSyncProvider = FutureProvider<void>((ref) async {
  final notificationHelper = ref.watch(notificationHelperProvider);
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);
  final sprintsAsync = ref.watch(sprintsProvider);

  // Wait for both to be available
  final tasks = tasksAsync.valueOrNull;
  final sprints = sprintsAsync.valueOrNull;

  if (tasks == null || sprints == null) {
    return; // Data not ready yet
  }

  // Get active sprint
  final builtSprints = BuiltList<Sprint>(sprints);
  final activeSprint = activeSprintSelector(builtSprints);

  // Sync all notifications
  await notificationHelper.syncNotificationForTasksAndSprint(
    tasks,
    activeSprint,
  );
});
