import 'package:flutter/material.dart';

/// Renders a single built-in context glyph keyed by canonical lowercase name.
///
/// Tier 1 (TM-181) ships a closed icon set — user-created contexts default to
/// `iconName: null` and render an empty `SizedBox.shrink()` from this widget;
/// the upcoming Tier-2 picker will let users choose one of these names for
/// their own contexts.
///
/// The set covers the eight names the pre-181 picker hardcoded (Computer,
/// Home, Office, E-Mail, Phone, Outside, Reading, Planning) plus the broader
/// roster from the design prototype (people, errand, car, shopping, writing,
/// outdoors, anywhere) so a future icon picker has good coverage without
/// requiring new code.
class ContextIcon extends StatelessWidget {
  final String? name;
  final double size;
  final Color? color;

  const ContextIcon({
    super.key,
    required this.name,
    this.size = 14,
    this.color,
  });

  /// True if [name] resolves to a built-in icon. Helpful for callers that
  /// want to short-circuit empty space (e.g. the task-list card meta-row
  /// only inserts an interpunct separator when at least one icon will render).
  static bool hasIcon(String? name) {
    if (name == null || name.isEmpty) return false;
    return _resolve(name) != null;
  }

  /// Canonical names that resolve to a glyph in the Tier-1 closed set.
  /// Keep in sync with [_resolve] below — exposed so the Tier-2 picker can
  /// enumerate available choices without hard-coding the list separately.
  static const List<String> canonicalNames = [
    'computer',
    'home',
    'office',
    'email',
    'phone',
    'outside',
    'outdoors',
    'reading',
    'planning',
    'people',
    'errand',
    'car',
    'shopping',
    'writing',
    'anywhere',
  ];

  static IconData? _resolve(String name) {
    switch (name.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'home':
        return Icons.home_outlined;
      case 'office':
        return Icons.business_center_outlined;
      case 'email':
        return Icons.mail_outline;
      case 'phone':
        return Icons.phone_outlined;
      // 'outside' is the user-facing default seed name; the prototype uses
      // 'outdoors' / 'sun' for the same glyph. Both resolve to the same icon.
      case 'outside':
      case 'outdoors':
        return Icons.wb_sunny_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'planning':
        return Icons.checklist_outlined;
      case 'people':
        return Icons.people_outline;
      case 'errand':
        return Icons.shopping_bag_outlined;
      case 'car':
        return Icons.directions_car_outlined;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'writing':
        return Icons.edit_outlined;
      case 'anywhere':
        return Icons.public;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = name == null ? null : _resolve(name!);
    if (iconData == null) return const SizedBox.shrink();
    return Icon(
      iconData,
      size: size,
      color: color ?? IconTheme.of(context).color,
    );
  }
}
