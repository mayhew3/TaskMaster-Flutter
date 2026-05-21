import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/task_colors.dart';
import '../../providers/selected_task_providers.dart';
import 'right_pane_empty_state.dart';

/// Wide-layout right-pane container (TM-383 Story 2 of Epic TM-188).
///
/// Switches on [rightPaneProvider] to decide which surface to render.
/// Story 2 only ever lands [RightPaneMode.empty]; the [editor] and
/// [viewOptions] branches are scaffolded with explicit placeholder
/// widgets that reference the real follow-up Jira stories so the contract
/// is visible at a glance.
///
/// The container itself paints the deeper background (`TaskColors
/// .bgDeep`) so the right pane reads as visually distinct from both the
/// sidebar (brand blue) and the center column (background); matches the
/// prototype's `var(--bg-deep)`.
class RightPaneContainer extends ConsumerWidget {
  const RightPaneContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(rightPaneProvider);
    return Material(
      color: TaskColors.bgDeep,
      child: switch (mode) {
        RightPaneMode.empty => const RightPaneEmptyState(),
        RightPaneMode.editor => const _RightPaneEditorPlaceholder(),
        RightPaneMode.viewOptions => const _RightPaneViewOptionsPlaceholder(),
      },
    );
  }
}

/// Stand-in for the docked editor pane — landed by TM-384 (Story 3).
/// Visible only if someone manually flips [rightPaneProvider] to
/// [RightPaneMode.editor]; Story 2 never sets it.
// TODO(TM-384): replace with the docked editor pane.
class _RightPaneEditorPlaceholder extends StatelessWidget {
  const _RightPaneEditorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          'Editor pane lands in TM-384 (Story 3).',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: TaskColors.textFaint,
          ),
        ),
      ),
    );
  }
}

/// Stand-in for the View-Options side panel — landed by TM-385 (Story 4).
// TODO(TM-385): replace with the View-Options side panel.
class _RightPaneViewOptionsPlaceholder extends StatelessWidget {
  const _RightPaneViewOptionsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          'View Options panel lands in TM-385 (Story 4).',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: TaskColors.textFaint,
          ),
        ),
      ),
    );
  }
}
