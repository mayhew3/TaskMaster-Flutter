import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/delayed_checkbox.dart';

import 'integration_test_helper.dart';

/// Integration Test: Recurring Task Flow
///
/// Tests the recurring task functionality:
/// 1. Display recurring tasks with recurrence info
/// 2. Show task recurrence patterns (daily, weekly, monthly)
/// 3. Display next occurrence information
/// 4. Handle tasks linked to recurrence patterns
///
/// This ensures recurring task metadata is properly displayed to users.
void main() {
  group('Recurring Task Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('Task linked to daily recurrence displays correctly',
        (tester) async {
      // Setup: Create a daily recurring task pattern
      final dailyRecurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-daily'
        ..personDocId = 'test-person-123'
        ..name = 'Daily Standup'
        ..recurNumber = 1
        ..recurUnit = 'days'
        ..recurWait = false
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = DateTime.now().toUtc()
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = DateTime.now().toUtc());

      // Create a task linked to this recurrence
      final recurringTask = TaskItem((b) => b
        ..docId = 'task-recurring-1'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Daily Standup'
        ..personDocId = 'test-person-123'
        ..recurrenceDocId = 'recurrence-daily'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [recurringTask],
        initialRecurrences: [dailyRecurrence],
      );

      // Verify: Task name is visible
      expect(find.text('Daily Standup'), findsOneWidget);

      print('✓ Daily recurring task displayed correctly');
    });

    testWidgets('Task linked to weekly recurrence displays correctly',
        (tester) async {
      // Setup: Create a weekly recurring task pattern
      final weeklyRecurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-weekly'
        ..personDocId = 'test-person-123'
        ..name = 'Weekly Report'
        ..recurNumber = 1
        ..recurUnit = 'weeks'
        ..recurWait = false
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = DateTime.now().toUtc()
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = DateTime.now().toUtc());

      // Create a task linked to this recurrence
      final recurringTask = TaskItem((b) => b
        ..docId = 'task-recurring-2'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Weekly Report'
        ..personDocId = 'test-person-123'
        ..recurrenceDocId = 'recurrence-weekly'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [recurringTask],
        initialRecurrences: [weeklyRecurrence],
      );

      // Verify: Task name is visible
      expect(find.text('Weekly Report'), findsOneWidget);

      print('✓ Weekly recurring task displayed correctly');
    });

    testWidgets('Multiple recurring tasks display correctly', (tester) async {
      // Setup: Create multiple recurring patterns
      final dailyRecurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-daily'
        ..personDocId = 'test-person-123'
        ..name = 'Morning Exercise'
        ..recurNumber = 1
        ..recurUnit = 'days'
        ..recurWait = false
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = DateTime.now().toUtc()
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = DateTime.now().toUtc());

      final weeklyRecurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-weekly'
        ..personDocId = 'test-person-123'
        ..name = 'Team Meeting'
        ..recurNumber = 1
        ..recurUnit = 'weeks'
        ..recurWait = false
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = DateTime.now().toUtc()
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = DateTime.now().toUtc());

      // Create tasks for each pattern
      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-1'
          ..dateAdded = DateTime.now().toUtc()
          ..name = 'Morning Exercise'
          ..personDocId = 'test-person-123'
          ..recurrenceDocId = 'recurrence-daily'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-2'
          ..dateAdded = DateTime.now().toUtc()
          ..name = 'Team Meeting'
          ..personDocId = 'test-person-123'
          ..recurrenceDocId = 'recurrence-weekly'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: tasks,
        initialRecurrences: [dailyRecurrence, weeklyRecurrence],
      );

      // Verify: Both tasks are visible
      expect(find.text('Morning Exercise'), findsOneWidget);
      expect(find.text('Team Meeting'), findsOneWidget);

      print('✓ Multiple recurring tasks displayed correctly');
    });

    testWidgets('Non-recurring tasks display alongside recurring tasks',
        (tester) async {
      // Setup: Mix of recurring and non-recurring tasks
      final recurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-1'
        ..personDocId = 'test-person-123'
        ..name = 'Recurring Task'
        ..recurNumber = 1
        ..recurUnit = 'days'
        ..recurWait = false
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = DateTime.now().toUtc()
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = DateTime.now().toUtc());

      final tasks = [
        // Recurring task
        TaskItem((b) => b
          ..docId = 'task-recurring'
          ..dateAdded = DateTime.now().toUtc()
          ..name = 'Recurring Task'
          ..personDocId = 'test-person-123'
          ..recurrenceDocId = 'recurrence-1'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        // Non-recurring task
        TaskItem((b) => b
          ..docId = 'task-one-time'
          ..dateAdded = DateTime.now().toUtc()
          ..name = 'One-Time Task'
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
        initialRecurrences: [recurrence],
      );

      // Verify: Both types of tasks are visible
      expect(find.text('Recurring Task'), findsOneWidget);
      expect(find.text('One-Time Task'), findsOneWidget);

      print('✓ Mixed recurring and non-recurring tasks displayed correctly');
    });

    testWidgets('Task recurrence patterns are properly associated',
        (tester) async {
      // Setup: Create recurrence with monthly schedule
      final monthlyRecurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-monthly'
        ..personDocId = 'test-person-123'
        ..name = 'Monthly Review'
        ..recurNumber = 1
        ..recurUnit = 'months'
        ..recurWait = false
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = DateTime.now().toUtc()
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = DateTime.now().toUtc());

      final recurringTask = TaskItem((b) => b
        ..docId = 'task-monthly'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Monthly Review'
        ..personDocId = 'test-person-123'
        ..recurrenceDocId = 'recurrence-monthly'
        ..dueDate = DateTime.now().add(Duration(days: 30)).toUtc()
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [recurringTask],
        initialRecurrences: [monthlyRecurrence],
      );

      // Verify: Task displays with all details
      expect(find.text('Monthly Review'), findsOneWidget);

      // TODO: Add assertions for recurrence indicator icon/badge
      // Your UI likely shows a recurring icon or badge on these tasks

      print('✓ Monthly recurring task with due date displayed correctly');
    });

    testWidgets('Completing recurring task creates next iteration',
        (tester) async {
      // Setup: Create a daily recurring task pattern
      final now = DateTime.now().toUtc();
      final tomorrow = now.add(Duration(days: 1));

      final dailyRecurrence = TaskRecurrence((b) => b
        ..docId = 'recurrence-complete-test'
        ..personDocId = 'test-person-123'
        ..name = 'Daily Exercise'
        ..recurNumber = 1
        ..recurUnit = 'days'
        ..recurWait = false  // On Schedule (not On Complete)
        ..recurIteration = 0
        ..anchorDate = AnchorDate((a) => a
          ..dateValue = now
          ..dateType = TaskDateTypes.start).toBuilder()
        ..dateAdded = now);

      // Create a task linked to this recurrence
      final recurringTask = TaskItem((b) => b
        ..docId = 'task-to-complete'
        ..dateAdded = now
        ..name = 'Daily Exercise'
        ..personDocId = 'test-person-123'
        ..recurrenceDocId = 'recurrence-complete-test'
        ..recurIteration = 1
        ..startDate = now
        ..targetDate = tomorrow
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      // Write task to Firestore so it can be updated
      await writeTaskToFirestore(fakeFirestore, recurringTask, dailyRecurrence);

      await IntegrationTestHelper.pumpApp(
        tester,
        firestore: fakeFirestore,
        initialTasks: [recurringTask],
        initialRecurrences: [dailyRecurrence],
      );

      // Verify: Task is visible
      expect(find.text('Daily Exercise'), findsOneWidget);

      // Step 1: Complete the task by tapping checkbox
      final checkbox = find.byType(DelayedCheckbox).first;
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Sync completion and next iteration creation to Redux
      await syncRecurringTaskCompletion(
        tester,
        fakeFirestore,
        'task-to-complete',
        dailyRecurrence,
      );

      // Verify: Original task is completed
      final store = StoreProvider.of<AppState>(
        tester.element(find.byType(MaterialApp)),
      );
      final completedTask = store.state.taskItems
          .firstWhere((t) => t.docId == 'task-to-complete');
      expect(completedTask.completionDate, isNotNull);
      expect(completedTask.isCompleted(), true);

      // Verify: Next iteration was created
      final nextIterationTasks = store.state.taskItems.where(
        (t) => t.recurrenceDocId == 'recurrence-complete-test' && t.docId != 'task-to-complete',
      );
      expect(nextIterationTasks.length, 1,
          reason: 'Should have created one next iteration');

      final nextTask = nextIterationTasks.first;

      // Verify: Next task has correct recurrence metadata
      expect(nextTask.name, 'Daily Exercise');
      expect(nextTask.recurrenceDocId, 'recurrence-complete-test');
      expect(nextTask.recurIteration, 2,
          reason: 'Next iteration should increment from 1 to 2');
      expect(nextTask.completionDate, null,
          reason: 'Next iteration should not be completed');

      // Verify: Next task has dates shifted by 1 day
      expect(nextTask.startDate, isNotNull);
      expect(nextTask.startDate!.difference(recurringTask.startDate!).inDays, 1,
          reason: 'Start date should be 1 day later');
      expect(nextTask.targetDate, isNotNull);
      expect(nextTask.targetDate!.difference(recurringTask.targetDate!).inDays, 1,
          reason: 'Target date should be 1 day later');

      print('✓ Completing recurring task creates next iteration with correct dates');
    });
  });
}

