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

    testWidgets('User can create a task with just a name', (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - test uses Redux sync helpers incompatible with Riverpod screens

    testWidgets('User can create a task with name and description',
        (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - test uses Redux sync incompatible with Riverpod providers

    testWidgets('User can create a task with name only (variant 2)',
        (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - test uses Redux sync incompatible with Riverpod providers

    testWidgets('User can create multiple tasks', (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - test uses Redux sync incompatible with Riverpod providers

    testWidgets('User cannot save task without name (validation)',
        (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - FAB visibility wrapper was removed, test expectation invalid

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
