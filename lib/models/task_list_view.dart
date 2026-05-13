import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'task_list_view.g.dart';

/// Which task-list surface a [TaskListView] applies to. Each surface keeps
/// its own G/S/F selections; the enum value also keys SharedPreferences
/// persistence (`taskmaestro.listview.v1.<surface>`).
enum TaskListSurface { tasks, family, sprint, plan }

/// Axes a user can group tasks by. `dueStatus` is the default and replicates
/// the pre-TM-359 hardcoded 6-bucket grouping (`Past Due` / `Urgent` /
/// `Target` / `Tasks` / `Scheduled` / `Completed`). `none` renders a flat
/// list with no group headers.
enum TaskGroupAxis {
  dueStatus,
  none,
  priority,
  area,
  points,
  duration,
}

/// Axes a user can sort tasks by within a group. `dueStatus` is a sentinel
/// meaning "use the bucket's natural sort" — preserves the existing per-
/// bucket sort behavior under group-by-dueStatus (Scheduled ascending by
/// startDate, Completed descending by completionDate, others insertion
/// order). For non-dueStatus group axes, `dueStatus` falls back to
/// `dateAdded`.
enum TaskSortAxis {
  dueStatus,
  dateAdded,
  points,
  area,
  duration,
  priority,
  efficiency,
  startDate,
  completionDate,
}

enum SortDirection { ascending, descending }

/// Recurrence filter. `all` = no filter, the other values restrict to tasks
/// whose recurrence state matches.
enum RecurrenceFilter { all, scheduled, completed, none }

/// Multi-selectable due-status filter buckets. Matches the grouping bucket
/// identifiers but is independent (you can filter to "only Urgent" without
/// grouping by due status).
enum DueStatusBucket { pastDue, urgent, target, scheduled, normal, completed }

// ─── TaskFilters ─────────────────────────────────────────────────────────

/// The composable filter state for a [TaskListView]. Each axis defaults to
/// "any" so an empty filter set is a pass-through. Use `rebuild()` to mutate
/// individual axes.
abstract class TaskFilters implements Built<TaskFilters, TaskFiltersBuilder> {
  /// Selected area names. Empty = "any area".
  BuiltSet<String> get areas;

  /// Selected context names. Empty = "any context".
  BuiltSet<String> get contexts;

  /// Due-status buckets the user wants visible. Empty = "any bucket".
  BuiltSet<DueStatusBucket> get dueStatus;

  /// Inclusive lower bound on priority (1..5). Null = no lower bound.
  int? get minPriority;

  /// Inclusive upper bound on priority (1..5). Null = no upper bound.
  int? get maxPriority;

  /// Inclusive lower bound on `gamePoints`. Null = no lower bound.
  int? get minPoints;

  /// Inclusive upper bound on `gamePoints`. Null = no upper bound.
  int? get maxPoints;

  /// Recurrence-shape filter. Default = [RecurrenceFilter.all].
  RecurrenceFilter get recurrence;

  /// Maximum age in days since `dateAdded`. Null = "any age".
  int? get maxAgeDays;

  /// Family surface only: filter to tasks owned by the current user.
  bool get ownedByMeOnly;

  /// Case-insensitive search across `name`. Empty = no search.
  String get search;

  TaskFilters._();

  factory TaskFilters([void Function(TaskFiltersBuilder) updates]) =
      _$TaskFilters;

  /// Pass-through filter: no axis active.
  factory TaskFilters.empty() => TaskFilters((b) => b);

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(TaskFiltersBuilder b) => b
    ..recurrence = RecurrenceFilter.all
    ..ownedByMeOnly = false
    ..search = '';

  /// JSON shape used by SharedPreferences. Stable across releases: don't
  /// remove a key or its meaning, only add new keys with defaults so old
  /// payloads round-trip. Unknown keys are ignored.
  Map<String, dynamic> toJson() => {
        'areas': areas.toList(),
        'contexts': contexts.toList(),
        'dueStatus': dueStatus.map((b) => b.name).toList(),
        if (minPriority != null) 'minPriority': minPriority,
        if (maxPriority != null) 'maxPriority': maxPriority,
        if (minPoints != null) 'minPoints': minPoints,
        if (maxPoints != null) 'maxPoints': maxPoints,
        'recurrence': recurrence.name,
        if (maxAgeDays != null) 'maxAgeDays': maxAgeDays,
        'ownedByMeOnly': ownedByMeOnly,
        'search': search,
      };

  /// Inverse of [toJson]. Unknown enum names and bad types fall back to the
  /// default for that field — never throws on malformed input.
  static TaskFilters fromJson(Map<String, dynamic> json) {
    return TaskFilters((b) => b
      ..areas =
          SetBuilder<String>(_asStringList(json['areas']))
      ..contexts =
          SetBuilder<String>(_asStringList(json['contexts']))
      ..dueStatus = SetBuilder<DueStatusBucket>(_asStringList(json['dueStatus'])
          .map((s) => _byNameOrNull(DueStatusBucket.values, s))
          .whereType<DueStatusBucket>())
      ..minPriority = _asIntOrNull(json['minPriority'])
      ..maxPriority = _asIntOrNull(json['maxPriority'])
      ..minPoints = _asIntOrNull(json['minPoints'])
      ..maxPoints = _asIntOrNull(json['maxPoints'])
      ..recurrence = _byNameOr(
          RecurrenceFilter.values, json['recurrence'], RecurrenceFilter.all)
      ..maxAgeDays = _asIntOrNull(json['maxAgeDays'])
      ..ownedByMeOnly = _asBool(json['ownedByMeOnly'], false)
      ..search = _asString(json['search'], ''));
  }
}

// ─── TaskListView ────────────────────────────────────────────────────────

