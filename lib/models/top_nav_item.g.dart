// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_nav_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TopNavItem extends TopNavItem {
  @override
  final String label;
  @override
  final IconData icon;
  @override
  final WidgetGetter widgetGetter;
  @override
  final NavDestination destination;

  factory _$TopNavItem([void Function(TopNavItemBuilder)? updates]) =>
      (TopNavItemBuilder()..update(updates))._build();

  _$TopNavItem._({
    required this.label,
    required this.icon,
    required this.widgetGetter,
    required this.destination,
  }) : super._();
  @override
  TopNavItem rebuild(void Function(TopNavItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TopNavItemBuilder toBuilder() => TopNavItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is TopNavItem &&
        label == other.label &&
        icon == other.icon &&
        widgetGetter == _$dynamicOther.widgetGetter &&
        destination == other.destination;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, icon.hashCode);
    _$hash = $jc(_$hash, widgetGetter.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TopNavItem')
          ..add('label', label)
          ..add('icon', icon)
          ..add('widgetGetter', widgetGetter)
          ..add('destination', destination))
        .toString();
  }
}

class TopNavItemBuilder implements Builder<TopNavItem, TopNavItemBuilder> {
  _$TopNavItem? _$v;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  IconData? _icon;
  IconData? get icon => _$this._icon;
  set icon(IconData? icon) => _$this._icon = icon;

  WidgetGetter? _widgetGetter;
  WidgetGetter? get widgetGetter => _$this._widgetGetter;
  set widgetGetter(WidgetGetter? widgetGetter) =>
      _$this._widgetGetter = widgetGetter;

  NavDestination? _destination;
  NavDestination? get destination => _$this._destination;
  set destination(NavDestination? destination) =>
      _$this._destination = destination;

  TopNavItemBuilder();

  TopNavItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _label = $v.label;
      _icon = $v.icon;
      _widgetGetter = $v.widgetGetter;
      _destination = $v.destination;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TopNavItem other) {
    _$v = other as _$TopNavItem;
  }

  @override
  void update(void Function(TopNavItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TopNavItem build() => _build();

  _$TopNavItem _build() {
    final _$result =
        _$v ??
        _$TopNavItem._(
          label: BuiltValueNullFieldError.checkNotNull(
            label,
            r'TopNavItem',
            'label',
          ),
          icon: BuiltValueNullFieldError.checkNotNull(
            icon,
            r'TopNavItem',
            'icon',
          ),
          widgetGetter: BuiltValueNullFieldError.checkNotNull(
            widgetGetter,
            r'TopNavItem',
            'widgetGetter',
          ),
          destination: BuiltValueNullFieldError.checkNotNull(
            destination,
            r'TopNavItem',
            'destination',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
