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

/// Task grouping for display (Past Due, Urgent, Target, Scheduled, Tasks, Completed)
class TaskGroup {
  final String name;
  final int displayOrder;
  final List<TaskItem> tasks;

  TaskGroup({
    required this.name,
    required this.displayOrder,
    required this.tasks,
  });
}

/// Grouped and sorted tasks for the task list
@riverpod
List<TaskGroup> groupedTasks(GroupedTasksRef ref) {
  final filtered = ref.watch(filteredTasksProvider);

  final groups = <String, List<TaskItem>>{
    'Past Due': [],
    'Urgent': [],
    'Target': [],
    'Tasks': [],
    'Scheduled': [],
    'Completed': [],
  };

  // Categorize tasks
  for (final task in filtered) {
    if (task.completionDate != null) {
      groups['Completed']!.add(task);
    } else if (task.isPastDue()) {
      groups['Past Due']!.add(task);
    } else if (task.isUrgent()) {
      groups['Urgent']!.add(task);
    } else if (task.isTarget()) {
      groups['Target']!.add(task);
    } else if (task.isScheduled()) {
      groups['Scheduled']!.add(task);
    } else {
      groups['Tasks']!.add(task);
    }
  }

  // Sort tasks within groups
  groups['Scheduled']!.sort((a, b) => a.startDate!.compareTo(b.startDate!));
  groups['Completed']!.sort((a, b) => b.completionDate!.compareTo(a.completionDate!));

  // Create task groups with display order
  final displayOrder = {
    'Past Due': 1,
    'Urgent': 2,
    'Target': 3,
    'Tasks': 4,
    'Scheduled': 5,
    'Completed': 6,
  };

  return groups.entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => TaskGroup(
            name: entry.key,
            displayOrder: displayOrder[entry.key]!,
            tasks: entry.value,
          ))
      .toList()
    ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
}
