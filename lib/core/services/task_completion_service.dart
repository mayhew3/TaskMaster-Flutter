import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import '../providers/notification_providers.dart';
import '../utils/performance_logger.dart';
import '../../features/tasks/data/firestore_task_repository.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../../models/task_item.dart';
import '../../models/task_item_blueprint.dart';
import '../../models/task_recurrence.dart';
import '../../models/snooze_blueprint.dart';
import '../../models/task_date_type.dart';
import '../../helpers/recurrence_helper.dart';
import '../../task_repository.dart' as legacy;
import '../../timezone_helper.dart';

part 'task_completion_service.g.dart';

class TaskCompletionResult {
  const TaskCompletionResult({
    required this.completedTask,
    this.nextRecurrence,
  });

  final TaskItem completedTask;
  final TaskItem? nextRecurrence;
}

class TaskCompletionService {
  TaskCompletionService(this._repository);

  final TaskRepository _repository;

  Future<TaskCompletionResult> completeTask({
    required TaskItem task,
    required List<TaskItem> allTasks,
    required List<TaskRecurrence> allRecurrences,
    required bool complete,
  }) async {
    final perf = PerformanceLogger.start('TaskCompletionService.completeTask');
    TaskItem? nextScheduledTask;

    // Create next recurrence if needed (before completing current task)
    if (task.recurrenceDocId != null &&
        complete &&
        !_hasNextIteration(task, allTasks)) {
      perf.checkpoint('needsNextRecurrence=true');

      // Find and populate the recurrence on the task
      final recurrence = allRecurrences.firstWhere(
        (r) => r.docId == task.recurrenceDocId,
        orElse: () => throw Exception('Recurrence not found: ${task.recurrenceDocId}'),
      );

      // Rebuild task with recurrence populated
      final taskWithRecurrence = task.rebuild((b) => b..recurrence = recurrence.toBuilder());

      final completionDate = DateTime.now();
      final nextPreview = RecurrenceHelper.createNextIteration(
        taskWithRecurrence,
        completionDate,
      );
      perf.checkpoint('createNextIteration');

      // Add the new task
      await _repository.addTask(nextPreview.toBlueprint());
      perf.checkpoint('repository.addTask (next recurrence)');
    } else {
      perf.checkpoint('needsNextRecurrence=false');
    }

    // Update the completed task
    final updatedTask = await _repository.toggleTaskCompletion(
      task,
      complete: complete,
    );
    perf.checkpoint('repository.toggleTaskCompletion');

    perf.finish();
    return TaskCompletionResult(
      completedTask: updatedTask,
      nextRecurrence: nextScheduledTask,
    );
  }

  bool _hasNextIteration(TaskItem task, List<TaskItem> allTasks) {
    final recurIteration = task.recurIteration;
    if (recurIteration == null) return false;

    return allTasks.any((ti) =>
        ti.recurrenceDocId == task.recurrenceDocId &&
        ti.recurIteration != null &&
        ti.recurIteration! > recurIteration);
  }
}

@riverpod
TaskCompletionService taskCompletionService(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskCompletionService(repository);
}

/// Controller for completing tasks
@riverpod
class CompleteTask extends _$CompleteTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task, {required bool complete}) async {
    final perf = PerformanceLogger.start('CompleteTask');

    // IMMEDIATE: Mark as pending (optimistic update for instant UI feedback)
    ref.read(pendingTasksProvider.notifier).markPending(task);
    perf.checkpoint('markPending');

