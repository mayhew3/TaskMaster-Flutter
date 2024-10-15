// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoadingScreenViewModel extends LoadingScreenViewModel {
  factory _$LoadingScreenViewModel(
          [void Function(LoadingScreenViewModelBuilder)? updates]) =>
      (new LoadingScreenViewModelBuilder()..update(updates))._build();

  _$LoadingScreenViewModel._() : super._();

  @override
  LoadingScreenViewModel rebuild(
          void Function(LoadingScreenViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoadingScreenViewModelBuilder toBuilder() =>
      new LoadingScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoadingScreenViewModel;
  }

  @override
  int get hashCode {
    return 102112346;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'LoadingScreenViewModel').toString();
  }
}

class LoadingScreenViewModelBuilder
    implements Builder<LoadingScreenViewModel, LoadingScreenViewModelBuilder> {
  _$LoadingScreenViewModel? _$v;

  LoadingScreenViewModelBuilder();

  @override
  void replace(LoadingScreenViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$LoadingScreenViewModel;
  }

  @override
  void update(void Function(LoadingScreenViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoadingScreenViewModel build() => _build();

  _$LoadingScreenViewModel _build() {
    final _$result = _$v ?? new _$LoadingScreenViewModel._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
