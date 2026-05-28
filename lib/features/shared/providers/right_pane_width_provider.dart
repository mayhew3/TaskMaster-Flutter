import 'dart:ui' as ui;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/platform/form_factor.dart';
import '../../../models/task_list_view.dart';
import '../../../models/top_nav_item.dart';
import '../../sprints/providers/sprint_providers.dart';
import 'navigation_provider.dart';
import 'selected_task_providers.dart';
import 'task_list_view_providers.dart';

part 'right_pane_width_provider.g.dart';

/// Currently-active [TaskListSurface] for the wide shell, or `null`
/// when the active destination has no list surface (Stats).
///
/// One canonical mapping shared across:
///   - [rightPaneWidthProvider] — which surface's persisted View
///     Options width to apply
///   - `DockedViewOptionsPane` — which surface's panel content to render
///   - `WideShortcuts` — which surface's grouped tasks j/k/c walk
///   - `WideNavSidebar._activeFilterSurface` — which surface's filters
///     the sidebar's area/context active-state pulls from
///
/// The Plan tab is the only branch that conditions on more than the
/// destination: with an active sprint it maps to
/// [TaskListSurface.sprint] (the sprint list's filters / group / sort
/// drive everything visible on the tab); without one, it maps to
/// [TaskListSurface.plan] (the sprint-creation / planning surface has
/// its own filter pipeline). `ViewOptionsButton(surface: ...)` already
/// makes this distinction at the call site in `plan_task_list.dart`;
/// this provider is the read-side counterpart so the sidebar and right
/// pane resolve the same surface for the same tab state.
@Riverpod(keepAlive: true)
TaskListSurface? activeSurface(Ref ref) {
  final dest = ref.watch(activeNavDestinationProvider);
  switch (dest) {
    case NavDestination.tasks:
      return TaskListSurface.tasks;
    case NavDestination.family:
      return TaskListSurface.family;
    case NavDestination.plan:
      return ref.watch(activeSprintProvider) != null
          ? TaskListSurface.sprint
          : TaskListSurface.plan;
    case NavDestination.stats:
      return null;
  }
}

/// Pure NavDestination → TaskListSurface mapping that IGNORES the
/// active-sprint distinction on the Plan tab (always returns
/// `.sprint`). For active-surface resolution that matches what the
/// View Options button and the sidebar use, prefer
/// [activeSurfaceProvider] (which conditions on
/// [activeSprintProvider] for the Plan tab).
///
/// Kept as a pure function for test mirrors and pure-mapping use
/// cases that don't have a `Ref` in scope.
TaskListSurface? surfaceForDestination(NavDestination dest) {
  switch (dest) {
    case NavDestination.tasks:
      return TaskListSurface.tasks;
    case NavDestination.family:
      return TaskListSurface.family;
    case NavDestination.plan:
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
///
/// ## Why this lives in its own file
///
/// Combines reads from `selected_task_providers` (`rightPaneProvider`)
/// and `navigation_provider` (`activeNavDestinationProvider`).
/// `navigation_provider` already depends on `selected_task_providers`
/// (for `RightPane`, `SelectedTask`, `ExpandedTask`); if this provider
/// lived in `selected_task_providers` it would have to import
/// `navigation_provider` and complete a Dart import cycle. The third
/// file breaks the cycle without forcing either side to know about
/// the other.
@Riverpod(keepAlive: true)
double rightPaneWidth(Ref ref) {
  final mode = ref.watch(rightPaneProvider);
  if (mode != RightPaneMode.viewOptions) return kRightPaneWidth;
  final surface = ref.watch(activeSurfaceProvider);
  if (surface == null) return kRightPaneWidth;
  final view = ref.watch(taskListViewStateProvider(surface));
  if (view.viewOptionsCollapsed) return kViewOptionsHandleWidth;
  return ui.lerpDouble(
    kViewOptionsExpandedMin,
    kViewOptionsExpandedMax,
    view.viewOptionsExpandedRatio.clamp(0.0, 1.0),
  )!;
}
