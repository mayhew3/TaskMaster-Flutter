import 'package:flutter/material.dart';

import '../../../../models/task_colors.dart';

/// A single tappable row in the wide-layout navigation sidebar (TM-382).
///
/// Used for both Destinations (leading [icon]) and Areas (leading
/// [dotColor]). The active row gets the dark rounded "pill" treatment from
/// the Claude Design handoff (`wide-chrome.jsx`): a translucent-black
/// background, slightly heavier label weight.
///
/// TM-385 added a mouse-hover overlay (touch / pen pointers don't fire
/// `MouseRegion.onEnter`, so the affordance is mouse-only and degrades
/// to identical behavior on phone tests).
class SidebarRow extends StatefulWidget {
  const SidebarRow({
    super.key,
    this.icon,
    this.dotColor,
    this.leading,
    required this.label,
    this.trailingText,
    this.selected = false,
    this.onTap,
  }) : assert(
         icon != null || dotColor != null || leading != null,
         'SidebarRow needs an icon, a dotColor, or a leading widget',
       );

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
  State<SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends State<SidebarRow> {
  bool _hovered = false;

  /// Row background: the selected "pill" (or transparent) as the base,
  /// with the hover overlay composited ON TOP so selected rows also
  /// show hover feedback (TM-385 R6 — the if/else version swallowed
  /// hover whenever `selected` was true).
  Color _rowColor() {
    final base = widget.selected
        ? Colors.black.withValues(alpha: 0.28)
        : Colors.transparent;
    if (!_hovered) return base;
    return Color.alphaBlend(Colors.white.withValues(alpha: 0.04), base);
  }

  @override
  Widget build(BuildContext context) {
    final Widget resolvedLeading =
        widget.leading ??
        (widget.dotColor != null
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.dotColor,
                  shape: BoxShape.circle,
                ),
              )
            : Icon(widget.icon, size: 20, color: TaskColors.textDim));

    return Padding(
      // matches the prototype's 1px row gap / 10px gutter
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          // TM-385: hover overlay is ADDITIVE — composited OVER the
          // base (selected pill or transparent) via alphaBlend, so a
          // selected row still gets visible hover feedback rather than
          // the hover being swallowed by the selected branch. The
          // selected "pill" base is an intentional literal: the
          // prototype's active row is a translucent-black overlay on
          // brand-blue, which no existing TaskColors token expresses
          // (a sidebar token is a Story-4 cleanup, TM-385).
          color: _rowColor(),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Center(child: resolvedLeading)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.selected
                            ? TaskColors.textPrimary
                            : TaskColors.textDim,
                        fontSize: 13.5,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.trailingText != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.trailingText!,
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
      ),
    );
  }
}