/// The full view state for one task-list surface — group axis, sort axis,
/// sort direction, filters, and per-group collapse state. Persisted via
/// `TaskListViewStorage` keyed by [TaskListSurface].
abstract class TaskListView implements Built<TaskListView, TaskListViewBuilder> {
  TaskGroupAxis get groupAxis;
  TaskSortAxis get sortAxis;
  SortDirection get sortDirection;
  TaskFilters get filters;

  /// Group keys (e.g. `due:urgent`, `area:Work`) the user has collapsed.
  /// Survives axis flips so collapsing `Urgent` once stays collapsed when
  /// the user returns to group-by-due-status later.
  BuiltSet<String> get collapsedGroups;

  TaskListView._();

  factory TaskListView([void Function(TaskListViewBuilder) updates]) =
      _$TaskListView;

  /// Default state for Tasks tab. `dueStatus` is pre-populated with the
  /// four "actionable" buckets so scheduled and completed tasks are
  /// hidden by default (matches pre-TM-359's `showScheduled=false` /
  /// `showCompleted=false` toggles). The other multi-select filters
  /// (`areas`, `contexts`) start empty = "no filter applied, show all";
  /// the View Options sheet visually renders empty as "all selected" so
  /// a newly-added area/context is included by default.
  factory TaskListView.tasksDefault() => TaskListView((b) => b
    ..groupAxis = TaskGroupAxis.dueStatus
    ..sortAxis = TaskSortAxis.dateAdded
    ..sortDirection = SortDirection.descending
    ..filters.replace(TaskFilters.empty().rebuild((f) => f
      ..dueStatus.replace(const {
        DueStatusBucket.pastDue,
        DueStatusBucket.urgent,
        DueStatusBucket.target,
        DueStatusBucket.normal,
      }))));

  /// Default state for Family tab (mirror of Tasks tab).
  factory TaskListView.familyDefault() => TaskListView.tasksDefault();

  /// Default state for Sprint tab — preserves TM-339 sprint-assignment
  /// order. `dueStatus` is empty (= no filter / show all buckets) so
  /// every assigned task remains visible regardless of state.
  factory TaskListView.sprintDefault() => TaskListView((b) => b
    ..groupAxis = TaskGroupAxis.none
    ..sortAxis = TaskSortAxis.dueStatus
    ..sortDirection = SortDirection.descending
    ..filters.replace(TaskFilters.empty()));

  /// Default state for plan-mode (Create Sprint / Add Tasks to Sprint).
  /// `dueStatus` is empty so every eligible task is visible; the plan-
  /// mode 8-bucket overlay continues to render the existing categories.
  factory TaskListView.planDefault() => TaskListView((b) => b
    ..groupAxis = TaskGroupAxis.dueStatus
    ..sortAxis = TaskSortAxis.dateAdded
    ..sortDirection = SortDirection.descending
    ..filters.replace(TaskFilters.empty()));

  /// Factory dispatch for surface-keyed lookup.
  factory TaskListView.defaultForSurface(TaskListSurface surface) {
    switch (surface) {
      case TaskListSurface.tasks:
        return TaskListView.tasksDefault();
      case TaskListSurface.family:
        return TaskListView.familyDefault();
      case TaskListSurface.sprint:
        return TaskListView.sprintDefault();
      case TaskListSurface.plan:
        return TaskListView.planDefault();
    }
  }

  /// JSON shape used by SharedPreferences.
  Map<String, dynamic> toJson() => {
        'groupAxis': groupAxis.name,
        'sortAxis': sortAxis.name,
        'sortDirection': sortDirection.name,
        'filters': filters.toJson(),
        'collapsedGroups': collapsedGroups.toList(),
      };

  /// Serialize to a single string for SharedPreferences write.
  String toJsonString() => jsonEncode(toJson());

  /// Inverse of [toJson]. Unknown enum names / bad types fall back to the
  /// supplied [defaultView] (per-field, not whole-object) so old payloads
  /// gracefully degrade instead of throwing.
  static TaskListView fromJson(
    Map<String, dynamic> json, {
    required TaskListView defaultView,
  }) {
    return TaskListView((b) => b
      ..groupAxis = _byNameOr(
          TaskGroupAxis.values, json['groupAxis'], defaultView.groupAxis)
      ..sortAxis = _byNameOr(
          TaskSortAxis.values, json['sortAxis'], defaultView.sortAxis)
      ..sortDirection = _byNameOr(SortDirection.values, json['sortDirection'],
          defaultView.sortDirection)
      ..filters.replace(json['filters'] is Map<String, dynamic>
          ? TaskFilters.fromJson(json['filters'] as Map<String, dynamic>)
          : defaultView.filters)
      ..collapsedGroups = SetBuilder<String>(
          _asStringList(json['collapsedGroups'])));
  }

  /// Inverse of [toJsonString]. Falls back to [defaultView] on parse errors.
  static TaskListView fromJsonString(
    String s, {
    required TaskListView defaultView,
  }) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map<String, dynamic>) return defaultView;
      return fromJson(decoded, defaultView: defaultView);
    } catch (_) {
      return defaultView;
    }
  }
}

// ─── Local helpers ───────────────────────────────────────────────────────

T _byNameOr<T extends Enum>(List<T> values, dynamic name, T fallback) {
  if (name is! String) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

T? _byNameOrNull<T extends Enum>(List<T> values, dynamic name) {
  if (name is! String) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

Iterable<String> _asStringList(dynamic raw) {
  if (raw is! List) return const Iterable<String>.empty();
  return raw.whereType<String>();
}

int? _asIntOrNull(dynamic raw) => raw is int ? raw : null;

bool _asBool(dynamic raw, bool fallback) => raw is bool ? raw : fallback;

String _asString(dynamic raw, String fallback) =>
    raw is String ? raw : fallback;
