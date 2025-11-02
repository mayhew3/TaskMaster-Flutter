import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaster/features/tasks/presentation/task_details_screen.dart';

import 'integration_test_helper.dart';

/// Integration Test: Task Editing Flow
///
/// Tests the complete user flow for editing an existing task:
/// 1. Start with a task in the list
/// 2. Tap task to open details screen
/// 3. Tap edit FAB to open edit screen
/// 4. Modify task fields (name, description, project, context)
/// 5. Tap save button
/// 6. Verify changes appear in list
/// 7. Verify changes persisted to Redux state
///
/// This tests one of the most common user actions - editing tasks.
void main() {
  group('Task Editing Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    /// Helper: Write task to Firestore
    /// (Required before updating tasks, as updates require existing docs)
    Future<void> writeTaskToFirestore(
      FakeFirebaseFirestore firestore,
      TaskItem task,
    ) async {
      final taskDoc = firestore.collection('tasks').doc(task.docId);
      await taskDoc.set({
        'dateAdded': task.dateAdded,
        'name': task.name,
        'personDocId': task.personDocId,
        'offCycle': task.offCycle,
        'pendingCompletion': task.pendingCompletion,
        if (task.description != null) 'description': task.description,
        if (task.project != null) 'project': task.project,
        if (task.context != null) 'context': task.context,
        if (task.completionDate != null) 'completionDate': task.completionDate,
        if (task.retired != null) 'retired': task.retired,
      });
    }

    /// Helper: Manually sync Firestore task updates to Redux state
    /// (Firestore listeners are disabled in tests for performance)
    Future<void> syncFirestoreModificationsToRedux(
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

      // Convert Firestore docs to TaskItems
      final modifiedTasks = <TaskItem>[];
      for (final doc in tasksSnapshot.docs) {
        final taskData = doc.data();
        taskData['docId'] = doc.id;
        final task = TaskItem.fromJson(taskData);

        // Check if this task exists in state and has been modified
        final existingTask = store.state.taskItems
            .where((t) => t.docId == task.docId)
            .firstOrNull;
        if (existingTask != null && existingTask != task) {
          modifiedTasks.add(task);
        }
      }

      if (modifiedTasks.isNotEmpty) {
        store.dispatch(TasksModifiedAction(modifiedTasks));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('User can edit a task name', (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - test uses Redux sync incompatible with Riverpod providers

    testWidgets('User can edit task description', (tester) async {
      // Setup: Create task with description
      final initialTask = TaskItem((b) => b
        ..docId = 'task-2'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Task with description'
        ..description = 'Original description'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await writeTaskToFirestore(fakeFirestore, initialTask);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [initialTask],
      );

      // Step 1: Open task details and edit
      await tester.tap(find.text('Task with description'));
      await tester.pumpAndSettle();

      final editFab = find.descendant(
        of: find.byType(TaskDetailsScreen),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(editFab);
      await tester.pumpAndSettle();

      // Step 2: Modify description
      final descriptionField = find.widgetWithText(TextFormField, 'Notes');
      expect(descriptionField, findsOneWidget);
      await tester.enterText(descriptionField, 'Updated description');
      await tester.pumpAndSettle();

      // Step 3: Save
      final saveFab = find.descendant(
        of: find.byType(TaskAddEditScreen),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(saveFab);
      await tester.pumpAndSettle();

      // Sync modifications
      await syncFirestoreModificationsToRedux(tester, fakeFirestore);

      // Verify: Task still appears with same name
      expect(find.text('Task with description'), findsOneWidget);

      // Verify: Description updated in state
      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );
      expect(store.state.taskItems.first.description, 'Updated description');

      print('✓ User edited task description');
    });

    testWidgets('User can edit task name and description together',
        (tester) async {
      // Setup
      final initialTask = TaskItem((b) => b
        ..docId = 'task-3'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Old name'
        ..description = 'Old description'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await writeTaskToFirestore(fakeFirestore, initialTask);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [initialTask],
      );

      // Open edit screen
      await tester.tap(find.text('Old name'));
      await tester.pumpAndSettle();

      final editFab = find.descendant(
        of: find.byType(TaskDetailsScreen),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(editFab);
      await tester.pumpAndSettle();

      // Modify both fields
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'New name');
      await tester.pumpAndSettle();

      final descriptionField = find.widgetWithText(TextFormField, 'Notes');
      await tester.enterText(descriptionField, 'New description');
      await tester.pumpAndSettle();

      // Save
      final saveFab = find.descendant(
        of: find.byType(TaskAddEditScreen),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(saveFab);
      await tester.pumpAndSettle();

      // Sync modifications
      await syncFirestoreModificationsToRedux(tester, fakeFirestore);

      // Verify both changes
      expect(find.text('New name'), findsOneWidget);
      expect(find.text('Old name'), findsNothing);

      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );
      expect(store.state.taskItems.first.name, 'New name');
      expect(store.state.taskItems.first.description, 'New description');

      print('✓ User edited task name and description together');
    });

    testWidgets('User can cancel task editing', (tester) async {
      // Setup
      final initialTask = TaskItem((b) => b
        ..docId = 'task-4'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Unchanged task'
        ..personDocId = 'test-person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await writeTaskToFirestore(fakeFirestore, initialTask);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [initialTask],
      );

      // Open edit screen
      await tester.tap(find.text('Unchanged task'));
      await tester.pumpAndSettle();

      final editFab = find.descendant(
        of: find.byType(TaskDetailsScreen),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(editFab);
      await tester.pumpAndSettle();

      // Make changes but don't save
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'This should not save');
      await tester.pumpAndSettle();

      // Cancel by tapping back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify: Back on details screen
      expect(find.byType(TaskAddEditScreen), findsNothing);
      expect(find.byType(TaskDetailsScreen), findsOneWidget);

      // Go back to list
      final backButton2 = find.byType(BackButton);
      await tester.tap(backButton2);
      await tester.pumpAndSettle();

      // Verify: Original name still in list (no changes saved)
      expect(find.text('Unchanged task'), findsOneWidget);
      expect(find.text('This should not save'), findsNothing);

      // Verify: State unchanged
      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );
      expect(store.state.taskItems.first.name, 'Unchanged task');

      print('✓ User cancelled task editing');
    });

    testWidgets('User can edit multiple tasks sequentially', (tester) async {},
      skip: true); // TODO TM-283: Rewrite for Riverpod - test uses Redux sync incompatible with Riverpod providers
  });
}
