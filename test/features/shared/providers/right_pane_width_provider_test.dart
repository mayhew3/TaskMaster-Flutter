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
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-385 — `rightPaneWidthProvider` returns the pixel width the
/// right pane should occupy. Width is dynamic only for
/// `RightPaneMode.viewOptions`; other modes resolve to the fixed
/// `kRightPaneWidth` baseline.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer({bool inFamily = false}) {
    final container = ProviderContainer(overrides: [
      // SelectedTask / RightPane watch personDocIdProvider; activeNav
      // reads currentFamilyDocId. Stub both so the auth chain doesn't
      // try to wire up Firebase Auth in this unit-test environment.
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => inFamily ? 'fam-1' : null),
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
      // Default active tab is Plan (index 0); active destination maps
      // to Plan → TaskListSurface.sprint, which has a default ratio
      // of 1.0 (per TM-385 _setDefaults hook).
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      expect(c.read(rightPaneWidthProvider), kViewOptionsExpandedMax);
    });

    test('expanded + ratio 0.0 → kViewOptionsExpandedMin', () {
      final c = makeContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      // Plan tab is the default active destination → sprint surface.
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

    test('width is per-surface — switching tab while in .viewOptions '
        'flips to the new surface\'s ratio', () {
      // Make sure Family destination is available — the active-nav
      // mapping for tab index 2 requires inFamily=true.
      final c = makeContainer(inFamily: true);
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);

      // Plan (default tab=0) → sprint surface: set narrow.
      c.read(taskListViewStateProvider(TaskListSurface.sprint).notifier)
          .setViewOptionsExpandedRatio(0.0);
      expect(c.read(rightPaneWidthProvider), kViewOptionsExpandedMin);

      // Switch to Tasks (tab=1) → tasks surface (uses default ratio=1.0).
      c.read(activeTabIndexProvider.notifier).setTab(1);
      // setTab uses scheduleMicrotask; drain it.
      return Future<void>.delayed(Duration.zero).then((_) {
        expect(c.read(rightPaneWidthProvider), kViewOptionsExpandedMax,
            reason: 'switching to Tasks tab should expose the tasks '
                'surface\'s independent persisted ratio (default 1.0)');
      });
    });

    test('Stats destination has no list surface → falls back to '
        'kRightPaneWidth (defensive — View Options button isn\'t '
        'rendered on Stats)', () {
      // Without Family, tabs are [Plan(0), Tasks(1), Stats(2)].
      final c = makeContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      c.read(activeTabIndexProvider.notifier).setTab(2);
      return Future<void>.delayed(Duration.zero).then((_) {
        expect(c.read(rightPaneWidthProvider), kRightPaneWidth,
            reason: 'Stats destination → no TaskListSurface → no '
                'per-surface view state to read; defensive fallback '
                'is the baseline kRightPaneWidth');
      });
    });
  });
}
