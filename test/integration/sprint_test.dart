import 'package:built_collection/built_collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/actions/sprint_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/containers/planning_home.dart';
import 'package:taskmaster/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaster/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaster/features/tasks/presentation/task_list_screen.dart';

import 'integration_test_helper.dart';

/// Integration Test: Sprint Management
///
/// Tests sprint planning functionality:
/// 1. Sprint state management (creation, assignments, sequencing)
/// 2. Sprint UI display (NewSprint form, active sprint tasks)
/// 3. Sprint-task relationships (assignments, data integrity)
///
/// Note: The app only displays ONE active sprint at a time via the Plan tab:
/// - No active sprint → Shows NewSprint form
/// - Active sprint exists → Shows SprintTaskItems (tasks for that sprint)
void main() {
  group('Sprint Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    // =======================================================================
    // UI DISPLAY TESTS - Test actual screens shown to users
    // =======================================================================

    testWidgets('NewSprint form displays when no active sprint exists',
        (tester) async {
      // Setup: Create app with no sprints (or only closed sprints)
      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialSprints: [],
        initialTasks: [],
      );

      await tester.pumpAndSettle();

      // Navigate to Plan tab (where sprints are shown)
      // NOTE: There are TWO NavigationBars in the widget tree:
      // 1. Test wrapper's NavigationBar (no key) - controls which screen is shown
      // 2. AppBottomNav inside the current screen (key: TaskMasterKeys.tabs) - doesn't control test navigation
      // We need to tap the test wrapper's NavigationBar, not the AppBottomNav

      // Find NavigationDestinations that are NOT descendants of the keyed NavigationBar
      final appBottomNav = find.byKey(TaskMasterKeys.tabs);
      final allDestinations = find.byType(NavigationDestination);
      final testWrapperDestinations = allDestinations.evaluate().where((element) {
        // Check if this destination is inside the AppBottomNav
        final isInsideAppBottomNav = find.descendant(
          of: appBottomNav,
          matching: find.byWidget(element.widget),
        ).evaluate().isNotEmpty;
        return !isInsideAppBottomNav;
      }).toList();

      // Tap the first test wrapper destination (Plan tab - index 0)
      await tester.tap(find.byWidget(testWrapperDestinations.first.widget));
      await tester.pumpAndSettle();

      // Verify: NewSprint form is visible (shows sprint creation UI)
      expect(find.byType(NewSprintScreen), findsOneWidget);

      // Verify: SprintTaskItems is NOT shown (no active sprint)
      expect(find.byType(SprintTaskItemsScreen), findsNothing);
    });

    testWidgets('SprintTaskItems displays when active sprint exists',
        (tester) async {
      // Setup: Create an active sprint with tasks
      final now = DateTime.now().toUtc();

      final task1 = TaskItem((b) => b
        ..docId = 'task-1'
        ..dateAdded = now
        ..name = 'Sprint Task 1'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task2 = TaskItem((b) => b
        ..docId = 'task-2'
        ..dateAdded = now
        ..name = 'Sprint Task 2'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final activeSprint = Sprint((b) => b
        ..docId = 'sprint-active'
        ..dateAdded = now
        ..startDate = now
        ..endDate = now.add(Duration(days: 7))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'test-person-123'
        ..sprintNumber = 1
        ..retired = null
        ..retiredDate = null
        ..closeDate = null // No close date = active
        ..sprintAssignments = ListBuilder<SprintAssignment>([
          SprintAssignment((a) => a
            ..docId = 'assignment-1'
            ..taskDocId = 'task-1'
            ..sprintDocId = 'sprint-active'
            ..retired = null
            ..retiredDate = null),
          SprintAssignment((a) => a
            ..docId = 'assignment-2'
            ..taskDocId = 'task-2'
            ..sprintDocId = 'sprint-active'
            ..retired = null
            ..retiredDate = null),
        ]));

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialSprints: [activeSprint],
        initialTasks: [task1, task2],
      );

      await tester.pumpAndSettle();

      // Navigate to Plan tab (where sprints are shown)
      // NOTE: There are TWO NavigationBars in the widget tree - see comment in first test
      final appBottomNav = find.byKey(TaskMasterKeys.tabs);
      final allDestinations = find.byType(NavigationDestination);
      final testWrapperDestinations = allDestinations.evaluate().where((element) {
        final isInsideAppBottomNav = find.descendant(
          of: appBottomNav,
          matching: find.byWidget(element.widget),
        ).evaluate().isNotEmpty;
        return !isInsideAppBottomNav;
      }).toList();

      // Tap the first test wrapper destination (Plan tab - index 0)
      await tester.tap(find.byWidget(testWrapperDestinations.first.widget));
      await tester.pumpAndSettle();

      // Verify: SprintTaskItems is shown (displays active sprint)
      expect(find.byType(SprintTaskItemsScreen), findsOneWidget);

      // Verify: NewSprint form is NOT shown (we have an active sprint)
      expect(find.byType(NewSprintScreen), findsNothing);

      // Verify: Sprint tasks are visible
      expect(find.text('Sprint Task 1'), findsOneWidget);
      expect(find.text('Sprint Task 2'), findsOneWidget);
    });

    // =======================================================================
    // STATE MANAGEMENT TESTS - Test Redux state and data relationships
    // =======================================================================

    testWidgets('Sprint creation via action adds sprint to state',
        (tester) async {
      // Setup: Start with no sprints
      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialSprints: [],
        initialTasks: [],
      );

      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );

      // Verify: No sprints initially
      expect(store.state.sprints.length, 0);

      // Action: Create a new sprint via Redux action
      final now = DateTime.now().toUtc();
      final newSprint = Sprint((b) => b
        ..docId = 'sprint-new'
        ..dateAdded = now
        ..startDate = now
        ..endDate = now.add(Duration(days: 7))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'test-person-123'
        ..sprintNumber = 1
        ..retired = null
        ..retiredDate = null
        ..closeDate = null
        ..sprintAssignments = ListBuilder<SprintAssignment>([]));

      // Write to Firestore
      await fakeFirestore.collection('sprints').doc(newSprint.docId).set({
        'dateAdded': newSprint.dateAdded,
        'startDate': newSprint.startDate,
        'endDate': newSprint.endDate,
        'numUnits': newSprint.numUnits,
        'unitName': newSprint.unitName,
        'personDocId': newSprint.personDocId,
        'sprintNumber': newSprint.sprintNumber,
      });

      // Dispatch action
      store.dispatch(SprintsAddedAction([newSprint]));
      await tester.pumpAndSettle();

      // Verify: Sprint appears in state with correct data
      expect(store.state.sprints.length, 1);
      expect(store.state.sprints.first.docId, 'sprint-new');
      expect(store.state.sprints.first.numUnits, 1);
      expect(store.state.sprints.first.unitName, 'week');
      expect(store.state.sprints.first.sprintNumber, 1);
    });

    testWidgets('Sprint with tasks maintains task assignments',
        (tester) async {
      // Setup: Create tasks first
      final now = DateTime.now().toUtc();

      final task1 = TaskItem((b) => b
        ..docId = 'task-sprint-1'
        ..dateAdded = now
        ..name = 'Sprint Task 1'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task2 = TaskItem((b) => b
        ..docId = 'task-sprint-2'
        ..dateAdded = now
        ..name = 'Sprint Task 2'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialSprints: [],
        initialTasks: [task1, task2],
      );

      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );

      // Action: Create a sprint with task assignments
      final sprint = Sprint((b) => b
        ..docId = 'sprint-with-tasks'
        ..dateAdded = now
        ..startDate = now
        ..endDate = now.add(Duration(days: 14))
        ..numUnits = 2
        ..unitName = 'weeks'
        ..personDocId = 'test-person-123'
        ..sprintNumber = 1
        ..retired = null
        ..retiredDate = null
        ..closeDate = null
        ..sprintAssignments = ListBuilder<SprintAssignment>([
          SprintAssignment((a) => a
            ..docId = 'assignment-new-1'
            ..taskDocId = 'task-sprint-1'
            ..sprintDocId = 'sprint-with-tasks'
            ..retired = null
            ..retiredDate = null),
          SprintAssignment((a) => a
            ..docId = 'assignment-new-2'
            ..taskDocId = 'task-sprint-2'
            ..sprintDocId = 'sprint-with-tasks'
            ..retired = null
            ..retiredDate = null),
        ]));

      // Add sprint to state
      store.dispatch(SprintsAddedAction([sprint]));
      await tester.pumpAndSettle();

      // Verify: Sprint exists with correct task assignments
      expect(store.state.sprints.length, 1);
      final createdSprint = store.state.sprints.first;
      expect(createdSprint.sprintAssignments.length, 2);
      expect(createdSprint.sprintAssignments[0].taskDocId, 'task-sprint-1');
      expect(createdSprint.sprintAssignments[1].taskDocId, 'task-sprint-2');
      expect(createdSprint.sprintAssignments[0].sprintDocId, 'sprint-with-tasks');
      expect(createdSprint.sprintAssignments[1].sprintDocId, 'sprint-with-tasks');
    });

    testWidgets('Multiple sprints can exist in state sequentially',
        (tester) async {
      // Setup: Start with one closed sprint
      final now = DateTime.now().toUtc();

      final sprint1 = Sprint((b) => b
        ..docId = 'sprint-seq-1'
        ..dateAdded = now.subtract(Duration(days: 14))
        ..startDate = now.subtract(Duration(days: 14))
        ..endDate = now.subtract(Duration(days: 7))
        ..closeDate = now.subtract(Duration(days: 6)) // Closed
        ..numUnits = 1
        ..unitName = 'Weeks' // Must be capitalized plural for DateUtil
        ..personDocId = 'test-person-123'
        ..sprintNumber = 1
        ..retired = null
        ..retiredDate = null
        ..sprintAssignments = ListBuilder<SprintAssignment>([]));

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialSprints: [sprint1],
        initialTasks: [],
      );

      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );

      // Verify: One sprint initially
      expect(store.state.sprints.length, 1);

      // Action: Create second sprint (new active sprint)
      final sprint2 = Sprint((b) => b
        ..docId = 'sprint-seq-2'
        ..dateAdded = now
        ..startDate = now
        ..endDate = now.add(Duration(days: 7))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'test-person-123'
        ..sprintNumber = 2
        ..retired = null
        ..retiredDate = null
        ..closeDate = null // Active
        ..sprintAssignments = ListBuilder<SprintAssignment>([]));

      store.dispatch(SprintsAddedAction([sprint2]));
      await tester.pumpAndSettle();

      // Verify: Both sprints exist in state
      expect(store.state.sprints.length, 2);
      expect(store.state.sprints.any((s) => s.sprintNumber == 1), true);
      expect(store.state.sprints.any((s) => s.sprintNumber == 2), true);

      // Verify: Sprint numbers are correct
      final sprintNumbers = store.state.sprints.map((s) => s.sprintNumber).toList();
      expect(sprintNumbers.contains(1), true);
      expect(sprintNumbers.contains(2), true);
    });

    testWidgets('Sprint number increments correctly across sprints',
        (tester) async {
      // Setup: Create 3 sprints with sequential numbers
      final now = DateTime.now().toUtc();

      final sprints = List.generate(3, (index) {
        return Sprint((b) => b
          ..docId = 'sprint-${index + 1}'
          ..dateAdded = now.add(Duration(days: index * 7))
          ..startDate = now.add(Duration(days: index * 7))
          ..endDate = now.add(Duration(days: (index + 1) * 7))
          ..numUnits = 1
          ..unitName = 'week'
          ..personDocId = 'test-person-123'
          ..sprintNumber = index + 1
          ..retired = null
          ..retiredDate = null
          // First 2 are closed, last one is active
          ..closeDate = (index < 2) ? now.add(Duration(days: (index + 1) * 7 - 1)) : null
          ..sprintAssignments = ListBuilder<SprintAssignment>([]));
      });

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialSprints: sprints,
        initialTasks: [],
      );

      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );

      // Verify: All 3 sprints loaded
      expect(store.state.sprints.length, 3);

      // Verify: Sprint numbers are sequential
      expect(store.state.sprints.map((s) => s.sprintNumber).toList(), [1, 2, 3]);

      // Verify: Closed sprints have closeDate, active sprint doesn't
      expect(store.state.sprints.where((s) => s.closeDate != null).length, 2);
      expect(store.state.sprints.where((s) => s.closeDate == null).length, 1);
    });
  });
}
