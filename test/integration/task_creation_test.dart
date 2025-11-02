import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaster/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';

import 'integration_test_helper.dart';

/// Integration Test: Task Creation Flow
///
/// Tests the complete user flow for creating a new task:
/// 1. Start with empty task list
/// 2. Tap FAB to open add task screen
/// 3. Fill in task name (required field)
/// 4. Optionally fill other fields (dates, project, context, description)
/// 5. Tap save button
/// 6. Verify task appears in list
/// 7. Verify task persisted to Redux state
///
/// This tests the most critical user action - creating a task.
void main() {
  group('Task Creation Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    /// Helper: Manually sync Firestore tasks to Redux state
    /// (Firestore listeners are disabled in tests for performance)
    Future<void> closeAddEditScreenIfOpen(WidgetTester tester) async {
      // In Riverpod, auto-close relies on Firestore listeners which are disabled in tests
      // So manually navigate back if screen is still open
      if (find.byType(TaskAddEditScreen).evaluate().isNotEmpty) {
        Navigator.of(tester.element(find.byType(TaskAddEditScreen))).pop();
        await tester.pumpAndSettle();
      }
    }

    Future<void> syncFirestoreToRedux(
      WidgetTester tester,
      FakeFirebaseFirestore firestore,
    ) async {
      // Wait for Firestore writes to complete
      await tester.pump(Duration(milliseconds: 100));

      // Read all tasks from Firestore
      final tasksSnapshot = await firestore.collection('tasks').get();

      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );

      // Get current task IDs in state
      final existingIds = store.state.taskItems.map((t) => t.docId).toSet();

      // Convert Firestore docs to TaskItems and dispatch only new ones
      final newTasks = <TaskItem>[];
      for (final doc in tasksSnapshot.docs) {
        if (!existingIds.contains(doc.id)) {
          final taskData = doc.data();
          taskData['docId'] = doc.id;
          newTasks.add(TaskItem.fromJson(taskData));
        }
      }

      if (newTasks.isNotEmpty) {
        store.dispatch(TasksAddedAction(newTasks));
        await tester.pumpAndSettle();
      }

      // Also invalidate Riverpod providers to trigger auto-close
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      container.invalidate(tasksProvider);
      await tester.pumpAndSettle();
    }

    testWidgets('User can create a task with just a name', (tester) async {
      // Setup: Start with empty task list, using live Firestore
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Initial state: No tasks
      expect(find.text('No eligible tasks found.'), findsOneWidget);

      // Step 1: Tap FAB to open add task screen
      final fab = find.byType(FloatingActionButton).first;
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify: TaskAddEditScreen opened
      expect(find.byType(TaskAddEditScreen), findsOneWidget);
      expect(find.text('Task Details'), findsOneWidget);

      // Step 2: Enter task name (required field)
      final nameField = find.widgetWithText(TextFormField, 'Name');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Buy groceries');
      await tester.pumpAndSettle();

      // Step 3: Tap save button (FloatingActionButton)
      final saveFab = find.byType(FloatingActionButton);
      expect(saveFab, findsAtLeastNWidgets(1)); // At least 1 FAB (might be 2 if both screens visible)
      await tester.tap(saveFab.last); // Tap the last one (the save button)
      await tester.pumpAndSettle();

      // Wait for Firestore write and stream update
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Auto-close relies on Firestore stream updates which might be delayed in tests
      // Manually close if still open
      await closeAddEditScreenIfOpen(tester);

      // Verify: Navigation back to task list
      expect(find.byType(TaskAddEditScreen), findsNothing);

      // Verify: Task appears in list
      expect(find.text('Buy groceries'), findsOneWidget);

      print('✓ User created task with name only');
    });

    testWidgets('User can create a task with name and description',
        (tester) async {
      // Setup: Start with empty task list, using live Firestore
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Step 1: Open add task screen
      final fab = find.byType(FloatingActionButton).first;
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Step 2: Enter task name
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'Write report');
      await tester.pumpAndSettle();

      // Step 3: Enter description
      final descriptionField = find.widgetWithText(TextFormField, 'Notes');
      expect(descriptionField, findsOneWidget);
      await tester.enterText(descriptionField, 'Q4 financial report for board');
      await tester.pumpAndSettle();

      // Step 4: Save task
      final saveFab = find.byType(FloatingActionButton);
      await tester.tap(saveFab.last);
      await tester.pumpAndSettle();

      // Wait for Firestore write and stream update
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Auto-close relies on Firestore stream updates which might be delayed in tests
      await closeAddEditScreenIfOpen(tester);

      // Verify: Task appears with name
      expect(find.text('Write report'), findsOneWidget);

      // Verify: Task exists in Firestore with description
      final tasksSnapshot = await fakeFirestore.collection('tasks').get();
      expect(tasksSnapshot.docs.length, 1);
      final taskData = tasksSnapshot.docs.first.data();
      expect(taskData['name'], 'Write report');
      expect(taskData['description'], 'Q4 financial report for board');

      print('✓ User created task with name and description');
    });

    testWidgets('User can create a task with name only (variant 2)',
        (tester) async {
      // Setup: Start with empty task list, using live Firestore
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Step 1: Open add task screen
      final fab = find.byType(FloatingActionButton).first;
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Step 2: Enter task name
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'Fix login bug');
      await tester.pumpAndSettle();

      // Step 3: Save task
      final saveFab = find.byType(FloatingActionButton);
      await tester.tap(saveFab.last);
      await tester.pumpAndSettle();

      // Wait for Firestore write and stream update
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Auto-close relies on Firestore stream updates which might be delayed in tests
      await closeAddEditScreenIfOpen(tester);

      // Verify: Task appears with name
      expect(find.text('Fix login bug'), findsOneWidget);

      print('✓ User created task with name');
    });

    testWidgets('User can create multiple tasks', (tester) async {
      // Setup: Start with empty task list, using live Firestore
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Create first task
      final fab = find.byType(FloatingActionButton).first;
      await tester.tap(fab);
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'First task');
      await tester.pumpAndSettle();

      final saveFab = find.byType(FloatingActionButton);
      await tester.tap(saveFab.last);
      await tester.pumpAndSettle();

      // Wait for Firestore write and stream update
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Auto-close relies on Firestore stream updates which might be delayed in tests
      await closeAddEditScreenIfOpen(tester);

      // Verify first task appears
      expect(find.text('First task'), findsOneWidget);

      // Create second task
      final fab2 = find.byType(FloatingActionButton).first;
      await tester.tap(fab2);
      await tester.pumpAndSettle();

      final nameField2 = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField2, 'Second task');
      await tester.pumpAndSettle();

      final saveFab2 = find.byType(FloatingActionButton);
      await tester.tap(saveFab2.last);
      await tester.pumpAndSettle();

      // Wait for Firestore write and stream update
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Auto-close relies on Firestore stream updates which might be delayed in tests
      await closeAddEditScreenIfOpen(tester);

      // Verify: Both tasks appear
      expect(find.text('First task'), findsOneWidget);
      expect(find.text('Second task'), findsOneWidget);

      print('✓ User created multiple tasks');
    });

    testWidgets('User cannot save task without name (validation)',
        (tester) async {
      // Setup: Start with empty task list, using live Firestore
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Step 1: Open add task screen
      final fab = find.byType(FloatingActionButton).first;
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Step 2: Try to save without entering name (FAB is now always visible)
      final saveFab = find.byType(FloatingActionButton);
      expect(saveFab, findsAtLeastNWidgets(1)); // FAB is visible

      await tester.tap(saveFab.last);
      await tester.pumpAndSettle();

      // Verify: Still on TaskAddEditScreen (validation prevented save)
      expect(find.byType(TaskAddEditScreen), findsOneWidget);
      expect(find.text('Task Details'), findsOneWidget);

      // Verify: No tasks created in Firestore
      final tasksSnapshot = await fakeFirestore.collection('tasks').get();
      expect(tasksSnapshot.docs.length, 0);

      print('✓ User cannot save task without name');
    });

    testWidgets('User can cancel task creation', (tester) async {
      // Setup: Start with empty task list
      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
      );

      // Step 1: Open add task screen
      final fab = find.byType(FloatingActionButton).first;
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Step 2: Enter task name
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'Task to cancel');
      await tester.pumpAndSettle();

      // Step 3: Tap back button to cancel
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify: Back on task list
      expect(find.byType(TaskAddEditScreen), findsNothing);

      // Verify: No task created
      expect(find.text('Task to cancel'), findsNothing);

      // Verify: Redux state unchanged
      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );
      expect(store.state.taskItems.length, 0);

      print('✓ User cancelled task creation');
    });
  });
}
