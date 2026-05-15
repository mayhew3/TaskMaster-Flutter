import 'package:flutter/material.dart';

/// Section header for a [TaskGroupResult] bucket. Visually matches the
/// pre-TM-359 `HeadingItem` (uppercase + bodySmall) but adds a leading
/// chevron that rotates 90° when collapsed, count + points badges, and
/// taps to toggle. Tappable only when [onTap] is non-null; otherwise it
/// renders identically to `HeadingItem`.
class CollapsibleGroupHeader extends StatelessWidget {
  final String label;
  final int count;

  /// Optional sum of `gamePoints` across the group's tasks. When non-null
  /// and > 0, a second badge ("N pts") renders alongside the count.
  final int? pointsTotal;

  final bool collapsed;
  final VoidCallback? onTap;

  const CollapsibleGroupHeader({
    super.key,
    required this.label,
    required this.count,
    required this.collapsed,
    this.pointsTotal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final smallStyle = Theme.of(context).textTheme.bodySmall;
    final dimColor = (smallStyle?.color ?? Colors.white).withValues(alpha: 0.65);

    // Bumped vertical padding + icon size for a comfortable tap target —
    // the prior 3-px padding made the row near-impossible to hit on
    // touch devices.
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AnimatedRotation(
            turns: collapsed ? -0.25 : 0,
            duration: const Duration(milliseconds: 120),
            child: Icon(
              Icons.expand_more,
              size: 20,
              color: dimColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: (smallStyle ?? const TextStyle())
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          _CountChip(label: '$count', dimColor: dimColor),
          if (pointsTotal != null && pointsTotal! > 0) ...[
            const SizedBox(width: 6),
            _CountChip(label: '$pointsTotal pts', dimColor: dimColor),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final Color dimColor;
  const _CountChip({required this.label, required this.dimColor});

  @override
  Widget build(BuildContext context) {
    final smallStyle = Theme.of(context).textTheme.bodySmall;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: dimColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: (smallStyle ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
          color: dimColor,
        ),
      ),
    );
  }
}
