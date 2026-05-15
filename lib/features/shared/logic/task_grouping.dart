import 'package:meta/meta.dart';

import '../../../models/area.dart';
import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';

/// One bucket in a grouped task list. The pipeline always returns these in
/// `displayOrder`-ascending order with empty buckets stripped.
@immutable
class TaskGroupResult {
  /// Stable key used for persisting collapse/expand state across axis
  /// flips (e.g. `due:urgent`, `area:Work`, `priority:3`).
  final String key;

  /// Header text rendered in the UI. May be the empty string when the
  /// group axis is `none` — the renderer hides empty-name headers.
  final String displayName;

  /// 1-based ordering across buckets in this group axis.
  final int displayOrder;

  final List<TaskItem> tasks;

  const TaskGroupResult({
    required this.key,
    required this.displayName,
    required this.displayOrder,
    required this.tasks,
  });
}

/// Apply [view]'s filters → group axis → in-group sort to [tasks].
///
/// Pure function. `now` is required (rather than reading the clock
/// internally) so tests are deterministic.
///
/// Surface-specific filters (hide-family-shared on the Tasks tab,
/// hide-active-sprint, sprint-membership scoping, etc.) are the
/// caller's responsibility — feed the already-pre-filtered tasks in.
///
/// `recentlyCompletedDocIds` is consulted when grouping by `dueStatus`
/// to preserve the TM-323 contract: a just-completed task stays in its
/// pre-completion bucket on the Tasks/Family tabs so it doesn't visibly
/// jump to "Completed" while the user is still looking at it.
///
/// `areas` orders Area buckets by `Area.sortOrder`. Pass an empty list to
/// fall back to alphabetical.
List<TaskGroupResult> groupAndSortTasks({
  required Iterable<TaskItem> tasks,
  required TaskListView view,
  required DateTime now,
  List<Area> areas = const [],
  Set<String> recentlyCompletedDocIds = const {},
}) {
  final filtered =
      _applyFilters(tasks, view.filters, now, recentlyCompletedDocIds);

  switch (view.groupAxis) {
    case TaskGroupAxis.dueStatus:
      return _dueStatusBuckets(filtered, view, now, recentlyCompletedDocIds);
    case TaskGroupAxis.none:
      return _noBuckets(filtered, view, now);
    case TaskGroupAxis.priority:
      return _priorityBuckets(filtered, view, now);
    case TaskGroupAxis.area:
      return _areaBuckets(filtered, view, areas, now);
    case TaskGroupAxis.points:
      return _pointsBuckets(filtered, view, now);
    case TaskGroupAxis.duration:
      return _durationBuckets(filtered, view, now);
  }
}

/// Public entry point for the filter step alone (without grouping/sorting).
/// Used by per-surface "filteredTasks" providers that need a flat list of
/// matching tasks but don't want to pay for grouping when the grouping
/// pass will be done elsewhere.
Iterable<TaskItem> applyTaskFilters(
  Iterable<TaskItem> tasks,
  TaskFilters filters, {
  required DateTime now,
  Set<String> recentlyCompletedDocIds = const {},
}) =>
    _applyFilters(tasks, filters, now, recentlyCompletedDocIds);

// ── Filter step ─────────────────────────────────────────────────────────

