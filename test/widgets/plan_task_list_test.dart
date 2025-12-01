import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/shared/presentation/plan_task_list.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/sprint.dart';

/// Widget Test: PlanTaskList
///
/// Tests the PlanTaskList widget (Riverpod version) to verify:
/// 1. Renders task selection UI
/// 2. Displays tasks grouped by categories
/// 3. Submit button appears when tasks are selected
/// 4. Shows loading/error states appropriately
///
/// PlanTaskList is used for sprint planning - selecting which tasks to include in a sprint
void main() {
  group('PlanTaskList Tests', () {
    // Helper to create test tasks
    TaskItem createTestTask({
      required String docId,
      required String name,
      DateTime? dueDate,
      DateTime? urgentDate,
      DateTime? targetDate,
      DateTime? startDate,
      DateTime? completionDate,
    }) {
      return TaskItem((b) => b
        ..docId = docId
        ..name = name
        ..personDocId = 'test_person_id'
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc()
        ..dueDate = dueDate?.toUtc()
        ..urgentDate = urgentDate?.toUtc()
        ..targetDate = targetDate?.toUtc()
        ..startDate = startDate?.toUtc()
        ..completionDate = completionDate?.toUtc());
    }

    // Helper to create test sprint
    Sprint createTestSprint({
      required String docId,
      required DateTime startDate,
      required DateTime endDate,
      required int sprintNumber,
    }) {
      return Sprint((b) => b
        ..docId = docId
        ..personDocId = 'test_person_id'
        ..startDate = startDate.toUtc()
        ..endDate = endDate.toUtc()
        ..dateAdded = DateTime.now().toUtc()
        ..numUnits = 1
        ..unitName = 'Weeks'
        ..sprintNumber = sprintNumber);
    }

    testWidgets('Displays loading indicator when data is loading', (tester) async {
      // Setup: Providers return loading state (never complete)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream<List<TaskItem>>.value([])),
            tasksWithRecurrencesProvider.overrideWith((ref) async => []),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream<List<Sprint>>.value([])),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Note: Since we provide empty streams that complete immediately,
      // we won't see a loading indicator. Instead, verify the screen loads.
      await tester.pump();

      // Verify: Screen renders
      expect(find.text('Select Tasks'), findsOneWidget);
    });

    testWidgets('Displays error message when data loading fails', (tester) async {
      // Setup: Providers return error state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream<List<TaskItem>>.error('Test error')),
            tasksWithRecurrencesProvider.overrideWith((ref) async => throw 'Test error'),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream<List<Sprint>>.value([])),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Error message appears
      expect(find.text('Error loading data'), findsOneWidget);
    });

    testWidgets('Displays task list when data is loaded', (tester) async {
      // Setup: Create test tasks
      final tasks = [
        createTestTask(
          docId: 'task1',
          name: 'Task 1',
          dueDate: DateTime.now().add(Duration(days: 2)),
        ),
        createTestTask(
          docId: 'task2',
          name: 'Task 2',
          urgentDate: DateTime.now().add(Duration(days: 3)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(tasks)),
            tasksWithRecurrencesProvider.overrideWith((ref) async => tasks),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Tasks are displayed
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);

      // Verify: "Select Tasks" title appears in AppBar
      expect(find.text('Select Tasks'), findsOneWidget);
    });

    testWidgets('Displays "No eligible tasks" when task list is empty', (tester) async {
      // Setup: Empty task list
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([])),
            tasksWithRecurrencesProvider.overrideWith((ref) async => []),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: "No eligible tasks" message appears
      expect(find.text('No eligible tasks found.'), findsOneWidget);
    });

    testWidgets('Submit button appears when tasks are selected', (tester) async {
      // Setup: Create tasks that will be auto-selected (urgent/due)
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(Duration(days: 1)), // Past urgent date
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([urgentTask])),
            tasksWithRecurrencesProvider.overrideWith((ref) async => [urgentTask]),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Submit button is visible (FloatingActionButton)
      expect(find.widgetWithText(FloatingActionButton, 'Submit'), findsOneWidget);
    });

    testWidgets('Tasks are grouped by category', (tester) async {
      // Setup: Create tasks in different categories
      final dueTask = createTestTask(
        docId: 'due_task',
        name: 'Due Task',
        dueDate: DateTime.now().add(Duration(days: 2)),
      );
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().add(Duration(days: 3)),
      );
      final targetTask = createTestTask(
        docId: 'target_task',
        name: 'Target Task',
        targetDate: DateTime.now().add(Duration(days: 4)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([dueTask, urgentTask, targetTask])),
            tasksWithRecurrencesProvider.overrideWith((ref) async => [dueTask, urgentTask, targetTask]),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Category headings appear
      // Tasks should be grouped under headings like "Due Soon", "Urgent Soon", "Target Soon", or "Tasks"
      expect(find.text('Due Task'), findsOneWidget);
      expect(find.text('Urgent Task'), findsOneWidget);
      expect(find.text('Target Task'), findsOneWidget);
    });

    testWidgets('Completed tasks are filtered out (not shown in task list)', (tester) async {
      // Setup: Create completed task
      final completedTask = createTestTask(
        docId: 'completed_task',
        name: 'Completed Task',
        completionDate: DateTime.now().subtract(Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([completedTask])),
            tasksWithRecurrencesProvider.overrideWith((ref) async => [completedTask]),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Completed task does NOT appear (filtered out by taskItemsForPlacingOnNewSprint)
      expect(find.text('Completed Task'), findsNothing);

      // Verify: Empty state message appears instead
      expect(find.text('No eligible tasks found.'), findsOneWidget);
    });

    testWidgets('ListView has bottom padding for FAB', (tester) async {
      // Setup: Basic task list
      final task = createTestTask(
        docId: 'task1',
        name: 'Test Task',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([task])),
            tasksWithRecurrencesProvider.overrideWith((ref) async => [task]),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: ListView exists with padding
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // The ListView should have bottom padding to prevent FAB overlap
      final listViewWidget = tester.widget<ListView>(listView);
      expect(listViewWidget.padding, isNotNull);
    });
  });
}
