import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  static const stats = NavTab(label: 'Stats', icon: Icons.show_chart, index: 2);

  static const List<NavTab> all = [plan, tasks, stats];
}

/// Provider for the currently active tab index
/// Using keepAlive to persist across widget rebuilds
@Riverpod(keepAlive: true)
class ActiveTabIndex extends _$ActiveTabIndex {
  @override
  int build() => 0; // Default to Plan tab

  void setTab(int index) {
    if (index >= 0 && index < NavTabs.all.length) {
      state = index;
    }
  }
}
