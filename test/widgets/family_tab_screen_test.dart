import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/features/family/presentation/family_tab_screen.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/family/providers/family_task_filter_providers.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
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

    final container = ProviderContainer(overrides: [
      // Body data path stubbed empty — render without touching Drift.
      familyGroupedTasksProvider
          .overrideWith((ref) => const <TaskGroupResult>[]),
      // AppBar's ConnectionStatusIndicator.
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
      // Drawer reads.
      authProvider.overrideWith(_FakeAuth.new),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: FamilyTabScreen()),
    ));
    await tester.pump();
    return container;
  }

  testWidgets(
      'compact viewport shows the AppBar search toggle (TM-382)',
      (tester) async {
    await pump(tester, logical: const Size(800, 600));
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets(
      'wide viewport hides the AppBar search toggle — the sidebar owns it '
      '(TM-382)', (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
      'in-AppBar search debounces: family surface filters.search updates '
      '~250ms after typing (TM-382)', (tester) async {
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
