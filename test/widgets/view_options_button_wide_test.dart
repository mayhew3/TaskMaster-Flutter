import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/database/app_database.dart' hide Area, Context;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/view_options_sheet.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-385 — `ViewOptionsButton.onPressed` is layout-aware. On the
/// two-pane wide layout it flips `rightPaneProvider` to `.viewOptions`
/// and force-expands the panel for the active surface (so a previously
/// collapsed panel re-opens visible). On phone / sub-two-pane wide it
/// keeps the pre-TM-385 bottom-sheet behavior.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpButton(
    WidgetTester tester, {
    required Size viewportSize,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = viewportSize;
    addTearDown(tester.view.reset);

    // `.viewOptions` mode build cascades into Drift-touching providers
    // even when only the button is mounted (the button itself just
    // reads `taskListViewStateProvider`). Override defensively so
    // sub-two-pane wide tests still don't open the real database.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            // AppBar so the IconButton renders in its expected
            // ancestry; ViewOptionsButton is designed for AppBar
            // actions.
            appBar: AppBar(
              actions: const [
                ViewOptionsButton(surface: TaskListSurface.tasks),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('two-pane wide tap → sets .viewOptions + force-expands the '
      'panel; no bottom sheet pushed (TM-385)', (tester) async {
    final c = await pumpButton(tester, viewportSize: const Size(1280, 800));
    // Pre-state: user previously collapsed the panel for this surface.
    c
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setViewOptionsCollapsed(true);

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
    await tester.tap(find.byTooltip('View options'));
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.viewOptions,
        reason: 'two-pane wide tap must flip the right pane into '
            '.viewOptions mode');
    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks))
          .viewOptionsCollapsed,
      isFalse,
      reason: 'tap must force-expand the panel — a user who '
          'previously collapsed it sees the full UI on re-open',
    );
    expect(find.byType(BottomSheet), findsNothing,
        reason: 'no bottom sheet pushed on wide');
  });

  testWidgets('sub-two-pane wide tap → still pushes the bottom sheet '
      '(no right pane to host the panel) (TM-385)', (tester) async {
    // 1100×800 = wide enough for the sidebar but below the two-pane
    // threshold (<1200dp). The right pane isn't rendered, so the
    // panel can't dock anywhere — keep the bottom sheet.
    final c = await pumpButton(tester, viewportSize: const Size(1100, 800));

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
    await tester.tap(find.byTooltip('View options'));
    await tester.pumpAndSettle();

    expect(c.read(rightPaneProvider), RightPaneMode.empty,
        reason: 'sub-two-pane wide must NOT flip the right pane mode '
            '(no right pane exists to render the panel)');
    expect(find.byType(BottomSheet), findsOneWidget,
        reason: 'sub-two-pane wide must push the bottom sheet');
  });

  testWidgets('phone tap → pushes the bottom sheet (TM-385 — phone path '
      'unchanged)', (tester) async {
    final c = await pumpButton(tester, viewportSize: const Size(400, 800));

    await tester.tap(find.byTooltip('View options'));
    await tester.pumpAndSettle();

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
