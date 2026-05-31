import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';

import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/plan_task_list.dart';
import 'package:taskmaestro/features/shared/presentation/planning_home.dart';
import 'package:taskmaestro/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaestro/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaestro/features/sprints/providers/create_sprint_draft_provider.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_grouped_tasks_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/sprint.dart';

/// TM-388 — on the wide layout the create-sprint flow swaps the cadence
/// form and the task picker IN PLACE inside the shell content area (so
/// the sidebar stays visible); compact keeps the full-screen route.
///
/// A push-counting [NavigatorObserver] is the discriminator: the wide
/// swap pushes NO new route (the sidebar can't be covered), while compact
/// pushes the picker as a full-screen route.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    required _PushCountingObserver observer,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      // No sprints → no active sprint → create-sprint flow; also makes
      // lastCompletedSprint null (defaults cadence). Stubs the Drift
      // stream so no database opens.
      sprintsProvider.overrideWith((ref) => Stream.value(const [])),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
      // PlanTaskList.createTemporaryIterations reads this unconditionally;
      // stub so no Drift database opens.
      taskRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
      personDocIdProvider.overrideWith((ref) => 'p'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      // AppBar ConnectionStatusIndicator.
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const PlanningHome(),
        ),
      ),
    );
    // Drain the sprints/tasks stream emissions without pumpAndSettle
    // (the loading-state CircularProgressIndicator would never settle).
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
      'wide: Create Sprint swaps form → picker IN PLACE (no route push, '
      'so the sidebar is never covered) (TM-388)', (tester) async {
    final observer = _PushCountingObserver();
    await pump(tester, size: const Size(1280, 800), observer: observer);

    expect(find.byType(NewSprintScreen), findsOneWidget);
    expect(find.byType(PlanTaskList), findsNothing);
    final pushesAtForm = observer.pushes;

    await tester.tap(find.text('Create Sprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PlanTaskList), findsOneWidget,
        reason: 'picker replaces the form in the same content slot');
    expect(find.byType(NewSprintScreen), findsNothing);
    expect(observer.pushes, pushesAtForm,
        reason: 'wide swaps in place — no full-screen route is pushed');
  });

  testWidgets(
      'compact: Create Sprint pushes the picker as a full-screen route '
      '(TM-388 — phone path unchanged)', (tester) async {
    final observer = _PushCountingObserver();
    await pump(tester, size: const Size(400, 800), observer: observer);

    expect(find.byType(NewSprintScreen), findsOneWidget);
    final pushesAtForm = observer.pushes;

    await tester.tap(find.text('Create Sprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PlanTaskList), findsOneWidget);
    expect(observer.pushes, greaterThan(pushesAtForm),
        reason: 'compact pushes the picker as a full-screen route');
  });

  // ── Add-to-existing-sprint flow (active sprint) ───────────────────

  Sprint makeActiveSprint() {
    final now = DateTime.now();
    return Sprint((b) => b
      ..docId = 'active-1'
      ..dateAdded = now.subtract(const Duration(days: 1))
      ..startDate = now.subtract(const Duration(days: 1))
      ..endDate = now.add(const Duration(days: 13))
      ..numUnits = 2
      ..unitName = 'Weeks'
      ..personDocId = 'p'
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder([]));
  }

  Future<void> pumpActive(
    WidgetTester tester, {
    required Size size,
    required _PushCountingObserver observer,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final sprint = makeActiveSprint();
    final container = ProviderContainer(overrides: [
      sprintsProvider.overrideWith((ref) => Stream.value([sprint])),
      sprintGroupedTasksProvider
          .overrideWith((ref, _) async => const <TaskGroupResult>[]),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
      taskRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
      personDocIdProvider.overrideWith((ref) => 'p'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const PlanningHome(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
      'wide: active-sprint "Add More..." swaps the picker IN PLACE (no '
      'route push) and Back returns to the sprint list (TM-388)',
      (tester) async {
    final observer = _PushCountingObserver();
    await pumpActive(tester, size: const Size(1280, 800), observer: observer);

    expect(find.byType(SprintTaskItemsScreen), findsOneWidget);
    final pushesAtList = observer.pushes;

    await tester.tap(find.text('Add More...'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PlanTaskList), findsOneWidget);
    expect(find.byType(SprintTaskItemsScreen), findsNothing);
    expect(observer.pushes, pushesAtList,
        reason: 'wide swaps in place — no full-screen route pushed');

    await tester.tap(find.byTooltip('Back to sprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SprintTaskItemsScreen), findsOneWidget);
    expect(find.byType(PlanTaskList), findsNothing);
  });

  testWidgets(
      'compact: active-sprint "Add More..." pushes a full-screen route '
      '(TM-388 — phone path unchanged)', (tester) async {
    final observer = _PushCountingObserver();
    await pumpActive(tester, size: const Size(400, 800), observer: observer);

    expect(find.byType(SprintTaskItemsScreen), findsOneWidget);
    final pushesAtList = observer.pushes;

    await tester.tap(find.text('Add More...'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PlanTaskList), findsOneWidget);
    expect(observer.pushes, greaterThan(pushesAtList));
  });

  testWidgets(
      'wide: the picker Back button returns to the cadence form in place '
      '(TM-388)', (tester) async {
    final observer = _PushCountingObserver();
    await pump(tester, size: const Size(1280, 800), observer: observer);

    await tester.tap(find.text('Create Sprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlanTaskList), findsOneWidget);

    await tester.tap(find.byTooltip('Back to cadence'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NewSprintScreen), findsOneWidget);
    expect(find.byType(PlanTaskList), findsNothing);
  });

  // ── creating-spinner branch + ListEquality re-emit guard ────────

  Future<ProviderContainer> pumpWithSprintsStream(
    WidgetTester tester, {
    required Stream<List<Sprint>> sprintsStream,
    required Size size,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      sprintsProvider.overrideWith((ref) => sprintsStream),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
      taskRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
      personDocIdProvider.overrideWith((ref) => 'p'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PlanningHome()),
      ),
    );
    await tester.pump();
    await tester.pump();
    return container;
  }

  testWidgets(
      'wide: creating step shows a spinner (covers the gap between submit '
      'and the sprints stream emitting the new sprint) (TM-388)',
      (tester) async {
    final controller = StreamController<List<Sprint>>();
    addTearDown(controller.close);
    controller.add(const <Sprint>[]);

    final c = await pumpWithSprintsStream(
      tester,
      sprintsStream: controller.stream,
      size: const Size(1280, 800),
    );

    // Form is rendered first.
    expect(find.byType(NewSprintScreen), findsOneWidget);

    // Simulate post-submit transition into `creating`.
    c.read(createSprintStepProvider.notifier).toCreating();
    await tester.pump();

    expect(find.byType(NewSprintScreen), findsNothing);
    expect(find.byType(PlanTaskList), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'wide: ListEquality guard — a no-op sprints re-emit during `creating` '
      'does NOT drop back to the form (TM-388)', (tester) async {
    final controller = StreamController<List<Sprint>>();
    addTearDown(controller.close);
    controller.add(const <Sprint>[]);

    final c = await pumpWithSprintsStream(
      tester,
      sprintsStream: controller.stream,
      size: const Size(1280, 800),
    );

    c.read(createSprintStepProvider.notifier).toCreating();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // No-op re-emission (same empty list) — Drift can do this on
    // unrelated watched-table touches.
    controller.add(const <Sprint>[]);
    await tester.pump();

    // Still on the spinner: the deep-compare in PlanningHome's
    // `ref.listen` discarded the no-op.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(c.read(createSprintStepProvider),
        CreateSprintStepValue.creating);
    expect(find.byType(NewSprintScreen), findsNothing);
  });

  testWidgets(
      'wide: a real sprints change during `creating` DOES drop back to the '
      'form (the submit-success path) (TM-388)', (tester) async {
    final controller = StreamController<List<Sprint>>();
    addTearDown(controller.close);
    controller.add(const <Sprint>[]);

    final c = await pumpWithSprintsStream(
      tester,
      sprintsStream: controller.stream,
      size: const Size(1280, 800),
    );

    c.read(createSprintStepProvider.notifier).toCreating();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // A real change — a sprint was added (the just-created one).
    // The candidate sprint here is intentionally NOT active (start in
    // the future), so PlanningHome still shows the create-sprint
    // surface — but it should be the form again, not the spinner.
    final now = DateTime.now();
    final newSprint = Sprint((b) => b
      ..docId = 'just-created'
      ..dateAdded = now
      ..startDate = now.add(const Duration(days: 14))
      ..endDate = now.add(const Duration(days: 28))
      ..numUnits = 2
      ..unitName = 'Weeks'
      ..personDocId = 'p'
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder([]));
    controller.add([newSprint]);
    await tester.pump();
    await tester.pump();

    expect(c.read(createSprintStepProvider), CreateSprintStepValue.form);
    expect(find.byType(NewSprintScreen), findsOneWidget);
  });
}

class _PushCountingObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

class _FakeSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;
}
