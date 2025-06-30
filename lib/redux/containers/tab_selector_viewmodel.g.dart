// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_selector_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TabSelectorViewModel extends TabSelectorViewModel {
  @override
  final TopNavItem activeTab;
  @override
  final BuiltList<TopNavItem> allTabs;
  @override
  final Function(int) onTabSelected;

  factory _$TabSelectorViewModel([
    void Function(TabSelectorViewModelBuilder)? updates,
  ]) => (TabSelectorViewModelBuilder()..update(updates))._build();

  _$TabSelectorViewModel._({
    required this.activeTab,
    required this.allTabs,
    required this.onTabSelected,
  }) : super._();
  @override
  TabSelectorViewModel rebuild(
    void Function(TabSelectorViewModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TabSelectorViewModelBuilder toBuilder() =>
      TabSelectorViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is TabSelectorViewModel &&
        activeTab == other.activeTab &&
        allTabs == other.allTabs &&
        onTabSelected == _$dynamicOther.onTabSelected;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, allTabs.hashCode);
    _$hash = $jc(_$hash, onTabSelected.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TabSelectorViewModel')
          ..add('activeTab', activeTab)
          ..add('allTabs', allTabs)
          ..add('onTabSelected', onTabSelected))
        .toString();
  }
}

class TabSelectorViewModelBuilder
    implements Builder<TabSelectorViewModel, TabSelectorViewModelBuilder> {
  _$TabSelectorViewModel? _$v;

  TopNavItemBuilder? _activeTab;
  TopNavItemBuilder get activeTab => _$this._activeTab ??= TopNavItemBuilder();
  set activeTab(TopNavItemBuilder? activeTab) => _$this._activeTab = activeTab;

  ListBuilder<TopNavItem>? _allTabs;
  ListBuilder<TopNavItem> get allTabs =>
      _$this._allTabs ??= ListBuilder<TopNavItem>();
  set allTabs(ListBuilder<TopNavItem>? allTabs) => _$this._allTabs = allTabs;

  Function(int)? _onTabSelected;
  Function(int)? get onTabSelected => _$this._onTabSelected;
  set onTabSelected(Function(int)? onTabSelected) =>
      _$this._onTabSelected = onTabSelected;

  TabSelectorViewModelBuilder();

  TabSelectorViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeTab = $v.activeTab.toBuilder();
      _allTabs = $v.allTabs.toBuilder();
      _onTabSelected = $v.onTabSelected;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TabSelectorViewModel other) {
    _$v = other as _$TabSelectorViewModel;
  }

  @override
  void update(void Function(TabSelectorViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TabSelectorViewModel build() => _build();

  _$TabSelectorViewModel _build() {
    _$TabSelectorViewModel _$result;
    try {
      _$result =
          _$v ??
          _$TabSelectorViewModel._(
            activeTab: activeTab.build(),
            allTabs: allTabs.build(),
            onTabSelected: BuiltValueNullFieldError.checkNotNull(
              onTabSelected,
              r'TabSelectorViewModel',
              'onTabSelected',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeTab';
        activeTab.build();
        _$failedField = 'allTabs';
        allTabs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TabSelectorViewModel',
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
