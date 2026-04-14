import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_recurrence.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../../shared/presentation/filter_button.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../tasks/providers/task_providers.dart';
import '../../shared/presentation/task_item_list.dart';

part 'sprint_task_items_screen.g.dart';

/// Provider for sprint filter settings
/// Using keepAlive to persist state across tab switches
@Riverpod(keepAlive: true)
class ShowCompletedInSprint extends _$ShowCompletedInSprint {
  @override
  bool build() => true; // Default to true for sprint tab

  void toggle() => state = !state;
}

@Riverpod(keepAlive: true)
class ShowScheduledInSprint extends _$ShowScheduledInSprint {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

/// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
/// with recurrences populated. Used by [sprintTaskItems] so that completed
/// tasks appear in the "Completed" section at the bottom of the list
/// (not just recently-completed ones).
///
/// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
/// loading), which broke the sprint screen's Completed section. This provider
/// bypasses that restriction via a direct Drift query scoped to the sprint's
/// task docIds, so the result set is bounded and cheap.
@riverpod
Stream<List<TaskItem>> sprintAllTasks(Ref ref, Sprint sprint) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value(const []);

  final docIds =
      sprint.sprintAssignments.map((sa) => sa.taskDocId).toList(growable: false);
  if (docIds.isEmpty) return Stream.value(const []);

  final tasksStream =
      db.taskDao.watchTasksByDocIds(personDocId, docIds).map((rows) {
    final result = <TaskItem>[];
    for (final row in rows) {
      try {
        result.add(taskItemFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [sprintAllTasks] Failed to convert task ${row.docId}: $e');
      }
    }
    return result;
  });

  final recurrencesStream =
      db.taskRecurrenceDao.watchActive(personDocId).map((rows) {
    final result = <TaskRecurrence>[];
    for (final row in rows) {
      try {
        result.add(taskRecurrenceFromRow(row));
      } catch (_) {
        // ignore conversion failures; recurrence will just be null-joined
      }
    }
    return result;
  });

  return Rx.combineLatest2<List<TaskItem>, List<TaskRecurrence>,
      List<TaskItem>>(
    tasksStream,
    recurrencesStream,
    (tasks, recurrences) {
      final recurrenceMap = {for (final r in recurrences) r.docId: r};
      return tasks.map((task) {
        if (task.recurrenceDocId != null) {
          final recurrence = recurrenceMap[task.recurrenceDocId];
          if (recurrence != null) {
            return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
          }
        }
        return task;
      }).toList();
    },
  );
}

/// Provider for filtered tasks in the active sprint
@riverpod
Future<List<TaskItem>> sprintTaskItems(Ref ref, Sprint sprint) async {
  // Source: all sprint-assigned tasks (incomplete + completed) with recurrences.
  final allSprintTasks = await ref.watch(sprintAllTasksProvider(sprint).future);
  final pendingTasks = ref.watch(pendingTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final showCompleted = ref.watch(showCompletedInSprintProvider);
  final showScheduled = ref.watch(showScheduledInSprintProvider);

  // Build a docId → task map with pending state overlaid for optimistic UI.
  final taskMap = <String, TaskItem>{};
  for (final task in allSprintTasks) {
    taskMap[task.docId] = pendingTasks[task.docId] ?? task;
  }
  // Include any recentlyCompleted tasks that haven't propagated through the
  // Drift stream yet (write-confirmation race).
  for (final task in recentlyCompleted) {
    final inThisSprint =
        sprint.sprintAssignments.any((sa) => sa.taskDocId == task.docId);
    if (inThisSprint) {
      taskMap.putIfAbsent(task.docId, () => task);
    }
  }

  // Iterate sprint assignments IN ORDER so positions are stable across
  // completions (TM-339): completing a task doesn't reshuffle the list.
  final ordered = <TaskItem>[];
  for (final sa in sprint.sprintAssignments) {
    final task = taskMap[sa.taskDocId];
    if (task != null) ordered.add(task);
  }

  // Apply filters
  return ordered.where((task) {
    if (task.retired != null) return false;

    // Completed tasks: show when showCompleted is true OR if recently completed.
    // Bypasses the scheduled filter so completed tasks with future start dates still appear.
    if (task.completionDate != null) {
      final isRecentlyCompleted =
          recentlyCompleted.any((t) => t.docId == task.docId);
      return showCompleted || isRecentlyCompleted;
    }

    // Non-completed tasks: check scheduled filter
    final scheduledPredicate = task.startDate == null ||
        task.startDate!.isBefore(DateTime.now()) ||
        showScheduled;
    return scheduledPredicate;
  }).toList();
}

class SprintTaskItemsScreen extends ConsumerWidget {
  final Sprint sprint;

  const SprintTaskItemsScreen({
    super.key,
    required this.sprint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskItemsAsync = ref.watch(sprintTaskItemsProvider(sprint));
    final showCompleted = ref.watch(showCompletedInSprintProvider);
    final showScheduled = ref.watch(showScheduledInSprintProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint Tasks'),
        actions: <Widget>[
          const ConnectionStatusIndicator(),
          FilterButton(
            scheduledGetter: () => showScheduled,
            completedGetter: () => showCompleted,
            toggleScheduled: () =>
                ref.read(showScheduledInSprintProvider.notifier).toggle(),
            toggleCompleted: () =>
                ref.read(showCompletedInSprintProvider.notifier).toggle(),
          ),
          const RefreshButton(),
        ],
      ),
      body: taskItemsAsync.when(
        data: (taskItems) => TaskItemList(
          taskItems: BuiltList<TaskItem>(taskItems),
          sprintMode: true,
        ),
        loading: () {
          // Preserve previous data during loading to prevent list disappearing
          if (taskItemsAsync.hasValue) {
            return TaskItemList(
              taskItems: BuiltList<TaskItem>(taskItemsAsync.value!),
              sprintMode: true,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          print('❌ Error loading sprint tasks: $err\n$stack');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load sprint tasks. Please try again.'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(sprintTaskItemsProvider(sprint)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
