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

/// Returns whether `bucket` is currently visible on `surface`. Under the
/// new model, "visible" = either `dueStatus` is empty (= no filter) OR the
/// bucket is in the whitelist set.
bool _bucketIsVisible(
  TaskListView view,
  DueStatusBucket bucket,
) {
  final set = view.filters.dueStatus;
  return set.isEmpty || set.contains(bucket);
}

@Riverpod(keepAlive: true)
class ShowCompleted extends _$ShowCompleted {
  @override
  bool build() {
    final value = ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
        .select((v) => _bucketIsVisible(v, DueStatusBucket.completed)));
    // Side effect: lazily prefetch the first older-completed-tasks batch
    // when the value transitions off→on, regardless of *which* UI path
    // (legacy popup vs new ViewOptionsSheet) triggered the change.
    //
    // `fireImmediately: true` covers the startup case: if the persisted
    // Tasks-surface view already has the Completed bucket visible when
    // `build()` first runs (e.g., user toggled it on in a prior session),
    // the listener won't otherwise fire and `loadNextBatch()` would never
    // run until the user toggled off then on again. The wasOn=false
    // fallback for `prev == null` ensures the first synthetic fire is
    // treated as the off→on transition we want.
    ref.listen<TaskListView>(
      taskListViewStateProvider(TaskListSurface.tasks),
      (prev, next) {
        final wasOn = prev == null
            ? false
            : _bucketIsVisible(prev, DueStatusBucket.completed);
        final isOn = _bucketIsVisible(next, DueStatusBucket.completed);
        if (!wasOn && isOn) {
          ref
              .read(olderCompletedTasksBatchesProvider.notifier)
              .loadNextBatch();
        }
      },
      fireImmediately: true,
    );
    return value;
  }

  void toggle() => set(!state);

  void set(bool value) {
    if (state == value) return;
    _toggleBucket(ref, DueStatusBucket.completed, visible: value);
  }
}

@Riverpod(keepAlive: true)
class ShowScheduled extends _$ShowScheduled {
  @override
  bool build() {
    return ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
        .select((v) => _bucketIsVisible(v, DueStatusBucket.scheduled)));
  }

  void toggle() => set(!state);

  void set(bool value) {
    if (state == value) return;
    _toggleBucket(ref, DueStatusBucket.scheduled, visible: value);
  }
}

/// Add or remove [bucket] from the Tasks-tab `dueStatus` whitelist.
///
/// The translation accounts for the empty-set sentinel: when the whitelist
/// is empty (= "no filter, show all"), toggling a bucket *off* requires
/// materializing the catalog-minus-this-bucket; toggling a bucket *on*
/// when already implicitly visible is a no-op.
///
/// Whenever a write would land on "every bucket selected", normalize back
/// to the empty set — that's the canonical "show all" representation, and
/// `TaskListView.isDefaultForSurface` / `ViewOptionsButton._hasNonDefaults`
/// rely on it. Without this normalization, e.g. on Sprint (default
/// `dueStatus = {}`), toggling Completed off then back on would leave the
/// view at `{all 6 buckets}` and the green non-default badge would stay
/// lit even though the effective filter is unchanged.
void _toggleBucket(Ref ref, DueStatusBucket bucket, {required bool visible}) {
  final viewNotifier =
      ref.read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
  final current = ref.read(taskListViewStateProvider(TaskListSurface.tasks));
  final set = current.filters.dueStatus;
  Set<DueStatusBucket>? next;
  if (visible) {
    if (set.isEmpty || set.contains(bucket)) return;
    next = {...set, bucket};
  } else {
    if (set.isEmpty) {
      // Materialize: hide this one bucket, keep everything else visible.
      next = DueStatusBucket.values.where((b) => b != bucket).toSet();
    } else if (set.contains(bucket)) {
      next = {...set}..remove(bucket);
    }
  }
  if (next == null) return;
  // Normalize: "all buckets selected" collapses to empty = canonical
  // "show all" sentinel.
  if (next.length == DueStatusBucket.values.length) next = <DueStatusBucket>{};
  viewNotifier.setFilters(
      current.filters.rebuild((b) => b..dueStatus.replace(next!)));
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

  // Merge progressively-loaded older completed tasks when the Completed
  // bucket is visible (empty `dueStatus` = no filter = show all = include
  // completed; or explicit whitelist contains the completed bucket).
  final completedVisible = view.filters.dueStatus.isEmpty ||
      view.filters.dueStatus.contains(DueStatusBucket.completed);
  if (completedVisible) {
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

