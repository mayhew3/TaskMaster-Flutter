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

/// Provider that syncs notifications ONCE on app startup
/// Individual task changes are handled via updateNotificationForTask() in CompleteTask
/// This avoids re-scheduling ALL notifications on every task change (major perf fix)
final notificationSyncProvider = FutureProvider<void>((ref) async {
  final notificationHelper = ref.watch(notificationHelperProvider);

  // Use ref.read (not ref.watch) to avoid re-triggering on task changes
  final tasks = await ref.read(tasksWithRecurrencesProvider.future);
  final sprints = await ref.read(sprintsProvider.future);

  // Get active sprint
  final builtSprints = BuiltList<Sprint>(sprints);
  final activeSprint = activeSprintSelector(builtSprints);

  // Full sync only on startup
  await notificationHelper.syncNotificationForTasksAndSprint(
    tasks,
    activeSprint,
  );
});
