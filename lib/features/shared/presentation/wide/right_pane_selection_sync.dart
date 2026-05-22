import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/selected_task_providers.dart';

/// Bridges [selectedTaskProvider] → [rightPaneProvider] in the wide shell
/// (TM-384).
///
/// - Non-null selection → [RightPaneMode.editor] (docked editor takes
///   over the right pane in edit-mode for the selected task).
/// - Null selection AND current mode is [RightPaneMode.editor] (i.e.
///   the editor was previously opened by selecting a task and the
///   user re-tapped to deselect) → [RightPaneMode.empty] ("Select a
///   task" empty state). The downgrade is gated on `current == .editor`
///   so explicit user actions that clear selection alongside an
///   intentional mode (e.g. the sidebar "+ Add task" button clearing
///   selection and setting [RightPaneMode.addingNewTask]) don't get
///   clobbered back to `.empty` by the listener firing on the
///   selection-clear half of that operation.
///
/// Only mounted in the wide adaptive shell — `selectedTaskProvider` is
/// wide-only. The listener is wired once in `initState` via
/// `ref.listenManual` (not in `build`), matching the lifecycle pattern
/// the aura layer (TM-383) uses.
///
/// Renders [child] unchanged.
class RightPaneSelectionSync extends ConsumerStatefulWidget {
  final Widget child;

  const RightPaneSelectionSync({super.key, required this.child});

  @override
  ConsumerState<RightPaneSelectionSync> createState() =>
      _RightPaneSelectionSyncState();
}

class _RightPaneSelectionSyncState
    extends ConsumerState<RightPaneSelectionSync> {
  ProviderSubscription<String?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.listenManual<String?>(
      selectedTaskProvider,
      (prev, next) {
        final paneNotifier = ref.read(rightPaneProvider.notifier);
        if (next != null) {
          paneNotifier.setMode(RightPaneMode.editor);
        } else {
          // Only downgrade if the editor was selection-driven. Leave
          // `.addingNewTask` / `.viewOptions` / `.empty` alone — those
          // were set by explicit user intent and shouldn't be clobbered
          // by a selection-clear that happens to coincide.
          final current = ref.read(rightPaneProvider);
          if (current == RightPaneMode.editor) {
            paneNotifier.setMode(RightPaneMode.empty);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.close();
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