Iterable<TaskItem> _applyFilters(
  Iterable<TaskItem> tasks,
  TaskFilters f,
  DateTime now,
  Set<String> recentlyCompletedDocIds,
) {
  return tasks.where((task) {
    // Area multi-select. Empty set = "any area"; matched by name with a
    // null-area treated as the empty string so the "(none)" filter (which
    // the UI represents as an empty string) still works.
    if (f.areas.isNotEmpty && !f.areas.contains(task.area ?? '')) return false;

    // Context multi-select. Task qualifies if any of its contexts is in
    // the selected set (OR semantics).
    if (f.contexts.isNotEmpty &&
        !task.contexts.any((c) => f.contexts.contains(c.name))) {
      return false;
    }

    // Due-status whitelist (empty = no filter / show all). When a task is
    // in the recently-completed set we check against the bucket it had
    // *before* completion (TM-323): a just-completed urgent task remains
    // visible under `dueStatus = {pastDue, urgent, target, normal}`.
    if (f.dueStatus.isNotEmpty) {
      final actualBucket = _dueStatusBucketOf(task, now);
      final isRecentlyCompleted =
          recentlyCompletedDocIds.contains(task.docId);
      final effectiveBucket =
          (isRecentlyCompleted && actualBucket == DueStatusBucket.completed)
              ? _dueStatusBucketIgnoringCompletion(task, now)
              : actualBucket;
      if (!f.dueStatus.contains(effectiveBucket)) return false;
    }

    // Priority bounds. Null priority always excluded when ANY bound is set.
    final p = task.priority;
    if (f.minPriority != null && (p == null || p < f.minPriority!)) return false;
    if (f.maxPriority != null && (p == null || p > f.maxPriority!)) return false;

    // Points bounds. Same null-treatment as priority.
    final pts = task.gamePoints;
    if (f.minPoints != null && (pts == null || pts < f.minPoints!)) return false;
    if (f.maxPoints != null && (pts == null || pts > f.maxPoints!)) return false;

    // Duration bounds (minutes). Same null-treatment as priority/points.
    final dur = task.duration;
    if (f.minDuration != null && (dur == null || dur < f.minDuration!)) {
      return false;
    }
    if (f.maxDuration != null && (dur == null || dur > f.maxDuration!)) {
      return false;
    }

    if (!_matchesRecurrence(task, f.recurrence)) return false;

    // Max age (days since dateAdded).
    if (f.maxAgeDays != null) {
      final ageDays = now.difference(task.dateAdded).inDays;
      if (ageDays > f.maxAgeDays!) return false;
    }

    // Case-insensitive search over name.
    if (f.search.isNotEmpty) {
      if (!task.name.toLowerCase().contains(f.search.toLowerCase())) {
        return false;
      }
    }

    return true;
  });
}

bool _matchesRecurrence(TaskItem t, RecurrenceFilter mode) {
  switch (mode) {
    case RecurrenceFilter.all:
      return true;
    case RecurrenceFilter.scheduled:
      return t.recurrenceDocId != null && t.completionDate == null;
    case RecurrenceFilter.completed:
      return t.recurrenceDocId != null && t.completionDate != null;
    case RecurrenceFilter.none:
      return t.recurrenceDocId == null;
  }
}

DueStatusBucket _dueStatusBucketOf(TaskItem t, DateTime now) {
  if (t.completionDate != null) return DueStatusBucket.completed;
  return _dueStatusBucketIgnoringCompletion(t, now);
}

DueStatusBucket _dueStatusBucketIgnoringCompletion(TaskItem t, DateTime now) {
  if (t.dueDate != null && t.dueDate!.isBefore(now)) {
    return DueStatusBucket.pastDue;
  }
  if (t.urgentDate != null && t.urgentDate!.isBefore(now)) {
    return DueStatusBucket.urgent;
  }
  if (t.targetDate != null && t.targetDate!.isBefore(now)) {
    return DueStatusBucket.target;
  }
  if (t.startDate != null && t.startDate!.isAfter(now)) {
    return DueStatusBucket.scheduled;
  }
  return DueStatusBucket.normal;
}

// ── Bucket steps (one per TaskGroupAxis) ────────────────────────────────

const _kDueStatusDisplayName = <DueStatusBucket, String>{
  DueStatusBucket.pastDue: 'Past Due',
  DueStatusBucket.urgent: 'Urgent',
  DueStatusBucket.target: 'Target',
  DueStatusBucket.normal: 'Tasks',
  DueStatusBucket.scheduled: 'Scheduled',
  DueStatusBucket.completed: 'Completed',
};

const _kDueStatusOrder = <DueStatusBucket, int>{
  DueStatusBucket.pastDue: 1,
  DueStatusBucket.urgent: 2,
  DueStatusBucket.target: 3,
  DueStatusBucket.normal: 4,
  DueStatusBucket.scheduled: 5,
  DueStatusBucket.completed: 6,
};

