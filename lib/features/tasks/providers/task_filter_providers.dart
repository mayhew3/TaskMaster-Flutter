import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/area.dart';
import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../shared/logic/task_grouping.dart';
import '../../shared/providers/task_list_view_providers.dart';
import '../../areas/providers/area_providers.dart';
import '../../sprints/providers/sprint_providers.dart';
import 'task_providers.dart';

part 'task_filter_providers.g.dart';

// ─── Legacy filter facades (TM-359) ──────────────────────────────────────
//
// TM-359 unified all per-axis filter state into
// `taskListViewStateProvider(TaskListSurface.tasks)`. These three legacy
// providers stay as thin facades that read/write through the new state
// so the rest of the codebase (sprint_providers, navigation_provider,
// integration tests) can be migrated commit-by-commit without one giant
// disruptive change. They will be deleted in commit 9 once no consumers
// remain.

@Riverpod(keepAlive: true)
class ShowCompleted extends _$ShowCompleted {
  @override
  bool build() {
    final value = ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
        .select((v) => v.filters.showCompleted));
    // Side effect: lazily prefetch the first older-completed-tasks batch
    // when the value transitions off→on, regardless of *which* UI path
    // (legacy popup vs new ViewOptionsSheet) triggered the change.
    ref.listen<TaskListView>(
      taskListViewStateProvider(TaskListSurface.tasks),
      (prev, next) {
        final wasOn = prev?.filters.showCompleted ?? false;
        final isOn = next.filters.showCompleted;
        if (!wasOn && isOn) {
          ref
              .read(olderCompletedTasksBatchesProvider.notifier)
              .loadNextBatch();
        }
      },
    );
    return value;
  }

  void toggle() => set(!state);

  void set(bool value) {
    if (state == value) return;
    final viewNotifier = ref
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
    final current =
        ref.read(taskListViewStateProvider(TaskListSurface.tasks));
    viewNotifier.setFilters(
        current.filters.rebuild((b) => b..showCompleted = value));
  }
}

@Riverpod(keepAlive: true)
class ShowScheduled extends _$ShowScheduled {
  @override
  bool build() {
    return ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
        .select((v) => v.filters.showScheduled));
  }

  void toggle() => set(!state);

  void set(bool value) {
    if (state == value) return;
    final viewNotifier = ref
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
    final current =
        ref.read(taskListViewStateProvider(TaskListSurface.tasks));
    viewNotifier.setFilters(
        current.filters.rebuild((b) => b..showScheduled = value));
  }
}

@Riverpod(keepAlive: true)
class SearchQuery extends _$SearchQuery {
  @override
  String build() {
    return ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
        .select((v) => v.filters.search));
  }

  void set(String value) {
    if (state == value) return;
    ref
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setSearch(value);
  }

  void clear() => set('');
}

// ─── Derived providers (rewritten on top of `groupAndSortTasks`) ─────────

