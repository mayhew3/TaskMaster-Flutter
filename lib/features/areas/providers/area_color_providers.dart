import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/task_colors.dart';
import 'area_providers.dart';

part 'area_color_providers.g.dart';

/// Stable name → color mapping for the user's areas.
///
/// Built from `areasProvider`, which already streams areas sorted by
/// `sortOrder`. Each area's index in that list maps to a slot in
/// `TaskColors.areaPalette` — so the first N areas (where N ≤ palette
/// length) get distinct colors. Unknown / stale area strings fall back to
/// the hash-based `AreaColorHelper.colorForArea` at the call site.
@Riverpod(keepAlive: true)
Map<String, Color> areaColors(Ref ref) {
  final areas = ref.watch(areasProvider).value ?? const [];
  final palette = TaskColors.areaPalette;
  final result = <String, Color>{};
  for (var i = 0; i < areas.length; i++) {
    final key = areas[i].name.trim().toLowerCase();
    if (key.isEmpty) continue;
    result[key] = palette[i % palette.length];
  }
  return result;
}
