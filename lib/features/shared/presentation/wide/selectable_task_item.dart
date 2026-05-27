import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/form_factor.dart';
import '../../../../models/task_list_view.dart' show TaskListSurface;
import '../../providers/selected_task_providers.dart';
import 'aura_stack.dart';
import 'selection_tap_policy.dart';

/// Marks a task row as the **selected row** so the parent-level
/// [AuraStack] can locate it and paint the magenta selection aura at its
/// bounds (TM-383 Story 2 of Epic TM-188).
///
/// TM-385: also installs a [SelectionTapPolicy] over the child so the
/// leaf [EditableTaskItemWidget._summaryRow.onTap] can drive the
/// wide-shell selection write WITHOUT reading form-factor or shell
/// providers itself. The policy's `onShellTap` does the tap-same-to-
/// clear / tap-different-to-swap logic against `selectedTaskProvider`.
///
/// This widget no longer paints the aura itself; that responsibility
/// moved to [AuraStack] at the list-body level so the aura paints BELOW
/// all rows in z-order (per-row painting bled the aura over the row
/// above because of `ListView`'s sequential paint order — see
/// `AuraStack`'s docstring for the geometry).
///
/// On wide:
///   - Wraps [child] in a [SelectionTapPolicy] so the leaf row's tap
///     handler can fire the selection write via `maybeOf(context)`.
///   - When this row is the selected row, additionally wraps in a
///     [KeyedSubtree] with a [GlobalObjectKey] keyed by ([surface],
///     [taskDocId]) so [AuraStack]'s aura layer can `findRenderObject()`
///     and read the row's bounds.
///
/// On compact: returns [child] unchanged (no policy, no key, no
/// rebuild surface). The leaf row's `SelectionTapPolicy.maybeOf` will
/// return null and the row defaults to accordion-only behavior —
/// matching pre-TM-383 phone semantics.
///
/// ## Why the key includes [surface]
///
/// The wide shell uses `IndexedStack` to keep all destination bodies
/// mounted simultaneously (so destination switches are instant). A
/// family-shared task that's also in the active sprint appears in BOTH
/// the Family tab AND the Plan tab's sprint view at the same time. If
/// the user selects that task, both `SelectableTaskItem` instances
/// would try to attach the same `GlobalObjectKey(_AuraRowKey(docId))` —
/// and Flutter throws a "Duplicate GlobalKey" error at runtime.
///
/// Scoping the key by surface guarantees each `AuraStack` (Tasks /
/// Family / Sprint) finds only its own surface's row, even when the
/// same docId is rendered in multiple lists at once.
///
/// The rebuild surface is narrowed by `select`ing only the membership
/// boolean for this row's docId — flipping selection between two rows A
/// and B rebuilds only those two rows, not the whole list.
class SelectableTaskItem extends ConsumerWidget {
  /// Which list surface this row belongs to. The wide shell renders
  /// multiple surfaces simultaneously via `IndexedStack`, so the same
  /// task docId can appear in more than one place at once — the
  /// surface scope keeps each surface's selection aura on its own key
  /// namespace.
  final TaskListSurface surface;
  final String taskDocId;
  final Widget child;

  const SelectableTaskItem({
    super.key,
    required this.surface,
    required this.taskDocId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = isWideLayout(MediaQuery.sizeOf(context));
    if (!wide) return child;

    final selected =
        ref.watch(selectedTaskProvider.select((id) => id == taskDocId));

    // Tap policy: a fresh closure every build so identity stays in
    // sync with the latest WidgetRef + taskDocId — InheritedWidget's
    // updateShouldNotify gates downstream rebuilds on closure
    // inequality, but since the captured taskDocId is constant per
    // instance the policy is effectively stable for a given row.
    Widget policyWrapped = SelectionTapPolicy(
      onShellTap: () {
        final notifier = ref.read(selectedTaskProvider.notifier);
        final current = ref.read(selectedTaskProvider);
        if (current == taskDocId) {
          notifier.clear();
        } else {
          notifier.select(taskDocId);
        }
      },
      child: child,
    );

    if (!selected) return policyWrapped;

    // Only the SELECTED row WITHIN THIS SURFACE gets the GlobalObjectKey,
    // so there's never more than one row in the tree carrying it —
    // Flutter would throw "Duplicate GlobalKey" otherwise.
    return KeyedSubtree(
      key: SelectableTaskItemKey.of(surface, taskDocId),
      child: policyWrapped,
    );
  }
}
