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

  factory _$SprintTaskItemsViewModel(
          [void Function(SprintTaskItemsViewModelBuilder)? updates]) =>
      (new SprintTaskItemsViewModelBuilder()..update(updates))._build();

  _$SprintTaskItemsViewModel._(
      {this.activeSprint, required this.taskItems, required this.loading})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        taskItems, r'SprintTaskItemsViewModel', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(
        loading, r'SprintTaskItemsViewModel', 'loading');
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
        loading == other.loading;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeSprint.hashCode);
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, loading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SprintTaskItemsViewModel')
          ..add('activeSprint', activeSprint)
          ..add('taskItems', taskItems)
          ..add('loading', loading))
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

  SprintTaskItemsViewModelBuilder();

  SprintTaskItemsViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeSprint = $v.activeSprint?.toBuilder();
      _taskItems = $v.taskItems.toBuilder();
      _loading = $v.loading;
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
                  loading, r'SprintTaskItemsViewModel', 'loading'));
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
