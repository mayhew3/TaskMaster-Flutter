import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Accent palette for [SegmentedBar].
/// - [brand]: light periwinkle blue (general-purpose, e.g. recurrence unit/anchor)
/// - [priority]: red/orange/blue ramp by index (1-2 cool, 3 amber, 4-5 coral)
/// - [points]: solid white (used by [PointsPicker])
enum SegmentedBarAccent { brand, priority, points }

/// Generic segmented selector — N equal-width buttons in a row. The active
/// segment is filled with the accent color; the others show a translucent
/// outline. Used by Priority, Recurrence Unit, Recurrence Anchor, Length, and
/// internally by PointsPicker.
class SegmentedBar extends StatelessWidget {
  /// Currently-selected segment, **1-based** to match how the UI reads
  /// (e.g. priority 1..5). `null` = no segment selected.
  final int? value;

  /// Number of segments. If [labels] is provided, must equal [labels.length].
  final int segments;

  /// Labels per segment. Defaults to "1", "2", … "[segments]" when null.
  final List<String>? labels;

  /// Called with the new value when a segment is tapped, or `null` if the
  /// active segment was tapped while [allowZero] is true.
  final ValueChanged<int?> onChanged;

  /// Accent palette for filled segments.
  final SegmentedBarAccent accent;

  /// If true, tapping the currently-selected segment clears the selection
  /// (emits `null`). If false, taps on the active segment are no-ops.
  final bool allowZero;

  /// Pixel height of each segment button. Default matches the design (32).
  final double height;

  /// Gap between segments in pixels. Default 4.
  final double gap;

  /// When `true`, every segment with index ≤ the selected one is filled
  /// (progress-bar style). When `false` (default), only the selected segment
  /// is filled. Use `true` for ordinal scales like Priority and Points;
  /// leave `false` for category pickers (recurrence unit/anchor, time bucket).
  final bool fillUpTo;

  const SegmentedBar({
    required this.value,
    required this.segments,
    required this.onChanged,
    this.labels,
    this.accent = SegmentedBarAccent.brand,
    this.allowZero = true,
    this.height = 32,
    this.gap = 4,
    this.fillUpTo = false,
    super.key,
  })  : assert(segments > 0),
        assert(labels == null || labels.length == segments,
            'labels.length must equal segments');

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < segments; i++) {
      if (i > 0) children.add(SizedBox(width: gap));
      final segmentValue = i + 1;
      final filled = value != null &&
          (fillUpTo ? segmentValue <= value! : segmentValue == value);
      final label = labels?[i] ?? '$segmentValue';
      // Tap-to-clear is gated on exact value match, not the visual `filled`
      // state. With `fillUpTo: true`, segments below the active one
      // (e.g. priority 3 when value=4) are visually filled but tapping
      // them sets the value to that segment, not null. Only tapping the
      // exact active segment (segmentValue == value) clears.
      final isActive = value == segmentValue;
      children.add(Expanded(
        child: Segment(
          label: label,
          filled: filled,
          fillColor: accentColorForIndex(accent, i),
          height: height,
          onTap: () {
            if (isActive) {
              if (allowZero) onChanged(null);
            } else {
              onChanged(segmentValue);
            }
          },
        ),
      ));
    }
    return Row(children: children);
  }
}

/// Public so consumers (e.g. [PointsPicker]) can compose their own row of
/// segments with custom click behavior while keeping the visual style.
Color accentColorForIndex(SegmentedBarAccent accent, int i) {
  switch (accent) {
    case SegmentedBarAccent.priority:
      if (i >= 3) return const Color.fromRGBO(255, 160, 140, 0.95);
      if (i >= 2) return const Color.fromRGBO(255, 206, 128, 0.95);
      return TaskColors.primaryLight; // periwinkle
    case SegmentedBarAccent.points:
      return Colors.white.withValues(alpha: 0.85);
    case SegmentedBarAccent.brand:
      return const Color.fromRGBO(143, 184, 255, 0.95);
  }
}

/// Single segment button used by [SegmentedBar] and other composite pickers.
class Segment extends StatelessWidget {
  final String label;
  final bool filled;
  final Color fillColor;
  final double height;
  final VoidCallback onTap;

  const Segment({
    required this.label,
    required this.filled,
    required this.fillColor,
    required this.height,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: filled ? fillColor : TaskColors.segmentInactiveSurface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: filled
                  ? null
                  : Border.all(color: TaskColors.segmentInactiveBorder, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled
                    ? TaskColors.segmentActiveTextOnLight
                    : TaskColors.textFaint,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
