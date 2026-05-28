import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/right_pane_width_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/task_list_view.dart';
import 'package:taskmaestro/models/top_nav_item.dart';

/// TM-385 — `rightPaneWidthProvider` returns the pixel width the
/// right pane should occupy. Width is dynamic only for
/// `RightPaneMode.viewOptions`; other modes resolve to the fixed
/// `kRightPaneWidth` baseline.
///
/// Tests override [activeSurfaceProvider] directly so the width
/// behavior is exercised independent of the active-tab + active-sprint
/// resolution chain (which has its own tests in `wide_shortcuts_test`
/// and via the sidebar / docked-pane tests).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer({
    TaskListSurface? surface = TaskListSurface.sprint,
  }) {
    final container = ProviderContainer(overrides: [
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      activeSurfaceProvider.overrideWith((ref) => surface),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('returns kRightPaneWidth for RightPaneMode.empty (default)', () {
    final c = makeContainer();
    expect(c.read(rightPaneProvider), RightPaneMode.empty);
    expect(c.read(rightPaneWidthProvider), kRightPaneWidth);
  });

  test('returns kRightPaneWidth for RightPaneMode.editor', () {
    final c = makeContainer();
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
    expect(c.read(rightPaneWidthProvider), kRightPaneWidth);
  });

  test('returns kRightPaneWidth for RightPaneMode.addingNewTask', () {
    final c = makeContainer();
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.addingNewTask);
    expect(c.read(rightPaneWidthProvider), kRightPaneWidth);
  });

  group('RightPaneMode.viewOptions', () {
    test('expanded + default ratio 1.0 → kViewOptionsExpandedMax', () {
      final c = makeContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      expect(c.read(rightPaneWidthProvider), kViewOptionsExpandedMax);
    });

    test('expanded + ratio 0.0 → kViewOptionsExpandedMin', () {
      final c = makeContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      c
          .read(taskListViewStateProvider(TaskListSurface.sprint).notifier)
          .setViewOptionsExpandedRatio(0.0);
      expect(c.read(rightPaneWidthProvider), kViewOptionsExpandedMin);
    });

    test('expanded + ratio 0.5 → midpoint of [min, max]', () {
      final c = makeContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      c
          .read(taskListViewStateProvider(TaskListSurface.sprint).notifier)
          .setViewOptionsExpandedRatio(0.5);
      expect(
        c.read(rightPaneWidthProvider),
        (kViewOptionsExpandedMin + kViewOptionsExpandedMax) / 2,
      );
    });

    test('collapsed → kViewOptionsHandleWidth (regardless of ratio)', () {
      final c = makeContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      final sprint = TaskListSurface.sprint;
      c.read(taskListViewStateProvider(sprint).notifier)
          .setViewOptionsExpandedRatio(0.5);
      c.read(taskListViewStateProvider(sprint).notifier)
          .setViewOptionsCollapsed(true);
      expect(c.read(rightPaneWidthProvider), kViewOptionsHandleWidth);
    });

    test('width is per-surface — different active surfaces resolve to '
        'their own persisted ratios', () {
      // Surface: tasks, expanded ratio default 1.0 → max.
      final c = makeContainer(surface: TaskListSurface.tasks);
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      expect(c.read(rightPaneWidthProvider), kViewOptionsExpandedMax);

      // Override the active surface to family with a narrower ratio.
      c
          .read(taskListViewStateProvider(TaskListSurface.family).notifier)
          .setViewOptionsExpandedRatio(0.0);
      // Flip the active surface override; we'd dispose+rebuild in production
      // when activeTabIndex changes — here we directly tear down + remake.
      // (The test pins per-surface width semantics, not the source of the
      // surface change.)
      final c2 = ProviderContainer(overrides: [
        personDocIdProvider.overrideWith((ref) => 'test-person'),
        currentFamilyDocIdProvider.overrideWith((ref) => null),
        activeSurfaceProvider.overrideWith((ref) => TaskListSurface.family),
      ]);
      addTearDown(c2.dispose);
      c2.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      c2
          .read(taskListViewStateProvider(TaskListSurface.family).notifier)
          .setViewOptionsExpandedRatio(0.0);
      expect(c2.read(rightPaneWidthProvider), kViewOptionsExpandedMin,
          reason: 'family surface reads its own persisted ratio, not '
              'the tasks-surface ratio from the previous container');
    });

    test('null active surface (Stats) → kRightPaneWidth fallback '
        "(defensive — View Options button isn't rendered on Stats)", () {
      final c = makeContainer(surface: null);
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      expect(c.read(rightPaneWidthProvider), kRightPaneWidth);
    });
  });

  /// TM-385 — `activeSurfaceProvider` is the one canonical mapping
  /// shared by the sidebar, right pane width, docked View Options
  /// pane, and keyboard shortcuts. Every consumer should observe the
  /// same surface for the same tab state, including the Plan-tab
  /// branch that conditions on `activeSprintProvider` (the source of
  /// truth `WideNavSidebar._activeFilterSurface` previously held
  /// privately).
  group('activeSurfaceProvider canonical mapping', () {
    ProviderContainer makeContainerFor({
      required NavDestination dest,
      Sprint? activeSprint,
    }) {
      final container = ProviderContainer(overrides: [
        personDocIdProvider.overrideWith((ref) => 'test-person'),
        currentFamilyDocIdProvider.overrideWith((ref) => null),
        activeNavDestinationProvider.overrideWith((ref) => dest),
        activeSprintProvider.overrideWith((ref) => activeSprint),
      ]);
      addTearDown(container.dispose);
      return container;
    }

    test('Tasks → TaskListSurface.tasks', () {
      final c = makeContainerFor(dest: NavDestination.tasks);
      expect(c.read(activeSurfaceProvider), TaskListSurface.tasks);
    });

    test('Family → TaskListSurface.family', () {
      final c = makeContainerFor(dest: NavDestination.family);
      expect(c.read(activeSurfaceProvider), TaskListSurface.family);
    });

    test('Plan WITH active sprint → TaskListSurface.sprint', () {
      final sprint = Sprint((b) => b
        ..docId = 'sprint-1'
        ..personDocId = 'test-person'
        ..sprintNumber = 1
        ..numUnits = 2
        ..unitName = 'weeks'
        ..startDate = DateTime.utc(2026, 1, 1)
        ..endDate = DateTime.utc(2026, 1, 14)
        ..dateAdded = DateTime.now().toUtc());
      final c = makeContainerFor(
        dest: NavDestination.plan,
        activeSprint: sprint,
      );
      expect(c.read(activeSurfaceProvider), TaskListSurface.sprint);
    });

    test('Plan WITHOUT active sprint → TaskListSurface.plan '
        '(regression for R2 bug — pre-fix, this returned .sprint '
        'unconditionally, mismatching the ViewOptionsButton(surface: '
        'TaskListSurface.plan) call site in plan_task_list.dart)', () {
      final c = makeContainerFor(
        dest: NavDestination.plan,
        activeSprint: null,
      );
      expect(c.read(activeSurfaceProvider), TaskListSurface.plan);
    });

    test('Stats → null', () {
      final c = makeContainerFor(dest: NavDestination.stats);
      expect(c.read(activeSurfaceProvider), isNull);
    });
  });
}
