import 'package:flutter/widgets.dart';

/// Inherited contract by which a wide-shell wrapper supplies the
/// "shell tap" behavior to a leaf task row (TM-385 Story 4 of Epic
/// TM-188).
///
/// ## Why this exists
///
/// Pre-TM-385, `EditableTaskItemWidget._summaryRow.onTap` mixed three
/// concerns:
///   1. accordion toggle (leaf-row state)
///   2. `isWideLayout` form-factor check (shell-layout policy)
///   3. `selectedTaskProvider` write with tap-same-to-clear logic
///      (shell-level state)
///
/// TM-383's parallel-review flagged the (2)+(3) coupling as a leak —
/// the leaf row shouldn't know about wide-layout policy or the
/// shell's selection provider. This policy is the seam: the wide-
/// shell wrapper [SelectableTaskItem] installs a [SelectionTapPolicy]
/// over its child; the leaf row consults `maybeOf(context)` inside
/// its tap handler and invokes `onShellTap()`. On compact (where
/// [SelectableTaskItem] returns its child unchanged) no policy is
/// installed and the row defaults to accordion-only behavior —
/// matching pre-TM-383 phone semantics.
///
/// ## What the leaf row calls
///
/// ```dart
/// onTap: () {
///   SelectionTapPolicy.maybeOf(context)?.onShellTap();
///   if (canExpand) ref.read(expandedTaskProvider.notifier).toggle(...);
/// }
/// ```
///
/// The policy's `onShellTap` is called BEFORE the accordion toggle so
/// they fire in lockstep on wide (same frame, no visual stagger).
///
/// ## Why InheritedWidget instead of a constructor callback
///
/// `EditableTaskItemWidget` is constructed at the row's call site
/// (Tasks list, Family list, Sprint list, Plan list). Threading a
/// `onShellTap: VoidCallback?` through its constructor would force
/// every call site to plumb the wide-layout / selection logic — the
/// exact coupling TM-385 is removing. An InheritedWidget lets the
/// wrapper install the policy without the row's constructor having
/// to know about it.
class SelectionTapPolicy extends InheritedWidget {
  /// Invoked from the leaf row's tap handler. Implementations
  /// typically write to `selectedTaskProvider` (toggle-on-same, set
  /// otherwise) — see [SelectableTaskItem].
  final VoidCallback onShellTap;

  const SelectionTapPolicy({
    super.key,
    required this.onShellTap,
    required super.child,
  });

  /// Returns the nearest [SelectionTapPolicy] ancestor, or `null` if
  /// the row isn't wrapped in one (compact path). The leaf row uses
  /// the null-check as its "no shell policy here, just do accordion"
  /// branch.
  static SelectionTapPolicy? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectionTapPolicy>();

  @override
  bool updateShouldNotify(SelectionTapPolicy old) =>
      onShellTap != old.onShellTap;
}
