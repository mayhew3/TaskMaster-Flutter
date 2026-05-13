// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_view.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskFilters extends TaskFilters {
  @override
  final BuiltSet<String> areas;
  @override
  final BuiltSet<String> contexts;
  @override
  final BuiltSet<DueStatusBucket> dueStatus;
  @override
  final int? minPriority;
  @override
  final int? maxPriority;
  @override
  final int? minPoints;
  @override
  final int? maxPoints;
  @override
  final RecurrenceFilter recurrence;
  @override
  final int? maxAgeDays;
  @override
  final bool ownedByMeOnly;
  @override
  final String search;

  factory _$TaskFilters([void Function(TaskFiltersBuilder)? updates]) =>
      (TaskFiltersBuilder()..update(updates))._build();

  _$TaskFilters._({
    required this.areas,
    required this.contexts,
    required this.dueStatus,
    this.minPriority,
    this.maxPriority,
    this.minPoints,
    this.maxPoints,
    required this.recurrence,
    this.maxAgeDays,
    required this.ownedByMeOnly,
    required this.search,
  }) : super._();
  @override
  TaskFilters rebuild(void Function(TaskFiltersBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskFiltersBuilder toBuilder() => TaskFiltersBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskFilters &&
        areas == other.areas &&
        contexts == other.contexts &&
        dueStatus == other.dueStatus &&
        minPriority == other.minPriority &&
        maxPriority == other.maxPriority &&
        minPoints == other.minPoints &&
        maxPoints == other.maxPoints &&
        recurrence == other.recurrence &&
        maxAgeDays == other.maxAgeDays &&
        ownedByMeOnly == other.ownedByMeOnly &&
        search == other.search;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, areas.hashCode);
    _$hash = $jc(_$hash, contexts.hashCode);
    _$hash = $jc(_$hash, dueStatus.hashCode);
    _$hash = $jc(_$hash, minPriority.hashCode);
    _$hash = $jc(_$hash, maxPriority.hashCode);
    _$hash = $jc(_$hash, minPoints.hashCode);
    _$hash = $jc(_$hash, maxPoints.hashCode);
    _$hash = $jc(_$hash, recurrence.hashCode);
    _$hash = $jc(_$hash, maxAgeDays.hashCode);
    _$hash = $jc(_$hash, ownedByMeOnly.hashCode);
    _$hash = $jc(_$hash, search.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskFilters')
          ..add('areas', areas)
          ..add('contexts', contexts)
          ..add('dueStatus', dueStatus)
          ..add('minPriority', minPriority)
          ..add('maxPriority', maxPriority)
          ..add('minPoints', minPoints)
          ..add('maxPoints', maxPoints)
          ..add('recurrence', recurrence)
          ..add('maxAgeDays', maxAgeDays)
          ..add('ownedByMeOnly', ownedByMeOnly)
          ..add('search', search))
        .toString();
  }
}

class TaskFiltersBuilder implements Builder<TaskFilters, TaskFiltersBuilder> {
  _$TaskFilters? _$v;

  SetBuilder<String>? _areas;
  SetBuilder<String> get areas => _$this._areas ??= SetBuilder<String>();
  set areas(SetBuilder<String>? areas) => _$this._areas = areas;

  SetBuilder<String>? _contexts;
  SetBuilder<String> get contexts => _$this._contexts ??= SetBuilder<String>();
  set contexts(SetBuilder<String>? contexts) => _$this._contexts = contexts;

  SetBuilder<DueStatusBucket>? _dueStatus;
  SetBuilder<DueStatusBucket> get dueStatus =>
      _$this._dueStatus ??= SetBuilder<DueStatusBucket>();
  set dueStatus(SetBuilder<DueStatusBucket>? dueStatus) =>
      _$this._dueStatus = dueStatus;

  int? _minPriority;
  int? get minPriority => _$this._minPriority;
  set minPriority(int? minPriority) => _$this._minPriority = minPriority;

  int? _maxPriority;
  int? get maxPriority => _$this._maxPriority;
  set maxPriority(int? maxPriority) => _$this._maxPriority = maxPriority;

  int? _minPoints;
  int? get minPoints => _$this._minPoints;
  set minPoints(int? minPoints) => _$this._minPoints = minPoints;

  int? _maxPoints;
  int? get maxPoints => _$this._maxPoints;
  set maxPoints(int? maxPoints) => _$this._maxPoints = maxPoints;

  RecurrenceFilter? _recurrence;
  RecurrenceFilter? get recurrence => _$this._recurrence;
  set recurrence(RecurrenceFilter? recurrence) =>
      _$this._recurrence = recurrence;

  int? _maxAgeDays;
  int? get maxAgeDays => _$this._maxAgeDays;
  set maxAgeDays(int? maxAgeDays) => _$this._maxAgeDays = maxAgeDays;

  bool? _ownedByMeOnly;
  bool? get ownedByMeOnly => _$this._ownedByMeOnly;
  set ownedByMeOnly(bool? ownedByMeOnly) =>
      _$this._ownedByMeOnly = ownedByMeOnly;

  String? _search;
  String? get search => _$this._search;
  set search(String? search) => _$this._search = search;

  TaskFiltersBuilder() {
    TaskFilters._setDefaults(this);
  }

  TaskFiltersBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _areas = $v.areas.toBuilder();
      _contexts = $v.contexts.toBuilder();
      _dueStatus = $v.dueStatus.toBuilder();
      _minPriority = $v.minPriority;
      _maxPriority = $v.maxPriority;
      _minPoints = $v.minPoints;
      _maxPoints = $v.maxPoints;
      _recurrence = $v.recurrence;
      _maxAgeDays = $v.maxAgeDays;
      _ownedByMeOnly = $v.ownedByMeOnly;
      _search = $v.search;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskFilters other) {
    _$v = other as _$TaskFilters;
  }

  @override
  void update(void Function(TaskFiltersBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskFilters build() => _build();

  _$TaskFilters _build() {
    _$TaskFilters _$result;
    try {
      _$result =
          _$v ??
          _$TaskFilters._(
            areas: areas.build(),
            contexts: contexts.build(),
            dueStatus: dueStatus.build(),
            minPriority: minPriority,
            maxPriority: maxPriority,
            minPoints: minPoints,
            maxPoints: maxPoints,
            recurrence: BuiltValueNullFieldError.checkNotNull(
              recurrence,
              r'TaskFilters',
              'recurrence',
            ),
            maxAgeDays: maxAgeDays,
            ownedByMeOnly: BuiltValueNullFieldError.checkNotNull(
              ownedByMeOnly,
              r'TaskFilters',
              'ownedByMeOnly',
            ),
            search: BuiltValueNullFieldError.checkNotNull(
              search,
              r'TaskFilters',
              'search',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'areas';
        areas.build();
        _$failedField = 'contexts';
        contexts.build();
        _$failedField = 'dueStatus';
        dueStatus.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TaskFilters',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$TaskListView extends TaskListView {
  @override
  final TaskGroupAxis groupAxis;
  @override
  final TaskSortAxis sortAxis;
  @override
  final SortDirection sortDirection;
  @override
  final TaskFilters filters;
  @override
  final BuiltSet<String> collapsedGroups;

  factory _$TaskListView([void Function(TaskListViewBuilder)? updates]) =>
      (TaskListViewBuilder()..update(updates))._build();

  _$TaskListView._({
    required this.groupAxis,
    required this.sortAxis,
    required this.sortDirection,
    required this.filters,
    required this.collapsedGroups,
  }) : super._();
  @override
  TaskListView rebuild(void Function(TaskListViewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskListViewBuilder toBuilder() => TaskListViewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskListView &&
        groupAxis == other.groupAxis &&
        sortAxis == other.sortAxis &&
        sortDirection == other.sortDirection &&
        filters == other.filters &&
        collapsedGroups == other.collapsedGroups;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupAxis.hashCode);
    _$hash = $jc(_$hash, sortAxis.hashCode);
    _$hash = $jc(_$hash, sortDirection.hashCode);
    _$hash = $jc(_$hash, filters.hashCode);
    _$hash = $jc(_$hash, collapsedGroups.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskListView')
          ..add('groupAxis', groupAxis)
          ..add('sortAxis', sortAxis)
          ..add('sortDirection', sortDirection)
          ..add('filters', filters)
          ..add('collapsedGroups', collapsedGroups))
        .toString();
  }
}

class TaskListViewBuilder
    implements Builder<TaskListView, TaskListViewBuilder> {
  _$TaskListView? _$v;

  TaskGroupAxis? _groupAxis;
  TaskGroupAxis? get groupAxis => _$this._groupAxis;
  set groupAxis(TaskGroupAxis? groupAxis) => _$this._groupAxis = groupAxis;

  TaskSortAxis? _sortAxis;
  TaskSortAxis? get sortAxis => _$this._sortAxis;
  set sortAxis(TaskSortAxis? sortAxis) => _$this._sortAxis = sortAxis;

  SortDirection? _sortDirection;
  SortDirection? get sortDirection => _$this._sortDirection;
  set sortDirection(SortDirection? sortDirection) =>
      _$this._sortDirection = sortDirection;

  TaskFiltersBuilder? _filters;
  TaskFiltersBuilder get filters => _$this._filters ??= TaskFiltersBuilder();
  set filters(TaskFiltersBuilder? filters) => _$this._filters = filters;

  SetBuilder<String>? _collapsedGroups;
  SetBuilder<String> get collapsedGroups =>
      _$this._collapsedGroups ??= SetBuilder<String>();
  set collapsedGroups(SetBuilder<String>? collapsedGroups) =>
      _$this._collapsedGroups = collapsedGroups;

  TaskListViewBuilder();

  TaskListViewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupAxis = $v.groupAxis;
      _sortAxis = $v.sortAxis;
      _sortDirection = $v.sortDirection;
      _filters = $v.filters.toBuilder();
      _collapsedGroups = $v.collapsedGroups.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskListView other) {
    _$v = other as _$TaskListView;
  }

  @override
  void update(void Function(TaskListViewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskListView build() => _build();

  _$TaskListView _build() {
    _$TaskListView _$result;
    try {
      _$result =
          _$v ??
          _$TaskListView._(
            groupAxis: BuiltValueNullFieldError.checkNotNull(
              groupAxis,
              r'TaskListView',
              'groupAxis',
            ),
            sortAxis: BuiltValueNullFieldError.checkNotNull(
              sortAxis,
              r'TaskListView',
              'sortAxis',
            ),
            sortDirection: BuiltValueNullFieldError.checkNotNull(
              sortDirection,
              r'TaskListView',
              'sortDirection',
            ),
            filters: filters.build(),
            collapsedGroups: collapsedGroups.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'filters';
        filters.build();
        _$failedField = 'collapsedGroups';
        collapsedGroups.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TaskListView',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
