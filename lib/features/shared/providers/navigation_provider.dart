import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../tasks/providers/task_filter_providers.dart';
import '../../tasks/providers/task_providers.dart';

part 'navigation_provider.g.dart';

/// Navigation tab definition for Riverpod-based navigation
class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
    required this.index,
  });

  final String label;
  final IconData icon;
  final int index;
}

/// Predefined navigation tabs
class NavTabs {
  static const plan = NavTab(label: 'Plan', icon: Icons.assignment, index: 0);
  static const tasks = NavTab(label: 'Tasks', icon: Icons.list, index: 1);
  // Family tab is appended dynamically when the user is in a family (TM-335);
  // its index is computed at render time so it slots in between Tasks and
  // Stats without breaking the existing static indices.
  static const family =
      NavTab(label: 'Family', icon: Icons.family_restroom, index: 2);
  static const stats = NavTab(label: 'Stats', icon: Icons.show_chart, index: 2);

  static const List<NavTab> all = [plan, tasks, stats];

  /// Tabs visible to the current user. The Family tab is included only when
  /// [inFamily] is true; otherwise the layout matches the legacy 3-tab
  /// arrangement.
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
    // The valid range depends on whether the Family tab is present, so the
    // widget layer is responsible for clamping. Treat any non-negative input
    // as valid here; the active screen is a switch on `index < navItems.length`.
    if (index >= 0) {
      // Clear recently completed tasks when navigating between tabs
      // This allows completed tasks to move from their original section
      // to the "Completed" section after navigation (TM-312)
      ref.read(recentlyCompletedTasksProvider.notifier).clear();
      ref.read(recentlyCompletedIndicesProvider.notifier).clear();
      ref.read(searchQueryProvider.notifier).clear();
      state = index;
    }
  }
}