    try {
      final service = ref.read(taskCompletionServiceProvider);
      perf.checkpoint('getService');

      // Use cached data if available (don't wait for stream)
      final tasksAsync = ref.read(tasksProvider);
      final recurrencesAsync = ref.read(taskRecurrencesProvider);

      final List<TaskItem> allTasks;
      final List<TaskRecurrence> allRecurrences;

      if (tasksAsync.hasValue && recurrencesAsync.hasValue) {
        allTasks = tasksAsync.value!;
        allRecurrences = recurrencesAsync.value!;
        perf.checkpoint('getData (cached)');
      } else {
        allTasks = await ref.read(tasksProvider.future);
        allRecurrences = await ref.read(taskRecurrencesProvider.future);
        perf.checkpoint('getData (awaited)');
      }

      final result = await service.completeTask(
        task: task,
        allTasks: allTasks,
        allRecurrences: allRecurrences,
        complete: complete,
      );
      perf.checkpoint('service.completeTask');

      // Track recently completed tasks (matches Redux pattern)
      final recentlyCompleted = ref.read(recentlyCompletedTasksProvider.notifier);
      if (complete) {
        recentlyCompleted.add(result.completedTask);
      } else {
        recentlyCompleted.remove(result.completedTask);
      }
      perf.checkpoint('recentlyCompleted update');

      // Clear pending state after success
      ref.read(pendingTasksProvider.notifier).clearPending(task.docId);
      perf.checkpoint('clearPending');

      perf.finish('success');

      // Fire-and-forget: Update notification in background (not critical for UI)
      final notificationHelper = ref.read(notificationHelperProvider);
      notificationHelper.updateNotificationForTask(result.completedTask).then((_) {
        print('⏱️ [CompleteTask] notification updated (background)');
      }).catchError((e) {
        print('⚠️ [CompleteTask] notification error: $e');
      });
    } catch (e, stack) {
      print('❌ [CompleteTask] Error: $e\n$stack');
      // Clear pending on error so UI reverts to stream state
      ref.read(pendingTasksProvider.notifier).clearPending(task.docId);
      perf.finish('error');
      rethrow;
    }
  }
}

/// Controller for deleting tasks
@riverpod
class DeleteTask extends _$DeleteTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      await repository.deleteTask(task);
    });
  }
}

/// Controller for adding new tasks
@riverpod
class AddTask extends _$AddTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItemBlueprint blueprint) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      final personDocId = ref.read(personDocIdProvider);

      // Set personDocId on the blueprint (matching Redux middleware behavior)
      blueprint.personDocId = personDocId;
      blueprint.recurrenceBlueprint?.personDocId = personDocId;

      await repository.addTask(blueprint);
    });
  }
}

/// Controller for updating tasks
@riverpod
class UpdateTask extends _$UpdateTask {
  @override
  FutureOr<void> build() {}

  Future<void> call({
    required TaskItem task,
    required TaskItemBlueprint blueprint,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      final personDocId = ref.read(personDocIdProvider);

      // Set personDocId on the blueprint (matching AddTask behavior)
      // This is needed when adding recurrence to an existing task
      blueprint.personDocId = personDocId;
      blueprint.recurrenceBlueprint?.personDocId = personDocId;

      await repository.updateTaskAndRecurrence(task.docId, blueprint);
    });
  }
}

/// Controller for snoozing tasks
@riverpod
class SnoozeTask extends _$SnoozeTask {
  @override
  FutureOr<void> build() {}

  Future<void> call({
    required TaskItem taskItem,
    required TaskItemBlueprint blueprint,
    required int numUnits,
    required String unitSize,
    required TaskDateType dateType,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final legacyRepository = ref.read(legacyTaskRepositoryProvider);

      // Generate the preview (updates blueprint in place)
      RecurrenceHelper.generatePreview(blueprint, numUnits, unitSize, dateType);

      // Get original anchor date before update
      final originalValue = taskItem.getAnchorDate();

      // Update task and maybe recurrence
      final result = await RecurrenceHelper.updateTaskAndMaybeRecurrenceForSnooze(
        repository: legacyRepository,
        taskItem: taskItem,
        blueprint: blueprint,
      );

      // Get new anchor date
      final newAnchorDate = dateType.dateFieldGetter(result.taskItem)!;

      // Create snooze record
      final snooze = SnoozeBlueprint(
        taskDocId: result.taskItem.docId,
        snoozeNumber: numUnits,
        snoozeUnits: unitSize,
        snoozeAnchor: dateType.label,
        previousAnchor: originalValue?.dateValue,
        newAnchor: newAnchorDate,
      );

      legacyRepository.addSnooze(snooze);
    });
  }
}

/// Provider for legacy TaskRepository (for snooze functionality)
@riverpod
legacy.TaskRepository legacyTaskRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return legacy.TaskRepository(firestore: firestore);
}

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first
@Riverpod(keepAlive: true)
class TimezoneHelperNotifier extends _$TimezoneHelperNotifier {
  @override
  Future<TimezoneHelper> build() async {
    final helper = TimezoneHelper();
    await helper.configureLocalTimeZone();
    return helper;
  }
}
