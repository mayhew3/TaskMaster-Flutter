import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart'
    hide Task, TaskRecurrence, Sprint, SprintAssignment;
import '../database/converters.dart';
import '../providers/auth_providers.dart';
import '../providers/database_provider.dart';
import '../providers/firebase_providers.dart';
import '../providers/notification_providers.dart';
import '../utils/performance_logger.dart';
import 'analytics_service.dart';
import 'sync_service.dart';
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

/// Thrown when a recurring task references a recurrence that is missing from
/// the local cache. Callers can catch this to show a user-friendly message.
class RecurrenceNotFoundException implements Exception {
  RecurrenceNotFoundException({required this.recurrenceDocId, required this.taskDocId});

  final String recurrenceDocId;
  final String taskDocId;

  @override
  String toString() =>
      'RecurrenceNotFoundException(recurrenceDocId: $recurrenceDocId, taskDocId: $taskDocId)';
}

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
        orElse: () => throw RecurrenceNotFoundException(
          recurrenceDocId: task.recurrenceDocId!,
          taskDocId: task.docId,
        ),
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
      final db = ref.read(databaseProvider);
      final firestore = ref.read(firestoreProvider);

      // Use cached data if available (don't wait for stream)
      final tasksAsync = ref.read(tasksProvider);
      final recurrencesAsync = ref.read(taskRecurrencesProvider);

      final List<TaskItem> allTasks = tasksAsync.hasValue
          ? tasksAsync.value!
          : await ref.read(tasksProvider.future);
      final List<TaskRecurrence> allRecurrences = recurrencesAsync.hasValue
          ? recurrencesAsync.value!
          : await ref.read(taskRecurrencesProvider.future);

      perf.checkpoint('getData');

      // Create next recurrence iteration if needed.
      if (task.recurrenceDocId != null &&
          complete &&
          !_hasNextIteration(task, allTasks)) {
        final recurrence = allRecurrences.firstWhere(
          (r) => r.docId == task.recurrenceDocId,
          orElse: () => throw RecurrenceNotFoundException(
            recurrenceDocId: task.recurrenceDocId!,
            taskDocId: task.docId,
          ),
        );
        final taskWithRecurrence =
            task.rebuild((b) => b..recurrence = recurrence.toBuilder());
        final nextPreview = RecurrenceHelper.createNextIteration(
          taskWithRecurrence,
          DateTime.now(),
        );
        final nextBlueprint = nextPreview.toBlueprint();
        final personDocId = ref.read(personDocIdProvider);
        if (personDocId == null) {
          throw StateError(
              'Cannot create next recurrence iteration: personDocId is null (not authenticated).');
        }
        final now = DateTime.now().toUtc();

        // If the recurrence blueprint signals iteration increment, persist it.
        final recBp = nextBlueprint.recurrenceBlueprint;
        if (recBp != null && nextBlueprint.recurrenceDocId != null) {
          await db.taskRecurrenceDao.markUpdatePending(
            nextBlueprint.recurrenceDocId!,
            recurrenceBlueprintToDiff(recBp),
          );
        }

        final nextDocId = firestore.collection('tasks').doc().id;
        await db.taskDao.insertPending(
          taskBlueprintToCompanion(
            docId: nextDocId,
            personDocId: personDocId,
            dateAdded: now,
            blueprint: nextBlueprint,
          ),
        );
        perf.checkpoint('insertNextRecurrence');
      }

      // Toggle completionDate on the current task.
      final completionDate = complete ? DateTime.now().toUtc() : null;
      await db.taskDao.markUpdatePending(
        task.docId,
        TasksCompanion(completionDate: Value(completionDate)),
      );
      perf.checkpoint('markUpdatePending');

      // Build updated task for notifications/recentlyCompleted.
      final updatedTask = task.rebuild((b) => b..completionDate = completionDate);

      // Track recently completed tasks (matches Redux pattern).
      final recentlyCompleted = ref.read(recentlyCompletedTasksProvider.notifier);
      final recentlyCompletedIndices =
          ref.read(recentlyCompletedIndicesProvider.notifier);
      if (complete) {
        recentlyCompleted.add(updatedTask);
        // Capture the task's current position in the base list so
        // filteredTasksProvider can re-insert it at the same spot on the
        // Tasks tab instead of appending at the end (TM-339 Tasks tab).
        final originalIndex =
            allTasks.indexWhere((t) => t.docId == task.docId);
        if (originalIndex >= 0) {
          recentlyCompletedIndices.set(task.docId, originalIndex);
        }
      } else {
        recentlyCompleted.remove(updatedTask);
        recentlyCompletedIndices.remove(task.docId);
      }

      ref.read(analyticsServiceProvider).logTaskCompleted(complete: complete).ignore();
      ref.read(syncServiceProvider).pushPendingWrites(caller: 'CompleteTask').ignore();
      perf.checkpoint('recentlyCompleted + push');

      // Clear pending state after success.
      ref.read(pendingTasksProvider.notifier).clearPending(task.docId);
      perf.checkpoint('clearPending');

      perf.finish('success');

      // Fire-and-forget: Update notification in background.
      final notificationHelper = ref.read(notificationHelperProvider);
      notificationHelper.updateNotificationForTask(updatedTask).then((_) {
        print('⏱️ [CompleteTask] notification updated (background)');
      }).catchError((e) {
        print('⚠️ [CompleteTask] notification error: $e');
      });
    } catch (e, stack) {
      print('❌ [CompleteTask] Error: $e\n$stack');
      ref.read(pendingTasksProvider.notifier).clearPending(task.docId);
      perf.finish('error');
      rethrow;
    }
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

