import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/tasks/data/firestore_task_repository.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../../models/task_item.dart';
import '../../helpers/recurrence_helper.dart';

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
    required bool complete,
  }) async {
    TaskItem? nextScheduledTask;

    // Create next recurrence if needed (before completing current task)
    if (task.recurrenceDocId != null &&
        complete &&
        !_hasNextIteration(task, allTasks)) {
      final completionDate = DateTime.now();
      final nextPreview = RecurrenceHelper.createNextIteration(
        task,
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

      await service.completeTask(
        task: task,
        allTasks: allTasks,
        complete: complete,
      );
    });
  }
}