List<TaskGroupResult> _dueStatusBuckets(
  Iterable<TaskItem> tasks,
  TaskListView view,
  DateTime now,
  Set<String> recentlyCompletedDocIds,
) {
  final buckets = <DueStatusBucket, List<TaskItem>>{};
  for (final t in tasks) {
    final bucket = (t.completionDate != null &&
            recentlyCompletedDocIds.contains(t.docId))
        ? _dueStatusBucketIgnoringCompletion(t, now)
        : _dueStatusBucketOf(t, now);
    buckets.putIfAbsent(bucket, () => []).add(t);
  }
  return _kDueStatusOrder.entries
      .where((e) => (buckets[e.key]?.isNotEmpty ?? false))
      .map((e) => TaskGroupResult(
            key: 'due:${e.key.name}',
            displayName: _kDueStatusDisplayName[e.key]!,
            displayOrder: e.value,
            tasks: _sortBucket(buckets[e.key]!, view, e.key, now),
          ))
      .toList();
}

List<TaskGroupResult> _noBuckets(
    Iterable<TaskItem> tasks, TaskListView view, DateTime now) {
  final list = tasks.toList();
  return [
    TaskGroupResult(
      key: 'all',
      displayName: '',
      displayOrder: 1,
      tasks: _sortBucket(list, view, null, now),
    ),
  ];
}

List<TaskGroupResult> _priorityBuckets(
    Iterable<TaskItem> tasks, TaskListView view, DateTime now) {
  final buckets = <int?, List<TaskItem>>{};
  for (final t in tasks) {
    buckets.putIfAbsent(t.displayPriority, () => []).add(t);
  }
  final result = <TaskGroupResult>[];
  // Ascending 1..5 first, then "No priority" at the end.
  for (var p = 1; p <= 5; p++) {
    final list = buckets[p];
    if (list == null || list.isEmpty) continue;
    result.add(TaskGroupResult(
      key: 'priority:$p',
      displayName: 'Priority $p',
      displayOrder: p,
      tasks: _sortBucket(list, view, null, now),
    ));
  }
  final noPriority = buckets[null];
  if (noPriority != null && noPriority.isNotEmpty) {
    result.add(TaskGroupResult(
      key: 'priority:none',
      displayName: 'No priority',
      displayOrder: 6,
      tasks: _sortBucket(noPriority, view, null, now),
    ));
  }
  return result;
}

List<TaskGroupResult> _areaBuckets(Iterable<TaskItem> tasks, TaskListView view,
    List<Area> areas, DateTime now) {
  final buckets = <String?, List<TaskItem>>{};
  for (final t in tasks) {
    buckets.putIfAbsent(t.area, () => []).add(t);
  }
  // Sort order: areas registered in `areas` by their sortOrder, then any
  // ghost area names (tasks tagged with a since-deleted area) alphabetically,
  // then `null` last.
  final knownByName = {for (final a in areas) a.name: a};
  final present = buckets.keys.whereType<String>().toList();
  present.sort((a, b) {
    final aa = knownByName[a];
    final bb = knownByName[b];
    if (aa != null && bb != null) {
      final cmp = aa.sortOrder.compareTo(bb.sortOrder);
      if (cmp != 0) return cmp;
      return a.compareTo(b);
    }
    if (aa != null) return -1;
    if (bb != null) return 1;
    return a.compareTo(b);
  });
  var order = 1;
  final result = <TaskGroupResult>[];
  for (final name in present) {
    result.add(TaskGroupResult(
      key: 'area:$name',
      displayName: name,
      displayOrder: order++,
      tasks: _sortBucket(buckets[name]!, view, null, now),
    ));
  }
  final noArea = buckets[null];
  if (noArea != null && noArea.isNotEmpty) {
    result.add(TaskGroupResult(
      key: 'area:none',
      displayName: 'No area',
      displayOrder: order,
      tasks: _sortBucket(noArea, view, null, now),
    ));
  }
  return result;
}

/// PointsPicker-aligned Fibonacci buckets — 1, 2, 3, 5, 8, 13 + Other +
/// "No points". Tasks with non-Fibonacci `gamePoints` fall into Other.
const _kPointsBuckets = [1, 2, 3, 5, 8, 13];

