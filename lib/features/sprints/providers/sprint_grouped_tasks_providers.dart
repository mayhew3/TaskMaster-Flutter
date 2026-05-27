import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../../models/task_recurrence.dart';
import '../../shared/logic/task_grouping.dart';
import '../../shared/providers/task_list_view_providers.dart';
import '../../tasks/providers/task_providers.dart';
import 'sprint_providers.dart';

part 'sprint_grouped_tasks_providers.g.dart';

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

/// Pre-filter sprint pool: the membership-resolved task set
/// (assignments + optimistic-pending overlay + recently-completed +
/// older-completed / firestore-roster when completed is visible),
/// retired rows dropped — everything *before* the user's TaskFilters.
/// Split out (TM-382) so the sidebar can compute faceted counts by
/// re-running `applyTaskFilters` over this pool with one filter axis
/// cleared, without duplicating this assembly.
@riverpod
Future<List<TaskItem>> sprintBasePool(Ref ref, Sprint sprint) async {
  // Narrow watch: the base pool's only view dependency is `dueStatus`
  // (the completedVisible gate below). Watching the full TaskListView
  // would force a rebuild on any group/sort/collapse change.
  final dueStatusFilter =
      ref.watch(taskListViewStateProvider(TaskListSurface.sprint)
          .select((v) => v.filters.dueStatus));
  final allSprintTasks =
      await ref.watch(sprintAllTasksProvider(sprint).future);
  final pendingTasks = ref.watch(pendingTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);
  final firestoreRoster =
      await ref.watch(sprintRosterFirestoreProvider(sprint).future);

  final sprintDocIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toSet();

  final taskMap = <String, TaskItem>{};
  for (final task in allSprintTasks) {
    taskMap[task.docId] = pendingTasks[task.docId] ?? task;
  }
  for (final task in recentlyCompleted) {
    if (sprintDocIds.contains(task.docId)) {
      if (task.completionDate != null) {
        taskMap[task.docId] = task;
      } else {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
  }
  final sprintCompletedVisible = dueStatusFilter.isEmpty ||
      dueStatusFilter.contains(DueStatusBucket.completed);
  if (sprintCompletedVisible) {
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

  return taskMap.values.where((t) => t.retired == null).toList();
}

/// Sprint task set (membership-resolved), with the user's TaskFilters
/// applied via the shared pipeline. Ordering is intentionally NOT
/// preserved here — `sprintGroupedTasks` re-buckets + sorts by the
/// surface's group/sort axes (default: due-status grouping, urgency
/// sort) before anything renders, so any order this provider produced
/// would be discarded. (Pre-TM-359 this walked
/// `sprint.sprintAssignments` in order for the TM-339 stability
/// contract; that contract no longer holds at the UI level.)
///
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks`.
@riverpod
Future<List<TaskItem>> sprintTaskItems(Ref ref, Sprint sprint) async {
  // Narrow watch: only `filters` drive this stage; group/sort/collapse
  // changes flow through `sprintGroupedTasks` instead.
  final filters = ref.watch(taskListViewStateProvider(TaskListSurface.sprint)
      .select((v) => v.filters));
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final base = await ref.watch(sprintBasePoolProvider(sprint).future);
  return applyTaskFilters(
    base,
    filters,
    now: DateTime.now(),
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  ).toList();
}

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
/// result is the bucketed view with most-pressing tasks first within
/// each bucket. The user can pick any other group/sort axis via the
/// View Options sheet.
///
/// Lives in a separate providers file (not in the screen file) so the
/// `ViewOptionsSummaryBar` — which renders inside the same screen's
/// AppBar — can read it without forming a Dart import cycle
/// (screen ↔ summary bar would close one otherwise).
@riverpod
Future<List<TaskGroupResult>> sprintGroupedTasks(Ref ref, Sprint sprint) async {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.sprint));
  final tasks = await ref.watch(sprintTaskItemsProvider(sprint).future);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);

  // `sprintTaskItems` already ran the user's TaskFilters via
  // `applyTaskFilters`; running them again here would (a) be redundant
  // work and (b) introduce a subtle time-boundary inconsistency because
  // each pass captures its own `DateTime.now()` — a task right at the
  // urgent/target boundary could land in different buckets across the
  // two passes. Pass a filters-stripped view so `groupAndSortTasks`
  // skips its internal filter step and only buckets + sorts.
  final groupingView = view.rebuild((b) => b
    ..filters.replace(TaskFilters.empty()));
  return groupAndSortTasks(
    tasks: tasks,
    view: groupingView,
    now: DateTime.now(),
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  );
}
