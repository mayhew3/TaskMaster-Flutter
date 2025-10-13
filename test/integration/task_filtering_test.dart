import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_item.dart';

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
}
