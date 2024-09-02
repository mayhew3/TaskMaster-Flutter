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

  factory _$FilteredTaskItemsViewModel(
          [void Function(FilteredTaskItemsViewModelBuilder)? updates]) =>
      (new FilteredTaskItemsViewModelBuilder()..update(updates))._build();

  _$FilteredTaskItemsViewModel._(
      {required this.taskItems, required this.loading})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'FilteredTaskItemsViewModel', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(
        loading, r'FilteredTaskItemsViewModel', 'loading');
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
        loading == other.loading;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, loading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FilteredTaskItemsViewModel')
          ..add('taskItems', taskItems)
          ..add('loading', loading))
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

  FilteredTaskItemsViewModelBuilder();

  FilteredTaskItemsViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskItems = $v.taskItems.toBuilder();
      _loading = $v.loading;
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
                  loading, r'FilteredTaskItemsViewModel', 'loading'));
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
