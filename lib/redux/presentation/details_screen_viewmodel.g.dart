// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'details_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DetailsScreenViewModel extends DetailsScreenViewModel {
  @override
  final TaskItem taskItem;
  @override
  final TimezoneHelper timezoneHelper;

  factory _$DetailsScreenViewModel([
    void Function(DetailsScreenViewModelBuilder)? updates,
  ]) => (DetailsScreenViewModelBuilder()..update(updates))._build();

  _$DetailsScreenViewModel._({
    required this.taskItem,
    required this.timezoneHelper,
  }) : super._();
  @override
  DetailsScreenViewModel rebuild(
    void Function(DetailsScreenViewModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DetailsScreenViewModelBuilder toBuilder() =>
      DetailsScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DetailsScreenViewModel &&
        taskItem == other.taskItem &&
        timezoneHelper == other.timezoneHelper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskItem.hashCode);
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DetailsScreenViewModel')
          ..add('taskItem', taskItem)
          ..add('timezoneHelper', timezoneHelper))
        .toString();
  }
}

class DetailsScreenViewModelBuilder
    implements Builder<DetailsScreenViewModel, DetailsScreenViewModelBuilder> {
  _$DetailsScreenViewModel? _$v;

  TaskItemBuilder? _taskItem;
  TaskItemBuilder get taskItem => _$this._taskItem ??= TaskItemBuilder();
  set taskItem(TaskItemBuilder? taskItem) => _$this._taskItem = taskItem;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  DetailsScreenViewModelBuilder();

  DetailsScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskItem = $v.taskItem.toBuilder();
      _timezoneHelper = $v.timezoneHelper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DetailsScreenViewModel other) {
    _$v = other as _$DetailsScreenViewModel;
  }

  @override
  void update(void Function(DetailsScreenViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DetailsScreenViewModel build() => _build();

  _$DetailsScreenViewModel _build() {
    _$DetailsScreenViewModel _$result;
    try {
      _$result =
          _$v ??
          _$DetailsScreenViewModel._(
            taskItem: taskItem.build(),
            timezoneHelper: BuiltValueNullFieldError.checkNotNull(
              timezoneHelper,
              r'DetailsScreenViewModel',
              'timezoneHelper',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItem';
        taskItem.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DetailsScreenViewModel',
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
