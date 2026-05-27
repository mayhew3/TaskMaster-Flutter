import 'dart:ui' as ui;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/platform/form_factor.dart';
import '../../../models/task_list_view.dart';
import '../../../models/top_nav_item.dart';
import 'navigation_provider.dart';
import 'selected_task_providers.dart';
import 'task_list_view_providers.dart';

part 'right_pane_width_provider.g.dart';

/// Maps a top-nav [NavDestination] to its corresponding
/// [TaskListSurface], or returns null when the destination has no list
/// surface (Stats). Shared across the wide-shell helpers
/// ([rightPaneWidthProvider], `DockedViewOptionsPane`,
/// `WideShortcuts`) since multiple call sites resolve the same
/// mapping.
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
  final surface = surfaceForDestination(ref.watch(activeNavDestinationProvider));
  if (surface == null) return kRightPaneWidth;
  final view = ref.watch(taskListViewStateProvider(surface));
  if (view.viewOptionsCollapsed) return kViewOptionsHandleWidth;
  return ui.lerpDouble(
    kViewOptionsExpandedMin,
    kViewOptionsExpandedMax,
    view.viewOptionsExpandedRatio.clamp(0.0, 1.0),
  )!;
}
