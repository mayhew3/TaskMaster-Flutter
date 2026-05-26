import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/family/presentation/pending_invitation_banner.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/app_drawer.dart';
import 'package:taskmaestro/features/shared/providers/sidebar_facet_counts.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/sidebar_locked_row.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_nav_sidebar.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sync/presentation/sync_conflict_banner.dart';
import 'package:taskmaestro/features/sync/providers/sync_conflict_providers.dart';
import 'package:taskmaestro/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/context.dart';
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

  Context ctx(String name, int order) => Context((b) => b
    ..docId = name.toLowerCase()
    ..name = name
    ..sortOrder = order
    ..iconName = 'phone'
    ..personDocId = 'p1'
    ..dateAdded = DateTime.utc(2026, 1, 1));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required Size logical,
    List<Area> areas = const [],
    Map<String, int> counts = const {},
    List<Context> contexts = const [],
    Map<String, int> contextCounts = const {},
    int conflicts = 0,
    NavigatorObserver? observer,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      areasProvider.overrideWith((ref) => Stream.value(areas)),
      areaTaskCountsProvider.overrideWith((ref) => Stream.value(counts)),
      contextsProvider.overrideWith((ref) => Stream.value(contexts)),
      contextTaskCountsProvider
          .overrideWith((ref) => Stream.value(contextCounts)),
      // Keep the widget tests off the real per-surface base pipeline;
      // faceting correctness is covered by sidebar_facet_counts_test.
      sidebarFacetCountsProvider.overrideWith((ref, surface) async =>
          SidebarFacetCounts(areas: counts, contexts: contextCounts)),
      authProvider.overrideWith(_FakeAuth.new),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      pendingInvitationsForMeProvider
          .overrideWith((ref) => const Stream.empty()),
      allConflictsCountProvider.overrideWith((ref) => conflicts),
      activeSprintProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorObservers:
            observer != null ? [observer] : const <NavigatorObserver>[],
        home: const _ShellHarness(),
      ),
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

  testWidgets('tapping an Area scopes the active destination, no tab jump',
      (tester) async {
    // Default destination is Plan (index 0); activeSprint overridden null
    // → the plan surface. The Area tap must scope *that* list, not jump
    // to Tasks.
    final c = await pump(
      tester,
      logical: const Size(1280, 800),
      areas: [area('Work', 0), area('Home', 1)],
      counts: {'work': 3},
    );
    expect(c.read(activeTabIndexProvider), 0); // Plan
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(c.read(activeTabIndexProvider), 0); // still Plan — no jump
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.plan))
          .filters
          .areas
          .toSet(),
      {'Work'},
    );
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .filters
          .areas
          .toSet(),
      isEmpty,
    );

    // Tapping the active scope again clears it on the active surface.
    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.plan))
          .filters
          .areas
          .toSet(),
      isEmpty,
    );
  });

  testWidgets('tapping a Context scopes the active destination, no tab jump',
      (tester) async {
    final c = await pump(
      tester,
      logical: const Size(1280, 800),
      contexts: [ctx('Phone', 0), ctx('Computer', 1)],
      contextCounts: {'phone': 2},
    );
    expect(c.read(activeTabIndexProvider), 0); // Plan
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Computer'), findsOneWidget);

    await tester.tap(find.text('Phone'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(c.read(activeTabIndexProvider), 0); // still Plan — no jump
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.plan))
          .filters
          .contexts
          .toSet(),
      {'Phone'},
    );
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .filters
          .contexts
          .toSet(),
      isEmpty,
    );

    // Tapping the active scope again clears it on the active surface.
    await tester.tap(find.text('Phone'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(
      c
          .read(taskListViewStateProvider(TaskListSurface.plan))
          .filters
          .contexts
          .toSet(),
      isEmpty,
    );
  });

  testWidgets('Area row shows the active-surface faceted count',
      (tester) async {
    await pump(
      tester,
      logical: const Size(1280, 800),
      areas: [area('Work', 0)],
      counts: {'work': 3},
    );
    await tester.pumpAndSettle(); // let the async facet provider resolve
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets(
      'zero-count areas are hidden on a real surface, shown where counts '
      'do not apply', (tester) async {
    final c = await pump(
      tester,
      logical: const Size(1280, 800),
      areas: [area('Work', 0), area('Home', 1)],
      counts: {'work': 2}, // Home absent → count 0
    );
    await tester.pumpAndSettle();
    // Default destination is Plan → counts not meaningful → both show.
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Switch to Tasks (a real filterable surface) → zero-count hidden.
    await tester.tap(find.text('Tasks'));
    await tester.pump(); // setTab microtask
    await tester.pumpAndSettle(); // facet provider resolves
    expect(c.read(activeTabIndexProvider), 1);
    expect(find.text('Work'), findsOneWidget); // count 2 → shown
    expect(find.text('Home'), findsNothing); // count 0 → hidden
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

  testWidgets('search on the Tasks destination scopes the Tasks surface',
      (tester) async {
    final c = await pump(tester, logical: const Size(1280, 800));
    await tester.tap(find.text('Tasks'));
    await tester.pump(); // drain setTab microtask
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'report');
    await tester.pump(const Duration(milliseconds: 300)); // past debounce

    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks)).filters.search,
      'report',
    );
    // The tasks-only searchQueryProvider facade stays in sync.
    expect(c.read(searchQueryProvider), 'report');
  });

  testWidgets(
      'search on the Plan destination scopes the plan surface, not tasks',
      (tester) async {
    // Default destination is Plan (index 0); activeSprint overridden null
    // → the plan surface.
    final c = await pump(tester, logical: const Size(1280, 800));

    await tester.enterText(find.byType(TextField), 'groceries');
    await tester.pump(const Duration(milliseconds: 300)); // past debounce

    expect(
      c.read(taskListViewStateProvider(TaskListSurface.plan)).filters.search,
      'groceries',
    );
    expect(
      c.read(taskListViewStateProvider(TaskListSurface.tasks)).filters.search,
      isEmpty,
    );
  });

  testWidgets('search field is disabled on the Stats destination',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    await tester.tap(find.text('Stats'));
    await tester.pump(); // drain setTab microtask
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).enabled,
      isFalse,
    );
  });

  testWidgets(
      'X clear button appears once the user types, hidden when empty '
      '(TM-383)', (tester) async {
    await pump(tester, logical: const Size(1280, 800));

    // Empty field: no close icon (only the search prefix icon).
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.enterText(find.byType(TextField), 'report');
    await tester.pump();

    expect(find.byIcon(Icons.close), findsOneWidget,
        reason: 'X clear icon should appear once the field has text');
  });

  testWidgets(
      'tapping the X immediately clears the field AND the search '
      'provider (no debounce wait) (TM-383)', (tester) async {
    final c = await pump(tester, logical: const Size(1280, 800));
    await tester.tap(find.text('Tasks'));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'report');
    await tester.pump(const Duration(milliseconds: 300)); // past debounce
    expect(c.read(searchQueryProvider), 'report');

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    // No 250ms wait — clear commits immediately.
    expect(c.read(searchQueryProvider), '');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '');
    // And the X disappears now that the field is empty.
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets(
      'X is hidden when the field is disabled (Stats destination) even '
      'if there was prior text — defensive (TM-383)', (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    await tester.tap(find.text('Stats'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Disabled fields can't be typed into; double-check no X regardless.
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('tapping the profile footer opens the AppDrawer',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(find.byType(AppDrawer), findsNothing); // closed initially

    await tester.tap(find.text('User')); // _FakeAuth → no user → "User"
    await tester.pumpAndSettle();

    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets('tapping "Add task" at two-pane width opens the docked editor '
      'in add-mode (no route push) (TM-384)', (tester) async {
    final observer = _NavObserver();
    // 1280×800 → two-pane wide (≥1200dp).
    final c = await pump(tester,
        logical: const Size(1280, 800), observer: observer);
    expect(observer.pushed, hasLength(1)); // initial MaterialApp home

    // Seed a non-null selection AND an expanded accordion so the
    // post-tap assertions actually prove the sidebar's `clear()` +
    // `collapse()` calls ran (asserting isNull on a never-set provider
    // would pass trivially).
    c.read(selectedTaskProvider.notifier).select('seeded-selection');
    c.read(expandedTaskProvider.notifier).toggle('seeded-selection');
    expect(c.read(selectedTaskProvider), 'seeded-selection');
    expect(c.read(expandedTaskProvider), 'seeded-selection');

    await tester.tap(find.text('Add task'));
    await tester.pump();

    // No route pushed — the docked editor handles add-mode in the pane.
    expect(observer.pushed, hasLength(1));
    // Selection cleared by the sidebar handler before flipping mode,
    // and the pane flips to `.addingNewTask` — distinct from `.editor`
    // so the selection-sync listener doesn't immediately downgrade it.
    expect(c.read(selectedTaskProvider), isNull,
        reason: 'sidebar handler must clear() any prior selection so '
            'the add-mode body keys to "__add__", not to the prior '
            'task\'s docId');
    // Accordion collapsed alongside selection so the row's expanded
    // body doesn't linger while the pane is in add-mode (Copilot R1
    // pre-push review feedback).
    expect(c.read(expandedTaskProvider), isNull,
        reason: 'sidebar handler must also collapse() expandedTask so '
            'an open accordion does not desync from the add-mode pane');
    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask);
  });

  testWidgets('tapping "Add task" below two-pane width pushes the full-screen '
      'route (no right pane to host the editor) (TM-384)', (tester) async {
    final observer = _NavObserver();
    // 1100×800 → wide enough for the sidebar but below the two-pane
    // threshold (<1200dp); the right pane isn't rendered, so add still
    // uses the dedicated full-screen route (same as the phone FABs).
    await pump(tester,
        logical: const Size(1100, 800), observer: observer);
    expect(observer.pushed, hasLength(1));

    await tester.tap(find.text('Add task'));
    await tester.pump();

    expect(observer.pushed, hasLength(2));
    expect(observer.pushed.last, isA<MaterialPageRoute<void>>());
    // Default destination is Plan → defaultFamilyShared is false.
    // Extract from the pushed route's builder rather than via
    // `find.byType(TaskAddEditScreen)` — the latter is racy when
    // Drift-stream watchers aren't overridden in this harness.
    final pushedRoute = observer.pushed.last as MaterialPageRoute<void>;
    final pushedWidget = pushedRoute.builder(
      tester.element(find.byType(WideNavSidebar)),
    );
    expect(pushedWidget, isA<TaskAddEditScreen>());
    final screen = pushedWidget as TaskAddEditScreen;
    expect(screen.defaultFamilyShared, isFalse,
        reason: 'add-task from Plan destination must default to '
            'personal (not family-shared)');

    // Pop the pushed TaskAddEditScreen subtree so its controllers
    // (TextField cursor-blink Timer etc.) dispose before the
    // post-test pending-timer invariant check runs.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('on the Family destination, sub-two-pane "Add task" pushes the '
      'full-screen route with defaultFamilyShared: true — matches the '
      'compact Family-tab FAB behavior, which is hidden on wide (TM-384 '
      '— Copilot R3 review feedback)', (tester) async {
    final observer = _NavObserver();
    // Family destination requires being in a family + tab index 2.
    final container = ProviderContainer(overrides: [
      areasProvider.overrideWith((ref) => Stream.value(const <Area>[])),
      areaTaskCountsProvider
          .overrideWith((ref) => Stream.value(const <String, int>{})),
      contextsProvider.overrideWith((ref) => Stream.value(const <Context>[])),
      contextTaskCountsProvider
          .overrideWith((ref) => Stream.value(const <String, int>{})),
      sidebarFacetCountsProvider.overrideWith((ref, surface) async =>
          const SidebarFacetCounts(areas: {}, contexts: {})),
      authProvider.overrideWith(_FakeAuth.new),
      currentFamilyDocIdProvider.overrideWith((ref) => 'fam-1'),
      pendingInvitationsForMeProvider
          .overrideWith((ref) => const Stream.empty()),
      allConflictsCountProvider.overrideWith((ref) => 0),
      activeSprintProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1100, 800);
    addTearDown(tester.view.reset);

    // Switch to Family destination BEFORE pumping so the sidebar
    // sees it on first build (activeTabIndex=2 maps to Family when
    // currentFamilyDocId != null, per `activeNavDestinationProvider`).
    container.read(activeTabIndexProvider.notifier).setTab(2);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorObservers: [observer],
        home: const _ShellHarness(),
      ),
    ));
    await tester.pump(); // drain setTab microtask + initial stream
    await tester.pumpAndSettle();

    expect(observer.pushed, hasLength(1));

    await tester.tap(find.text('Add task'));
    // Multiple pumps to settle the route push + the body's first
    // build pass. Don't pumpAndSettle — TaskAddEditScreen's Drift-
    // stream watchers aren't overridden in this harness and would
    // never settle. 300ms of frame ticks is enough to land the route
    // transition without entering the unsettled Drift wait.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(observer.pushed, hasLength(2),
        reason: 'sidebar Add Task in sub-two-pane wide should push '
            'the full-screen route');
    // Extract defaultFamilyShared from the pushed route's settings —
    // more reliable than `find.byType(TaskAddEditScreen)` since the
    // unsettled Drift watchers make the widget tree's mount status
    // racy in this harness.
    final pushedRoute = observer.pushed.last as MaterialPageRoute<void>;
    final pushedWidget = pushedRoute.builder(
      tester.element(find.byType(WideNavSidebar)),
    );
    expect(pushedWidget, isA<TaskAddEditScreen>());
    final screen = pushedWidget as TaskAddEditScreen;
    expect(screen.defaultFamilyShared, isTrue,
        reason: 'add-task from Family destination must default to '
            'family-shared — pre-fix this silently created personal '
            'tasks because the Family-tab FAB (which set this flag) '
            'was hidden on wide and the sidebar didn\'t derive it.');

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('tapping the Areas "+" trailing pushes Manage Areas (TM-382)',
      (tester) async {
    final observer = _NavObserver();
    await pump(
      tester,
      logical: const Size(1280, 800),
      areas: [area('Work', 0)],
      observer: observer,
    );
    expect(observer.pushed, hasLength(1));

    // The Areas trailing IconButton has tooltip 'Manage Areas' — unique.
    await tester.tap(find.byTooltip('Manage Areas'));
    await tester.pump();

    expect(observer.pushed, hasLength(2));
    expect(observer.pushed.last, isA<MaterialPageRoute<void>>());
  });

  testWidgets(
      'tapping the Contexts "+" trailing pushes Manage Contexts (TM-382)',
      (tester) async {
    final observer = _NavObserver();
    await pump(
      tester,
      logical: const Size(1280, 800),
      contexts: [ctx('Phone', 0)],
      observer: observer,
    );
    expect(observer.pushed, hasLength(1));

    await tester.tap(find.byTooltip('Manage Contexts'));
    await tester.pump();

    expect(observer.pushed, hasLength(2));
    expect(observer.pushed.last, isA<MaterialPageRoute<void>>());
  });

  testWidgets('SidebarSection collapses + re-expands on header tap (TM-382)',
      (tester) async {
    await pump(
      tester,
      logical: const Size(1280, 800),
      areas: [area('Work', 0), area('Home', 1)],
    );
    // Rows visible initially.
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Tap the Areas section header — case-sensitive uppercase per the
    // SidebarSection style.
    await tester.tap(find.text('AREAS'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsNothing);
    expect(find.text('Home'), findsNothing);

    // Tap again → expanded.
    await tester.tap(find.text('AREAS'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'sidebar search syncs from external provider changes — cursor lands '
      'at end (TM-382)', (tester) async {
    final c = await pump(tester, logical: const Size(1280, 800));
    // Default surface is plan (Plan dest + no active sprint). The search
    // field is keyed by surface, so we mutate the plan surface here.
    c
        .read(taskListViewStateProvider(TaskListSurface.plan).notifier)
        .setSearch('externalFoo');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'externalFoo');
    // Cursor at end so a follow-up keystroke appends, not prepends.
    expect(
      field.controller!.selection,
      const TextSelection.collapsed(offset: 'externalFoo'.length),
    );
  });
}

class _NavObserver extends NavigatorObserver {
  final pushed = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
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
          widgetGetter: () => const _Body('Plan'),
          destination: NavDestination.plan),
      TopNavItem.init(
          label: 'Tasks',
          icon: Icons.list,
          widgetGetter: () => const _Body('Tasks'),
          destination: NavDestination.tasks),
      TopNavItem.init(
          label: 'Stats',
          icon: Icons.show_chart,
          widgetGetter: () => const _Body('Stats'),
          destination: NavDestination.stats),
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
