import 'package:flutter/widgets.dart';

/// Small `MouseRegion` + state helper for mouse-hover affordances
/// (TM-385 Story 4 of Epic TM-188).
///
/// Story 4 added the first hover layer to the app; the convention
/// across all hover targets is a subtle alpha overlay using existing
/// `Color.withValues(alpha: ...)` tokens. Wrapping each callsite in
/// `Hoverable` keeps the StatefulWidget machinery out of the
/// rendering widgets themselves — the builder receives a
/// `(context, hovered)` pair and decides what visual to apply.
///
/// Example:
/// ```dart
/// Hoverable(
///   builder: (context, hovered) => Container(
///     color: hovered ? Colors.white.withValues(alpha: 0.04) : null,
///     child: ...,
///   ),
/// )
/// ```
///
/// Touch / pen / stylus pointers don't trigger the hover state —
/// `MouseRegion`'s default behavior already handles that. Phone /
/// touch-only tests pass without any per-platform branching.
class Hoverable extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered) builder;

  /// Whether to enable the hover behavior. False → wraps the builder
  /// with `hovered: false` and no MouseRegion; useful for disabled
  /// rows that shouldn't visually respond to mouse-over.
  final bool enabled;

  const Hoverable({
    super.key,
    required this.builder,
    this.enabled = true,
  });

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.builder(context, false);
    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _hovered = false);
      },
      child: widget.builder(context, _hovered),
    );
  }
}
