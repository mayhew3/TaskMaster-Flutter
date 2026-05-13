import 'package:flutter/material.dart';

/// Section header for a [TaskGroupResult] bucket. Visually matches the
/// pre-TM-359 `HeadingItem` (uppercase + bodySmall) but adds a leading
/// chevron that rotates 90° when collapsed, a trailing count badge, and
/// taps to toggle. Tappable only when [onTap] is non-null; otherwise it
/// renders identically to `HeadingItem`.
class CollapsibleGroupHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool collapsed;
  final VoidCallback? onTap;

  const CollapsibleGroupHeader({
    super.key,
    required this.label,
    required this.count,
    required this.collapsed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final smallStyle = Theme.of(context).textTheme.bodySmall;
    final dimColor = (smallStyle?.color ?? Colors.white).withValues(alpha: 0.65);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: [
          AnimatedRotation(
            turns: collapsed ? -0.25 : 0,
            duration: const Duration(milliseconds: 120),
            child: Icon(
              Icons.expand_more,
              size: 16,
              color: dimColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: smallStyle,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: dimColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: (smallStyle ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w600,
                color: dimColor,
              ),
            ),
          ),
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
