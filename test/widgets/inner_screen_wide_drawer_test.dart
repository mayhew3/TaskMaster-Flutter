import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';
import 'package:taskmaestro/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaestro/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_grouped_tasks_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/presentation/stats_screen.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';

/// TM-388 — each inner screen suppresses its own `AppDrawer` on the wide
/// layout, because the wide shell's profile-footer trigger opens an outer
/// drawer; leaving the inner one in place would duplicate the menu and
/// (for the auto-burger in `AppBar`) slide it in from the wrong edge —
/// right of the sidebar.
///
/// This file pins the contract for three representative screens. The
/// remaining two screens — `TaskListScreen` and `FamilyTabScreen` —
/// use the **identical** one-liner
/// (`drawer: isWideLayout(MediaQuery.sizeOf(context)) ? null : const AppDrawer()`),
/// so a regression in the shared `isWideLayout` predicate would be caught
/// here.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Scaffold scaffoldOf(WidgetTester tester) =>
      tester.widget<Scaffold>(find.byType(Scaffold).first);

  // Takes a pre-built ProviderContainer rather than a typed override list
  // so we don't need to import `Override` from the non-public
  // `flutter_riverpod/misc.dart` entrypoint (R3 follow-up).
  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    required Widget child,
    required ProviderContainer container,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: child),
      ),
    );
    await tester.pump();
  }

  // ── NewSprintScreen ──────────────────────────────────────────────

  ProviderContainer newSprintContainer() => ProviderContainer(overrides: [
        lastCompletedSprintProvider.overrideWith((ref) => null),
        personDocIdProvider.overrideWith((ref) => 'p'),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
        syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
      ]);

  testWidgets('NewSprintScreen: wide → drawer is null (TM-388)',
      (tester) async {
    await pump(
      tester,
      size: const Size(1280, 800),
      child: const NewSprintScreen(),
      container: newSprintContainer(),
    );
    expect(scaffoldOf(tester).drawer, isNull);
  });

  testWidgets('NewSprintScreen: compact → drawer is the AppDrawer (TM-388)',
      (tester) async {
    await pump(
      tester,
      size: const Size(400, 800),
      child: const NewSprintScreen(),
      container: newSprintContainer(),
    );
    expect(scaffoldOf(tester).drawer, isNotNull);
  });

  // ── StatsScreen ──────────────────────────────────────────────────

  ProviderContainer statsContainer() => ProviderContainer(overrides: [
        tasksProvider.overrideWith((ref) => Stream.value(const [])),
        completedTaskCountProvider.overrideWith((ref) async => 0),
        personDocIdProvider.overrideWith((ref) => 'p'),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ]);

  testWidgets('StatsScreen: wide → drawer is null (TM-388)', (tester) async {
    await pump(
      tester,
      size: const Size(1280, 800),
      child: const StatsScreen(),
      container: statsContainer(),
    );
    expect(scaffoldOf(tester).drawer, isNull);
  });

  testWidgets('StatsScreen: compact → drawer is the AppDrawer (TM-388)',
      (tester) async {
    await pump(
      tester,
      size: const Size(400, 800),
      child: const StatsScreen(),
      container: statsContainer(),
    );
    expect(scaffoldOf(tester).drawer, isNotNull);
  });

  // ── SprintTaskItemsScreen ────────────────────────────────────────

  Sprint testSprint() {
    final now = DateTime.now();
    return Sprint((b) => b
      ..docId = 's-1'
      ..dateAdded = now
      ..startDate = now.subtract(const Duration(days: 1))
      ..endDate = now.add(const Duration(days: 13))
      ..numUnits = 2
      ..unitName = 'Weeks'
      ..personDocId = 'p'
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder<SprintAssignment>());
  }

  ProviderContainer sprintScreenContainer() => ProviderContainer(overrides: [
        sprintGroupedTasksProvider
            .overrideWith((ref, _) async => const <TaskGroupResult>[]),
        sprintsProvider.overrideWith((ref) => Stream.value(const [])),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value(const [])),
        taskRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
        personDocIdProvider.overrideWith((ref) => 'p'),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ]);

  testWidgets('SprintTaskItemsScreen: wide → drawer is null (TM-388)',
      (tester) async {
    await pump(
      tester,
      size: const Size(1280, 800),
      child: SprintTaskItemsScreen(sprint: testSprint()),
      container: sprintScreenContainer(),
    );
    expect(scaffoldOf(tester).drawer, isNull);
  });

  testWidgets(
      'SprintTaskItemsScreen: compact → drawer is the AppDrawer (TM-388)',
      (tester) async {
    await pump(
      tester,
      size: const Size(400, 800),
      child: SprintTaskItemsScreen(sprint: testSprint()),
      container: sprintScreenContainer(),
    );
    expect(scaffoldOf(tester).drawer, isNotNull);
  });
}

class _FakeSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;
}
