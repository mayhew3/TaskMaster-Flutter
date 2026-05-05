import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expanded_task_provider.g.dart';

/// Tracks which task card (if any) is currently expanded inline.
///
/// Accordion semantics: at most one card is expanded at a time across all
/// task lists. State is session-scoped (no `keepAlive`); switching tabs
/// collapses any open card.
@riverpod
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
