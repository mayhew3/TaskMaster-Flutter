import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/database/app_database.dart' hide Area, Context;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/view_options_summary_bar.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-385 — ViewOptionsSummaryBar: chip row under the wide-shell app
/// bar that shows the active surface's group axis + sort axis +
/// sort direction. Tapping a chip opens the View Options panel.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpBar(
    WidgetTester tester, {
    int activeTabIndex = 1, // default Tasks
  }) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    container.read(activeTabIndexProvider.notifier).setTab(activeTabIndex);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: ViewOptionsSummaryBar(surface: TaskListSurface.tasks)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return container;
  }

  testWidgets('Tasks surface → shows GROUP + SORT chips with current labels '
      '(TM-385)', (tester) async {
    final c = await pumpBar(tester); // default Tasks tab
    // Default Tasks view: groupAxis=dueStatus, sortAxis=urgency,
    // direction=ascending → "Due Status" + "Urgency ↑".
    expect(find.text('GROUP'), findsOneWidget);
    expect(find.text('SORT'), findsOneWidget);
    expect(find.text('Due Status'), findsOneWidget);
    expect(find.text('Urgency ↑'), findsOneWidget);

    // Flip group axis → label updates.
    c
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setGroupAxis(TaskGroupAxis.area);
    await tester.pump();
    expect(find.text('Area'), findsOneWidget);
  });

  testWidgets('SORT chip shows ↓ when sort direction is descending '
      '(TM-385)', (tester) async {
    final c = await pumpBar(tester);
    c
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setSortDirection(SortDirection.descending);
    await tester.pump();

    expect(find.text('Urgency ↓'), findsOneWidget);
  });

  // Stats-destination test removed: the bar takes its surface as a
  // constructor param now, so there's no "active destination" branch
  // to test — each screen passes its own surface and Stats simply
  // never instantiates the bar.

  testWidgets('tap on GROUP chip opens the View Options panel (TM-385)',
      (tester) async {
    final c = await pumpBar(tester);
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    await tester.tap(find.text('GROUP'));
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.viewOptions,
        reason: 'GROUP chip tap must flip the pane mode to '
            '.viewOptions (same handler as the AppBar button)');
    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks))
          .viewOptionsCollapsed,
      isFalse,
      reason: 'tap must force-expand the panel for the active surface',
    );
  });
}
