import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/task_item.dart';
import 'task_providers.dart';
import '../../sprints/providers/sprint_providers.dart';

part 'task_filter_providers.g.dart';

/// Simple state providers for filter toggles
/// Using keepAlive: true to persist state across tab switches
@Riverpod(keepAlive: true)
class ShowCompleted extends _$ShowCompleted {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class ShowScheduled extends _$ShowScheduled {
  @override
  bool build() => false; // Default to false to hide scheduled tasks

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// Filtered tasks based on visibility settings
@riverpod
Future<List<TaskItem>> filteredTasks(FilteredTasksRef ref) async {
  final showCompleted = ref.watch(showCompletedProvider);
  final showScheduled = ref.watch(showScheduledProvider);
  final activeSprint = ref.watch(activeSprintProvider);

  print('📋 filteredTasksProvider: Starting with showCompleted=$showCompleted, showScheduled=$showScheduled');

  // Watch the tasks future
  final tasks = await ref.watch(tasksWithRecurrencesProvider.future);
  print('📋 filteredTasksProvider: Received ${tasks.length} tasks');

  final filtered = tasks.where((task) {
    // Always hide retired tasks
    if (task.retired != null) return false;

    // Hide all tasks in active sprint (they're shown via sprint banner's "Show Tasks")
    if (activeSprint != null) {
      final isInActiveSprint = activeSprint.sprintAssignments
          .any((sa) => sa.taskDocId == task.docId);
      if (isInActiveSprint) {
        return false;
      }
    }

    // Filter completed tasks
    final completedPredicate = task.completionDate == null || showCompleted;

    // Filter scheduled tasks (future startDate)
    final scheduledPredicate = task.startDate == null ||
        task.startDate!.isBefore(DateTime.now()) ||
        showScheduled;

    return completedPredicate && scheduledPredicate;
  }).toList();

  print('📋 filteredTasksProvider: Returning ${filtered.length} filtered tasks');
  return filtered;
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
Future<List<TaskGroup>> groupedTasks(GroupedTasksRef ref) async {
  print('📋 groupedTasksProvider: Starting');

  // Watch the filtered tasks future
  final filtered = await ref.watch(filteredTasksProvider.future);
  print('📋 groupedTasksProvider: Received ${filtered.length} filtered tasks');

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

  final result = groups.entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => TaskGroup(
            name: entry.key,
            displayOrder: displayOrder[entry.key]!,
            tasks: entry.value,
          ))
      .toList()
    ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  print('📋 groupedTasksProvider: Returning ${result.length} task groups');
  return result;
}
