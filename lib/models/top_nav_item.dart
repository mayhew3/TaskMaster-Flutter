
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:taskmaestro/typedefs.dart';

part 'top_nav_item.g.dart';

/// Stable identifier for a top-level destination (bottom nav + wide
/// sidebar). The wide sidebar's surface-resolution switches on this so
/// it can't be silently broken by a label rename or future localization.
enum NavDestination { plan, tasks, family, stats }

abstract class TopNavItem implements Built<TopNavItem, TopNavItemBuilder> {
  String get label;
  IconData get icon;
  WidgetGetter get widgetGetter;
  NavDestination get destination;

  TopNavItem._();

  factory TopNavItem([void Function(TopNavItemBuilder) updates]) = _$TopNavItem;

  factory TopNavItem.init({
    required String label,
    required IconData icon,
    required WidgetGetter widgetGetter,
    required NavDestination destination,
  }) =>
      TopNavItem((navItem) => navItem
        ..label = label
        ..icon = icon
        ..widgetGetter = widgetGetter
        ..destination = destination);
}