List<TaskGroupResult> _pointsBuckets(
    Iterable<TaskItem> tasks, TaskListView view, DateTime now) {
  final buckets = <int?, List<TaskItem>>{};
  for (final t in tasks) {
    final pts = t.gamePoints;
    if (pts == null) {
      buckets.putIfAbsent(null, () => []).add(t);
    } else if (_kPointsBuckets.contains(pts)) {
      buckets.putIfAbsent(pts, () => []).add(t);
    } else {
      // Sentinel `-1` = "Other"; not -presentable to the user but
      // distinguishable from `null` (No points).
      buckets.putIfAbsent(-1, () => []).add(t);
    }
  }
  final result = <TaskGroupResult>[];
  var order = 1;
  for (final pts in _kPointsBuckets) {
    final list = buckets[pts];
    if (list == null || list.isEmpty) continue;
    result.add(TaskGroupResult(
      key: 'points:$pts',
      displayName: '$pts pts',
      displayOrder: order++,
      tasks: _sortBucket(list, view, null, now),
    ));
  }
  final other = buckets[-1];
  if (other != null && other.isNotEmpty) {
    result.add(TaskGroupResult(
      key: 'points:other',
      displayName: 'Other points',
      displayOrder: order++,
      tasks: _sortBucket(other, view, null, now),
    ));
  }
  final none = buckets[null];
  if (none != null && none.isNotEmpty) {
    result.add(TaskGroupResult(
      key: 'points:none',
      displayName: 'No points',
      displayOrder: order,
      tasks: _sortBucket(none, view, null, now),
    ));
  }
  return result;
}

/// LengthBucketPicker-aligned minute buckets — keep in sync with that
/// widget. Tasks fall into the closest bucket; non-bucketed durations
/// (out of range) get the closest endpoint.
const _kDurationBucketsMin = [5, 15, 30, 60, 120, 240, 480, 1440];
const _kDurationBucketLabels = [
  '5m',
  '15m',
  '30m',
  '1h',
  '2h',
  '4h',
  '8h',
  '1d',
];

List<TaskGroupResult> _durationBuckets(
    Iterable<TaskItem> tasks, TaskListView view, DateTime now) {
  final buckets = <int?, List<TaskItem>>{};
  for (final t in tasks) {
    final d = t.duration;
    if (d == null) {
      buckets.putIfAbsent(null, () => []).add(t);
    } else {
      buckets.putIfAbsent(_closestDurationBucket(d), () => []).add(t);
    }
  }
  final result = <TaskGroupResult>[];
  var order = 1;
  for (var i = 0; i < _kDurationBucketsMin.length; i++) {
    final list = buckets[i];
    if (list == null || list.isEmpty) continue;
    result.add(TaskGroupResult(
      key: 'duration:${_kDurationBucketsMin[i]}',
      displayName: _kDurationBucketLabels[i],
      displayOrder: order++,
      tasks: _sortBucket(list, view, null, now),
    ));
  }
  final none = buckets[null];
  if (none != null && none.isNotEmpty) {
    result.add(TaskGroupResult(
      key: 'duration:none',
      displayName: 'No duration',
      displayOrder: order,
      tasks: _sortBucket(none, view, null, now),
    ));
  }
  return result;
}

/// Index into `_kDurationBucketsMin` of the bucket whose value is closest
/// to [minutes]. Mirrors LengthBucketPicker.closestBucketIndex behavior.
int _closestDurationBucket(int minutes) {
  var bestIdx = 0;
  var bestDist = (minutes - _kDurationBucketsMin[0]).abs();
  for (var i = 1; i < _kDurationBucketsMin.length; i++) {
    final dist = (minutes - _kDurationBucketsMin[i]).abs();
    if (dist < bestDist) {
      bestDist = dist;
      bestIdx = i;
    }
  }
  return bestIdx;
}

// ── Sort step (within bucket) ───────────────────────────────────────────