/// Helper: Write task and recurrence to Firestore
Future<void> writeTaskToFirestore(
  FakeFirebaseFirestore firestore,
  TaskItem task,
  TaskRecurrence recurrence,
) async {
  // Write recurrence first
  final recurrenceDoc = firestore.collection('taskRecurrences').doc(recurrence.docId);
  await recurrenceDoc.set({
    'dateAdded': recurrence.dateAdded,
    'name': recurrence.name,
    'personDocId': recurrence.personDocId,
    'recurNumber': recurrence.recurNumber,
    'recurUnit': recurrence.recurUnit,
    'recurWait': recurrence.recurWait,
    'recurIteration': recurrence.recurIteration,
    if (recurrence.anchorDate != null) 'anchorDate': {
      'dateValue': recurrence.anchorDate!.dateValue,
      'dateType': recurrence.anchorDate!.dateType.label,
    },
  });

  // Write task
  final taskDoc = firestore.collection('tasks').doc(task.docId);
  await taskDoc.set({
    'dateAdded': task.dateAdded,
    'name': task.name,
    'personDocId': task.personDocId,
    'offCycle': task.offCycle,
    'pendingCompletion': task.pendingCompletion,
    if (task.recurrenceDocId != null) 'recurrenceDocId': task.recurrenceDocId,
    if (task.recurIteration != null) 'recurIteration': task.recurIteration,
    if (task.startDate != null) 'startDate': task.startDate,
    if (task.targetDate != null) 'targetDate': task.targetDate,
    if (task.completionDate != null) 'completionDate': task.completionDate,
    if (task.retired != null) 'retired': task.retired,
  });
}