/// Controller for skipping a recurring task instance
@riverpod
class SkipTask extends _$SkipTask {
  @override
  FutureOr<void> build() {}

  /// Skip: create next iteration at the normal scheduled date, mark current as
  /// skipped=true, and set its completionDate for persistence/filtering.
  Future<void> call(TaskItem task) async {
    try {
      final db = ref.read(databaseProvider);
      final firestore = ref.read(firestoreProvider);
      final personDocId = ref.read(personDocIdProvider);
      if (personDocId == null) {
        throw StateError('Cannot skip task: personDocId is null (not authenticated).');
      }

      final tasksAsync = ref.read(tasksProvider);
      final recurrencesAsync = ref.read(taskRecurrencesProvider);
      final List<TaskItem> allTasks = tasksAsync.hasValue
          ? tasksAsync.value!
          : await ref.read(tasksProvider.future);
      final List<TaskRecurrence> allRecurrences = recurrencesAsync.hasValue
          ? recurrencesAsync.value!
          : await ref.read(taskRecurrencesProvider.future);

      if (task.recurrenceDocId != null && !_hasNextIteration(task, allTasks)) {
        final recurrence = allRecurrences.firstWhere(
          (r) => r.docId == task.recurrenceDocId,
          orElse: () => throw RecurrenceNotFoundException(
            recurrenceDocId: task.recurrenceDocId!,
            taskDocId: task.docId,
          ),
        );
        final taskWithRecurrence = task.rebuild((b) => b..recurrence = recurrence.toBuilder());
        final nextPreview = RecurrenceHelper.createNextIteration(
          taskWithRecurrence,
          DateTime.now(),
        );
        final nextBlueprint = nextPreview.toBlueprint();

        final recBp = nextBlueprint.recurrenceBlueprint;
        if (recBp != null && nextBlueprint.recurrenceDocId != null) {
          await db.taskRecurrenceDao.markUpdatePending(
            nextBlueprint.recurrenceDocId!,
            recurrenceBlueprintToDiff(recBp),
          );
        }

        final nextDocId = firestore.collection('tasks').doc().id;
        final now = DateTime.now().toUtc();
        await db.taskDao.insertPending(
          taskBlueprintToCompanion(
            docId: nextDocId,
            personDocId: personDocId,
            dateAdded: now,
            blueprint: nextBlueprint,
          ),
        );
      }

      // Mark current instance as skipped, set completionDate so it sorts/filters like completed
      final skippedAt = DateTime.now().toUtc();
      await db.taskDao.markUpdatePending(
        task.docId,
        TasksCompanion(skipped: const Value(true), completionDate: Value(skippedAt)),
      );

      // Keep task in place until user leaves tab (mirrors CompleteTask behaviour)
      final updatedTask = task.rebuild((b) => b
        ..skipped = true
        ..completionDate = skippedAt);
      final recentlyCompleted = ref.read(recentlyCompletedTasksProvider.notifier);
      final recentlyCompletedIndices = ref.read(recentlyCompletedIndicesProvider.notifier);
      recentlyCompleted.add(updatedTask);
      final originalIndex = allTasks.indexWhere((t) => t.docId == task.docId);
      if (originalIndex >= 0) {
        recentlyCompletedIndices.set(task.docId, originalIndex);
      }

      ref.read(syncServiceProvider).pushPendingWrites(caller: 'SkipTask').ignore();
    } catch (e, stack) {
      print('❌ [SkipTask] Error: $e\n$stack');
      rethrow;
    }
  }

