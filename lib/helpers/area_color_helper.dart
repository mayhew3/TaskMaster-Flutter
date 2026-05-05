import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Picks a color for an area name from `TaskColors.areaPalette` using a
/// hash of the (trimmed, lowercased) name. Two calls with the same input
/// in the same program run will return the same color. `String.hashCode`
/// is **not** specified to be stable across Dart releases or even across
/// program executions, so the colour an unknown area gets may shift after
/// an SDK upgrade. That's acceptable here because this is purely a
/// visual fallback for area strings that aren't in `areaColorsProvider`'s
/// sortOrder map; known areas are stable through that provider.
class AreaColorHelper {
  AreaColorHelper._();

  static const Color _fallback = Color(0x4DFFFFFF); // 30% white

  static Color colorForArea(String? areaName) {
    final index = paletteIndexForArea(areaName);
    if (index == null) return _fallback;
    return TaskColors.areaPalette[index];
  }

  /// Returns null for null/empty; otherwise an index into `areaPalette`.
  /// Exposed for testability.
  static int? paletteIndexForArea(String? areaName) {
    if (areaName == null) return null;
    final key = areaName.trim().toLowerCase();
    if (key.isEmpty) return null;
    return key.hashCode.abs() % TaskColors.areaPalette.length;
  }
}
