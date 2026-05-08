import 'package:flutter/material.dart';

/// Rounded display chip used for Contexts and date-summary entries on the
/// edit-task screen. When [color] is supplied, the pill is tinted with a
/// translucent version of that color and shows a 7px dot to its left.
/// When [onRemove] is supplied, a ✕ button appears at the right.
class Pill extends StatelessWidget {
  final Widget label;
  final Widget? leading;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const Pill({
    required this.label,
    this.leading,
    this.color,
    this.onTap,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color == null
        ? Colors.white.withValues(alpha: 0.06)
        : color!.withValues(alpha: 0.16);
    final border = color == null
        ? Colors.white.withValues(alpha: 0.14)
        : color!.withValues(alpha: 0.40);

    final content = Container(
      padding: EdgeInsets.fromLTRB(
        leading == null && color == null ? 12 : 10,
        6,
        onRemove == null ? 12 : 6,
        6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 6),
          ],
          DefaultTextStyle.merge(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            child: label,
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            _RemoveButton(onPressed: onRemove!),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: content,
        ),
      );
    }
    return content;
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RemoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onPressed,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.20),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close,
          size: 12,
          color: Colors.white.withValues(alpha: 0.70),
        ),
      ),
    );
  }
}

/// Dashed pill with a ＋ icon, used to add a new entry to a chip group
/// (e.g. "+ Add" next to context pills).
class AddPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddPill({required this.label, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 13,
                color: Colors.white.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
