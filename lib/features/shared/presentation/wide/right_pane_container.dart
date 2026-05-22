import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/task_colors.dart';
import '../../providers/selected_task_providers.dart';
import 'docked_task_editor_pane.dart';
import 'right_pane_empty_state.dart';

/// Wide-layout right-pane container (TM-383 Story 2 of Epic TM-188).
///
/// Switches on [rightPaneProvider] to decide which surface to render.
/// [RightPaneMode.editor] lands the docked editor (TM-384); the
/// [viewOptions] branch is still scaffolded with a placeholder that
/// references its follow-up Jira story.
///
/// Editor ⟺ View Options exclusivity is structural: [rightPaneProvider]
/// holds a single [RightPaneMode], so only one surface is ever active.
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
        // Editor handles both edit-mode (`.editor`, driven by selection)
        // and add-mode (`.addingNewTask`, opened by sidebar "+ Add task").
        // The pane reads `selectedTaskProvider` internally to pick which.
        RightPaneMode.editor => const DockedTaskEditorPane(),
        RightPaneMode.addingNewTask => const DockedTaskEditorPane(),
        // TODO(TM-385): replace with the View-Options side panel.
        RightPaneMode.viewOptions => const _RightPanePlaceholder(
          'View Options panel lands in TM-385 (Story 4).',
        ),
      },
    );
  }
}

/// Stand-in for the not-yet-built [RightPaneMode.viewOptions] surface.
/// TM-385 (Story 4) replaces it with the real View-Options side panel.
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
