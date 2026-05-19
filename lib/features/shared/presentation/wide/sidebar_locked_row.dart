import 'package:flutter/material.dart';

import '../../../../models/task_colors.dart';

/// A disabled "Coming Soon" placeholder row in the wide-layout sidebar
/// (TM-382): Yearly Goals / Monthly Plan / Projects. Purely decorative —
/// no gesture handler, dimmed, and an "SOON" badge. Wrapped in
/// [IgnorePointer] so it cannot receive taps or focus.
class SidebarLockedRow extends StatelessWidget {
  const SidebarLockedRow({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.55,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Icon(icon, size: 20, color: TaskColors.textDim),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TaskColors.textDim,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TaskColors.hairline),
                ),
                child: Text(
                  'SOON',
                  style: TextStyle(
                    color: TaskColors.textFaint,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
