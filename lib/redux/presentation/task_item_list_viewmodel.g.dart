// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_list_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskItemListViewModel extends TaskItemListViewModel {
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final BuiltList<TaskItem> recentlyCompleted;
  @override
  final Sprint? activeSprint;
  @override
  final bool isLoading;
  @override
  final bool loadFailed;
  @override
  final CheckState? Function(TaskItem, CheckState) onCheckboxClicked;

  factory _$TaskItemListViewModel([
    void Function(TaskItemListViewModelBuilder)? updates,
  ]) => (TaskItemListViewModelBuilder()..update(updates))._build();

  _$TaskItemListViewModel._({
    required this.taskItems,
    required this.recentlyCompleted,
    this.activeSprint,
    required this.isLoading,
    required this.loadFailed,
    required this.onCheckboxClicked,
  }) : super._();
  @override
  TaskItemListViewModel rebuild(
    void Function(TaskItemListViewModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TaskItemListViewModelBuilder toBuilder() =>
      TaskItemListViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is TaskItemListViewModel &&
        taskItems == other.taskItems &&
        recentlyCompleted == other.recentlyCompleted &&
        activeSprint == other.activeSprint &&
        isLoading == other.isLoading &&
        loadFailed == other.loadFailed &&
        onCheckboxClicked == _$dynamicOther.onCheckboxClicked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, recentlyCompleted.hashCode);
    _$hash = $jc(_$hash, activeSprint.hashCode);
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jc(_$hash, loadFailed.hashCode);
    _$hash = $jc(_$hash, onCheckboxClicked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskItemListViewModel')
          ..add('taskItems', taskItems)
          ..add('recentlyCompleted', recentlyCompleted)
          ..add('activeSprint', activeSprint)
          ..add('isLoading', isLoading)
          ..add('loadFailed', loadFailed)
          ..add('onCheckboxClicked', onCheckboxClicked))
        .toString();
  }
}

class TaskItemListViewModelBuilder
    implements Builder<TaskItemListViewModel, TaskItemListViewModelBuilder> {
  _$TaskItemListViewModel? _$v;

  ListBuilder<TaskItem>? _taskItems;
  ListBuilder<TaskItem> get taskItems =>
      _$this._taskItems ??= ListBuilder<TaskItem>();
  set taskItems(ListBuilder<TaskItem>? taskItems) =>
      _$this._taskItems = taskItems;

  ListBuilder<TaskItem>? _recentlyCompleted;
  ListBuilder<TaskItem> get recentlyCompleted =>
      _$this._recentlyCompleted ??= ListBuilder<TaskItem>();
  set recentlyCompleted(ListBuilder<TaskItem>? recentlyCompleted) =>
      _$this._recentlyCompleted = recentlyCompleted;

  SprintBuilder? _activeSprint;
  SprintBuilder get activeSprint => _$this._activeSprint ??= SprintBuilder();
  set activeSprint(SprintBuilder? activeSprint) =>
      _$this._activeSprint = activeSprint;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  bool? _loadFailed;
  bool? get loadFailed => _$this._loadFailed;
  set loadFailed(bool? loadFailed) => _$this._loadFailed = loadFailed;

  CheckState? Function(TaskItem, CheckState)? _onCheckboxClicked;
  CheckState? Function(TaskItem, CheckState)? get onCheckboxClicked =>
      _$this._onCheckboxClicked;
  set onCheckboxClicked(
    CheckState? Function(TaskItem, CheckState)? onCheckboxClicked,
  ) => _$this._onCheckboxClicked = onCheckboxClicked;

  TaskItemListViewModelBuilder();

  TaskItemListViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskItems = $v.taskItems.toBuilder();
      _recentlyCompleted = $v.recentlyCompleted.toBuilder();
      _activeSprint = $v.activeSprint?.toBuilder();
      _isLoading = $v.isLoading;
      _loadFailed = $v.loadFailed;
      _onCheckboxClicked = $v.onCheckboxClicked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskItemListViewModel other) {
    _$v = other as _$TaskItemListViewModel;
  }

  @override
  void update(void Function(TaskItemListViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskItemListViewModel build() => _build();

  _$TaskItemListViewModel _build() {
    _$TaskItemListViewModel _$result;
    try {
      _$result =
          _$v ??
          _$TaskItemListViewModel._(
            taskItems: taskItems.build(),
            recentlyCompleted: recentlyCompleted.build(),
            activeSprint: _activeSprint?.build(),
            isLoading: BuiltValueNullFieldError.checkNotNull(
              isLoading,
              r'TaskItemListViewModel',
              'isLoading',
            ),
            loadFailed: BuiltValueNullFieldError.checkNotNull(
              loadFailed,
              r'TaskItemListViewModel',
              'loadFailed',
            ),
            onCheckboxClicked: BuiltValueNullFieldError.checkNotNull(
              onCheckboxClicked,
              r'TaskItemListViewModel',
              'onCheckboxClicked',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItems';
        taskItems.build();
        _$failedField = 'recentlyCompleted';
        recentlyCompleted.build();
        _$failedField = 'activeSprint';
        _activeSprint?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TaskItemListViewModel',
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
