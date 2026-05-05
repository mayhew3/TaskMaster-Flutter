import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaestro/features/tasks/presentation/task_details_screen.dart';
import 'package:taskmaestro/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaestro/models/task_item.dart';
import '../../../integration/integration_test_helper.dart';

/// Tests for TM-282: Navigation bugs after Riverpod migration
/// Specifically: "Create task doesn't navigate back to task list"
///
/// NOTE: These tests use pumpAppWithLiveFirestore() instead of pumpApp()
/// because auto-close logic requires Firestore streams to see task updates.
///
/// Also includes field validation tests (TM-297).
void main() {
  group('TaskAddEditScreen Navigation Tests (TM-282)', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Creating a new task navigates back to task list',
        (tester) async {
      // Setup: Start with empty task list
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
        initialSprints: [],
      );

      await tester.pumpAndSettle();

      // Navigate to Tasks tab
      final appBottomNav = find.byType(NavigationBar);
      final tasksDestination = find.descendant(
        of: appBottomNav,
        matching: find.byWidgetPredicate(
          (widget) => widget is NavigationDestination && widget.label == 'Tasks',
        ),
      );

      if (tasksDestination.evaluate().isNotEmpty) {
        await tester.tap(tasksDestination);
        await tester.pumpAndSettle();
      }

      // Verify we're on the task list
      expect(find.byType(TaskListScreen), findsOneWidget);

      // Tap the "+" FAB to add a task
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on the add/edit screen
      expect(find.byType(TaskAddEditScreen), findsOneWidget);

      // Fill in task name
      final nameField = find.byKey(const Key('task_name_field'));
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Test Task');
      await tester.pumpAndSettle();

      // Find and tap the save button (add icon for new tasks)
      final saveButton = find.byIcon(Icons.add);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);

      // Wait for the task to be saved and auto-close to trigger
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify: Should have navigated back to task list
      expect(find.byType(TaskAddEditScreen), findsNothing,
          reason: 'TaskAddEditScreen should have closed after saving task');
      expect(find.byType(TaskListScreen), findsOneWidget,
          reason: 'Should have navigated back to TaskListScreen');
    });

    testWidgets('Editing an existing task navigates back after save',
        (tester) async {
      // Setup: Start with one task
      final now = DateTime.now().toUtc();

      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [
          TaskItem((b) => b
            ..docId = 'task-1'
            ..name = 'Original Task Name'
            ..personDocId = 'test-person-123'
            ..dateAdded = now
            ..completionDate = null
            ..retired = null
            ..offCycle = false
            ..pendingCompletion = false),
        ],
        initialSprints: [],
      );

      await tester.pumpAndSettle();

      // Navigate to Tasks tab
      final appBottomNav = find.byType(NavigationBar);
      final tasksDestination = find.descendant(
        of: appBottomNav,
        matching: find.byWidgetPredicate(
          (widget) => widget is NavigationDestination && widget.label == 'Tasks',
        ),
      );

      if (tasksDestination.evaluate().isNotEmpty) {
        await tester.tap(tasksDestination);
        await tester.pumpAndSettle();
      }

      // Tap the task to open details screen
      final taskTile = find.text('Original Task Name');
      expect(taskTile, findsOneWidget);
      await tester.tap(taskTile);
      await tester.pumpAndSettle();

      // Verify we're on the details screen
      expect(find.byType(TaskDetailsScreen), findsOneWidget);

      // Tap the edit FAB to open edit screen
      final editFab = find.byIcon(Icons.edit);
      expect(editFab, findsOneWidget);
      await tester.tap(editFab);
      await tester.pumpAndSettle();

      // Verify we're now on the edit screen
      expect(find.byType(TaskAddEditScreen), findsOneWidget);

      // Modify the task name
      final nameField = find.byKey(const Key('task_name_field'));
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Updated Task Name');
      await tester.pumpAndSettle();

      // Find and tap the save button (checkmark icon)
      final saveButton = find.byIcon(Icons.check);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);

      // Wait for the task to be updated and auto-close to trigger
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify: Should have navigated back to task details screen
      expect(find.byType(TaskAddEditScreen), findsNothing,
          reason: 'TaskAddEditScreen should have closed after updating task');
      expect(find.byType(TaskDetailsScreen), findsOneWidget,
          reason: 'Should have navigated back to TaskDetailsScreen');

      // Verify task name was updated
      expect(find.text('Updated Task Name'), findsOneWidget);
    });

    testWidgets(
      'Creating a new task does not trip a lifecycle assertion (TM-348)',
      (tester) async {
        // Same auto-close race as the edit case below, but for the new-task
        // branch of _checkForAutoClose (separate Navigator.pop call site,
        // same bug pattern). Without this companion test the new-task
        // branch could regress silently.
        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [],
          initialSprints: [],
        );
        await tester.pumpAndSettle();

        final tasksDestination = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byWidgetPredicate((widget) =>
              widget is NavigationDestination &&
              widget.label == 'Tasks'),
        );
        if (tasksDestination.evaluate().isNotEmpty) {
          await tester.tap(tasksDestination);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byKey(const Key('task_name_field')), 'Brand New Task');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull,
            reason:
                'Creating a new task must not trip any Flutter lifecycle assertions. Same race as the edit-task path — _checkForAutoClose was popping synchronously inside a provider listener.');
      },
    );

    testWidgets(
      'Saving an edited task does not trip a lifecycle assertion (TM-348)',
      (tester) async {
        // Regression test for the auto-close race fixed in TM-348:
        // _checkForAutoClose was popping synchronously from inside a
        // ref.listen callback, starting element disposal mid-notification-
        // cycle. Other ref.watch listeners on the same provider then fired
        // markNeedsBuild on the now-defunct element, tripping
        // `_lifecycleState != _ElementLifecycle.defunct`. The existing
        // navigation tests above only verify that the screen closes —
        // they'd still pass with the synchronous pop. tester.takeException()
        // catches the assertion specifically.
        final now = DateTime.now().toUtc();

        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [
            TaskItem((b) => b
              ..docId = 'task-1'
              ..name = 'Original Task Name'
              ..personDocId = 'test-person-123'
              ..dateAdded = now
              ..completionDate = null
              ..retired = null
              ..offCycle = false
              ..pendingCompletion = false),
          ],
          initialSprints: [],
        );
        await tester.pumpAndSettle();

        final tasksDestination = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byWidgetPredicate((widget) =>
              widget is NavigationDestination && widget.label == 'Tasks'),
        );
        if (tasksDestination.evaluate().isNotEmpty) {
          await tester.tap(tasksDestination);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Original Task Name'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        final nameField = find.byKey(const Key('task_name_field'));
        await tester.enterText(nameField, 'Updated Task Name');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull,
            reason:
                'Saving a task must not trip any Flutter lifecycle assertions. The original bug was a markNeedsBuild on a defunct element after the screen popped synchronously from inside a provider listener.');
      },
    );
  });

  group('TaskAddEditScreen Validation Tests (TM-297)', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Name field is required - cannot save without name',
        (tester) async {
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
        initialSprints: [],
      );

      await tester.pumpAndSettle();

      // Navigate to Tasks tab
      final appBottomNav = find.byType(NavigationBar);
      final tasksDestination = find.descendant(
        of: appBottomNav,
        matching: find.byWidgetPredicate(
          (widget) => widget is NavigationDestination && widget.label == 'Tasks',
        ),
      );

      if (tasksDestination.evaluate().isNotEmpty) {
        await tester.tap(tasksDestination);
        await tester.pumpAndSettle();
      }

      // Tap the "+" FAB to add a task
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on the add/edit screen
      expect(find.byType(TaskAddEditScreen), findsOneWidget);

      // Try to save without entering a name
      final saveButton = find.byIcon(Icons.add);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should still be on the add/edit screen (validation failed)
      expect(find.byType(TaskAddEditScreen), findsOneWidget,
          reason: 'Should remain on add/edit screen when validation fails');

      // Should show validation error (message is "Name is required")
      expect(find.text('Name is required'), findsOneWidget,
          reason: 'Should show validation message for name field');
    });

    testWidgets('Name field shows error after clearing text',
        (tester) async {
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
        initialSprints: [],
      );

      await tester.pumpAndSettle();

      // Navigate to Tasks tab
      final appBottomNav = find.byType(NavigationBar);
      final tasksDestination = find.descendant(
        of: appBottomNav,
        matching: find.byWidgetPredicate(
          (widget) => widget is NavigationDestination && widget.label == 'Tasks',
        ),
      );

      if (tasksDestination.evaluate().isNotEmpty) {
        await tester.tap(tasksDestination);
        await tester.pumpAndSettle();
      }

      // Tap the "+" FAB to add a task
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Enter text then clear it (simulates user typing then deleting)
      final nameField = find.byKey(const Key('task_name_field'));
      await tester.enterText(nameField, 'Test');
      await tester.pumpAndSettle();
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Validation error should appear due to autovalidateMode.onUserInteraction
      expect(find.text('Name is required'), findsOneWidget,
          reason: 'Should show validation message after clearing name');
    });

    testWidgets('Form prevents save when name is empty',
        (tester) async {
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        firestore: fakeFirestore,
        initialTasks: [],
        initialSprints: [],
      );

      await tester.pumpAndSettle();

      // Navigate to Tasks tab
      final appBottomNav = find.byType(NavigationBar);
      final tasksDestination = find.descendant(
        of: appBottomNav,
        matching: find.byWidgetPredicate(
          (widget) => widget is NavigationDestination && widget.label == 'Tasks',
        ),
      );

      if (tasksDestination.evaluate().isNotEmpty) {
        await tester.tap(tasksDestination);
        await tester.pumpAndSettle();
      }

      // Tap the "+" FAB to add a task
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Get initial task count from Firestore
      final tasksBefore = await fakeFirestore.collection('tasks').get();
      final countBefore = tasksBefore.docs.length;

      // Try to save without entering a name
      final saveButton = find.byIcon(Icons.add);
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify no task was created
      final tasksAfter = await fakeFirestore.collection('tasks').get();
      expect(tasksAfter.docs.length, countBefore,
          reason: 'No task should be created when validation fails');

      // Should still be on the add/edit screen
      expect(find.byType(TaskAddEditScreen), findsOneWidget);
    });
  });
}
