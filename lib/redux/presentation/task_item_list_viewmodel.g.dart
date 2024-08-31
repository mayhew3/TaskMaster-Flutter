// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_list_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskItemListViewModel extends TaskItemListViewModel {
  @override
  final BuiltList<TaskItem> taskItems;

  factory _$TaskItemListViewModel(
          [void Function(TaskItemListViewModelBuilder)? updates]) =>
      (new TaskItemListViewModelBuilder()..update(updates))._build();

  _$TaskItemListViewModel._({required this.taskItems}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'TaskItemListViewModel', 'taskItems');
  }

  @override
  TaskItemListViewModel rebuild(
          void Function(TaskItemListViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskItemListViewModelBuilder toBuilder() =>
      new TaskItemListViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskItemListViewModel && taskItems == other.taskItems;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskItemListViewModel')
          ..add('taskItems', taskItems))
        .toString();
  }
}

class TaskItemListViewModelBuilder
    implements Builder<TaskItemListViewModel, TaskItemListViewModelBuilder> {
  _$TaskItemListViewModel? _$v;

  ListBuilder<TaskItem>? _taskItems;
  ListBuilder<TaskItem> get taskItems =>
      _$this._taskItems ??= new ListBuilder<TaskItem>();
  set taskItems(ListBuilder<TaskItem>? taskItems) =>
      _$this._taskItems = taskItems;

  TaskItemListViewModelBuilder();

  TaskItemListViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskItems = $v.taskItems.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskItemListViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
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
          _$v ?? new _$TaskItemListViewModel._(taskItems: taskItems.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItems';
        taskItems.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'TaskItemListViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
