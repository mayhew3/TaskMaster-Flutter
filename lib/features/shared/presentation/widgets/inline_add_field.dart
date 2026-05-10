import 'package:flutter/material.dart';

import '../../../../models/task_colors.dart';

/// Dashed-border row with a leading `+` icon, a single-line text input, and a
/// magenta "Add" button that appears once the user types.
///
/// Used by the area + context pickers (TM-345 / TM-181) to add new entries
/// to the user's catalog inline at the bottom of a list. Lifted out of
/// `area_picker.dart` so both pickers share the same visual without
/// duplicate code or drift.
///
/// The caller's [onSubmit] is async-aware: return `null` on success (the
/// field clears), or a user-visible error message on failure (the field
/// keeps the typed text and surfaces the message inline below the row so
/// the user can edit-and-retry without retyping). Validation that the
/// caller wants to enforce locally (reserved sentinel names / duplicate
/// names) goes in [validator] — runs client-side before [onSubmit] is
/// called. **The field handles empty input itself** ("Name required");
/// [validator] is invoked only with a non-empty trimmed string, so callers
/// don't need to re-check for empty values.
class InlineAddField extends StatefulWidget {
  const InlineAddField({
    super.key,
    required this.hintText,
    required this.onSubmit,
    this.validator,
    this.maxLength = 40,
  });

  final String hintText;
  final Future<String?> Function(String name) onSubmit;
  final String? Function(String value)? validator;
  final int maxLength;

  @override
  State<InlineAddField> createState() => _InlineAddFieldState();
}

class _InlineAddFieldState extends State<InlineAddField> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final raw = _controller.text;
    final trimmed = raw.trim();
    final localError = trimmed.isEmpty
        ? 'Name required'
        : widget.validator?.call(trimmed);
    if (localError != null) {
      setState(() => _error = localError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final serviceError = await widget.onSubmit(trimmed);
      if (!mounted) return;
      if (serviceError != null) {
        setState(() => _error = serviceError);
      } else {
        _controller.clear();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashedBorderBox(
          color: Colors.white.withValues(alpha: 0.25),
          radius: 10,
          dash: 5,
          gap: 3,
          child: Container(
            color: Colors.white.withValues(alpha: 0.04),
            padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    maxLength: widget.maxLength,
                    enabled: !_submitting,
                    onChanged: (_) {
                      // Single setState refreshes both the Add-button
                      // visibility (derived from `_controller.text` via
                      // `hasText` below) and clears any prior inline
                      // error message.
                      setState(() => _error = null);
                    },
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      counterText: '',
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.40),
                        fontSize: 14,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (hasText)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 32),
                        backgroundColor: TaskColors.brandMagenta,
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFFFB4B4),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

/// Wraps [child] with a dashed rounded-rectangle border. Flutter's
/// BoxDecoration doesn't support dashes natively, so this draws via
/// CustomPaint. Stroke width is fixed at 1 px to match the design.
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.child,
  });

  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        dash: dash,
        gap: gap,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) {
    return old.color != color ||
        old.radius != radius ||
        old.dash != dash ||
        old.gap != gap;
  }
}
