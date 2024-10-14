// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_task_items_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FilteredTaskItemsViewModel extends FilteredTaskItemsViewModel {
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final bool loading;
  @override
  final bool showCompleted;
  @override
  final bool showScheduled;
  @override
  final bool offlineMode;
  @override
  final TimezoneHelper timezoneHelper;

  factory _$FilteredTaskItemsViewModel(
          [void Function(FilteredTaskItemsViewModelBuilder)? updates]) =>
      (new FilteredTaskItemsViewModelBuilder()..update(updates))._build();

  _$FilteredTaskItemsViewModel._(
      {required this.taskItems,
      required this.loading,
      required this.showCompleted,
      required this.showScheduled,
      required this.offlineMode,
      required this.timezoneHelper})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'FilteredTaskItemsViewModel', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(
        loading, r'FilteredTaskItemsViewModel', 'loading');
    BuiltValueNullFieldError.checkNotNull(
        showCompleted, r'FilteredTaskItemsViewModel', 'showCompleted');
    BuiltValueNullFieldError.checkNotNull(
        showScheduled, r'FilteredTaskItemsViewModel', 'showScheduled');
    BuiltValueNullFieldError.checkNotNull(
        offlineMode, r'FilteredTaskItemsViewModel', 'offlineMode');
    BuiltValueNullFieldError.checkNotNull(
        timezoneHelper, r'FilteredTaskItemsViewModel', 'timezoneHelper');
  }

  @override
  FilteredTaskItemsViewModel rebuild(
          void Function(FilteredTaskItemsViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FilteredTaskItemsViewModelBuilder toBuilder() =>
      new FilteredTaskItemsViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FilteredTaskItemsViewModel &&
        taskItems == other.taskItems &&
        loading == other.loading &&
        showCompleted == other.showCompleted &&
        showScheduled == other.showScheduled &&
        offlineMode == other.offlineMode &&
        timezoneHelper == other.timezoneHelper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, loading.hashCode);
    _$hash = $jc(_$hash, showCompleted.hashCode);
    _$hash = $jc(_$hash, showScheduled.hashCode);
    _$hash = $jc(_$hash, offlineMode.hashCode);
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FilteredTaskItemsViewModel')
          ..add('taskItems', taskItems)
          ..add('loading', loading)
          ..add('showCompleted', showCompleted)
          ..add('showScheduled', showScheduled)
          ..add('offlineMode', offlineMode)
          ..add('timezoneHelper', timezoneHelper))
        .toString();
  }
}

class FilteredTaskItemsViewModelBuilder
    implements
        Builder<FilteredTaskItemsViewModel, FilteredTaskItemsViewModelBuilder> {
  _$FilteredTaskItemsViewModel? _$v;

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

  bool? _offlineMode;
  bool? get offlineMode => _$this._offlineMode;
  set offlineMode(bool? offlineMode) => _$this._offlineMode = offlineMode;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  FilteredTaskItemsViewModelBuilder();

  FilteredTaskItemsViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskItems = $v.taskItems.toBuilder();
      _loading = $v.loading;
      _showCompleted = $v.showCompleted;
      _showScheduled = $v.showScheduled;
      _offlineMode = $v.offlineMode;
      _timezoneHelper = $v.timezoneHelper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FilteredTaskItemsViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$FilteredTaskItemsViewModel;
  }

  @override
  void update(void Function(FilteredTaskItemsViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FilteredTaskItemsViewModel build() => _build();

  _$FilteredTaskItemsViewModel _build() {
    _$FilteredTaskItemsViewModel _$result;
    try {
      _$result = _$v ??
          new _$FilteredTaskItemsViewModel._(
              taskItems: taskItems.build(),
              loading: BuiltValueNullFieldError.checkNotNull(
                  loading, r'FilteredTaskItemsViewModel', 'loading'),
              showCompleted: BuiltValueNullFieldError.checkNotNull(
                  showCompleted,
                  r'FilteredTaskItemsViewModel',
                  'showCompleted'),
              showScheduled: BuiltValueNullFieldError.checkNotNull(
                  showScheduled,
                  r'FilteredTaskItemsViewModel',
                  'showScheduled'),
              offlineMode: BuiltValueNullFieldError.checkNotNull(
                  offlineMode, r'FilteredTaskItemsViewModel', 'offlineMode'),
              timezoneHelper: BuiltValueNullFieldError.checkNotNull(
                  timezoneHelper,
                  r'FilteredTaskItemsViewModel',
                  'timezoneHelper'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItems';
        taskItems.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'FilteredTaskItemsViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
