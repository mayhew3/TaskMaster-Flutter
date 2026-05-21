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
        // TODO(TM-384): replace with the docked editor pane.
        RightPaneMode.editor => const _RightPanePlaceholder(
          'Editor pane lands in TM-384 (Story 3).',
        ),
        // TODO(TM-385): replace with the View-Options side panel.
        RightPaneMode.viewOptions => const _RightPanePlaceholder(
          'View Options panel lands in TM-385 (Story 4).',
        ),
      },
    );
  }
}

/// Stand-in for the not-yet-built right-pane surfaces ([RightPaneMode
/// .editor] / [RightPaneMode.viewOptions]). Story 2 never lands either
/// of those modes; the placeholder only shows if a future caller flips
/// the mode before Stories 3 / 4 ship.
class _RightPanePlaceholder extends StatelessWidget {
  final String message;
  const _RightPanePlaceholder(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: TaskColors.textFaint),
        ),
      ),
    );
  }
}
