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

  static const List<int> fibBuckets = [1, 2, 3, 5, 8];

  const PointsPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Index (0-based) of the segment that should highlight for [v]:
  /// 0..4 = matching Fibonacci bucket, 5 = "Other", null = no selection.
  static int? activeSegmentIndex(int? v) {
    if (v == null || v <= 0) return null;
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
      // Tapping the currently-active Fib is a no-op; user clears via Other.
      if (value == fibBuckets[segmentIndex]) return;
      onChanged(fibBuckets[segmentIndex]);
      return;
    }
    // "Other" tapped (whether active or not) — open numeric input.
    final initial = (activeSegmentIndex(value) == 5) ? value : null;
    final result = await _promptForCustomPoints(context, initial);
    if (result == null) return; // user cancelled
    if (result == 0) {
      onChanged(null);
    } else {
      onChanged(result);
    }
  }

  /// Returns the entered integer, or `null` if the user cancelled.
  /// `0` is a valid sentinel that callers may interpret as "clear".
  static Future<int?> _promptForCustomPoints(
      BuildContext context, int? initial) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => _CustomPointsDialog(initial: initial),
    );
  }
}

class _CustomPointsDialog extends StatefulWidget {
  final int? initial;

  const _CustomPointsDialog({required this.initial});

  @override
  State<_CustomPointsDialog> createState() => _CustomPointsDialogState();
}

class _CustomPointsDialogState extends State<_CustomPointsDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial == null ? '' : '${widget.initial}',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      Navigator.of(context).pop(0);
      return;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) {
      setState(() => _error = 'Enter a non-negative whole number');
      return;
    }
    Navigator.of(context).pop(parsed);
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
          onPressed: () => Navigator.of(context).pop(),
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
