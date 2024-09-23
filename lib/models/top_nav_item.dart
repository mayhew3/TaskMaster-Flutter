
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:taskmaster/typedefs.dart';

part 'top_nav_item.g.dart';

abstract class TopNavItem implements Built<TopNavItem, TopNavItemBuilder> {
  String get label;
  IconData get icon;
  WidgetGetter get widgetGetter;

  TopNavItem._();

  factory TopNavItem([void Function(TopNavItemBuilder) updates]) = _$TopNavItem;

  factory TopNavItem.init({required String label, required IconData icon, required WidgetGetter widgetGetter}) => TopNavItem((navItem) => navItem
    ..label = label
    ..icon = icon
    ..widgetGetter = widgetGetter
  );
}
