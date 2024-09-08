// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_task_items_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SprintTaskItemsViewModel extends SprintTaskItemsViewModel {
  @override
  final Sprint? activeSprint;
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final bool loading;
  @override
  final bool showCompleted;
  @override
  final bool showScheduled;
  @override
  final TimezoneHelper timezoneHelper;

  factory _$SprintTaskItemsViewModel(
          [void Function(SprintTaskItemsViewModelBuilder)? updates]) =>
      (new SprintTaskItemsViewModelBuilder()..update(updates))._build();

  _$SprintTaskItemsViewModel._(
      {this.activeSprint,
      required this.taskItems,
      required this.loading,
      required this.showCompleted,
      required this.showScheduled,
      required this.timezoneHelper})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'SprintTaskItemsViewModel', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(
        loading, r'SprintTaskItemsViewModel', 'loading');
    BuiltValueNullFieldError.checkNotNull(
        showCompleted, r'SprintTaskItemsViewModel', 'showCompleted');
    BuiltValueNullFieldError.checkNotNull(
        showScheduled, r'SprintTaskItemsViewModel', 'showScheduled');
    BuiltValueNullFieldError.checkNotNull(
        timezoneHelper, r'SprintTaskItemsViewModel', 'timezoneHelper');
  }

  @override
  SprintTaskItemsViewModel rebuild(
          void Function(SprintTaskItemsViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SprintTaskItemsViewModelBuilder toBuilder() =>
      new SprintTaskItemsViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SprintTaskItemsViewModel &&
        activeSprint == other.activeSprint &&
        taskItems == other.taskItems &&
        loading == other.loading &&
        showCompleted == other.showCompleted &&
        showScheduled == other.showScheduled &&
        timezoneHelper == other.timezoneHelper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeSprint.hashCode);
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, loading.hashCode);
    _$hash = $jc(_$hash, showCompleted.hashCode);
    _$hash = $jc(_$hash, showScheduled.hashCode);
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SprintTaskItemsViewModel')
          ..add('activeSprint', activeSprint)
          ..add('taskItems', taskItems)
          ..add('loading', loading)
          ..add('showCompleted', showCompleted)
          ..add('showScheduled', showScheduled)
          ..add('timezoneHelper', timezoneHelper))
        .toString();
  }
}

class SprintTaskItemsViewModelBuilder
    implements
        Builder<SprintTaskItemsViewModel, SprintTaskItemsViewModelBuilder> {
  _$SprintTaskItemsViewModel? _$v;

  SprintBuilder? _activeSprint;
  SprintBuilder get activeSprint =>
      _$this._activeSprint ??= new SprintBuilder();
  set activeSprint(SprintBuilder? activeSprint) =>
      _$this._activeSprint = activeSprint;

  ListBuilder<TaskItem>? _taskItems;
  ListBuilder<TaskItem> get taskItems =>
      _$this._taskItems ??= new ListBuilder<TaskItem>();
  set taskItems(ListBuilder<TaskItem>? taskItems) =>
      _$this._taskItems = taskItems;

  bool? _loading;
  bool? get loading => _$this._loading;
  set loading(bool? loading) => _$this._loading = loading;

  bool? _showCompleted;
  bool? get showCompleted => _$this._showCompleted;
  set showCompleted(bool? showCompleted) =>
      _$this._showCompleted = showCompleted;

  bool? _showScheduled;
  bool? get showScheduled => _$this._showScheduled;
  set showScheduled(bool? showScheduled) =>
      _$this._showScheduled = showScheduled;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  SprintTaskItemsViewModelBuilder();

  SprintTaskItemsViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeSprint = $v.activeSprint?.toBuilder();
      _taskItems = $v.taskItems.toBuilder();
      _loading = $v.loading;
      _showCompleted = $v.showCompleted;
      _showScheduled = $v.showScheduled;
      _timezoneHelper = $v.timezoneHelper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SprintTaskItemsViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SprintTaskItemsViewModel;
  }

  @override
  void update(void Function(SprintTaskItemsViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SprintTaskItemsViewModel build() => _build();

  _$SprintTaskItemsViewModel _build() {
    _$SprintTaskItemsViewModel _$result;
    try {
      _$result = _$v ??
          new _$SprintTaskItemsViewModel._(
              activeSprint: _activeSprint?.build(),
              taskItems: taskItems.build(),
              loading: BuiltValueNullFieldError.checkNotNull(
                  loading, r'SprintTaskItemsViewModel', 'loading'),
              showCompleted: BuiltValueNullFieldError.checkNotNull(
                  showCompleted, r'SprintTaskItemsViewModel', 'showCompleted'),
              showScheduled: BuiltValueNullFieldError.checkNotNull(
                  showScheduled, r'SprintTaskItemsViewModel', 'showScheduled'),
              timezoneHelper: BuiltValueNullFieldError.checkNotNull(
                  timezoneHelper,
                  r'SprintTaskItemsViewModel',
                  'timezoneHelper'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeSprint';
        _activeSprint?.build();
        _$failedField = 'taskItems';
        taskItems.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SprintTaskItemsViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
