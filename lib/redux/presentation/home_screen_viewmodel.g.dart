// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HomeScreenViewModel extends HomeScreenViewModel {
  @override
  final TopNavItem activeTab;

  factory _$HomeScreenViewModel(
          [void Function(HomeScreenViewModelBuilder)? updates]) =>
      (new HomeScreenViewModelBuilder()..update(updates))._build();

  _$HomeScreenViewModel._({required this.activeTab}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        activeTab, r'HomeScreenViewModel', 'activeTab');
  }

  @override
  HomeScreenViewModel rebuild(
          void Function(HomeScreenViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HomeScreenViewModelBuilder toBuilder() =>
      new HomeScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HomeScreenViewModel && activeTab == other.activeTab;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HomeScreenViewModel')
          ..add('activeTab', activeTab))
        .toString();
  }
}

class HomeScreenViewModelBuilder
    implements Builder<HomeScreenViewModel, HomeScreenViewModelBuilder> {
  _$HomeScreenViewModel? _$v;

  TopNavItemBuilder? _activeTab;
  TopNavItemBuilder get activeTab =>
      _$this._activeTab ??= new TopNavItemBuilder();
  set activeTab(TopNavItemBuilder? activeTab) => _$this._activeTab = activeTab;

  HomeScreenViewModelBuilder();

  HomeScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeTab = $v.activeTab.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HomeScreenViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$HomeScreenViewModel;
  }

  @override
  void update(void Function(HomeScreenViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HomeScreenViewModel build() => _build();

  _$HomeScreenViewModel _build() {
    _$HomeScreenViewModel _$result;
    try {
      _$result =
          _$v ?? new _$HomeScreenViewModel._(activeTab: activeTab.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeTab';
        activeTab.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'HomeScreenViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
