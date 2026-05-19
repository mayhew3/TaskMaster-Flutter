import 'package:flutter/material.dart';

import '../../../../models/task_colors.dart';

/// A collapsible labelled group in the wide-layout sidebar (TM-382):
/// Destinations / Areas / Coming Soon. The expand/collapse state is local
/// and ephemeral — persisting it is explicitly Story 4 (TM-385).
class SidebarSection extends StatefulWidget {
  const SidebarSection({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Widget> children;

  /// Optional header action (e.g. the Areas "+" → Manage Areas).
  final Widget? trailing;
  final bool initiallyExpanded;

  @override
  State<SidebarSection> createState() => _SidebarSectionState();
}

class _SidebarSectionState extends State<SidebarSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.chevron_right,
                      size: 15, color: TaskColors.textFaint),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(
                      color: TaskColors.textFaint,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
        if (_expanded) ...widget.children,
      ],
    );
  }
}
