// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_edit_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddEditScreenViewModel extends AddEditScreenViewModel {
  @override
  final bool updating;
  @override
  final BuiltList<TaskItem> allTaskItems;

  factory _$AddEditScreenViewModel(
          [void Function(AddEditScreenViewModelBuilder)? updates]) =>
      (new AddEditScreenViewModelBuilder()..update(updates))._build();

  _$AddEditScreenViewModel._(
      {required this.updating, required this.allTaskItems})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        updating, r'AddEditScreenViewModel', 'updating');
    BuiltValueNullFieldError.checkNotNull(
        allTaskItems, r'AddEditScreenViewModel', 'allTaskItems');
  }

  @override
  AddEditScreenViewModel rebuild(
          void Function(AddEditScreenViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddEditScreenViewModelBuilder toBuilder() =>
      new AddEditScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddEditScreenViewModel &&
        updating == other.updating &&
        allTaskItems == other.allTaskItems;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, updating.hashCode);
    _$hash = $jc(_$hash, allTaskItems.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddEditScreenViewModel')
          ..add('updating', updating)
          ..add('allTaskItems', allTaskItems))
        .toString();
  }
}

class AddEditScreenViewModelBuilder
    implements Builder<AddEditScreenViewModel, AddEditScreenViewModelBuilder> {
  _$AddEditScreenViewModel? _$v;

  bool? _updating;
  bool? get updating => _$this._updating;
  set updating(bool? updating) => _$this._updating = updating;

  ListBuilder<TaskItem>? _allTaskItems;
  ListBuilder<TaskItem> get allTaskItems =>
      _$this._allTaskItems ??= new ListBuilder<TaskItem>();
  set allTaskItems(ListBuilder<TaskItem>? allTaskItems) =>
      _$this._allTaskItems = allTaskItems;

  AddEditScreenViewModelBuilder();

  AddEditScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _updating = $v.updating;
      _allTaskItems = $v.allTaskItems.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddEditScreenViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
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
      _$result = _$v ??
          new _$AddEditScreenViewModel._(
              updating: BuiltValueNullFieldError.checkNotNull(
                  updating, r'AddEditScreenViewModel', 'updating'),
              allTaskItems: allTaskItems.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'allTaskItems';
        allTaskItems.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'AddEditScreenViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
