import 'dart:ui' as ui;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/platform/form_factor.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../models/task_list_view.dart';
import '../../../models/top_nav_item.dart';
import 'navigation_provider.dart';
import 'task_list_view_providers.dart';

part 'selected_task_providers.g.dart';

/// Currently-selected task on the wide layout, by `docId`. `null` means
/// no row is selected. (TM-383 Story 2 of Epic TM-188.)
///
/// On the wide adaptive shell, tapping a task row in the center list
/// pane unconditionally sets/toggles this provider, AND — only when the
/// row `hasExpandableContent(...)` (per `EditableTaskItemWidget`'s tap
/// gate) — ALSO toggles `expandedTaskProvider`. So a wide tap on a
/// no-dates / no-notes row still selects the row (right pane stays in
/// sync) but does not flip the accordion (nothing to expand). On the
/// compact / phone path this provider is never written — taps only flip
/// the accordion (still gated by `canExpand`), same as before TM-383.
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
  String? build() {
    // Watch personDocId so a sign-out / user-switch resets selection.
    // keepAlive means this notifier survives provider-graph rebuilds;
    // without this watch, a stale docId from a previous user could
    // outlive the sign-out and render in the next user's wide pane.
    ref.watch(personDocIdProvider);
    return null;
  }

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
/// - [empty] — no selection, no add-in-progress; shows
///   `RightPaneEmptyState` with the "Select a task" prompt.
/// - [editor] — docked editor in **edit-mode** for the currently
///   selected task (selection-driven; the `RightPaneSelectionSync`
///   listener flips between this and [empty] as `selectedTaskProvider`
///   becomes non-null / null).
/// - [addingNewTask] — docked editor in **add-mode**, opened
///   explicitly by the sidebar "+ Add task" button on the wide
///   two-pane layout. Distinguished from [editor] so the selection
///   listener doesn't downgrade it to [empty] when the user clears
///   selection to start a new task (add-mode also has no selection,
///   but its mode was set by explicit user intent — not by selection
///   going null — so it must persist past the listener's null-
///   selection check).
/// - [viewOptions] — TM-385 (scaffolded; not yet implemented).
enum RightPaneMode { empty, editor, addingNewTask, viewOptions }

/// Current right-pane mode for the wide adaptive shell (TM-383).
///
/// Reset to [RightPaneMode.empty] on destination switch alongside
/// [SelectedTask] so a stale `.editor` from another destination never
/// outlives the tab swap. `keepAlive` for the same reason as
/// `SelectedTask`.
@Riverpod(keepAlive: true)
class RightPane extends _$RightPane {
  @override
  RightPaneMode build() {
    // Same rationale as [SelectedTask.build]: reset on user switch so
    // a stale `.editor` from the previous user doesn't outlive sign-out.
    ref.watch(personDocIdProvider);
    return RightPaneMode.empty;
  }

  void setMode(RightPaneMode mode) {
    if (state == mode) return;
    state = mode;
  }
}

/// Maps a top-nav [NavDestination] to its corresponding
/// [TaskListSurface], or returns null when the destination has no list
/// surface (Stats). Used by [rightPaneWidthProvider] to find the
/// per-surface View Options state for the active tab. Lives here
/// alongside the right-pane providers because that's the only
/// consumer; not promoted to a top-level utility until a second
/// caller needs it.
TaskListSurface? _surfaceForDestination(NavDestination dest) {
  switch (dest) {
    case NavDestination.tasks:
      return TaskListSurface.tasks;
    case NavDestination.family:
      return TaskListSurface.family;
    case NavDestination.plan:
      // Plan tab hosts the sprint-list view (and the create-sprint
      // flow). The View Options surface there is the sprint list's
      // own surface; the create-sprint pane has its own state.
      return TaskListSurface.sprint;
    case NavDestination.stats:
      return null;
  }
}

/// Pixel width the right pane should occupy in the current frame
/// (TM-385). Used by `_buildWideShell`'s `SizedBox(width: ...)`
/// wrapping `RightPaneContainer`.
///
/// Width is dynamic only for [RightPaneMode.viewOptions]; every other
/// mode uses the fixed [kRightPaneWidth] (380dp) that pre-TM-385
/// hard-coded.
///
/// View Options sizing:
///   - **Collapsed** (the per-surface `viewOptionsCollapsed` flag is
///     true): pane shrinks to [kViewOptionsHandleWidth] (44dp), making
///     room for the center list. The handle widget renders inside.
///   - **Expanded**: pane width is `lerp(min, max, ratio)` where the
///     ratio is the per-surface persisted value in `[0, 1]`. Default
///     ratio = 1.0 lands at [kViewOptionsExpandedMax].
///
/// The width is per-surface (Tasks remembers its width independently
/// from Plan), so tab-switching while in `.viewOptions` swaps both
/// the panel contents AND the width — desirable: a user who prefers
/// a wider panel on the Tasks tab can also prefer a narrower one on
/// Plan, and both stay sticky.
///
/// Stats tab has no list surface, so the width falls back to
/// [kRightPaneWidth] (defensive — the View Options button isn't
/// rendered on Stats anyway, so this branch should be unreachable in
/// production).
@Riverpod(keepAlive: true)
double rightPaneWidth(Ref ref) {
  final mode = ref.watch(rightPaneProvider);
  if (mode != RightPaneMode.viewOptions) return kRightPaneWidth;
  final surface = _surfaceForDestination(ref.watch(activeNavDestinationProvider));
  if (surface == null) return kRightPaneWidth;
  final view = ref.watch(taskListViewStateProvider(surface));
  if (view.viewOptionsCollapsed) return kViewOptionsHandleWidth;
  return ui.lerpDouble(
    kViewOptionsExpandedMin,
    kViewOptionsExpandedMax,
    view.viewOptionsExpandedRatio.clamp(0.0, 1.0),
  )!;
}
