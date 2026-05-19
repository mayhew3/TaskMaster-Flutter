import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/features/family/presentation/pending_invitation_banner.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/app_drawer.dart';
import 'package:taskmaestro/features/shared/presentation/wide/sidebar_locked_row.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_nav_sidebar.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sync/presentation/sync_conflict_banner.dart';
import 'package:taskmaestro/features/sync/providers/sync_conflict_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/task_list_view.dart';
import 'package:taskmaestro/models/top_nav_item.dart';

/// TM-382 — wide adaptive shell + Direction-A sidebar (Story 1 of TM-188).
/// `_AuthenticatedHome` is private and intentionally not exposed; the
/// shell's `isWideLayout`-driven branch is pinned by the form_factor unit
/// tests, and a small `_ShellHarness` mirrors that branch so the sidebar's
/// behaviour can be exercised end-to-end.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Area area(String name, int order) => Area((b) => b
    ..docId = name.toLowerCase()
    ..name = name
    ..sortOrder = order
    ..personDocId = 'p1'
    ..dateAdded = DateTime.utc(2026, 1, 1));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required Size logical,
    List<Area> areas = const [],
    Map<String, int> counts = const {},
    int conflicts = 0,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      areasProvider.overrideWith((ref) => Stream.value(areas)),
      areaTaskCountsProvider.overrideWith((ref) => Stream.value(counts)),
      authProvider.overrideWith(_FakeAuth.new),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      pendingInvitationsForMeProvider
          .overrideWith((ref) => const Stream.empty()),
      allConflictsCountProvider.overrideWith((ref) => conflicts),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: _ShellHarness()),
    ));
    await tester.pump(); // drain the overridden stream emissions
    return container;
  }

  testWidgets('wide viewport renders the sidebar, not the bottom nav',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(find.byType(WideNavSidebar), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('compact 800x600 renders the bottom nav, not the sidebar',
      (tester) async {
    await pump(tester, logical: const Size(800, 600));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(WideNavSidebar), findsNothing);
  });

  testWidgets('tapping a sidebar destination switches tab + body',
      (tester) async {
    final c = await pump(tester, logical: const Size(1280, 800));
    expect(find.text('BODY:Plan'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pump(); // drain setTab microtask
    await tester.pumpAndSettle();

    expect(c.read(activeTabIndexProvider), 2);
    expect(find.text('BODY:Stats'), findsOneWidget);
  });

  testWidgets('tapping an Area scopes the Tasks filter + switches to Tasks',
      (tester) async {
    final c = await pump(
      tester,
      logical: const Size(1280, 800),
      areas: [area('Work', 0), area('Home', 1)],
      counts: {'work': 3},
    );
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(c.read(activeTabIndexProvider), 1); // Tasks
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .filters
          .areas
          .toSet(),
      {'Work'},
    );

    // Tapping the active scope again clears it back to "all areas".
    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .filters
          .areas
          .toSet(),
      isEmpty,
    );
  });

  testWidgets('Coming Soon rows render locked and are non-interactive',
      (tester) async {
    final c = await pump(tester, logical: const Size(1280, 800));
    expect(find.byType(SidebarLockedRow), findsNWidgets(3));
    expect(find.text('Yearly Goals'), findsOneWidget);
    expect(find.text('SOON'), findsNWidgets(3));

    final before = c.read(activeTabIndexProvider);
    await tester.tap(find.text('Yearly Goals'), warnIfMissed: false);
    await tester.pump();
    expect(c.read(activeTabIndexProvider), before);
  });

  testWidgets(
      'both banners are hosted in the wide layout; sync banner shows when '
      'conflicts > 0', (tester) async {
    await pump(tester, logical: const Size(1280, 800), conflicts: 2);
    expect(find.byType(PendingInvitationBanner), findsOneWidget);
    expect(find.byType(SyncConflictBanner), findsOneWidget);
    expect(
      find.text('2 sync conflicts need your attention.'),
      findsOneWidget,
    );
    expect(find.text('Resolve'), findsOneWidget);
  });

  testWidgets('typing in the sidebar search updates searchQueryProvider',
      (tester) async {
    final c = await pump(tester, logical: const Size(1280, 800));
    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    await tester.enterText(field, 'report');
    await tester.pump();

    expect(c.read(searchQueryProvider), 'report');
  });

  testWidgets('tapping the profile footer opens the AppDrawer',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(find.byType(AppDrawer), findsNothing); // closed initially

    await tester.tap(find.text('User')); // _FakeAuth → no user → "User"
    await tester.pumpAndSettle();

    expect(find.byType(AppDrawer), findsOneWidget);
  });
}

/// Unauthenticated stand-in so the footer/AppDrawer `authProvider` read
/// never touches Firebase.
class _FakeAuth extends Auth {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

class _Body extends StatelessWidget {
  const _Body(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text('BODY:$label'));
}

/// Mirrors `_AuthenticatedHome`'s `isWideLayout`-driven chrome branch with
/// a trivial nav-item set and body, so the sidebar can be driven in tests
/// without exposing the private production shell.
class _ShellHarness extends ConsumerWidget {
  const _ShellHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = <TopNavItem>[
      TopNavItem.init(
          label: 'Plan',
          icon: Icons.assignment,
          widgetGetter: () => const _Body('Plan')),
      TopNavItem.init(
          label: 'Tasks',
          icon: Icons.list,
          widgetGetter: () => const _Body('Tasks')),
      TopNavItem.init(
          label: 'Stats',
          icon: Icons.show_chart,
          widgetGetter: () => const _Body('Stats')),
    ];
    final idx =
        ref.watch(activeTabIndexProvider).clamp(0, navItems.length - 1);
    final body = navItems[idx].widgetGetter();

    if (isWideLayout(MediaQuery.sizeOf(context))) {
      return Scaffold(
        drawer: const AppDrawer(),
        body: Row(
          children: [
            WideNavSidebar(
              navItems: navItems,
              selectedIndex: idx,
              onSelectDestination: (i) =>
                  ref.read(activeTabIndexProvider.notifier).setTab(i),
            ),
            Expanded(
              child: Column(
                children: [
                  const PendingInvitationBanner(),
                  const SyncConflictBanner(),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) =>
            ref.read(activeTabIndexProvider.notifier).setTab(i),
        destinations: [
          for (final n in navItems)
            NavigationDestination(icon: Icon(n.icon), label: n.label),
        ],
      ),
    );
  }
}
