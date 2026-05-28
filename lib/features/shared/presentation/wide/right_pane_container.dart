import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/task_colors.dart';
import '../../providers/selected_task_providers.dart';
import 'docked_task_editor_pane.dart';
import 'docked_view_options_pane.dart';
import 'right_pane_empty_state.dart';

/// Wide-layout right-pane container (TM-383 Story 2 of Epic TM-188).
///
/// Switches on [rightPaneProvider] to decide which surface to render:
/// [RightPaneMode.editor] / `.addingNewTask` land the docked editor
/// (TM-384); [RightPaneMode.viewOptions] lands the View Options side
/// panel (TM-385); `.empty` shows the idle background.
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
        // TM-385: View Options side panel (handle when collapsed,
        // panel + resize divider when expanded — DockedViewOptionsPane
        // reads the per-surface state itself).
        RightPaneMode.viewOptions => const DockedViewOptionsPane(),
      },
    );
  }
}
