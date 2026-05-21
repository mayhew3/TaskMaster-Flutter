import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../tasks/providers/expanded_task_provider.dart';
import '../../tasks/providers/task_filter_providers.dart';
import '../../tasks/providers/task_providers.dart';
import 'selected_task_providers.dart';

part 'navigation_provider.g.dart';

/// Navigation tab definition for Riverpod-based navigation. The active index
/// is owned by [ActiveTabIndex] and the live tab order is determined by the
/// widget that renders the bottom-nav (currently the Riverpod app home in
/// `riverpod_app.dart`, which splices in the Family tab when in a family);
/// individual `NavTab` instances do not carry their own index.
class NavTab {
  const NavTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Predefined navigation tabs
class NavTabs {
  static const plan = NavTab(label: 'Plan', icon: Icons.assignment);
  static const tasks = NavTab(label: 'Tasks', icon: Icons.list);
  static const family = NavTab(label: 'Family', icon: Icons.family_restroom);
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
    // TM-361: defer the synchronous notification chain a microtask. The
    // NavigationBar onTap handler fires while the gesture pipeline is mid-
    // dispatch; under Riverpod 4, synchronously notifying watchers in that
    // window occasionally lands on a ConsumerStatefulElement that has
    // already begun unmounting (the previous tab body's children), and
    // `markNeedsBuild` on the defunct element throws an assertion. The
    // microtask hop lets the gesture pipeline unwind first, by which point
    // any in-flight unmounts have finished and the subscription set is
    // clean. No visible delay — runs before the next frame.
    scheduleMicrotask(() {
      // Guard against the notifier (and its ref) having been disposed
      // between the synchronous setTab call and this microtask firing.
      // Rapid teardown paths (sign-out / scope re-creation) can dispose
      // the keepAlive ActiveTabIndex before the microtask runs; touching
      // `ref.read` or `state =` on a disposed notifier throws. Bail out
      // cleanly — the new scope will rebuild from defaults anyway.
      if (!ref.mounted) return;
      _resetPerTabState();
      state = clamped;
    });
  }

  /// Resets transient per-tab UI state on every destination switch.
  /// Each clear is annotated with the ticket that added it so the
  /// rationale doesn't drift when the list grows.
  void _resetPerTabState() {
    // TM-312: completed tasks move from their original section to the
    // "Completed" section after navigation.
    ref.read(recentlyCompletedTasksProvider.notifier).clear();
    ref.read(recentlyCompletedIndicesProvider.notifier).clear();
    ref.read(searchQueryProvider.notifier).clear();
    // TM-383: clear the wide-layout selection + reset the right pane.
    // Phone never writes the selection providers; this is wide-only.
    ref.read(selectedTaskProvider.notifier).clear();
    ref.read(rightPaneProvider.notifier).setMode(RightPaneMode.empty);
    // TM-383: collapse the inline accordion on destination switch. This
    // is INTENTIONALLY a behavior change for BOTH compact and wide:
    //
    // - Wide: keeps the accordion in sync with `selectedTaskProvider`
    //   (the wide tap fires both, so they must reset together —
    //   otherwise a tap on a still-expanded card after a tab round-trip
    //   would flip them out of phase).
    // - Compact: previously the accordion survived tab switches (per
    //   ExpandedTask's keepAlive). The change makes it reset in line
    //   with the existing TM-312 / TM-359 reset pattern (search,
    //   recently-completed lists are already cleared here) so per-tab
    //   transient UI state is uniformly cleared on switch.
    //
    // The compact-behavior change was explicitly user-approved during
    // the TM-383 implementation iteration (the alternative was a
    // wide-only gate, which requires coupling this notifier to layout
    // state — rejected as too much plumbing for the marginal benefit
    // of preserving the prior phone behavior).
    ref.read(expandedTaskProvider.notifier).collapse();
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