List<TaskItem> _sortBucket(
  List<TaskItem> tasks,
  TaskListView view,
  DueStatusBucket? bucket,
  DateTime now,
) {
  // Urgency: bucket-aware. Each task's bucket determines which dates
  // act as the primary/secondary sort key. The global ascending /
  // descending toggle flips the entire ordering (ascending = most
  // urgent first).
  if (view.sortAxis == TaskSortAxis.urgency) {
    final dir = view.sortDirection == SortDirection.ascending ? 1 : -1;
    return [...tasks]..sort((a, b) => _cmpUrgency(a, b, now) * dir);
  }

  final keyOf = _sortKeyFor(view.sortAxis);
  final dir = view.sortDirection == SortDirection.ascending ? 1 : -1;
  final result = [...tasks];
  result.sort((a, b) {
    final ka = keyOf(a);
    final kb = keyOf(b);
    if (ka == null && kb == null) {
      // Tiebreak: dateAdded (in current direction).
      return _cmpDate(a.dateAdded, b.dateAdded, dir);
    }
    if (ka == null) return 1; // nulls always last regardless of direction
    if (kb == null) return -1;
    final cmp = Comparable.compare(ka, kb);
    if (cmp != 0) return cmp * dir;
    // Tiebreak by dateAdded (current direction) — keeps the ordering
    // stable across rebuilds even when the primary key collides.
    return _cmpDate(a.dateAdded, b.dateAdded, dir);
  });
  return result;
}

Comparable? Function(TaskItem) _sortKeyFor(TaskSortAxis axis) {
  switch (axis) {
    case TaskSortAxis.dateAdded:
      return (t) => t.dateAdded;
    case TaskSortAxis.points:
      return (t) => t.gamePoints;
    case TaskSortAxis.area:
      return (t) => t.area;
    case TaskSortAxis.duration:
      return (t) => t.duration;
    case TaskSortAxis.priority:
      return (t) => t.displayPriority;
    case TaskSortAxis.efficiency:
      return (t) {
        final pts = t.gamePoints;
        final d = t.duration;
        if (pts == null || d == null || d == 0) return null;
        return pts / d;
      };
    case TaskSortAxis.urgency:
      // Intercepted upstream in _sortBucket; the fallthrough keeps the
      // switch exhaustive without changing observable behavior.
      return (t) => t.dateAdded;
  }
}

/// Comparator for the [TaskSortAxis.urgency] sort. Tasks first sort by
/// due-status tier (past-due → urgent → target → normal → scheduled →
/// completed), then within each tier by the date fields most relevant
/// to that bucket. Always returns ascending = "most urgent first";
/// `_sortBucket` flips the sign for descending direction.
///
/// Per-bucket secondary keys:
/// - **pastDue**: dueDate
/// - **urgent**: dueDate, then urgentDate
/// - **target**: urgentDate, then targetDate
/// - **normal**: targetDate, then dateAdded
/// - **scheduled**: startDate (ascending — matches the legacy
///   dueStatus-sentinel behavior)
/// - **completed**: completionDate descending (also matches the legacy
///   sentinel; the outer direction multiplier composes with this so
///   global descending still puts completed last)
int _cmpUrgency(TaskItem a, TaskItem b, DateTime now) {
  final bucketA = _dueStatusBucketOf(a, now);
  final bucketB = _dueStatusBucketOf(b, now);
  final tierA = _kDueStatusOrder[bucketA] ?? 99;
  final tierB = _kDueStatusOrder[bucketB] ?? 99;
  if (tierA != tierB) return tierA.compareTo(tierB);

  switch (bucketA) {
    case DueStatusBucket.pastDue:
      return _cmpDate(a.dueDate, b.dueDate, 1);
    case DueStatusBucket.urgent:
      final c = _cmpDate(a.dueDate, b.dueDate, 1);
      if (c != 0) return c;
      return _cmpDate(a.urgentDate, b.urgentDate, 1);
    case DueStatusBucket.target:
      final c = _cmpDate(a.urgentDate, b.urgentDate, 1);
      if (c != 0) return c;
      return _cmpDate(a.targetDate, b.targetDate, 1);
    case DueStatusBucket.normal:
      final c = _cmpDate(a.targetDate, b.targetDate, 1);
      if (c != 0) return c;
      return _cmpDate(a.dateAdded, b.dateAdded, 1);
    case DueStatusBucket.scheduled:
      return _cmpDate(a.startDate, b.startDate, 1);
    case DueStatusBucket.completed:
      // Within Completed, most-recent first — same as the legacy sentinel.
      return _cmpDate(a.completionDate, b.completionDate, -1);
  }
}

int _cmpDate(DateTime? a, DateTime? b, int dir) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // nulls last
  if (b == null) return -1;
  return a.compareTo(b) * dir;
}
