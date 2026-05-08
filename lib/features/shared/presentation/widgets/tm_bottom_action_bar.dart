import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// Sticky bottom action bar with optional Cancel + primary Save.
///
/// Used at the bottom of the redesigned edit-task screen. Renders a vertical
/// gradient from transparent (top) to the editor background color (bottom)
/// so scrolled content fades behind it. Add this widget *outside* the scroll
/// view in a Stack — the gradient and SafeArea handle their own padding.
class TmBottomActionBar extends StatelessWidget {
  /// Label for the Cancel button. When null, only the Save button renders
  /// (full-width).
  final String? cancelLabel;

  /// Label for the primary save button. Required.
  final String saveLabel;

  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  /// Disables the save button when false. Cancel is always enabled when shown.
  final bool saveEnabled;

  const TmBottomActionBar({
    required this.saveLabel,
    this.cancelLabel,
    this.onCancel,
    this.onSave,
    this.saveEnabled = true,
    super.key,
  })  : assert(
          (cancelLabel == null) == (onCancel == null),
          'cancelLabel and onCancel must be supplied together: a Cancel '
          'button without a callback would render as interactive but do '
          'nothing on tap.',
        );

  @override
  Widget build(BuildContext context) {
    final showCancel = cancelLabel != null;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TaskColors.cardColor.withValues(alpha: 0.0),
            TaskColors.cardColor,
            TaskColors.cardColor,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              if (showCancel) ...[
                _SecondaryButton(
                  label: cancelLabel!,
                  onPressed: onCancel,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _PrimaryButton(
                  label: saveLabel,
                  onPressed: saveEnabled ? onSave : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? TaskColors.brandMagenta : TaskColors.brandMagenta.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(12),
      elevation: enabled ? 4 : 0,
      shadowColor: TaskColors.brandMagenta.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
