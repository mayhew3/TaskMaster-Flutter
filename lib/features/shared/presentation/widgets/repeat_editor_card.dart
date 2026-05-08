import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/field_label.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Recurrence rule editor — a card-style block with a toggle and (when on)
/// the "Every N", unit, and anchor controls.
///
/// Anchor values are normalized to the same labels the existing
/// `TaskItemBlueprint` uses: `"Schedule Dates"` and `"Completed Date"`.
/// Unit values match the legacy options: `"Days" | "Weeks" | "Months" | "Years"`.
class RepeatEditorCard extends StatelessWidget {
  /// Whether recurrence is on.
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;

  /// Recurrence number (the "Every N"). May be null when [enabled] is false.
  final int? number;
  final ValueChanged<int?> onNumberChanged;

  /// Unit string ("Days" | "Weeks" | "Months" | "Years"). May be null when
  /// no unit is selected yet.
  final String? unit;
  final ValueChanged<String?> onUnitChanged;

  /// Anchor string ("Completed Date" | "Schedule Dates"). May be null.
  final String? anchor;
  final ValueChanged<String?> onAnchorChanged;

  /// Optional message to render in place of the editor when recurrence is
  /// disallowed for some reason (e.g. family-shared tasks; TM-335).
  final String? disabledReason;

  /// When true, missing required fields (every-N / unit / anchor) render
  /// with a red border and a "Required" caption underneath. The parent
  /// flips this true when the user taps Save with [enabled] but any
  /// required field is missing, mirroring the pre-redesign FormField
  /// validator behavior.
  final bool showValidationErrors;

  const RepeatEditorCard({
    required this.enabled,
    required this.onEnabledChanged,
    required this.number,
    required this.onNumberChanged,
    required this.unit,
    required this.onUnitChanged,
    required this.anchor,
    required this.onAnchorChanged,
    this.disabledReason,
    this.showValidationErrors = false,
    super.key,
  });

  static const List<String> unitOptions = ['Days', 'Weeks', 'Months', 'Years'];
  static const List<String> anchorOptions = ['Completed Date', 'Schedule Dates'];

  /// Material's standard error red, slightly tuned to read against the
  /// brand-blue surface.
  static const Color _errorColor = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    if (disabledReason != null) {
      return _DisabledCard(message: disabledReason!);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TaskColors.fieldBorder, width: 1),
        color: enabled
            ? TaskColors.brandMagenta.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.autorenew,
                size: 14,
                color: enabled
                    ? const Color.fromRGBO(255, 150, 235, 0.95)
                    : Colors.white.withValues(alpha: 0.50),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  enabled
                      ? 'Repeats every ${number ?? '?'} ${(unit ?? '?').toLowerCase()} after ${(anchor ?? '?').toLowerCase()}'
                      : 'Does not repeat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? const Color.fromRGBO(255, 210, 245, 0.95)
                        : Colors.white.withValues(alpha: 0.70),
                  ),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeTrackColor: TaskColors.brandMagenta,
                activeColor: Colors.white,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Every'),
                      _NumberInput(
                        value: number,
                        onChanged: onNumberChanged,
                        showError: showValidationErrors &&
                            (number == null || number! <= 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Unit'),
                      _ErrorBorderWrap(
                        showError:
                            showValidationErrors && unit == null,
                        errorColor: _errorColor,
                        child: SegmentedBar(
                          value: _indexFor(unit, unitOptions),
                          segments: unitOptions.length,
                          labels: unitOptions,
                          allowZero: false,
                          onChanged: (v) => onUnitChanged(
                              v == null ? null : unitOptions[v - 1]),
                        ),
                      ),
                      if (showValidationErrors && unit == null)
                        const _ErrorCaption(message: 'Required'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const FieldLabel('Anchor'),
            _ErrorBorderWrap(
              showError: showValidationErrors && anchor == null,
              errorColor: _errorColor,
              child: SegmentedBar(
                value: _indexFor(anchor, anchorOptions),
                segments: anchorOptions.length,
                labels: anchorOptions,
                allowZero: false,
                onChanged: (v) =>
                    onAnchorChanged(v == null ? null : anchorOptions[v - 1]),
              ),
            ),
            if (showValidationErrors && anchor == null)
              const _ErrorCaption(message: 'Required'),
          ],
        ],
      ),
    );
  }

  static int? _indexFor(String? value, List<String> options) {
    if (value == null) return null;
    final i = options.indexOf(value);
    return i < 0 ? null : i + 1;
  }
}

class _NumberInput extends StatefulWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool showError;

  const _NumberInput({
    required this.value,
    required this.onChanged,
    this.showError = false,
  });

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.value == null ? '' : '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant _NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final s = widget.value == null ? '' : '${widget.value}';
      if (_controller.text != s) _controller.text = s;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: TaskColors.fieldSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: widget.showError
                ? RepeatEditorCard._errorColor
                : TaskColors.fieldBorder,
            width: widget.showError ? 1.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: widget.showError
                ? RepeatEditorCard._errorColor
                : TaskColors.brandMagenta.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        errorText: widget.showError ? 'Required' : null,
        errorStyle: const TextStyle(
          color: RepeatEditorCard._errorColor,
          fontSize: 11,
          height: 1.0,
        ),
      ),
      onChanged: (s) {
        final v = s.trim().isEmpty ? null : int.tryParse(s.trim());
        widget.onChanged(v);
      },
    );
  }
}

/// Adds a thin red border around the [child] when [showError] is true.
/// Padding is preserved when not in error so layout doesn't shift.
class _ErrorBorderWrap extends StatelessWidget {
  final bool showError;
  final Color errorColor;
  final Widget child;

  const _ErrorBorderWrap({
    required this.showError,
    required this.errorColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: showError ? errorColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _ErrorCaption extends StatelessWidget {
  final String message;
  const _ErrorCaption({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: const TextStyle(
          color: RepeatEditorCard._errorColor,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _DisabledCard extends StatelessWidget {
  final String message;
  const _DisabledCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: TaskColors.fieldBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.autorenew,
            color: TaskColors.textFaint,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: TaskColors.textDim,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
