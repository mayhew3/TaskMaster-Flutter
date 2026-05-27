import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../tasks/providers/task_providers.dart';
import '../../providers/selected_task_providers.dart';

/// Bridges [selectedTaskProvider] → [rightPaneProvider] in the wide shell
/// (TM-384).
///
/// - Non-null selection (with one exception, see below) AND the
///   selected task is editable by the current user →
///   [RightPaneMode.editor] (docked editor takes over for the
///   selected task). The exception: [RightPaneMode.addingNewTask] is
///   PRESERVED — the user is mid-typing a new task, and a coincident
///   row tap shouldn't silently discard their in-progress work.
///   Other modes ([RightPaneMode.empty], [RightPaneMode.editor],
///   [RightPaneMode.viewOptions]) all swap to the editor on a row
///   tap; this is the editor ⟺ View-Options structural exclusivity
///   per TM-385 D8 — selecting a task is the canonical "close View
///   Options" gesture.
///
///   Ownership guard: tapping a teammate's row (e.g. on the Family
///   tab where `_FamilyTaskTile` sets `onEdit: null` for tasks not
///   owned by the current user) selects the row (aura + accordion
///   expand) but doesn't open the editor — saved edits would either
///   clobber the `personDocId` or be rejected by Firestore rules.
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
        final current = ref.read(rightPaneProvider);
        if (next != null) {
          // Protect ONLY `.addingNewTask` — the user has in-progress
          // typed content that a coincident row tap shouldn't discard.
          // Other modes (`.empty`, `.editor`, `.viewOptions`) all
          // swap to the editor on a row tap; this is the editor ⟺
          // View-Options structural exclusivity (TM-385 D8) —
          // selecting a task is the canonical "close View Options"
          // gesture, and the user would otherwise be stuck in
          // `.viewOptions` with no way to surface the editor.
          if (current == RightPaneMode.addingNewTask) {
            return;
          }
          // Read-only guard: don't open the docked editor on a task
          // the current user can't edit. Mirrors the compact-path
          // contract `_FamilyTaskTile` enforces via `onEdit: null`
          // for teammate tasks — saving on someone else's task
          // would either clobber its `personDocId` (UpdateTask
          // rewrites the field from `personDocIdProvider`) or be
          // rejected by Firestore rules. Treat unknown ownership
          // (provider hasn't materialized the task yet) as editable
          // so a hot-path tap isn't silently lost on first frame.
          final task = ref.read(taskProvider(next));
          final myPersonDocId = ref.read(personDocIdProvider);
          if (task != null &&
              myPersonDocId != null &&
              task.personDocId != myPersonDocId) {
            return;
          }
          paneNotifier.setMode(RightPaneMode.editor);
        } else {
          // Only downgrade if the editor was selection-driven. Same
          // rationale: `.addingNewTask` / `.viewOptions` / `.empty`
          // were set explicitly and survive a selection-clear that
          // happens to coincide.
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
