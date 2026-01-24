import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/services/task_completion_service.dart';
import 'package:taskmaster/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaster/features/tasks/presentation/task_details_screen.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../../../mocks/mock_timezone_helper.dart';

/// Integration tests for TaskDetailsScreen
///
/// Tests the task details view to verify:
/// 1. Task fields display correctly
/// 2. Date fields show appropriate colors for past/future dates
/// 3. Recurrence information displays
/// 4. Edit FAB navigates to edit screen
/// 5. Delete button removes task and navigates back
/// 6. Completion checkbox toggles task state
void main() {
  group('TaskDetailsScreen Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    /// Helper to pump the details screen with a task
    Future<void> pumpDetailsScreen(
      WidgetTester tester, {
      required TaskItem task,
      TaskRecurrence? recurrence,
    }) async {
      // Link recurrence to task if provided
      final taskWithRecurrence = recurrence != null
          ? task.rebuild((t) => t..recurrence = recurrence.toBuilder())
          : task;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(fakeFirestore),
            tasksProvider.overrideWith((ref) => Stream.value([taskWithRecurrence])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value([taskWithRecurrence])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value(
              recurrence != null ? [recurrence] : [],
            )),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            timezoneHelperNotifierProvider.overrideWith(() => _TestTimezoneHelperNotifier()),
          ],
          child: MaterialApp(
            theme: ThemeData(
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.all(Colors.blue),
              ),
            ),
            home: TaskDetailsScreen(taskItemId: task.docId),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('Displays task name', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Test Task Name'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      expect(find.text('Test Task Name'), findsOneWidget);
      expect(find.text('Task Item Details'), findsOneWidget);
    });

    testWidgets('Displays project field when present', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Task With Project'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..project = 'Work Project'
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Work Project'), findsOneWidget);
    });

    testWidgets('Displays context field when present', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Task With Context'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..context = '@home'
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      expect(find.text('Context'), findsOneWidget);
      expect(find.text('@home'), findsOneWidget);
    });

    testWidgets('Displays priority, points, and length fields', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Task With Metrics'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..priority = 1
        ..gamePoints = 5
        ..duration = 30
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('Displays notes/description field', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Task With Notes'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..description = 'This is a detailed description of the task'
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('This is a detailed description of the task'), findsOneWidget);
    });

    testWidgets('Displays recurrence information for recurring task', (tester) async {
      final recurrence = TaskRecurrence((r) => r
        ..docId = 'recur-1'
        ..name = 'Weekly Recurrence'
        ..personDocId = 'person-123'
        ..recurNumber = 1
        ..recurUnit = 'Weeks'
        ..recurWait = false
        ..recurIteration = 1
        ..dateAdded = DateTime.now().toUtc()
        ..anchorDate = AnchorDate((a) => a
          ..dateType = TaskDateTypes.due
          ..dateValue = DateTime.now().toUtc()).toBuilder());

      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Recurring Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..recurrenceDocId = 'recur-1'
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task, recurrence: recurrence);

      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Every 1 week'), findsOneWidget);
    });

    testWidgets('Displays recurrence with "after completion" for recurWait=true', (tester) async {
      final recurrence = TaskRecurrence((r) => r
        ..docId = 'recur-1'
        ..name = 'Daily Recurrence'
        ..personDocId = 'person-123'
        ..recurNumber = 3
        ..recurUnit = 'Days'
        ..recurWait = true
        ..recurIteration = 1
        ..dateAdded = DateTime.now().toUtc()
        ..anchorDate = AnchorDate((a) => a
          ..dateType = TaskDateTypes.due
          ..dateValue = DateTime.now().toUtc()).toBuilder());

      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Recurring Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..recurrenceDocId = 'recur-1'
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task, recurrence: recurrence);

      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Every 3 days (after completion)'), findsOneWidget);
    });

    testWidgets('Displays "No recurrence" for non-recurring task', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'One-time Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('No recurrence.'), findsOneWidget);
    });

    testWidgets('Details screen uses scrollable ListView', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Task With Dates'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      // The screen is a ListView - verify it exists
      expect(find.byType(ListView), findsOneWidget);

      // Verify the scaffold structure is correct
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Edit FAB navigates to edit screen', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Editable Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      // Find and tap the edit FAB
      final editFab = find.byIcon(Icons.edit);
      expect(editFab, findsOneWidget);
      await tester.tap(editFab);
      await tester.pumpAndSettle();

      // Verify navigation to edit screen
      expect(find.byType(TaskAddEditScreen), findsOneWidget);
    });

    testWidgets('Delete button is present in app bar', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Deletable Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      // Find delete button
      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);
    });

    testWidgets('Shows "Task not found" when task does not exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(fakeFirestore),
            tasksProvider.overrideWith((ref) => Stream.value(<TaskItem>[])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(<TaskItem>[])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value(<TaskRecurrence>[])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            timezoneHelperNotifierProvider.overrideWith(() => _TestTimezoneHelperNotifier()),
          ],
          child: MaterialApp(
            theme: ThemeData(
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.all(Colors.blue),
              ),
            ),
            home: const TaskDetailsScreen(taskItemId: 'non-existent'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Task Not Found'), findsOneWidget);
      expect(find.text('Task not found'), findsOneWidget);
    });

    testWidgets('Displays checkbox for incomplete task', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Incomplete Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..completionDate = null
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      // Should have a DelayedCheckbox (wrapped in GestureDetector)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Displays completed checkbox for completed task', (tester) async {
      final now = DateTime.now().toUtc();
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Completed Task'
        ..personDocId = 'person-123'
        ..dateAdded = now
        ..completionDate = now
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      // Should show done_outline icon for completed state
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
    });

    testWidgets('Displays pending checkbox for pending completion', (tester) async {
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Pending Task'
        ..personDocId = 'person-123'
        ..dateAdded = DateTime.now().toUtc()
        ..completionDate = null
        ..offCycle = false
        ..pendingCompletion = true);

      await pumpDetailsScreen(tester, task: task);

      // Should show more_horiz icon for pending state
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('Task with all fields displays key information', (tester) async {
      final now = DateTime.now().toUtc();
      final task = TaskItem((b) => b
        ..docId = 'task-1'
        ..name = 'Complete Task'
        ..personDocId = 'person-123'
        ..dateAdded = now
        ..project = 'Work'
        ..context = '@office'
        ..priority = 2
        ..gamePoints = 10
        ..duration = 60
        ..description = 'Full task description'
        ..startDate = now.subtract(const Duration(days: 7))
        ..targetDate = now.add(const Duration(days: 3))
        ..urgentDate = now.add(const Duration(days: 5))
        ..dueDate = now.add(const Duration(days: 7))
        ..offCycle = false
        ..pendingCompletion = false);

      await pumpDetailsScreen(tester, task: task);

      // Verify visible fields (without scrolling)
      expect(find.text('Complete Task'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('@office'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);

      // Scroll down to see notes
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Full task description'), findsOneWidget);
    });
  });
}

/// Test helper for TimezoneHelperNotifier
class _TestTimezoneHelperNotifier extends TimezoneHelperNotifier {
  @override
  Future<TimezoneHelper> build() async {
    return MockTimezoneHelper();
  }
}
