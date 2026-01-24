import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../keys.dart';
import '../providers/navigation_provider.dart';

/// Riverpod-based bottom navigation bar
/// Replaces Redux TabSelector widget
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(activeTabIndexProvider);

    return NavigationBar(
      key: TaskMasterKeys.tabs,
      selectedIndex: activeIndex,
      onDestinationSelected: (index) {
        ref.read(activeTabIndexProvider.notifier).setTab(index);
      },
      destinations: NavTabs.all.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          label: tab.label,
        );
      }).toList(),
    );
  }
}
