import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/database/app_database.dart' hide Area, Context;
import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/docked_view_options_pane.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/right_pane_width_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/top_nav_item.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/context.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-385 Step 5 — DockedViewOptionsPane: handle when collapsed,
/// panel + resize divider when expanded. The pane reads the per-
/// surface View Options state from `taskListViewStateProvider`.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpPane(
    WidgetTester tester, {
    double paneWidth = kRightPaneWidth,
    int activeTabIndex = 1, // Tasks
    bool inFamily = false,
    bool initialCollapsed = false,
    double? initialRatio,
  }) async {
    // In-memory Drift so any provider chain that reaches for the
    // database resolves to a real-but-disposable DB (MEMORY:
    // project_drift_flutter_test_interaction — the View Options
    // content chain pulls in a few providers that indirectly touch
    // Drift even with the area/context-providers stubbed).
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => inFamily ? 'fam-1' : null),
      // Stub the Drift-touching providers ViewOptionsPanelContent's
      // children reach for, so the test doesn't open the database.
      areasWithDefaultsProvider.overrideWith(() => _StubAreas(const [])),
      contextsWithDefaultsProvider
          .overrideWith(() => _StubContexts(const [])),
    ]);
    addTearDown(container.dispose);
    // The pane is pumped directly, bypassing RightPaneContainer's
    // mode routing. The rightPaneWidthProvider gates dynamic width
    // on mode == .viewOptions; set it so the resize-divider's
    // startWidth read reflects the expanded ratio (not the fallback
    // kRightPaneWidth).
    container
        .read(rightPaneProvider.notifier)
        .setMode(RightPaneMode.viewOptions);
    // Set active destination → maps to a TaskListSurface in the pane.
    container.read(activeTabIndexProvider.notifier).setTab(activeTabIndex);
    // Seed per-surface View Options state BEFORE first pump so the
    // pane renders its initial layout at a size that fits paneWidth
    // (otherwise the expanded panel overflows a 44dp container).
    final dest = _destForIndex(activeTabIndex, inFamily: inFamily);
    final surface = surfaceForDestination(dest);
    if (surface != null) {
      final notifier =
          container.read(taskListViewStateProvider(surface).notifier);
      // SharedPreferences mock state persists across tests in the same
      // setUp block — reset to clear any state a prior test wrote.
      notifier.reset();
      if (initialCollapsed) notifier.setViewOptionsCollapsed(true);
      if (initialRatio != null) notifier.setViewOptionsExpandedRatio(initialRatio);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: paneWidth,
              child: const DockedViewOptionsPane(),
            ),
          ),
        ),
      ),
    );
    // `setTab` deferred its state mutation via scheduleMicrotask;
    // tester.pump drains microtasks (Future.delayed(Duration.zero)
    // doesn't — it would hang in flutter_test's fake-async zone).
    await tester.pump();
    await tester.pump();
    return container;
  }

  testWidgets('collapsed → renders the 44dp handle (sliders icon + label) '
      '(TM-385)', (tester) async {
    await pumpPane(
      tester,
      paneWidth: kViewOptionsHandleWidth,
      initialCollapsed: true,
    );

    expect(find.byIcon(Icons.tune), findsOneWidget,
        reason: 'collapsed handle shows the sliders icon');
    expect(find.text('VIEW OPTIONS'), findsOneWidget,
        reason: 'collapsed handle shows the rotated label');
  });

  testWidgets('expanded → renders the panel content (header + Apply bar) '
      '(TM-385)', (tester) async {
    // Pump at max-width to avoid the View Options form's internal
    // overflow at narrower widths (a known shape concern — the form
    // was designed for full-screen bottom sheet width; small overflows
    // at 380dp are visual nits the user can resize past).
    await pumpPane(tester, paneWidth: kViewOptionsExpandedMax);

    expect(find.text('Apply Changes'), findsOneWidget,
        reason: 'expanded pane renders the panel\'s sticky Apply bar');
    expect(find.text('Cancel'), findsOneWidget);
    // The handle's rotated label is NOT rendered when expanded.
    expect(find.text('VIEW OPTIONS'), findsNothing);
  });

  testWidgets('handle icon tap toggles expanded (TM-385)', (tester) async {
    // Pump at expanded-max width so the post-tap expanded layout can
    // render without overflow (in production, rightPaneWidthProvider
    // would size the SizedBox externally to match the new state).
    final c = await pumpPane(
      tester,
      paneWidth: kViewOptionsExpandedMax,
      initialCollapsed: true,
    );

    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks))
          .viewOptionsCollapsed,
      isTrue,
    );

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pump();

    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks))
          .viewOptionsCollapsed,
      isFalse,
      reason: 'tapping the handle\'s sliders icon must flip the per-'
          'surface viewOptionsCollapsed flag back to false',
    );
  });

  testWidgets('resize divider drag-right shrinks the ratio (TM-385)',
      (tester) async {
    final c = await pumpPane(tester, paneWidth: kViewOptionsExpandedMax);
    // Start at default ratio = 1.0. Drag-right (positive dx) at the
    // divider should shrink the pane (lower the ratio).

    // Find the MouseRegion with resize cursor as the divider.
    final divider = find.byWidgetPredicate(
      (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeLeftRight,
    );
    expect(divider, findsOneWidget);

    final initialRatio = c
        .read(taskListViewStateProvider(TaskListSurface.tasks))
        .viewOptionsExpandedRatio;
    expect(initialRatio, 1.0);

    final startCenter = tester.getCenter(divider);
    // Drag 100dp right with the mouse. The exact delta-to-ratio
    // mapping depends on the test framework's drag event batching;
    // we only assert the SHAPE of the change (shrinks, doesn't
    // collapse, stays within bounds). Exact width math is unit-
    // tested via `rightPaneWidthProvider`.
    await tester.dragFrom(
      startCenter,
      const Offset(100, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();

    final newRatio = c
        .read(taskListViewStateProvider(TaskListSurface.tasks))
        .viewOptionsExpandedRatio;
    expect(newRatio, lessThan(initialRatio),
        reason: 'drag-right must reduce the ratio');
    expect(newRatio, greaterThanOrEqualTo(0.0),
        reason: 'ratio stays within [0, 1]');
    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks))
          .viewOptionsCollapsed,
      isFalse,
      reason: 'a non-collapse-snap drag must not collapse the panel',
    );
  });

  testWidgets('drag below collapse-snap threshold collapses the panel '
      '(TM-385)', (tester) async {
    final c = await pumpPane(
      tester,
      paneWidth: kViewOptionsExpandedMin,
      initialRatio: 0.0, // start at min width = 340
    );

    final divider = find.byWidgetPredicate(
      (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeLeftRight,
    );
    final startCenter = tester.getCenter(divider);
    // Drag 50dp right from min — width becomes 290, below the
    // collapse-snap threshold (340 - 20 = 320). Should snap to
    // collapsed instead of clamping to min.
    await tester.dragFrom(
      startCenter,
      const Offset(50, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();

    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks))
          .viewOptionsCollapsed,
      isTrue,
      reason: 'drag past kViewOptionsCollapseSnapThreshold must snap '
          'to collapsed — the tactile "drag to close" affordance',
    );
  });

  testWidgets('Stats destination → pane renders SizedBox.shrink (defensive)',
      (tester) async {
    // Tabs without family: [Plan(0), Tasks(1), Stats(2)].
    await pumpPane(tester, activeTabIndex: 2);

    // Defensive case — no header, no handle, just nothing.
    expect(find.byIcon(Icons.tune), findsNothing);
    expect(find.text('Apply Changes'), findsNothing);
  });
}

// Index → NavDestination mapping mirrors riverpod_app.dart's
// liveNavItems layout (Plan, Tasks, [Family?], Stats).
NavDestination _destForIndex(int idx, {required bool inFamily}) {
  if (idx == 0) return NavDestination.plan;
  if (idx == 1) return NavDestination.tasks;
  if (inFamily && idx == 2) return NavDestination.family;
  return NavDestination.stats;
}

/// Sync AsyncValue.data stubs so the Drift stream backing the dropdowns
/// inside ViewOptionsPanelContent doesn't open the database and leak
/// cleanup timers (MEMORY: project_drift_flutter_test_interaction).
class _StubAreas extends AreasWithDefaults {
  _StubAreas(this._areas);
  final List<Area> _areas;
  @override
  AsyncValue<List<Area>> build() => AsyncValue.data(_areas);
}

class _StubContexts extends ContextsWithDefaults {
  _StubContexts(this._contexts);
  final List<Context> _contexts;
  @override
  AsyncValue<List<Context>> build() => AsyncValue.data(_contexts);
}
