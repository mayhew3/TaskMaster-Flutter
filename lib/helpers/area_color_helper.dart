import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Picks a color for an area name from `TaskColors.areaPalette` using a
/// deterministic hash of the (trimmed, lowercased) name. Same input → same
/// color across the app within a Dart SDK version. An SDK upgrade can rotate
/// colors; this is acceptable for visual decoration.
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
