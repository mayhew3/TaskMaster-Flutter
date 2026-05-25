import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Points picker with a Fibonacci scale (1, 2, 3, 5, 8) plus an "Other" slot
/// that opens a numeric input for arbitrary values.
///
/// When [value] matches one of the Fibonacci buckets, the matching segment
/// highlights. When [value] is non-Fibonacci (e.g. `13`, `21`), the "Other"
/// segment highlights and displays the actual stored number instead of the
/// word "Other". `null` = no segment highlighted.
class PointsPicker extends StatelessWidget {
  /// Current points value. `null` = unset.
  final int? value;

  /// Called with the new points value, or `null` if the user cleared it.
  final ValueChanged<int?> onChanged;

  /// Whether the "Other" custom-value dialog targets the root navigator.
  /// `true` (default) preserves the full-screen editor behavior. The
  /// docked editor pane (TM-384) passes `false` so the dialog renders
  /// scoped to the pane's nested navigator instead of the whole window.
  final bool useRootNavigator;

  static const List<int> fibBuckets = [1, 2, 3, 5, 8];

  const PointsPicker({
    required this.value,
    required this.onChanged,
    this.useRootNavigator = true,
    super.key,
  });

  /// Index (0-based) of the segment that should highlight for [v]:
  /// 0..4 = matching Fibonacci bucket, 5 = "Other", null = no selection.
  ///
  /// `null` and negative values map to no selection. `0` is a valid
  /// non-Fibonacci value: it routes to the "Other" segment and renders
  /// as "0" rather than the "Other" word — symmetric with the dialog's
  /// non-negative validation, which accepts 0 as a legitimate submission.
  static int? activeSegmentIndex(int? v) {
    if (v == null || v < 0) return null;
    final fibIdx = fibBuckets.indexOf(v);
    if (fibIdx >= 0) return fibIdx;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = activeSegmentIndex(value);
    final otherLabel = (activeIdx == 5) ? '$value' : 'Other';
    final fillColor = accentColorForIndex(SegmentedBarAccent.points, 0);

    final children = <Widget>[];
    for (var i = 0; i < 6; i++) {
      if (i > 0) children.add(const SizedBox(width: 4));
      final isFib = i < fibBuckets.length;
      final label = isFib ? '${fibBuckets[i]}' : otherLabel;
      // Progress-fill style: every segment up to and including the active
      // one is filled. Matches the Claude Design prototype's points bar.
      final filled = activeIdx != null && i <= activeIdx;
      children.add(Expanded(
        child: Segment(
          label: label,
          filled: filled,
          fillColor: fillColor,
          height: 32,
          onTap: () => _onSegmentTapped(context, i),
        ),
      ));
    }
    return Row(children: children);
  }

  Future<void> _onSegmentTapped(BuildContext context, int segmentIndex) async {
    if (segmentIndex < fibBuckets.length) {
      // Tapping the currently-active Fib clears the value (matches the
      // priority and length bars' tap-active-to-clear behaviour).
      if (value == fibBuckets[segmentIndex]) {
        onChanged(null);
      } else {
        onChanged(fibBuckets[segmentIndex]);
      }
      return;
    }
    // "Other" segment.
    if (activeSegmentIndex(value) == 5) {
      // Active and tapped → clear, matching tap-active-clears for fibs.
      // Re-tap to set a new custom value via the dialog.
      onChanged(null);
      return;
    }
    // Inactive Other → open numeric input. The active-Other branch above
    // clears (rather than opening pre-filled), so by the time we reach
    // here `value` is always null or a Fibonacci bucket; there's nothing
    // useful to pre-fill into the dialog.
    final result = await _promptForCustomPoints(context);
    // Cancel / barrier-dismiss → leave state alone.
    // `_PointsDialogValue(n)` → apply (n may legitimately be 0).
    if (result is _PointsDialogValue) {
      onChanged(result.value);
    }
  }

  /// Returns the dialog outcome: a value (possibly 0) or a cancel marker.
  Future<_PointsDialogResult?> _promptForCustomPoints(BuildContext context) {
    return showDialog<_PointsDialogResult>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => const _CustomPointsDialog(),
    );
  }
}

/// Result wrapper for `_CustomPointsDialog`. Distinguishes "user
/// cancelled / dismissed" from "user submitted N" — including N = 0,
/// which is otherwise ambiguous if the dialog returned a bare `int?`.
sealed class _PointsDialogResult {
  const _PointsDialogResult();
}

class _PointsDialogValue extends _PointsDialogResult {
  final int value;
  const _PointsDialogValue(this.value);
}

class _PointsDialogCancel extends _PointsDialogResult {
  const _PointsDialogCancel();
}

class _CustomPointsDialog extends StatefulWidget {
  const _CustomPointsDialog();

  @override
  State<_CustomPointsDialog> createState() => _CustomPointsDialogState();
}

class _CustomPointsDialogState extends State<_CustomPointsDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      // Empty submit is treated as cancel — the picker keeps whatever
      // value was previously set rather than clearing it implicitly.
      Navigator.of(context).pop(const _PointsDialogCancel());
      return;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) {
      setState(() => _error = 'Enter a non-negative whole number');
      return;
    }
    Navigator.of(context).pop(_PointsDialogValue(parsed));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TaskColors.popupBg,
      title: const Text('Custom points', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'e.g. 13',
          hintStyle: TextStyle(color: TaskColors.editorLabelHint),
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const _PointsDialogCancel()),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Set'),
        ),
      ],
    );
  }
}
