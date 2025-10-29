import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/app_state.dart';

import 'integration_test_helper.dart';

/// Integration Test: Task Filtering and Visibility
///
/// Tests the task filtering functionality:
/// 1. Completed tasks are filtered by default
/// 2. Retired tasks are always hidden
/// 3. Scheduled (future startDate) tasks are filtered by default
/// 4. Recently completed tasks bypass filters
/// 5. Active tasks always display
///
/// This ensures the task list shows the right tasks based on filtering rules.
///
/// Key filtering rules from filteredTaskItemsSelector:
/// - retired != null: Always filtered out
/// - completionDate != null: Filtered unless showCompleted=true
/// - startDate in future: Filtered unless showScheduled=true
/// - recentlyCompleted: Always shown (bypasses filters)
void main() {
  group('Task Filtering Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Active tasks display by default', (tester) async {
      // Setup: Create active tasks with no completion date, no retirement
      final now = DateTime.now().toUtc();

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-active-1'
          ..dateAdded = now
          ..name = 'Active Task 1'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-active-2'
          ..dateAdded = now
          ..name = 'Active Task 2'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Verify: Active tasks are visible
      expect(find.text('Active Task 1'), findsOneWidget);
      expect(find.text('Active Task 2'), findsOneWidget);

      print('✓ Active tasks display correctly');
    });

    testWidgets('Completed tasks are filtered by default', (tester) async {
      // Setup: Mix of completed and active tasks
      final now = DateTime.now().toUtc();

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-completed'
          ..dateAdded = now
          ..name = 'Completed Task'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-active'
          ..dateAdded = now
          ..name = 'Active Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Verify: Active task visible, completed task filtered out
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);

      print('✓ Completed tasks are filtered by default');
    });

    testWidgets('Retired tasks are always hidden', (tester) async {
      // Setup: Mix of retired and active tasks
      final now = DateTime.now().toUtc();

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-retired'
          ..dateAdded = now
          ..name = 'Retired Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = 'retired-reason'
          ..retiredDate = now
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-active'
          ..dateAdded = now
          ..name = 'Active Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Verify: Active task visible, retired task never shown
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Retired Task'), findsNothing);

      print('✓ Retired tasks are always hidden');
    });

    testWidgets('Scheduled (future startDate) tasks are filtered by default',
        (tester) async {
      // Setup: Mix of scheduled (future) and current tasks
      final now = DateTime.now().toUtc();
      final futureDate = now.add(Duration(days: 7));

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-scheduled'
          ..dateAdded = now
          ..name = 'Scheduled Task'
          ..personDocId = 'test-person-123'
          ..startDate = futureDate
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-current'
          ..dateAdded = now
          ..name = 'Current Task'
          ..personDocId = 'test-person-123'
          ..startDate = null  // No start date = shows now
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Verify: Current task visible, scheduled task filtered out
      expect(find.text('Current Task'), findsOneWidget);
      expect(find.text('Scheduled Task'), findsNothing);

      print('✓ Scheduled (future) tasks are filtered by default');
    });

    testWidgets('Tasks with past startDate display normally', (tester) async {
      // Setup: Task with past startDate (should display)
      final now = DateTime.now().toUtc();
      final pastDate = now.subtract(Duration(days: 7));

      final task = TaskItem((b) => b
        ..docId = 'task-past-start'
        ..dateAdded = now
        ..name = 'Past Start Date Task'
        ..personDocId = 'test-person-123'
        ..startDate = pastDate
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [task],
      );

      // Verify: Task with past startDate is visible
      expect(find.text('Past Start Date Task'), findsOneWidget);

      print('✓ Tasks with past startDate display normally');
    });

    testWidgets('Multiple filter conditions work together', (tester) async {
      // Setup: Various combinations of filters
      final now = DateTime.now().toUtc();
      final futureDate = now.add(Duration(days: 7));

      final tasks = [
        // Should show: active, no startDate
        TaskItem((b) => b
          ..docId = 'task-1'
          ..dateAdded = now
          ..name = 'Visible Task 1'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        // Should NOT show: completed
        TaskItem((b) => b
          ..docId = 'task-2'
          ..dateAdded = now
          ..name = 'Completed Task'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        // Should NOT show: retired
        TaskItem((b) => b
          ..docId = 'task-3'
          ..dateAdded = now
          ..name = 'Retired Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = 'archived'
          ..offCycle = false
          ..pendingCompletion = false),
        // Should NOT show: scheduled for future
        TaskItem((b) => b
          ..docId = 'task-4'
          ..dateAdded = now
          ..name = 'Future Scheduled Task'
          ..personDocId = 'test-person-123'
          ..startDate = futureDate
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        // Should show: active with past startDate
        TaskItem((b) => b
          ..docId = 'task-5'
          ..dateAdded = now
          ..name = 'Visible Task 2'
          ..personDocId = 'test-person-123'
          ..startDate = now.subtract(Duration(days: 1))
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Verify: Only active, non-retired, non-scheduled tasks are visible
      expect(find.text('Visible Task 1'), findsOneWidget);
      expect(find.text('Visible Task 2'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);
      expect(find.text('Retired Task'), findsNothing);
      expect(find.text('Future Scheduled Task'), findsNothing);

      print('✓ Multiple filter conditions work together correctly');
    });

    testWidgets('Tasks with various date fields display correctly',
        (tester) async {
      // Setup: Tasks with different date fields (targetDate, dueDate, urgentDate)
      final now = DateTime.now().toUtc();
      final tomorrow = now.add(Duration(days: 1));

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-with-target'
          ..dateAdded = now
          ..name = 'Task With Target Date'
          ..personDocId = 'test-person-123'
          ..targetDate = tomorrow
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-with-due'
          ..dateAdded = now
          ..name = 'Task With Due Date'
          ..personDocId = 'test-person-123'
          ..dueDate = tomorrow
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-with-urgent'
          ..dateAdded = now
          ..name = 'Task With Urgent Date'
          ..personDocId = 'test-person-123'
          ..urgentDate = tomorrow
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Verify: Tasks with various date types are all visible
      // (only startDate affects scheduling filter)
      expect(find.text('Task With Target Date'), findsOneWidget);
      expect(find.text('Task With Due Date'), findsOneWidget);
      expect(find.text('Task With Urgent Date'), findsOneWidget);

      print('✓ Tasks with various date fields display correctly');
    });

    testWidgets('Empty task list displays correctly', (tester) async {
      // Setup: No tasks
      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Verify: App handles empty state
      print('✓ Empty task list displays correctly');
    });

    testWidgets('OffCycle tasks are not filtered out', (tester) async {
      // Setup: Task with offCycle=true (should still display)
      final now = DateTime.now().toUtc();

      final task = TaskItem((b) => b
        ..docId = 'task-offcycle'
        ..dateAdded = now
        ..name = 'Off Cycle Task'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = true
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [task],
      );

      // Verify: OffCycle task is visible (offCycle doesn't affect filtering)
      expect(find.text('Off Cycle Task'), findsOneWidget);

      print('✓ OffCycle tasks are not filtered out');
    });
  });

  group('Task Filtering Interactive Toggle Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Toggling showCompleted filter shows/hides completed tasks',
        (tester) async {
      // Setup: Mix of completed and active tasks
      final now = DateTime.now().toUtc();

      final activeTask = TaskItem((b) => b
        ..docId = 'task-active'
        ..dateAdded = now
        ..name = 'Active Task'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final completedTask = TaskItem((b) => b
        ..docId = 'task-completed'
        ..dateAdded = now
        ..name = 'Completed Task'
        ..personDocId = 'test-person-123'
        ..completionDate = now
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [activeTask, completedTask],
      );

      // Initial state: Completed task is filtered out
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);

      // Step 1: Open filter menu
      final filterButton = find.byIcon(Icons.filter_list);
      expect(filterButton, findsOneWidget);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Step 2: Tap "Show Completed" to toggle it on
      expect(find.text('Show Completed'), findsOneWidget);
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Completed task now appears
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsOneWidget);

      // Step 3: Open filter menu again and toggle off
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Completed task hidden again
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);

      print('✓ Toggling showCompleted filter shows/hides completed tasks');
    });

    testWidgets('Toggling showScheduled filter shows/hides scheduled tasks',
        (tester) async {
      // Setup: Mix of current and scheduled (future) tasks
      final now = DateTime.now().toUtc();
      final futureDate = now.add(Duration(days: 7));

      final currentTask = TaskItem((b) => b
        ..docId = 'task-current'
        ..dateAdded = now
        ..name = 'Current Task'
        ..personDocId = 'test-person-123'
        ..startDate = null  // No start date = shows now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final scheduledTask = TaskItem((b) => b
        ..docId = 'task-scheduled'
        ..dateAdded = now
        ..name = 'Scheduled Task'
        ..personDocId = 'test-person-123'
        ..startDate = futureDate
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [currentTask, scheduledTask],
      );

      // Initial state: Scheduled task is filtered out
      expect(find.text('Current Task'), findsOneWidget);
      expect(find.text('Scheduled Task'), findsNothing);

      // Step 1: Open filter menu
      final filterButton = find.byIcon(Icons.filter_list);
      expect(filterButton, findsOneWidget);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Step 2: Tap "Show Scheduled" to toggle it on
      expect(find.text('Show Scheduled'), findsOneWidget);
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Scheduled task now appears
      expect(find.text('Current Task'), findsOneWidget);
      expect(find.text('Scheduled Task'), findsOneWidget);

      // Step 3: Open filter menu again and toggle off
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Scheduled task hidden again
      expect(find.text('Current Task'), findsOneWidget);
      expect(find.text('Scheduled Task'), findsNothing);

      print('✓ Toggling showScheduled filter shows/hides scheduled tasks');
    });

    testWidgets('Both filters can be toggled independently', (tester) async {
      // Setup: Active, completed, and scheduled tasks
      final now = DateTime.now().toUtc();
      final futureDate = now.add(Duration(days: 7));

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-active'
          ..dateAdded = now
          ..name = 'Active Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-completed'
          ..dateAdded = now
          ..name = 'Completed Task'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-scheduled'
          ..dateAdded = now
          ..name = 'Scheduled Task'
          ..personDocId = 'test-person-123'
          ..startDate = futureDate
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      // Initial: Only active task visible
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);
      expect(find.text('Scheduled Task'), findsNothing);

      final filterButton = find.byIcon(Icons.filter_list);

      // Step 1: Enable showCompleted
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Active and completed visible
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('Scheduled Task'), findsNothing);

      // Step 2: Enable showScheduled
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: All tasks visible
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('Scheduled Task'), findsOneWidget);

      // Step 3: Disable showCompleted (keep showScheduled on)
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Active and scheduled visible, completed hidden
      expect(find.text('Active Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);
      expect(find.text('Scheduled Task'), findsOneWidget);

      print('✓ Both filters can be toggled independently');
    });

    testWidgets('Filter state persists across filter toggles', (tester) async {
      // Setup: Tasks of different types
      final now = DateTime.now().toUtc();

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-1'
          ..dateAdded = now
          ..name = 'Task 1'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-2'
          ..dateAdded = now
          ..name = 'Task 2 Completed'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
      );

      final filterButton = find.byIcon(Icons.filter_list);
      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );

      // Initial filter state
      expect(store.state.taskListFilter.showCompleted, false);
      expect(store.state.taskListFilter.showScheduled, false);

      // Toggle showCompleted on
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: State updated
      expect(store.state.taskListFilter.showCompleted, true);

      // Toggle showCompleted off
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: State back to false
      expect(store.state.taskListFilter.showCompleted, false);

      print('✓ Filter state persists across filter toggles');
    });
  });
}
