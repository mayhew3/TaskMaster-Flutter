import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/form_factor.dart';
import '../../providers/selected_task_providers.dart';
import 'aura_stack.dart';

/// Marks a task row as the **selected row** so the parent-level
/// [AuraStack] can locate it and paint the magenta selection aura at its
/// bounds (TM-383 Story 2 of Epic TM-188).
///
/// This widget no longer paints the aura itself; that responsibility
/// moved to [AuraStack] at the list-body level so the aura paints BELOW
/// all rows in z-order (per-row painting bled the aura over the row
/// above because of `ListView`'s sequential paint order — see
/// `AuraStack`'s docstring for the geometry).
///
/// All this widget does:
///   - On wide AND selected: wraps [child] in a [KeyedSubtree] with a
///     [GlobalObjectKey] keyed by [taskDocId] so [AuraStack]'s aura
///     layer can `findRenderObject()` and read the row's bounds.
///   - On compact OR unselected: returns [child] unchanged (no
///     wrapper, no key, no rebuild surface).
///
/// The rebuild surface is narrowed by `select`ing only the membership
/// boolean for this row's docId — flipping selection between two rows A
/// and B rebuilds only those two rows, not the whole list.
class SelectableTaskItem extends ConsumerWidget {
  final String taskDocId;
  final Widget child;

  const SelectableTaskItem({
    super.key,
    required this.taskDocId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = isWideLayout(MediaQuery.sizeOf(context));
    if (!wide) return child;

    final selected =
        ref.watch(selectedTaskProvider.select((id) => id == taskDocId));
    if (!selected) return child;

    // Only the SELECTED row gets the GlobalObjectKey, so there's never
    // more than one row in the tree carrying it — Flutter would throw
    // "duplicate GlobalKey" otherwise.
    return KeyedSubtree(
      key: SelectableTaskItemKey.of(taskDocId),
      child: child,
    );
  }
}
