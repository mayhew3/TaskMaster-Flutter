// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HomeScreenViewModel extends HomeScreenViewModel {
  @override
  final bool showCompleted;
  @override
  final bool showScheduled;
  @override
  final AppTab activeTab;

  factory _$HomeScreenViewModel(
          [void Function(HomeScreenViewModelBuilder)? updates]) =>
      (new HomeScreenViewModelBuilder()..update(updates))._build();

  _$HomeScreenViewModel._(
      {required this.showCompleted,
      required this.showScheduled,
      required this.activeTab})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        showCompleted, r'HomeScreenViewModel', 'showCompleted');
    BuiltValueNullFieldError.checkNotNull(
        showScheduled, r'HomeScreenViewModel', 'showScheduled');
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
    return other is HomeScreenViewModel &&
        showCompleted == other.showCompleted &&
        showScheduled == other.showScheduled &&
        activeTab == other.activeTab;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, showCompleted.hashCode);
    _$hash = $jc(_$hash, showScheduled.hashCode);
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HomeScreenViewModel')
          ..add('showCompleted', showCompleted)
          ..add('showScheduled', showScheduled)
          ..add('activeTab', activeTab))
        .toString();
  }
}

class HomeScreenViewModelBuilder
    implements Builder<HomeScreenViewModel, HomeScreenViewModelBuilder> {
  _$HomeScreenViewModel? _$v;

  bool? _showCompleted;
  bool? get showCompleted => _$this._showCompleted;
  set showCompleted(bool? showCompleted) =>
      _$this._showCompleted = showCompleted;

  bool? _showScheduled;
  bool? get showScheduled => _$this._showScheduled;
  set showScheduled(bool? showScheduled) =>
      _$this._showScheduled = showScheduled;

  AppTab? _activeTab;
  AppTab? get activeTab => _$this._activeTab;
  set activeTab(AppTab? activeTab) => _$this._activeTab = activeTab;

  HomeScreenViewModelBuilder();

  HomeScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _showCompleted = $v.showCompleted;
      _showScheduled = $v.showScheduled;
      _activeTab = $v.activeTab;
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
    final _$result = _$v ??
        new _$HomeScreenViewModel._(
            showCompleted: BuiltValueNullFieldError.checkNotNull(
                showCompleted, r'HomeScreenViewModel', 'showCompleted'),
            showScheduled: BuiltValueNullFieldError.checkNotNull(
                showScheduled, r'HomeScreenViewModel', 'showScheduled'),
            activeTab: BuiltValueNullFieldError.checkNotNull(
                activeTab, r'HomeScreenViewModel', 'activeTab'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
