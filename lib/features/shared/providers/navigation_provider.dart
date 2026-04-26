import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../tasks/providers/task_filter_providers.dart';
import '../../tasks/providers/task_providers.dart';

part 'navigation_provider.g.dart';

/// Navigation tab definition for Riverpod-based navigation. The active index
/// is owned by [ActiveTabIndex] and the live tab order is determined by the
/// widget that renders the bottom-nav (currently the Riverpod app home in
/// `riverpod_app.dart`, which splices in the Family tab when in a family);
/// individual `NavTab` instances do not carry their own index.
class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

/// Predefined navigation tabs
class NavTabs {
  static const plan = NavTab(label: 'Plan', icon: Icons.assignment);
  static const tasks = NavTab(label: 'Tasks', icon: Icons.list);
  static const family =
      NavTab(label: 'Family', icon: Icons.family_restroom);
  static const stats = NavTab(label: 'Stats', icon: Icons.show_chart);

  static const List<NavTab> all = [plan, tasks, stats];

  /// Tabs visible to the current user. The Family tab is included only when
  /// [inFamily] is true; otherwise the layout matches the legacy 3-tab
  /// arrangement. Currently used as a reference layout — the live nav-item
  /// list is constructed inline in `riverpod_app.dart` so it can also wire
  /// up `widgetGetter` per tab.
  static List<NavTab> forUser({required bool inFamily}) {
    if (!inFamily) return [plan, tasks, stats];
    return [plan, tasks, family, stats];
  }
}

/// Provider for the currently active tab index
/// Using keepAlive to persist across widget rebuilds
@Riverpod(keepAlive: true)
class ActiveTabIndex extends _$ActiveTabIndex {
  @override
  int build() => 0; // Default to Plan tab

  void setTab(int index) {
    // Clamp to [0, maxIndex] where maxIndex is the last index in the
    // widest possible tab layout (4 tabs with the Family tab present).
    // riverpod_app.dart calls clampToLayout() when the live layout shrinks
    // so the stored value stays in range without each consumer needing to
    // clamp on read.
    final maxIndex = NavTabs.forUser(inFamily: true).length - 1;
    final clamped = index.clamp(0, maxIndex).toInt();
    // Clear recently completed tasks when navigating between tabs
    // This allows completed tasks to move from their original section
    // to the "Completed" section after navigation (TM-312)
    ref.read(recentlyCompletedTasksProvider.notifier).clear();
    ref.read(recentlyCompletedIndicesProvider.notifier).clear();
    ref.read(searchQueryProvider.notifier).clear();
    state = clamped;
  }

  /// Silently adjusts the stored index when a layout change makes it
  /// out of range. Unlike [setTab], this does NOT reset per-tab UI state
  /// (search query, recently-completed lists) because it is a layout-driven
  /// correction, not a user action.
  void clampToLayout(int liveTabCount) {
    final maxIndex = liveTabCount - 1;
    if (state > maxIndex) {
      state = maxIndex;
    }
  }
}