  /// Un-skip: revert skipped=true back to false
  Future<void> unskip(TaskItem task) async {
    try {
      final db = ref.read(databaseProvider);
      await db.taskDao.markUpdatePending(
        task.docId,
        const TasksCompanion(skipped: Value(false), completionDate: Value(null)),
      );
      ref.read(recentlyCompletedTasksProvider.notifier).remove(task);
      ref.read(recentlyCompletedIndicesProvider.notifier).remove(task.docId);
      ref.read(syncServiceProvider).pushPendingWrites(caller: 'SkipTask.unskip').ignore();
    } catch (e, stack) {
      print('❌ [SkipTask.unskip] Error: $e\n$stack');
      rethrow;
    }
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

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
@riverpod
class DeleteTask extends _$DeleteTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task) async {
    final db = ref.read(databaseProvider);
    await db.taskDao.markDeletePending(task.docId);
    ref.read(analyticsServiceProvider).logTaskDeleted().ignore();
    ref.read(syncServiceProvider).pushPendingWrites(caller: 'DeleteTask').ignore();
  }
}

/// Controller for adding new tasks.
@riverpod
class AddTask extends _$AddTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItemBlueprint blueprint) async {
    final db = ref.read(databaseProvider);
    final firestore = ref.read(firestoreProvider);
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      throw StateError(
          'Cannot add task: personDocId is null (not authenticated).');
    }

    blueprint.personDocId = personDocId;
    // familyDocId is supplied by the caller via the blueprint (TaskAddEditScreen
    // pre-sets it when launched with `defaultFamilyShared: true` from the
    // Family tab). Auto-stamping based on the user's current family was
    // surprising on the Tasks tab — newly-added tasks vanished from the tab
    // because filteredTasksProvider hides familyDocId-bearing rows.
    blueprint.recurrenceBlueprint?.personDocId = personDocId;

    final now = DateTime.now().toUtc();
    final recurrenceBlueprint = blueprint.recurrenceBlueprint;

    // If this is a new recurrence (no existing recurrenceDocId), create it first.
    if (recurrenceBlueprint != null && blueprint.recurrenceDocId == null) {
      final recurrenceDocId = firestore.collection('taskRecurrences').doc().id;
      blueprint.recurrenceDocId = recurrenceDocId;
      await db.taskRecurrenceDao.insertPending(
        recurrenceBlueprintToCompanion(
          docId: recurrenceDocId,
          personDocId: personDocId,
          dateAdded: now,
          blueprint: recurrenceBlueprint,
        ),
      );
    }

    final taskDocId = firestore.collection('tasks').doc().id;
    await db.taskDao.insertPending(
      taskBlueprintToCompanion(
        docId: taskDocId,
        personDocId: personDocId,
        dateAdded: now,
        blueprint: blueprint,
      ),
    );

    ref.read(analyticsServiceProvider)
        .logTaskCreated(hasRecurrence: recurrenceBlueprint != null)
        .ignore();
    ref.read(syncServiceProvider).pushPendingWrites(caller: 'AddTask').ignore();

    // Fire-and-forget: schedule notifications for the new task's dates.
    // Re-reads the just-saved row so the helper sees exactly what landed in
    // Drift instead of duplicating field-mapping logic from the blueprint.
    final savedRow = await db.taskDao.getByDocId(taskDocId);
    if (savedRow != null) {
      final newTask = taskItemFromRow(savedRow);
      ref
          .read(notificationHelperProvider)
          .updateNotificationForTask(newTask)
          .then((_) => print('⏱️ [AddTask] notification updated (background)'))
          .catchError((e) => print('⚠️ [AddTask] notification error: $e'));
    }
  }
}