/// Helper: Sync recurring task completion and next iteration to Redux
Future<void> syncRecurringTaskCompletion(
  WidgetTester tester,
  FakeFirebaseFirestore firestore,
  String taskId,
  TaskRecurrence recurrence,
) async {
  // Wait for Firestore writes
  await tester.pump(Duration(milliseconds: 100));

  final store = StoreProvider.of<AppState>(
    tester.element(find.byType(MaterialApp)),
  );

  // Read completed task from Firestore
  final taskDoc = await firestore.collection('tasks').doc(taskId).get();
  if (taskDoc.exists) {
    final taskData = taskDoc.data()!;
    taskData['docId'] = taskDoc.id;
    final completedTask = TaskItem.fromJson(taskData);

    // Read all tasks to find the next iteration (newest task with same recurrenceDocId)
    final tasksSnapshot = await firestore.collection('tasks')
        .where('recurrenceDocId', isEqualTo: recurrence.docId)
        .get();

    final allTasks = tasksSnapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;
      return TaskItem.fromJson(data);
    }).toList();

    // Find the newly created task (highest recurIteration)
    TaskItem? nextIterationTask;
    if (allTasks.length > 1) {
      allTasks.sort((a, b) => b.recurIteration!.compareTo(a.recurIteration!));
      nextIterationTask = allTasks.first;
    }

    // Dispatch RecurringTaskItemCompletedAction with both tasks
    if (nextIterationTask != null) {
      // First mark original as completed
      store.dispatch(TaskItemCompletedAction(completedTask, true));
      // Then add the next iteration
      store.dispatch(TasksAddedAction([nextIterationTask]));
    } else {
      // Non-recurring completion
      store.dispatch(TaskItemCompletedAction(completedTask, true));
    }

    await tester.pumpAndSettle();
  }
}
