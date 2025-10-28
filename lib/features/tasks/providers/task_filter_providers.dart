import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/task_item.dart';
import 'task_providers.dart';

part 'task_filter_providers.g.dart';

/// Simple state providers for filter toggles
@riverpod
class ShowCompleted extends _$ShowCompleted {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@riverpod
class ShowScheduled extends _$ShowScheduled {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// Filtered tasks based on visibility settings
@riverpod
List<TaskItem> filteredTasks(FilteredTasksRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final showScheduled = ref.watch(showScheduledProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      return tasks.where((task) {
        // Always hide retired tasks
        if (task.retired != null) return false;

        // Filter completed tasks
        final completedPredicate = task.completionDate == null || showCompleted;

        // Filter scheduled tasks (future startDate)
        final scheduledPredicate = task.startDate == null ||
            task.startDate!.isBefore(DateTime.now()) ||
            showScheduled;

        return completedPredicate && scheduledPredicate;
      }).toList();
    },
    orElse: () => [],
  );
}

/// Count of active (non-completed, non-retired) tasks
@riverpod
int activeTaskCount(ActiveTaskCountRef ref) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks
        .where((t) => t.completionDate == null && t.retired == null)
        .length,
    orElse: () => 0,
  );
}

/// Count of completed tasks
@riverpod
int completedTaskCount(CompletedTaskCountRef ref) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.completionDate != null).length,
    orElse: () => 0,
  );
}