/// Controller for updating tasks.
@riverpod
class UpdateTask extends _$UpdateTask {
  @override
  FutureOr<void> build() {}

  Future<void> call({
    required TaskItem task,
    required TaskItemBlueprint blueprint,
  }) async {
    final db = ref.read(databaseProvider);
    final firestore = ref.read(firestoreProvider);
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      throw StateError(
          'Cannot update task: personDocId is null (not authenticated).');
    }

    blueprint.personDocId = personDocId;
    blueprint.recurrenceBlueprint?.personDocId = personDocId;

    final recurrenceBlueprint = blueprint.recurrenceBlueprint;

    // If adding a brand-new recurrence to an existing task, create the record.
    if (recurrenceBlueprint != null && blueprint.recurrenceDocId == null) {
      final recurrenceDocId = firestore.collection('taskRecurrences').doc().id;
      blueprint.recurrenceDocId = recurrenceDocId;
      final now = DateTime.now().toUtc();
      await db.taskRecurrenceDao.insertPending(
        recurrenceBlueprintToCompanion(
          docId: recurrenceDocId,
          personDocId: personDocId,
          dateAdded: now,
          blueprint: recurrenceBlueprint,
        ),
      );
    } else if (recurrenceBlueprint != null &&
        blueprint.recurrenceDocId != null) {
      // Updating an existing recurrence.
      await db.taskRecurrenceDao.markUpdatePending(
        blueprint.recurrenceDocId!,
        recurrenceBlueprintToDiff(recurrenceBlueprint),
      );

      // Cascade recurrence field changes to upcoming tasks in the chain
      // (those with recurIteration > this task's) so they stay in sync with
      // the updated shared TaskRecurrence (TM-243). Compare new values against
      // the task's effective values (task-level fields with shared-recurrence
      // fallback) to detect actual changes — blueprints are typically
      // fully-populated, so a raw != null check would trigger on every save.
      final recurIteration = task.recurIteration;
      final effectiveRecurWait = task.recurWait ?? task.recurrence?.recurWait;
      final effectiveRecurNumber =
          task.recurNumber ?? task.recurrence?.recurNumber;
      final effectiveRecurUnit =
          task.recurUnit ?? task.recurrence?.recurUnit;
      final recurWaitChanged = recurrenceBlueprint.recurWait != null &&
          recurrenceBlueprint.recurWait != effectiveRecurWait;
      final recurNumberChanged = recurrenceBlueprint.recurNumber != null &&
          recurrenceBlueprint.recurNumber != effectiveRecurNumber;
      final recurUnitChanged = recurrenceBlueprint.recurUnit != null &&
          recurrenceBlueprint.recurUnit != effectiveRecurUnit;
      if (recurIteration != null &&
          (recurWaitChanged || recurNumberChanged || recurUnitChanged)) {
        final cascadeDiff = TasksCompanion(
          recurWait: recurWaitChanged
              ? Value(recurrenceBlueprint.recurWait)
              : const Value.absent(),
          recurNumber: recurNumberChanged
              ? Value(recurrenceBlueprint.recurNumber)
              : const Value.absent(),
          recurUnit: recurUnitChanged
              ? Value(recurrenceBlueprint.recurUnit)
              : const Value.absent(),
        );
        await db.taskDao.cascadeRecurrenceFieldsToUpcoming(
          personDocId: personDocId,
          recurrenceDocId: blueprint.recurrenceDocId!,
          afterIteration: recurIteration,
          diff: cascadeDiff,
        );
      }
    }

