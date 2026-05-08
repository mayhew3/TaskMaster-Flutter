import 'package:flutter/material.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';

/// Length picker with 8 semantic buckets:
/// 5m / 15m / 30m / 1h / 2h / 4h / 8h / 1d.
///
/// Replaces the legacy free-form `duration` numeric field on the edit-task
/// screen. Existing minute values not on a bucket boundary snap to the closest
/// bucket on display; user picks emit the canonical bucket value via
/// [onChanged].
class LengthBucketPicker extends StatelessWidget {
  /// Current length in minutes. `null` = unset.
  final int? minutes;

  /// Called with the canonical bucket value (in minutes) when a bucket is
  /// tapped, or `null` when the user taps the currently-active bucket to
  /// clear the selection.
  final ValueChanged<int?> onChanged;

  static const List<int> bucketsMinutes = [5, 15, 30, 60, 120, 240, 480, 1440];
  static const List<String> bucketsLabels = [
    '5m', '15m', '30m', '1h', '2h', '4h', '8h', '1d',
  ];

  const LengthBucketPicker({
    required this.minutes,
    required this.onChanged,
    super.key,
  });

  /// Index (0-based) of the bucket closest to [m], or `null` if [m] is null.
  static int? closestBucketIndex(int? m) {
    if (m == null) return null;
    var bestIdx = 0;
    var bestDelta = (bucketsMinutes[0] - m).abs();
    for (var i = 1; i < bucketsMinutes.length; i++) {
      final d = (bucketsMinutes[i] - m).abs();
      if (d < bestDelta) {
        bestDelta = d;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = closestBucketIndex(minutes);
    return SegmentedBar(
      value: activeIdx == null ? null : activeIdx + 1,
      segments: bucketsMinutes.length,
      labels: bucketsLabels,
      accent: SegmentedBarAccent.brand,
      // Tapping the currently-active bucket clears the value (matches the
      // priority bar's behavior).
      allowZero: true,
      gap: 3,
      onChanged: (v) {
        if (v == null) {
          onChanged(null);
        } else {
          onChanged(bucketsMinutes[v - 1]);
        }
      },
    );
  }
}
