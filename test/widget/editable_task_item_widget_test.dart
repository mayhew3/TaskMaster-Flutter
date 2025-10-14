import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/presentation/editable_task_item.dart';

/// Widget Test: EditableTaskItemWidget
///
/// Tests the EditableTaskItemWidget in isolation to verify:
/// 1. Task name displays correctly
/// 2. Project field shows/hides appropriately
/// 3. Background colors reflect task status
/// 4. Sprint indicator icon appears when needed
/// 5. Task borders change for sprint-highlighted tasks
/// 6. Date warnings display
///
/// These are widget tests (not integration tests), so we test the widget
/// in isolation without the full app context.
void main() {
  group('EditableTaskItemWidget Tests', () {
    testWidgets('Displays task name', (tester) async {
      // Setup: Create a simple task
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Test Task Name'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      // Build the widget wrapped in MaterialApp
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears
      expect(find.text('Test Task Name'), findsOneWidget);
    });

    testWidgets('Displays project field when present', (tester) async {
      // Setup: Task with project
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Task With Project'
        ..personDocId = 'person-123'
        ..project = 'Work Project'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Both task name and project appear
      expect(find.text('Task With Project'), findsOneWidget);
      expect(find.text('Work Project'), findsOneWidget);
    });

    testWidgets('Hides project field when not present', (tester) async {
      // Setup: Task without project
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Task Without Project'
        ..personDocId = 'person-123'
        ..project = null
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears, project field is hidden
      expect(find.text('Task Without Project'), findsOneWidget);

      // The project Visibility widget should exist but not be visible
      final visibility = tester.widget<Visibility>(
        find.byType(Visibility).first,
      );
      expect(visibility.visible, false);
    });

    testWidgets('Shows sprint icon when highlightSprint is true',
        (tester) async {
      // Setup: Task with sprint highlight
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Sprint Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: true,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Sprint icon appears
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });

    testWidgets('Hides sprint icon when highlightSprint is false',
        (tester) async {
      // Setup: Task without sprint highlight
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Non-Sprint Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: No sprint icon appears
      expect(find.byIcon(Icons.assignment), findsNothing);
    });

    testWidgets('Displays due date warning for past due tasks', (tester) async {
      // Setup: Task with past due date
      final now = DateTime.now().toUtc();
      final pastDue = now.subtract(Duration(days: 2));

      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = now
        ..name = 'Past Due Task'
        ..personDocId = 'person-123'
        ..dueDate = pastDue
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears
      expect(find.text('Past Due Task'), findsOneWidget);

      // Verify: Due date warning appears (contains "Due" and "ago")
      expect(find.textContaining('Due'), findsWidgets);
      expect(find.textContaining('ago'), findsWidgets);
    });

    testWidgets('Displays urgent date warning for urgent tasks', (tester) async {
      // Setup: Task with past urgent date
      final now = DateTime.now().toUtc();
      final pastUrgent = now.subtract(Duration(hours: 6));

      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = now
        ..name = 'Urgent Task'
        ..personDocId = 'person-123'
        ..urgentDate = pastUrgent
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears
      expect(find.text('Urgent Task'), findsOneWidget);

      // Verify: Urgent date warning appears
      expect(find.textContaining('Urgent'), findsWidgets);
      expect(find.textContaining('ago'), findsWidgets);
    });

    testWidgets('Displays target date warning for target tasks', (tester) async {
      // Setup: Task with past target date
      final now = DateTime.now().toUtc();
      final pastTarget = now.subtract(Duration(days: 1));

      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = now
        ..name = 'Target Task'
        ..personDocId = 'person-123'
        ..targetDate = pastTarget
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears
      expect(find.text('Target Task'), findsOneWidget);

      // Verify: Target date warning appears
      expect(find.textContaining('Target'), findsWidgets);
      expect(find.textContaining('ago'), findsWidgets);
    });

    testWidgets('Displays completed date for completed tasks', (tester) async {
      // Setup: Completed task
      final now = DateTime.now().toUtc();

      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = now
        ..name = 'Completed Task'
        ..personDocId = 'person-123'
        ..completionDate = now
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears
      expect(find.text('Completed Task'), findsOneWidget);

      // Verify: Completed date appears
      expect(find.textContaining('Completed'), findsWidgets);
    });

    testWidgets('Task with no dates shows no date warnings', (tester) async {
      // Setup: Task with no special dates
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Simple Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Task name appears
      expect(find.text('Simple Task'), findsOneWidget);

      // Verify: No date warnings (shouldn't find "Due", "Urgent", "Target")
      expect(find.textContaining('Due'), findsNothing);
      expect(find.textContaining('Urgent'), findsNothing);
      expect(find.textContaining('Target'), findsNothing);
    });

    testWidgets('Task card is wrapped in Dismissible widget', (tester) async {
      // Setup: Simple task
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Dismissible Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
            ),
          ),
        ),
      );

      // Verify: Dismissible widget exists (allows swipe to delete)
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('Task card is tappable via GestureDetector', (tester) async {
      // Setup: Task with tap handler
      bool tapped = false;
      final task = TaskItem((b) => b
        ..docId = 'test-task'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Tappable Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: EditableTaskItemWidget(
              taskItem: task,
              highlightSprint: false,
              onTaskCompleteToggle: (checkState) => null,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify: GestureDetector exists (multiple expected due to checkbox, etc.)
      expect(find.byType(GestureDetector), findsWidgets);

      // Tap the card
      await tester.tap(find.text('Tappable Task'));
      await tester.pump();

      // Verify: Tap was registered
      expect(tapped, true);
    });

    testWidgets('Multiple tasks display independently', (tester) async {
      // Setup: Multiple tasks
      final task1 = TaskItem((b) => b
        ..docId = 'task-1'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'First Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task2 = TaskItem((b) => b
        ..docId = 'task-2'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Second Task'
        ..personDocId = 'person-123'
        ..project = 'Project A'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: ListView(
              children: [
                EditableTaskItemWidget(
                  taskItem: task1,
                  highlightSprint: false,
                  onTaskCompleteToggle: (checkState) => null,
                ),
                EditableTaskItemWidget(
                  taskItem: task2,
                  highlightSprint: true,
                  onTaskCompleteToggle: (checkState) => null,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify: Both tasks appear
      expect(find.text('First Task'), findsOneWidget);
      expect(find.text('Second Task'), findsOneWidget);
      expect(find.text('Project A'), findsOneWidget);

      // Verify: Only second task has sprint icon
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });
  });
}
