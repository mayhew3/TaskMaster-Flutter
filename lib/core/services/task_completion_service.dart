import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
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
import '../../redux/actions/task_item_actions.dart' show ExecuteSnooze;

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
    TaskItem? nextScheduledTask;

    // Create next recurrence if needed (before completing current task)
    if (task.recurrenceDocId != null &&
        complete &&
        !_hasNextIteration(task, allTasks)) {
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

      // Add the new task
      await _repository.addTask(nextPreview.toBlueprint());

      // We'll get the added task from the stream
    }

    // Update the completed task
    final updatedTask = await _repository.toggleTaskCompletion(
      task,
      complete: complete,
    );

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
TaskCompletionService taskCompletionService(TaskCompletionServiceRef ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskCompletionService(repository);
}

/// Controller for completing tasks
@riverpod
class CompleteTask extends _$CompleteTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task, {required bool complete}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(taskCompletionServiceProvider);
      final allTasks = await ref.read(tasksProvider.future);
      final allRecurrences = await ref.read(taskRecurrencesProvider.future);

      final result = await service.completeTask(
        task: task,
        allTasks: allTasks,
        allRecurrences: allRecurrences,
        complete: complete,
      );

      // Track recently completed tasks (matches Redux pattern)
      final recentlyCompleted = ref.read(recentlyCompletedTasksProvider.notifier);
      if (complete) {
        recentlyCompleted.add(result.completedTask);
      } else {
        recentlyCompleted.remove(result.completedTask);
      }
    });
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
        legacyRepository,
        ExecuteSnooze(
          taskItem: taskItem,
          blueprint: blueprint,
          numUnits: numUnits,
          unitSize: unitSize,
          dateType: dateType,
        ),
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
legacy.TaskRepository legacyTaskRepository(LegacyTaskRepositoryRef ref) {
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
