// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HomeScreenViewModel extends HomeScreenViewModel {
  @override
  final TopNavItem activeTab;
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final BuiltList<Sprint> sprints;
  @override
  final BuiltList<TaskRecurrence> taskRecurrences;
  @override
  final bool tasksLoading;
  @override
  final bool sprintsLoading;
  @override
  final bool taskRecurrencesLoading;

  factory _$HomeScreenViewModel(
          [void Function(HomeScreenViewModelBuilder)? updates]) =>
      (new HomeScreenViewModelBuilder()..update(updates))._build();

  _$HomeScreenViewModel._(
      {required this.activeTab,
      required this.taskItems,
      required this.sprints,
      required this.taskRecurrences,
      required this.tasksLoading,
      required this.sprintsLoading,
      required this.taskRecurrencesLoading})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        activeTab, r'HomeScreenViewModel', 'activeTab');
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'HomeScreenViewModel', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(
        sprints, r'HomeScreenViewModel', 'sprints');
    BuiltValueNullFieldError.checkNotNull(
        taskRecurrences, r'HomeScreenViewModel', 'taskRecurrences');
    BuiltValueNullFieldError.checkNotNull(
        tasksLoading, r'HomeScreenViewModel', 'tasksLoading');
    BuiltValueNullFieldError.checkNotNull(
        sprintsLoading, r'HomeScreenViewModel', 'sprintsLoading');
    BuiltValueNullFieldError.checkNotNull(taskRecurrencesLoading,
        r'HomeScreenViewModel', 'taskRecurrencesLoading');
  }

  @override
  HomeScreenViewModel rebuild(
          void Function(HomeScreenViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HomeScreenViewModelBuilder toBuilder() =>
      new HomeScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HomeScreenViewModel &&
        activeTab == other.activeTab &&
        taskItems == other.taskItems &&
        sprints == other.sprints &&
        taskRecurrences == other.taskRecurrences &&
        tasksLoading == other.tasksLoading &&
        sprintsLoading == other.sprintsLoading &&
        taskRecurrencesLoading == other.taskRecurrencesLoading;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, sprints.hashCode);
    _$hash = $jc(_$hash, taskRecurrences.hashCode);
    _$hash = $jc(_$hash, tasksLoading.hashCode);
    _$hash = $jc(_$hash, sprintsLoading.hashCode);
    _$hash = $jc(_$hash, taskRecurrencesLoading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HomeScreenViewModel')
          ..add('activeTab', activeTab)
          ..add('taskItems', taskItems)
          ..add('sprints', sprints)
          ..add('taskRecurrences', taskRecurrences)
          ..add('tasksLoading', tasksLoading)
          ..add('sprintsLoading', sprintsLoading)
          ..add('taskRecurrencesLoading', taskRecurrencesLoading))
        .toString();
  }
}

class HomeScreenViewModelBuilder
    implements Builder<HomeScreenViewModel, HomeScreenViewModelBuilder> {
  _$HomeScreenViewModel? _$v;

  TopNavItemBuilder? _activeTab;
  TopNavItemBuilder get activeTab =>
      _$this._activeTab ??= new TopNavItemBuilder();
  set activeTab(TopNavItemBuilder? activeTab) => _$this._activeTab = activeTab;

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

  bool? _tasksLoading;
  bool? get tasksLoading => _$this._tasksLoading;
  set tasksLoading(bool? tasksLoading) => _$this._tasksLoading = tasksLoading;

  bool? _sprintsLoading;
  bool? get sprintsLoading => _$this._sprintsLoading;
  set sprintsLoading(bool? sprintsLoading) =>
      _$this._sprintsLoading = sprintsLoading;

  bool? _taskRecurrencesLoading;
  bool? get taskRecurrencesLoading => _$this._taskRecurrencesLoading;
  set taskRecurrencesLoading(bool? taskRecurrencesLoading) =>
      _$this._taskRecurrencesLoading = taskRecurrencesLoading;

  HomeScreenViewModelBuilder();

  HomeScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeTab = $v.activeTab.toBuilder();
      _taskItems = $v.taskItems.toBuilder();
      _sprints = $v.sprints.toBuilder();
      _taskRecurrences = $v.taskRecurrences.toBuilder();
      _tasksLoading = $v.tasksLoading;
      _sprintsLoading = $v.sprintsLoading;
      _taskRecurrencesLoading = $v.taskRecurrencesLoading;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HomeScreenViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$HomeScreenViewModel;
  }

  @override
  void update(void Function(HomeScreenViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HomeScreenViewModel build() => _build();

  _$HomeScreenViewModel _build() {
    _$HomeScreenViewModel _$result;
    try {
      _$result = _$v ??
          new _$HomeScreenViewModel._(
              activeTab: activeTab.build(),
              taskItems: taskItems.build(),
              sprints: sprints.build(),
              taskRecurrences: taskRecurrences.build(),
              tasksLoading: BuiltValueNullFieldError.checkNotNull(
                  tasksLoading, r'HomeScreenViewModel', 'tasksLoading'),
              sprintsLoading: BuiltValueNullFieldError.checkNotNull(
                  sprintsLoading, r'HomeScreenViewModel', 'sprintsLoading'),
              taskRecurrencesLoading: BuiltValueNullFieldError.checkNotNull(
                  taskRecurrencesLoading,
                  r'HomeScreenViewModel',
                  'taskRecurrencesLoading'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeTab';
        activeTab.build();
        _$failedField = 'taskItems';
        taskItems.build();
        _$failedField = 'sprints';
        sprints.build();
        _$failedField = 'taskRecurrences';
        taskRecurrences.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'HomeScreenViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
