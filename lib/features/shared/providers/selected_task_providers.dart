import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_task_providers.g.dart';

/// Currently-selected task on the wide layout, by `docId`. `null` means
/// no row is selected. (TM-383 Story 2 of Epic TM-188.)
///
/// On the wide adaptive shell, tapping a task row in the center list pane
/// sets this provider AND toggles the existing
/// `expandedTaskProvider` (inline accordion); both providers co-fire so
/// the accordion and the right pane stay in sync. On the compact / phone
/// path this provider is never written — taps only flip the accordion as
/// before TM-383.
///
/// Reset on destination switch via `ActiveTabIndex.setTab` (the same
/// microtask block that clears `searchQueryProvider` /
/// `recentlyCompletedTasksProvider`), so navigating away never leaves a
/// stale selection ringing on a tab the user can no longer see. The
/// magenta selection ring (`SelectableTaskItem`) reads this provider via
/// `select` to limit rebuilds to the single row whose membership flipped.
///
/// `keepAlive` matches the other UI-state notifiers in this directory
/// (`ActiveTabIndex`, `ExpandedTask`) so reattaching consumers after a
/// rebuild see the same selection without a default-state flash.
@Riverpod(keepAlive: true)
class SelectedTask extends _$SelectedTask {
  @override
  String? build() => null;

  void select(String docId) {
    if (state == docId) return;
    state = docId;
  }

  void clear() {
    if (state == null) return;
    state = null;
  }
}

/// What the contextual right pane is showing right now (TM-383 scaffold).
///
/// Story 2 only ever sets [empty]; [editor] and [viewOptions] are the
/// scaffolded states that TM-384 (docked editor) and TM-385 (View-Options
/// side panel) will switch into. They're declared now so the container
/// switch is exhaustive and Story 3 / Story 4 don't have to widen the
/// enum.
enum RightPaneMode { empty, editor, viewOptions }

/// Current right-pane mode for the wide adaptive shell (TM-383).
///
/// Reset to [RightPaneMode.empty] on destination switch alongside
/// [SelectedTask] so a stale `.editor` from another destination never
/// outlives the tab swap. `keepAlive` for the same reason as
/// `SelectedTask`.
@Riverpod(keepAlive: true)
class RightPane extends _$RightPane {
  @override
  RightPaneMode build() => RightPaneMode.empty;

  void setMode(RightPaneMode mode) {
    if (state == mode) return;
    state = mode;
  }
}
