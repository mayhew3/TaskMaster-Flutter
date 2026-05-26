import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/family/presentation/family_tab_screen.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/family/providers/family_task_filter_providers.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';
import 'package:taskmaestro/features/shared/presentation/wide/aura_stack.dart';
import 'package:taskmaestro/features/shared/presentation/wide/selectable_task_item.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_centered_column.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/context.dart' as ctx;
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-382: same two contracts as task_list_screen_test, but for the
/// Family screen — the wide sidebar hosts its own search field, so the
/// in-AppBar toggle hides at the wide breakpoint; the AppBar search
/// input is 250ms-debounced. Family already used `ref.listen` for the
/// external-clear sync, so it was immune to the build-time-sync bug
/// the Tasks screen had — but we test the same debounce contract for
/// symmetry.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required Size logical,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        // Body data path stubbed empty — render without touching Drift.
        familyGroupedTasksProvider.overrideWith(
          (ref) => const <TaskGroupResult>[],
        ),
        // AppBar's ConnectionStatusIndicator.
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
        syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
        // Drawer reads.
        authProvider.overrideWith(_FakeAuth.new),
        currentFamilyDocIdProvider.overrideWith((ref) => null),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: FamilyTabScreen()),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('compact viewport shows the AppBar search toggle (TM-382)', (
    tester,
  ) async {
    await pump(tester, logical: const Size(800, 600));
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets(
    'wide viewport hides the AppBar search toggle — the sidebar owns it '
    '(TM-382)',
    (tester) async {
      await pump(tester, logical: const Size(1280, 800));
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets(
    'in-AppBar search debounces: family surface filters.search updates '
    '~250ms after typing (TM-382)',
    (tester) async {
      final c = await pump(tester, logical: const Size(800, 600));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      final field = find.byType(TextField);
      expect(field, findsOneWidget);

      await tester.enterText(field, 'gifts');
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        c
            .read(taskListViewStateProvider(TaskListSurface.family))
            .filters
            .search,
        '',
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        c
            .read(taskListViewStateProvider(TaskListSurface.family))
            .filters
            .search,
        'gifts',
      );
    },
  );

  testWidgets('external clear of the family surface search syncs the AppBar '
      'controller (TM-382)', (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gifts');
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      c.read(taskListViewStateProvider(TaskListSurface.family)).filters.search,
      'gifts',
    );

    // External clear via the notifier (e.g. tab nav).
    c
        .read(taskListViewStateProvider(TaskListSurface.family).notifier)
        .setSearch('');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '');
  });

  testWidgets('closing the search bar cancels a pending debounce (TM-382)', (
    tester,
  ) async {
    final c = await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gifts');
    await tester.pump(const Duration(milliseconds: 100)); // timer pending
    expect(
      c.read(taskListViewStateProvider(TaskListSurface.family)).filters.search,
      '',
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      c.read(taskListViewStateProvider(TaskListSurface.family)).filters.search,
      '',
    );
  });

  testWidgets('opening the search bar seeds the controller from the family '
      "surface's current filters.search (TM-382)", (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    c
        .read(taskListViewStateProvider(TaskListSurface.family).notifier)
        .setSearch('externalFam');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'externalFam');
    expect(
      field.controller!.selection,
      const TextSelection.collapsed(offset: 'externalFam'.length),
    );
  });

  testWidgets('compact→wide resize keeps the close icon reachable when the '
      'search bar is open (TM-382 regression)', (tester) async {
    await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);

    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  // ─── TM-383: wide-shell integration ──────────────────────────────
  //
  // The triple wrap (`WideCenteredColumn` → `AuraStack` →
  // `ListView.builder` with `SelectableTaskItem`-wrapped tiles) lands
  // on the non-empty path of the Family screen too. The Tasks-screen
  // tests don't cover this — Family has its own `_FamilyTaskTile` with
  // `isMine` ownership gating that the Tasks tile doesn't have. These
  // pin the wrap presence; selection-tap behavior is exercised at the
  // tile level in `editable_task_item_selection_test.dart`.
  Future<ProviderContainer> pumpWithTasks(
    WidgetTester tester, {
    required Size logical,
    required List<TaskItem> tasks,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    final group = TaskGroupResult(
      key: 'g',
      displayName: '',
      displayOrder: 1,
      tasks: tasks,
    );

    final container = ProviderContainer(
      overrides: [
        familyGroupedTasksProvider.overrideWith((ref) => [group]),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
        syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
        authProvider.overrideWith(_FakeAuth.new),
        currentFamilyDocIdProvider.overrideWith((ref) => null),
        personDocIdProvider.overrideWith((ref) => 'test-person'),
        // _FamilyTaskTile renders EditableTaskItemWidget which would
        // otherwise open Drift via areaColors / contexts and trip the
        // !timersPending invariant (memory project_drift_flutter_test
        // _interaction).
        areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
        contextsProvider.overrideWith(
          (ref) => Stream.value(const <ctx.Context>[]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: FamilyTabScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  TaskItem _task(String docId, String name) {
    return TaskItem(
      (b) => b
        ..docId = docId
        ..name = name
        ..personDocId = 'test-person'
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc(),
    );
  }

  // `WideCenteredColumn` is always in the tree on the non-empty path
  // (it's a pass-through on compact, a wrap on wide). The observable
  // contract is whether the chain produces a `ConstrainedBox(maxWidth:
  // 720)` — that's the actual visual cap.
  Finder findCenteredWrap() => find.byWidgetPredicate(
    (w) =>
        w is ConstrainedBox &&
        w.constraints.maxWidth == WideCenteredColumn.maxWidth,
  );

  testWidgets('on wide + non-empty, the body is wrapped in WideCenteredColumn '
      '(720dp cap) + AuraStack + per-row SelectableTaskItem (TM-383)', (
    tester,
  ) async {
    await pumpWithTasks(
      tester,
      logical: const Size(1280, 800),
      tasks: [_task('docA', 'Family Task A')],
    );
    expect(
      findCenteredWrap(),
      findsAtLeastNWidgets(1),
      reason: 'expected the 720dp cap on wide',
    );
    expect(find.byType(AuraStack), findsOneWidget);
    expect(find.byType(SelectableTaskItem), findsAtLeastNWidgets(1));
  });

  testWidgets('on compact + non-empty, no 720dp wrap on the body (TM-383)', (
    tester,
  ) async {
    await pumpWithTasks(
      tester,
      logical: const Size(800, 600),
      tasks: [_task('docA', 'Family Task A')],
    );
    expect(
      findCenteredWrap(),
      findsNothing,
      reason: 'phone path: WideCenteredColumn returns child unchanged',
    );
  });

  testWidgets(
      'on wide + empty tiles, the empty-state path renders the centered '
      'Text card directly (no list wrap) (TM-383)', (tester) async {
    // Empty family — the default pump uses an empty groupedTasks
    // override, which exercises the `tiles.isEmpty` branch.
    await pump(tester, logical: const Size(1280, 800));
    // The empty-state body is `Center(Padding(Text(...)))` — no
    // ListView, no WideCenteredColumn at all on that path.
    expect(
      findCenteredWrap(),
      findsNothing,
      reason: 'empty-state path is not wrapped in the 720dp column',
    );
    expect(find.byType(AuraStack), findsNothing);
    expect(
      find.textContaining('No active tasks in your family yet'),
      findsOneWidget,
    );
  });

  testWidgets('on wide, the Family tab add-task FAB is hidden — the sidebar '
      '"+ Add task" is the canonical add affordance there (TM-384)',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(find.byType(FloatingActionButton), findsNothing,
        reason: 'wide layouts must not show a duplicate add-task FAB '
            'next to the sidebar\'s "+ Add task" button');
  });

  testWidgets('on compact, the Family tab add-task FAB is present (TM-384 '
      '/ behavior-preserving for phone)', (tester) async {
    await pump(tester, logical: const Size(800, 600));
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

class _FakeAuth extends Auth {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

class _FakeSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;
}
