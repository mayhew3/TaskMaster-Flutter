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
import '../providers/sprint_providers.dart';
import '../../shared/presentation/task_item_list.dart';

part 'sprint_task_items_screen.g.dart';

/// Provider for sprint-screen filter settings.
/// TM-368: sprint-screen-local UI state. Defaults are "show everything"
/// (true / true), so re-initializing on consumer remount is the same
/// behavior the user gets on first visit. Auto-dispose is correct.
@riverpod
class ShowCompletedInSprint extends _$ShowCompletedInSprint {
  @override
  bool build() => true; // Default to true for sprint tab

  void toggle() => state = !state;
}

@riverpod
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
///
/// TM-368: family provider keyed by Sprint. keepAlive would pin every
/// sprint a user has ever opened in this session into memory. Auto-dispose
/// releases the watch when the sprint screen unmounts.
@riverpod
Stream<List<TaskItem>> sprintAllTasks(Ref ref, Sprint sprint) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value(const []);

  // Filter retired assignments — a retired SprintAssignment means the task
  // has been removed from this sprint. Stays consistent with
  // `sprintRosterFirestoreProvider` and `sprintCompletionCountsProvider`,
  // both of which apply the same filter.
  final docIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toList(growable: false);
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
      } catch (e) {
        debugPrint(
            '⚠️ [sprintAllTasks] Failed to convert recurrence ${row.docId}: $e');
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

/// Provider for filtered tasks in the active sprint.
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks` (per-sprint instances shouldn't pin in memory).
@riverpod
Future<List<TaskItem>> sprintTaskItems(Ref ref, Sprint sprint) async {
  // Source: all sprint-assigned tasks (incomplete + completed) with recurrences.
  final allSprintTasks = await ref.watch(sprintAllTasksProvider(sprint).future);
  final pendingTasks = ref.watch(pendingTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);
  final showCompleted = ref.watch(showCompletedInSprintProvider);
  final showScheduled = ref.watch(showScheduledInSprintProvider);
  // Sprint-scoped Firestore roster: ensures completed-prior-to-session
  // tasks are visible when "Finished" is toggled on, regardless of whether
  // the global olderCompletedTasksBatches has been triggered. See
  // sprintRosterFirestoreProvider for the rationale.
  final firestoreRoster =
      await ref.watch(sprintRosterFirestoreProvider(sprint).future);

  // Retired assignments are excluded everywhere else (Firestore roster,
  // completion counts, sprintAllTasks); match that here so a removed task
  // doesn't continue to show in the sprint screen.
  final sprintDocIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toSet();

  // Build a docId → task map with pending state overlaid for optimistic UI.
  final taskMap = <String, TaskItem>{};
  for (final task in allSprintTasks) {
    taskMap[task.docId] = pendingTasks[task.docId] ?? task;
  }
  // Include any recentlyCompleted tasks that haven't propagated through the
  // Drift stream yet (write-confirmation race). Overwrite the existing entry
  // when recentlyCompleted carries a completionDate — Drift may still have the
  // pre-completion row, which would incorrectly treat the task as incomplete.
  for (final task in recentlyCompleted) {
    if (sprintDocIds.contains(task.docId)) {
      if (task.completionDate != null) {
        taskMap[task.docId] = task;
      } else {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
  }
  // Include older completed tasks loaded from Firestore that are absent from
  // Drift. Two sources: the global olderCompletedTasksBatches (loaded when
  // the user toggles Show Completed on the Tasks tab) and the sprint-scoped
  // Firestore roster (always fetched). Both are gated on showCompleted —
  // the filter below would drop them otherwise. `putIfAbsent` so Drift's
  // live state always wins over the Firestore snapshot.
  if (showCompleted) {
    for (final task in olderState.loadedTasks) {
      if (sprintDocIds.contains(task.docId)) {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
    for (final task in firestoreRoster) {
      if (sprintDocIds.contains(task.docId)) {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
  }

  // Iterate sprint assignments IN ORDER so positions are stable across
  // completions (TM-339): completing a task doesn't reshuffle the list.
  // Skip retired assignments to match the filter used for `sprintDocIds`.
  final ordered = <TaskItem>[];
  for (final sa in sprint.sprintAssignments) {
    if (sa.retired != null) continue;
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
                FilledButton.icon(
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
