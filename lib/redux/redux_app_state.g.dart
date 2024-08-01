// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redux_app_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReduxAppState extends ReduxAppState {
  @override
  final bool isLoading;
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final BuiltList<Sprint> sprints;
  @override
  final BuiltList<TaskRecurrence> taskRecurrences;
  @override
  final AppTab activeTab;
  @override
  final VisibilityFilter sprintListFilter;
  @override
  final VisibilityFilter taskListFilter;

  factory _$ReduxAppState([void Function(ReduxAppStateBuilder)? updates]) =>
      (new ReduxAppStateBuilder()..update(updates))._build();

  _$ReduxAppState._(
      {required this.isLoading,
      required this.taskItems,
      required this.sprints,
      required this.taskRecurrences,
      required this.activeTab,
      required this.sprintListFilter,
      required this.taskListFilter})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        isLoading, r'ReduxAppState', 'isLoading');
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'ReduxAppState', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(sprints, r'ReduxAppState', 'sprints');
    BuiltValueNullFieldError.checkNotNull(
        taskRecurrences, r'ReduxAppState', 'taskRecurrences');
    BuiltValueNullFieldError.checkNotNull(
        activeTab, r'ReduxAppState', 'activeTab');
    BuiltValueNullFieldError.checkNotNull(
        sprintListFilter, r'ReduxAppState', 'sprintListFilter');
    BuiltValueNullFieldError.checkNotNull(
        taskListFilter, r'ReduxAppState', 'taskListFilter');
  }

  @override
  ReduxAppState rebuild(void Function(ReduxAppStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReduxAppStateBuilder toBuilder() => new ReduxAppStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReduxAppState &&
        isLoading == other.isLoading &&
        taskItems == other.taskItems &&
        sprints == other.sprints &&
        taskRecurrences == other.taskRecurrences &&
        activeTab == other.activeTab &&
        sprintListFilter == other.sprintListFilter &&
        taskListFilter == other.taskListFilter;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, sprints.hashCode);
    _$hash = $jc(_$hash, taskRecurrences.hashCode);
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, sprintListFilter.hashCode);
    _$hash = $jc(_$hash, taskListFilter.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReduxAppState')
          ..add('isLoading', isLoading)
          ..add('taskItems', taskItems)
          ..add('sprints', sprints)
          ..add('taskRecurrences', taskRecurrences)
          ..add('activeTab', activeTab)
          ..add('sprintListFilter', sprintListFilter)
          ..add('taskListFilter', taskListFilter))
        .toString();
  }
}

class ReduxAppStateBuilder
    implements Builder<ReduxAppState, ReduxAppStateBuilder> {
  _$ReduxAppState? _$v;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  ListBuilder<TaskItem>? _taskItems;
  ListBuilder<TaskItem> get taskItems =>
      _$this._taskItems ??= new ListBuilder<TaskItem>();
  set taskItems(ListBuilder<TaskItem>? taskItems) =>
      _$this._taskItems = taskItems;

  ListBuilder<Sprint>? _sprints;
  ListBuilder<Sprint> get sprints =>
      _$this._sprints ??= new ListBuilder<Sprint>();
  set sprints(ListBuilder<Sprint>? sprints) => _$this._sprints = sprints;

  ListBuilder<TaskRecurrence>? _taskRecurrences;
  ListBuilder<TaskRecurrence> get taskRecurrences =>
      _$this._taskRecurrences ??= new ListBuilder<TaskRecurrence>();
  set taskRecurrences(ListBuilder<TaskRecurrence>? taskRecurrences) =>
      _$this._taskRecurrences = taskRecurrences;

  AppTab? _activeTab;
  AppTab? get activeTab => _$this._activeTab;
  set activeTab(AppTab? activeTab) => _$this._activeTab = activeTab;

  VisibilityFilterBuilder? _sprintListFilter;
  VisibilityFilterBuilder get sprintListFilter =>
      _$this._sprintListFilter ??= new VisibilityFilterBuilder();
  set sprintListFilter(VisibilityFilterBuilder? sprintListFilter) =>
      _$this._sprintListFilter = sprintListFilter;

  VisibilityFilterBuilder? _taskListFilter;
  VisibilityFilterBuilder get taskListFilter =>
      _$this._taskListFilter ??= new VisibilityFilterBuilder();
  set taskListFilter(VisibilityFilterBuilder? taskListFilter) =>
      _$this._taskListFilter = taskListFilter;

  ReduxAppStateBuilder();

  ReduxAppStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _isLoading = $v.isLoading;
      _taskItems = $v.taskItems.toBuilder();
      _sprints = $v.sprints.toBuilder();
      _taskRecurrences = $v.taskRecurrences.toBuilder();
      _activeTab = $v.activeTab;
      _sprintListFilter = $v.sprintListFilter.toBuilder();
      _taskListFilter = $v.taskListFilter.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReduxAppState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ReduxAppState;
  }

  @override
  void update(void Function(ReduxAppStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReduxAppState build() => _build();

  _$ReduxAppState _build() {
    _$ReduxAppState _$result;
    try {
      _$result = _$v ??
          new _$ReduxAppState._(
              isLoading: BuiltValueNullFieldError.checkNotNull(
                  isLoading, r'ReduxAppState', 'isLoading'),
              taskItems: taskItems.build(),
              sprints: sprints.build(),
              taskRecurrences: taskRecurrences.build(),
              activeTab: BuiltValueNullFieldError.checkNotNull(
                  activeTab, r'ReduxAppState', 'activeTab'),
              sprintListFilter: sprintListFilter.build(),
              taskListFilter: taskListFilter.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItems';
        taskItems.build();
        _$failedField = 'sprints';
        sprints.build();
        _$failedField = 'taskRecurrences';
        taskRecurrences.build();

        _$failedField = 'sprintListFilter';
        sprintListFilter.build();
        _$failedField = 'taskListFilter';
        taskListFilter.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ReduxAppState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