/// Tasks visible on the Tasks tab — surface-specific pre-filtering
/// (hide-family-shared, hide-active-sprint, retired removal) PLUS the
/// user's TaskFilters via the pipeline.
@Riverpod(keepAlive: true)
Future<List<TaskItem>> filteredTasks(Ref ref) async {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.tasks));
  final activeSprint = ref.watch(activeSprintProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);

  // Base query (incomplete) plus optimistic-pending overlay.
  final tasks = await ref.watch(tasksWithPendingStateProvider.future);

  final taskDocIds = tasks.map((t) => t.docId).toSet();
  final allTasks = <TaskItem>[...tasks];

  // TM-323: merge recently-completed tasks (the base query no longer
  // returns them once their `completionDate` is set, but they should stay
  // visible at the captured original index until the list refreshes).
  if (recentlyCompleted.isNotEmpty) {
    final indices = ref.watch(recentlyCompletedIndicesProvider);
    final uniqueRecent = recentlyCompleted
        .where((t) => !taskDocIds.contains(t.docId))
        .toList()
      ..sort((a, b) {
        final ai = indices[a.docId] ?? allTasks.length;
        final bi = indices[b.docId] ?? allTasks.length;
        final cmp = ai.compareTo(bi);
        return cmp != 0 ? cmp : a.docId.compareTo(b.docId);
      });
    for (final task in uniqueRecent) {
      final captured = indices[task.docId];
      final insertAt = captured == null
          ? allTasks.length
          : (captured < 0
              ? 0
              : (captured > allTasks.length ? allTasks.length : captured));
      allTasks.insert(insertAt, task);
      taskDocIds.add(task.docId);
    }
  }

  // Merge progressively-loaded older completed tasks when showCompleted is on.
  if (view.filters.showCompleted) {
    final olderState = ref.watch(olderCompletedTasksBatchesProvider);
    if (olderState.loadedTasks.isNotEmpty) {
      final uniqueOlder = olderState.loadedTasks
          .where((t) => !taskDocIds.contains(t.docId))
          .toList();
      allTasks.addAll(uniqueOlder);
    }
  }

  final surfaceFiltered = allTasks.where((task) {
    if (task.retired != null) return false;
    // Tasks tab is the personal queue — family-shared rows live on the
    // Family tab only (TM-335).
    if (task.familyDocId != null) return false;
    // Active-sprint tasks are surfaced via the sprint banner instead.
    if (activeSprint != null &&
        activeSprint.sprintAssignments
            .any((sa) => sa.taskDocId == task.docId)) {
      return false;
    }
    return true;
  });
  // Apply the user-selected TaskFilters via the shared pipeline. This is
  // the canonical filter step that mirrors the pre-TM-359 inline logic
  // (search / showCompleted / showScheduled / recurrence / age / etc.)
  // plus the recently-completed bypass.
  return applyTaskFilters(
    surfaceFiltered,
    view.filters,
    now: DateTime.now(),
    recentlyCompletedDocIds: recentlyCompleted.map((t) => t.docId).toSet(),
  ).toList();
}

/// Count of active (non-completed, non-retired) tasks.
/// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
/// recompute when a consumer reattaches.
@riverpod
int activeTaskCount(Ref ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.maybeWhen(
    data: (tasks) => tasks
        .where((t) => t.completionDate == null && t.retired == null)
        .length,
    orElse: () => 0,
  );
}

/// Count of completed (non-skipped, non-retired) tasks. See pre-TM-359
/// comment for the Firestore-aggregation rationale.
@riverpod
Future<int> completedTaskCount(Ref ref) async {
  final firestore = ref.watch(firestoreProvider);
  final db = ref.watch(databaseProvider);
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return 0;

  final result = await firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .where('completionDate', isNull: false)
      .count()
      .get();
  final total = result.count ?? 0;
  final skipped = await db.taskDao.skippedTaskCount(personDocId);
  return (total - skipped).clamp(0, total);
}

/// TM-359: grouped + sorted Tasks-tab tasks. Wraps `groupAndSortTasks`
/// with the per-surface TaskListView state.
@Riverpod(keepAlive: true)
Future<List<TaskGroupResult>> groupedTasks(Ref ref) async {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.tasks));
  final filtered = await ref.watch(filteredTasksProvider.future);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  // Read `areasProvider` only when the area axis actually needs it.
  // `areasProvider` streams from Drift; unconditional reads force a
  // database open even on tests that have overridden every other input
  // but not the areas stream.
  final List<Area> areas = view.groupAxis == TaskGroupAxis.area
      ? (ref.watch(areasProvider).value ?? const <Area>[])
      : const <Area>[];

  return groupAndSortTasks(
    tasks: filtered,
    view: view,
    now: DateTime.now(),
    areas: areas,
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  );
}

/// Legacy TaskGroup shape preserved as a thin wrapper around
/// [TaskGroupResult] so the Family tab (which still references this type
/// in commit 5) keeps compiling. Removed in commit 6 when Family
/// migrates to TaskGroupResult directly.
@Deprecated('Use TaskGroupResult from features/shared/logic/task_grouping.dart')
class TaskGroup {
  final String name;
  final int displayOrder;
  final List<TaskItem> tasks;
  const TaskGroup({
    required this.name,
    required this.displayOrder,
    required this.tasks,
  });
}
