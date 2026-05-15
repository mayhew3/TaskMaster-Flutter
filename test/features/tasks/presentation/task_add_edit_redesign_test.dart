import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaestro/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/task_item.dart';
import '../../../integration/integration_test_helper.dart';

/// Integration tests for the TM-358 edit-task redesign chrome and wiring.
///
/// Coverage focus:
///   - Top-nav redesign (back arrow + centered title + delete trash icon)
///   - Sticky bottom action bar (replaces the legacy FAB)
///   - Delete-from-edit confirm dialog flow
///
/// Field-population behavior (priority bar, length bucket snapping, points
/// Fibonacci) is covered by the per-widget tests in `test/widgets/` since
/// those don't depend on the Firestore + taskProvider wiring and run faster.
///
/// Like `task_add_edit_navigation_test.dart`, these use
/// `pumpAppWithLiveFirestore()` because the auto-close logic depends on
/// Firestore streams.
void main() {
  group('TaskAddEditScreen Redesign (TM-358)', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> _navigateToEditScreenForTask(WidgetTester tester) async {
      final tasksDestination = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byWidgetPredicate((widget) =>
            widget is NavigationDestination && widget.label == 'Tasks'),
      );
      if (tasksDestination.evaluate().isNotEmpty) {
        await tester.tap(tasksDestination);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Existing Task'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(TaskMaestroKeys.editableTaskItemEditButton('task-1')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TaskAddEditScreen), findsOneWidget);
    }

    TaskItem _seedTask({String name = 'Existing Task'}) {
      final now = DateTime.now().toUtc();
      return TaskItem((b) => b
        ..docId = 'task-1'
        ..name = name
        ..personDocId = 'test-person-123'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);
    }

    testWidgets(
      'Edit screen surfaces the redesigned chrome '
      '(top-nav title + sticky save bar, no FAB)',
      (tester) async {
        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [_seedTask()],
          initialSprints: [],
        );
        await tester.pumpAndSettle();
        await _navigateToEditScreenForTask(tester);

        // Top-nav title.
        expect(find.text('Edit task'), findsOneWidget);
        // Bottom action bar buttons present.
        expect(find.text('Save changes'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        // FAB is no longer rendered on this screen.
        expect(find.byType(FloatingActionButton), findsNothing);
      },
    );

    testWidgets(
      'Trash icon → confirm dialog → Cancel leaves the screen open',
      (tester) async {
        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [_seedTask()],
          initialSprints: [],
        );
        await tester.pumpAndSettle();
        await _navigateToEditScreenForTask(tester);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Confirm dialog visible.
        expect(find.text('Delete this task?'), findsOneWidget);

        // Cancel inside the dialog (TextButton) — disambiguated from the
        // bottom action bar's Cancel.
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(TaskAddEditScreen), findsOneWidget,
            reason: 'Cancelling delete should leave the edit screen open');
        expect(find.text('Delete this task?'), findsNothing,
            reason: 'Dialog should be dismissed');
      },
    );

    testWidgets(
      'Trash icon → Delete confirmation pops the screen and removes the task',
      (tester) async {
        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [_seedTask()],
          initialSprints: [],
        );
        await tester.pumpAndSettle();
        await _navigateToEditScreenForTask(tester);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Confirm via the FilledButton labeled "Delete" inside the dialog.
        await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(TaskAddEditScreen), findsNothing,
            reason: 'Confirmed delete should pop the edit screen');
        expect(find.byType(TaskListScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Edit-mode screen shows loading until the task materializes — '
      'previously fell through to blank "New task" form on startup race',
      (tester) async {
        // Pump the app with NO tasks seeded; navigate directly to the edit
        // screen for a task ID that the provider can't yet resolve. The
        // pre-fix behaviour was: didChangeDependencies fires ref.read,
        // sees null, initializes as a blank new-task blueprint, and latches
        // — so the screen showed "New task" with all fields empty even
        // though the user had clicked Edit on an existing task tile. The
        // fix watches the provider so the screen shows loading until the
        // task is actually available.
        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [],
          initialSprints: [],
        );
        await tester.pumpAndSettle();

        // Push the edit screen directly — bypassing the tile flow lets us
        // hit the "task not yet in any source" state deterministically.
        final navState = tester
            .state<NavigatorState>(find.byType(Navigator).first);
        navState.push(MaterialPageRoute<void>(
          builder: (_) => const TaskAddEditScreen(taskItemId: 'never-loads'),
        ));
        await tester.pump();
        await tester.pump();

        expect(find.byType(TaskAddEditScreen), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget,
            reason: 'Edit-mode screen should render a loading spinner '
                'while the task is still resolving in the provider.');
        expect(find.text('New task'), findsNothing,
            reason: 'Must not fall through to blank create-new mode.');
      },
    );

    testWidgets(
      'New-task screen shows "New task" title and "Add task" button '
      '(no trash icon)',
      (tester) async {
        await IntegrationTestHelper.pumpAppWithLiveFirestore(
          tester,
          firestore: fakeFirestore,
          initialTasks: [],
          initialSprints: [],
        );
        await tester.pumpAndSettle();

        // Navigate to Tasks tab and tap the FAB to open the add screen.
        final tasksDestination = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byWidgetPredicate((widget) =>
              widget is NavigationDestination && widget.label == 'Tasks'),
        );
        if (tasksDestination.evaluate().isNotEmpty) {
          await tester.tap(tasksDestination);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(TaskAddEditScreen), findsOneWidget);
        // Add-mode chrome.
        expect(find.text('New task'), findsOneWidget);
        expect(find.text('Add task'), findsOneWidget);
        // Trash icon should NOT appear in add mode.
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      },
    );
  });
}
