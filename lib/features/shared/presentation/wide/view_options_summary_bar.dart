import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/task_list_view.dart';
import '../../../family/providers/family_task_filter_providers.dart';
import '../../../sprints/presentation/sprint_task_items_screen.dart'
    show sprintGroupedTasksProvider;
import '../../../sprints/providers/sprint_providers.dart';
import '../../../tasks/providers/task_filter_providers.dart';
import '../../providers/selected_task_providers.dart';
import '../../providers/task_list_view_providers.dart';

const _kGroupAxisLabels = <TaskGroupAxis, String>{
  TaskGroupAxis.dueStatus: 'Due Status',
  TaskGroupAxis.none: 'None',
  TaskGroupAxis.priority: 'Priority',
  TaskGroupAxis.area: 'Area',
  TaskGroupAxis.points: 'Points',
  TaskGroupAxis.duration: 'Estimated Time',
};

const _kSortAxisLabels = <TaskSortAxis, String>{
  TaskSortAxis.urgency: 'Urgency',
  TaskSortAxis.dateAdded: 'Date Added',
  TaskSortAxis.points: 'Points',
  TaskSortAxis.area: 'Area',
  TaskSortAxis.duration: 'Estimated Time',
  TaskSortAxis.priority: 'Priority',
  TaskSortAxis.efficiency: 'Efficiency',
};

/// Wide-layout chip bar that surfaces the active list's group / sort
/// / total-count at a glance, regardless of whether the View Options
/// side panel is open or collapsed (TM-385).
///
/// Dropped into each per-surface screen's `AppBar.bottom` slot so it
/// renders BELOW the title bar and above the list body — matching
/// the prototype's `wide-view-options.jsx` `ViewOptionsSummaryBar`
/// placement. Implements [PreferredSizeWidget] so AppBar can size
/// its bottom region.
///
/// Renders nothing on surfaces without a list (Stats), so the bar
/// gracefully disappears when the user navigates there. (Stats has
/// no AppBar that hosts this; defensive only.)
///
/// Tapping the Group or Sort chip opens the View Options panel for
/// the active surface (the same handler `ViewOptionsButton` uses on
/// wide).
class ViewOptionsSummaryBar extends ConsumerWidget
    implements PreferredSizeWidget {
  /// The list surface this bar describes. Each screen passes its own
  /// surface — the bar doesn't read `activeNavDestinationProvider`
  /// (which would couple it to wide-shell tab state and force every
  /// per-screen test to seed that state).
  final TaskListSurface surface;

  const ViewOptionsSummaryBar({super.key, required this.surface});

  /// Approximate height: 10dp top padding + ~16dp chip height + 10dp
  /// bottom padding. Slight slack for line-height. Matches the
  /// `padding: const EdgeInsets.symmetric(...vertical: 10)` + the
  /// chip's intrinsic height.
  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskListViewStateProvider(surface));
    final groupLabel = _kGroupAxisLabels[view.groupAxis] ?? view.groupAxis.name;
    final sortLabel = _kSortAxisLabels[view.sortAxis] ?? view.sortAxis.name;
    final sortArrow = view.sortDirection == SortDirection.ascending ? '↑' : '↓';
    final count = _taskCount(ref);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _SummaryChip(
            label: 'GROUP',
            value: groupLabel,
            onTap: () => _openPanel(ref),
          ),
          const SizedBox(width: 7),
          _SummaryChip(
            label: 'SORT',
            value: '$sortLabel $sortArrow',
            onTap: () => _openPanel(ref),
          ),
          const Spacer(),
          if (count != null)
            Text(
              '$count tasks',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }

  void _openPanel(WidgetRef ref) {
    // Same wide-branch logic as ViewOptionsButton: force-expand for
    // this surface, flip mode → .viewOptions. Bypass the bottom-sheet
    // branch since the summary bar only renders on wide.
    ref
        .read(taskListViewStateProvider(surface).notifier)
        .setViewOptionsCollapsed(false);
    ref.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
  }

  /// Per-surface task count. Returns null when the surface doesn't
  /// have a sync-computable count (loading, no active sprint on Plan,
  /// etc.) — the bar then hides the count text instead of showing
  /// stale "0 tasks".
  int? _taskCount(WidgetRef ref) {
    switch (surface) {
      case TaskListSurface.tasks:
        final groups = ref.watch(groupedTasksProvider).value;
        if (groups == null) return null;
        return groups.fold<int>(0, (sum, g) => sum + g.tasks.length);
      case TaskListSurface.family:
        final groups = ref.watch(familyGroupedTasksProvider);
        return groups.fold<int>(0, (sum, g) => sum + g.tasks.length);
      case TaskListSurface.sprint:
        final sprint = ref.watch(activeSprintProvider);
        if (sprint == null) return null;
        // `sprintGroupedTasksProvider` is family-keyed by the active
        // Sprint and returns an AsyncValue<List<TaskGroupResult>>.
        // Skip the count until it resolves (the bar then hides the
        // count text rather than showing a stale "0 tasks").
        final groups = ref.watch(sprintGroupedTasksProvider(sprint)).value;
        if (groups == null) return null;
        return groups.fold<int>(0, (sum, g) => sum + g.tasks.length);
      case TaskListSurface.plan:
        // Planning surface has no single canonical count — skip.
        return null;
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 9, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

