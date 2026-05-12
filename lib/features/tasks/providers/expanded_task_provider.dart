import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expanded_task_provider.g.dart';

/// Tracks which task card (if any) is currently expanded inline.
///
/// Accordion semantics: at most one card is expanded at a time across all
/// task lists. TM-361 promoted this to `keepAlive: true` so the
/// notifier survives transient widget unmount/remount under Riverpod 4
/// (e.g. during tab swaps when no consumer is currently mounted). The
/// expansion state therefore persists across tab swaps; reset it
/// explicitly when that's not desired.
@Riverpod(keepAlive: true)
class ExpandedTask extends _$ExpandedTask {
  @override
  String? build() => null;

  /// Expands [docId], collapsing whatever was open. Toggles to null when the
  /// already-expanded card is tapped again.
  void toggle(String docId) {
    state = state == docId ? null : docId;
  }

  /// Forces collapse (e.g. when navigating away).
  void collapse() {
    state = null;
  }
}
