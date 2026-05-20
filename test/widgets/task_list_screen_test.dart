import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/task_item.dart';

/// TM-382: the wide sidebar hosts its own search field, so the in-AppBar
/// search toggle on TaskListScreen is hidden at the wide breakpoint; and
/// the in-AppBar search input is debounced (250ms) so small-screen
/// typing isn't laggy. Also pins the regression from the debounce + the
/// old build-time controller-sync interaction (a mid-typing unrelated
/// rebuild used to wipe the typed text under the if-check).
/// File-scope so the regression test can push a new emission to force a
/// parent rebuild during the debounce window.
late StreamController<List<TaskItem>> _tasksController;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required Size logical,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    // Non-broadcast: events are buffered until the StreamProvider
    // subscribes, so the screen's first ref.watch lands in AsyncData
    // (no infinite-spinner loading state that would jam pumpAndSettle).
    _tasksController = StreamController<List<TaskItem>>();
    addTearDown(_tasksController.close);
    _tasksController.add(<TaskItem>[]);

    final container = ProviderContainer(overrides: [
      // Body data path stubbed empty so the screen renders without
      // touching Drift / Firestore.
      tasksWithRecurrencesProvider
          .overrideWith((ref) => _tasksController.stream),
      groupedTasksProvider.overrideWith((ref) async => const []),
      activeSprintProvider.overrideWith((ref) => null),
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
      child: const MaterialApp(home: TaskListScreen()),
    ));
    await tester.pump(); // drain initial stream emissions
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
    // The search bar itself only opens via the (now-hidden) toggle, so
    // it must be absent too.
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
      'in-AppBar search debounces: provider updates ~250ms after typing '
      '(TM-382)', (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    // Open the search bar.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    await tester.enterText(field, 'invoices');
    // Before the debounce fires the provider is still empty.
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.read(searchQueryProvider), '');
    // After the debounce fires the provider has the typed value.
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.read(searchQueryProvider), 'invoices');
  });

  testWidgets(
      'an unrelated provider tick during the debounce window does not '
      'wipe the typed text (TM-382 regression)', (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'inv');

    // Force a parent rebuild via an unrelated provider the screen
    // watches (`tasksWithRecurrencesProvider`) before the debounce fires
    // — under the old build-time if-check, the controller would have
    // been cleared here because searchQueryProvider was still empty.
    // A new list instance ensures Riverpod sees a value change.
    _tasksController.add(<TaskItem>[]);
    await tester.pump(const Duration(milliseconds: 100));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'inv',
        reason: 'mid-typing rebuild should NOT clear the controller');

    // Debounce still fires and lands the typed value in the provider.
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.read(searchQueryProvider), 'inv');
  });

  testWidgets(
      'external clear of searchQueryProvider syncs the AppBar controller '
      '(TM-382)', (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'inv');
    await tester.pump(const Duration(milliseconds: 300)); // past debounce
    expect(c.read(searchQueryProvider), 'inv');

    // External clear (e.g. tab nav fires this via setTab).
    c.read(searchQueryProvider.notifier).clear();
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '');
  });

  testWidgets(
      'closing the search bar cancels a pending debounce (TM-382)',
      (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'inv');
    await tester.pump(const Duration(milliseconds: 100)); // timer pending
    expect(c.read(searchQueryProvider), ''); // not yet committed

    // Tap the close icon (search toggle is now showing Icons.close).
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    // Way past the original debounce window.
    await tester.pump(const Duration(milliseconds: 300));

    // The pending timer must have been cancelled — otherwise it would
    // overwrite the just-cleared provider with 'inv'.
    expect(c.read(searchQueryProvider), '');
  });

  testWidgets(
      'opening the search bar seeds the controller from the current '
      'provider value (TM-382)', (tester) async {
    final c = await pump(tester, logical: const Size(800, 600));
    // Search set externally (e.g. via the wide sidebar before the user
    // resized back to compact).
    c.read(searchQueryProvider.notifier).set('externalFoo');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'externalFoo');
    expect(
      field.controller!.selection,
      const TextSelection.collapsed(offset: 'externalFoo'.length),
    );
  });

  testWidgets(
      'compact→wide resize keeps the close icon reachable when the '
      'search bar is open (TM-382 regression)', (tester) async {
    // Start on compact, open the search bar.
    await pump(tester, logical: const Size(800, 600));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Resize to wide — before the fix, the IconButton's collection-if
    // unconditionally hid on wide, orphaning the TextField with no way
    // to close it. The fix keeps the close icon as long as the bar is
    // open.
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}

/// Unauthenticated stand-in so `AppDrawer`'s `authProvider` read never
/// reaches Firebase.
class _FakeAuth extends Auth {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

class _FakeSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;
}
