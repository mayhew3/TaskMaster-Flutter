// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_edit_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddEditScreenViewModel extends AddEditScreenViewModel {
  @override
  final BuiltList<TaskItem> allTaskItems;
  @override
  final BuiltList<TaskRecurrence> allTaskRecurrences;

  factory _$AddEditScreenViewModel([
    void Function(AddEditScreenViewModelBuilder)? updates,
  ]) => (AddEditScreenViewModelBuilder()..update(updates))._build();

  _$AddEditScreenViewModel._({
    required this.allTaskItems,
    required this.allTaskRecurrences,
  }) : super._();
  @override
  AddEditScreenViewModel rebuild(
    void Function(AddEditScreenViewModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AddEditScreenViewModelBuilder toBuilder() =>
      AddEditScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddEditScreenViewModel &&
        allTaskItems == other.allTaskItems &&
        allTaskRecurrences == other.allTaskRecurrences;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, allTaskItems.hashCode);
    _$hash = $jc(_$hash, allTaskRecurrences.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddEditScreenViewModel')
          ..add('allTaskItems', allTaskItems)
          ..add('allTaskRecurrences', allTaskRecurrences))
        .toString();
  }
}

class AddEditScreenViewModelBuilder
    implements Builder<AddEditScreenViewModel, AddEditScreenViewModelBuilder> {
  _$AddEditScreenViewModel? _$v;

  ListBuilder<TaskItem>? _allTaskItems;
  ListBuilder<TaskItem> get allTaskItems =>
      _$this._allTaskItems ??= ListBuilder<TaskItem>();
  set allTaskItems(ListBuilder<TaskItem>? allTaskItems) =>
      _$this._allTaskItems = allTaskItems;

  ListBuilder<TaskRecurrence>? _allTaskRecurrences;
  ListBuilder<TaskRecurrence> get allTaskRecurrences =>
      _$this._allTaskRecurrences ??= ListBuilder<TaskRecurrence>();
  set allTaskRecurrences(ListBuilder<TaskRecurrence>? allTaskRecurrences) =>
      _$this._allTaskRecurrences = allTaskRecurrences;

  AddEditScreenViewModelBuilder();

  AddEditScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _allTaskItems = $v.allTaskItems.toBuilder();
      _allTaskRecurrences = $v.allTaskRecurrences.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddEditScreenViewModel other) {
    _$v = other as _$AddEditScreenViewModel;
  }

  @override
  void update(void Function(AddEditScreenViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddEditScreenViewModel build() => _build();

  _$AddEditScreenViewModel _build() {
    _$AddEditScreenViewModel _$result;
    try {
      _$result =
          _$v ??
          _$AddEditScreenViewModel._(
            allTaskItems: allTaskItems.build(),
            allTaskRecurrences: allTaskRecurrences.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'allTaskItems';
        allTaskItems.build();
        _$failedField = 'allTaskRecurrences';
        allTaskRecurrences.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AddEditScreenViewModel',
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