    await db.taskDao.markUpdatePending(task.docId, taskBlueprintToDiff(blueprint));
    ref.read(syncServiceProvider).pushPendingWrites(caller: 'UpdateTask').ignore();

    // Fire-and-forget: refresh notifications for the (possibly changed) dates.
    final savedRow = await db.taskDao.getByDocId(task.docId);
    if (savedRow != null) {
      final updatedTask = taskItemFromRow(savedRow);
      ref
          .read(notificationHelperProvider)
          .updateNotificationForTask(updatedTask)
          .then((_) =>
              print('⏱️ [UpdateTask] notification updated (background)'))
          .catchError((e) => print('⚠️ [UpdateTask] notification error: $e'));
    }
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
    final db = ref.read(databaseProvider);
    final legacyRepository = ref.read(legacyTaskRepositoryProvider);

    // Generate the preview (updates blueprint in-place with snoozed dates).
    RecurrenceHelper.generatePreview(blueprint, numUnits, unitSize, dateType);

    // Mirror the anchorDate logic from RecurrenceHelper.updateTaskAndMaybeRecurrenceForSnooze:
    // if this is a scheduled recurrence (!recurWait) and not offCycle, update anchorDate.
    final recurrenceBlueprint = blueprint.recurrenceBlueprint;
    if (recurrenceBlueprint != null) {
      final recurWait = recurrenceBlueprint.recurWait;
      if (recurWait != null && !recurWait && !blueprint.offCycle) {
        recurrenceBlueprint.anchorDate = blueprint.getAnchorDate();
      }
    }

    // Get original anchor date before update (for snooze record).
    final originalValue = taskItem.getAnchorDate();

    // Write task update to Drift.
    await db.taskDao.markUpdatePending(
        taskItem.docId, taskBlueprintToDiff(blueprint));

    // Write recurrence update to Drift if present.
    if (recurrenceBlueprint != null && blueprint.recurrenceDocId != null) {
      await db.taskRecurrenceDao.markUpdatePending(
        blueprint.recurrenceDocId!,
        recurrenceBlueprintToDiff(recurrenceBlueprint),
      );
    }

    // Snooze record goes directly to Firestore (out of Drift scope).
    final newAnchorDate = dateType.dateFieldGetter(blueprint)!;
    final snooze = SnoozeBlueprint(
      taskDocId: taskItem.docId,
      snoozeNumber: numUnits,
      snoozeUnits: unitSize,
      snoozeAnchor: dateType.label,
      previousAnchor: originalValue?.dateValue,
      newAnchor: newAnchorDate,
    );
    await legacyRepository.addSnooze(snooze);

    ref.read(syncServiceProvider).pushPendingWrites(caller: 'SnoozeTask').ignore();

    // Fire-and-forget: snooze shifted dates, so notifications need to move
    // with them.
    final savedRow = await db.taskDao.getByDocId(taskItem.docId);
    if (savedRow != null) {
      final updatedTask = taskItemFromRow(savedRow);
      ref
          .read(notificationHelperProvider)
          .updateNotificationForTask(updatedTask)
          .then((_) =>
              print('⏱️ [SnoozeTask] notification updated (background)'))
          .catchError((e) => print('⚠️ [SnoozeTask] notification error: $e'));
    }
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
