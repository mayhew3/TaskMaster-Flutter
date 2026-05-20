import 'package:flutter/material.dart';

import '../../../../models/task_colors.dart';

/// A single tappable row in the wide-layout navigation sidebar (TM-382).
///
/// Used for both Destinations (leading [icon]) and Areas (leading
/// [dotColor]). The active row gets the dark rounded "pill" treatment from
/// the Claude Design handoff (`wide-chrome.jsx`): a translucent-black
/// background, slightly heavier label weight.
class SidebarRow extends StatelessWidget {
  const SidebarRow({
    super.key,
    this.icon,
    this.dotColor,
    this.leading,
    required this.label,
    this.trailingText,
    this.selected = false,
    this.onTap,
  }) : assert(icon != null || dotColor != null || leading != null,
            'SidebarRow needs an icon, a dotColor, or a leading widget');

  /// Leading glyph for Destination rows.
  final IconData? icon;

  /// Leading colour dot for Area rows.
  final Color? dotColor;

  /// Arbitrary leading widget (e.g. a ContextIcon for Context rows).
  /// Takes priority over [dotColor] / [icon] when provided.
  final Widget? leading;

  final String label;

  /// Optional right-aligned count (e.g. an Area's task count).
  final String? trailingText;

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget resolvedLeading = leading ??
        (dotColor != null
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              )
            : Icon(icon, size: 20, color: TaskColors.textDim));

    return Padding(
      // matches the prototype's 1px row gap / 10px gutter
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: selected
            // Intentional literal: the prototype's active "pill" is a
            // translucent-black overlay on brand-blue. No existing
            // TaskColors token expresses this; a sidebar token is a
            // Story-4 cleanup (TM-385).
            ? Colors.black.withValues(alpha: 0.28)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 20, child: Center(child: resolvedLeading)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? TaskColors.textPrimary
                          : TaskColors.textDim,
                      fontSize: 13.5,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (trailingText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    trailingText!,
                    style: TextStyle(
                      color: TaskColors.textFaint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
