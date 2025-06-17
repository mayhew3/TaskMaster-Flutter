
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data_builder.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
void main() {

  int getDaysFrom(DateTime earlierDate, DateTime laterDate) {
    var diff = DateUtil.withoutMillis(laterDate).difference(DateUtil.withoutMillis(earlierDate)).inDays;
    return diff;
  }

  int getDaysFromNow(DateTime date) {
    var now = DateTime.now();
    return getDaysFrom(now, date);
  }


  group('generatePreview', () {

    test('generatePreview moves target and due dates', () {
      var blueprint = MockTaskItemBuilder.withDates()
          .create().createBlueprint();

      var originalTarget = blueprint.targetDate!;
      var originalDue = blueprint.dueDate!;

      RecurrenceHelper.generatePreview(
          blueprint, 6, 'Days', TaskDateTypes.target);

      var newTarget = DateUtil.withoutMillis(blueprint.targetDate!);
      var diffTarget = newTarget
          .difference(DateUtil.withoutMillis(DateTime.now()))
          .inDays;

      expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');
      expect(newTarget.hour, originalTarget.hour,
          reason: 'Expect hour of target date to be unchanged.');

      var newDue = DateUtil.withoutMillis(blueprint.dueDate!);

      expect(getDaysFromNow(newDue), 13,
          reason: 'Expect Due date to be in 13 days.');
      expect(newDue.hour, originalDue.hour,
          reason: 'Expect hour of due date to be unchanged.');
    });

    test('generatePreview on task without a start date adds a start date', () {
      var taskItem = MockTaskItemBuilder
          .asDefault()
          .create().createBlueprint();

      RecurrenceHelper.generatePreview(
          taskItem, 4, 'Days', TaskDateTypes.start);

      var newStart = DateUtil.withoutMillis(taskItem.startDate!);

      expect(getDaysFromNow(newStart), 4,
          reason: 'Expect Start date to be 4 days from now.');
    });

  });


  group('updateTaskAndMaybeRecurrence', () {

    test('updateTaskAndMaybeRecurrence with no recurrence', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates()
          .create();
      var blueprint = taskItem.createBlueprint();
      blueprint.incrementDateIfExists(TaskDateTypes.due, Duration(days: 3));

      var action = ExecuteSnooze(taskItem: taskItem,
          blueprint: blueprint,
          numUnits: 3,
          unitSize: 'Days',
          dateType: TaskDateTypes.due);

      TaskItem? resultTask;
      TaskItemBlueprint? resultingBlueprint;

      when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any))
          .thenAnswer((invocation) {
        resultingBlueprint = invocation.positionalArguments[1];
        resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
        return Future.value((taskItem: resultTask!, recurrence: null));
      });

      RecurrenceHelper.updateTaskAndMaybeRecurrence(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(
          taskItem.docId, resultingBlueprint));
    });

    test('updateTaskAndMaybeRecurrence with On Complete recurrence', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates(offCycle: false)
          .withRecur(recurWait: false) // Mimics "On Complete"
          .create();
      var originalAnchorDate = taskItem.recurrence!.anchorDate;
      var blueprint = taskItem.createBlueprint();
      blueprint.incrementDateIfExists(TaskDateTypes.due, Duration(days: 3));

      var action = ExecuteSnooze(taskItem: taskItem,
          blueprint: blueprint,
          numUnits: 3,
          unitSize: 'Days',
          dateType: TaskDateTypes.due);

      TaskItem? resultTask;
      TaskItemBlueprint? resultingBlueprint;

      when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any))
          .thenAnswer((invocation) {
        resultingBlueprint = invocation.positionalArguments[1];
        resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
        return Future.value((taskItem: resultTask!, recurrence: null));
      });

      RecurrenceHelper.updateTaskAndMaybeRecurrence(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(
          taskItem.docId, resultingBlueprint));
      expect(resultingBlueprint!.recurrenceBlueprint!.anchorDate,
          originalAnchorDate);
    });

    test(
        'updateTaskAndMaybeRecurrence with On Schedule recurrence, on cycle', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates(offCycle: false)
          .withRecur(recurWait: true) // Mimics "On Schedule"
          .create();
      var originalAnchorDate = taskItem.recurrence!.anchorDate;
      var blueprint = taskItem.createBlueprint();
      blueprint.incrementDateIfExists(TaskDateTypes.due, Duration(days: 3));

      var action = ExecuteSnooze(taskItem: taskItem,
          blueprint: blueprint,
          numUnits: 3,
          unitSize: 'Days',
          dateType: TaskDateTypes.due);

      TaskItem? resultTask;
      TaskItemBlueprint? resultingBlueprint;

      when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any))
          .thenAnswer((invocation) {
        resultingBlueprint = invocation.positionalArguments[1];
        resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
        return Future.value((taskItem: resultTask!, recurrence: null));
      });

      RecurrenceHelper.updateTaskAndMaybeRecurrence(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(
          taskItem.docId, resultingBlueprint));
      expect(resultingBlueprint!.recurrenceBlueprint!.anchorDate, isNot(originalAnchorDate));
    });

    test(
        'updateTaskAndMaybeRecurrence with On Schedule recurrence, off cycle', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates(offCycle: true)
          .withRecur(recurWait: true) // Mimics "On Schedule"
          .create();
      var originalAnchorDate = taskItem.recurrence!.anchorDate;
      var blueprint = taskItem.createBlueprint();
      blueprint.incrementDateIfExists(TaskDateTypes.due, Duration(days: 3));

      var action = ExecuteSnooze(taskItem: taskItem,
          blueprint: blueprint,
          numUnits: 3,
          unitSize: 'Days',
          dateType: TaskDateTypes.due);

      TaskItem? resultTask;
      TaskItemBlueprint? resultingBlueprint;

      when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any))
          .thenAnswer((invocation) {
        resultingBlueprint = invocation.positionalArguments[1];
        resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
        return Future.value((taskItem: resultTask!, recurrence: null));
      });

      RecurrenceHelper.updateTaskAndMaybeRecurrence(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(
          taskItem.docId, resultingBlueprint));
      expect(resultingBlueprint!.recurrenceBlueprint!.anchorDate, originalAnchorDate);
    });

  });


  group('createNextIteration', () {
    test('should correctly create next iteration for a simple daily recurrence', () {
      final recurrence = (TaskRecurrenceBuilder()
            ..docId = 'recurDocId'
            ..dateAdded = DateTime(2023, 1, 1)
            ..personDocId = 'personDocId'
            ..name = 'Daily'
            ..recurNumber = 1
            ..recurUnit = 'Days'
            ..recurWait = true // Mimics "On Complete"
            ..recurIteration = 1
            ..anchorDate = DateTime(2024, 1, 1, 10, 0, 0) // Anchor to the original event time
            ..anchorType = TaskDateTypes.start.label // Assuming start date anchor
          ).build();

      final taskToIterate = (TaskItemBuilder()
            ..docId = 'taskDocId'
            ..name = 'Test Task'
            ..dateAdded = DateTime(2023,1,1)
            ..personDocId = 'person1'
            ..offCycle = false
            ..description = 'Test Task'
            ..startDate = DateTime(2024, 1, 1, 10, 0, 0)
            ..targetDate = DateTime(2024, 1, 2, 10, 0, 0)
            ..urgentDate = DateTime(2024, 1, 3, 10, 0, 0)
            ..dueDate = DateTime(2024, 1, 4, 10, 0, 0)
            ..recurrence = recurrence.toBuilder()
            ..recurIteration = 1
          ).build();
      final completionDate = DateTime(2024, 1, 1, 10, 0, 0); // Completed exactly at original start time

      final result = RecurrenceHelper.createNextIteration(taskToIterate, completionDate);

      // New anchorDate will be completionDate + 1 day = 2024, 1, 2, 10,0,0 (time preserved)
      // All dates shift by the difference between new anchor and old anchor (1 day)
      expect(result.startDate, DateTime(2024, 1, 2, 10, 0, 0));
      expect(result.targetDate, DateTime(2024, 1, 3, 10, 0, 0));
      expect(result.urgentDate, DateTime(2024, 1, 4, 10, 0, 0));
      expect(result.dueDate, DateTime(2024, 1, 5, 10, 0, 0));
    });

    test('should correctly create next iteration when recurWait is true (On Complete)', () {
      final anchorDate = DateTime(2024, 1, 1, 9, 0, 0); // Original anchor time
      final recurrence = (TaskRecurrenceBuilder()
        ..docId = 'recurDocId'
        ..dateAdded = DateTime(2023, 1, 1)
        ..personDocId = 'personDocId'
        ..name = 'Every 2 days on complete'
        ..recurNumber = 2
        ..recurUnit = 'Days'
        ..recurWait = true
        ..recurIteration = 1
        ..anchorDate = anchorDate
        ..anchorType = TaskDateTypes.start.label)
          .build();

      final taskToIterate = (TaskItemBuilder()
        ..docId = 'taskDocId'
        ..dateAdded = DateTime(2023,1,1)
        ..personDocId = 'person1'
        ..description = 'Test Task'
        // Dates are relative to the anchorDate
        ..startDate = DateTime(2024, 1, 5, 9, 0, 0) // anchorDate + 4 days
        ..targetDate = DateTime(2024, 1, 6, 9, 0, 0) // anchorDate + 5 days
        ..urgentDate = DateTime(2024, 1, 7, 9, 0, 0) // anchorDate + 6 days
        ..dueDate = DateTime(2024, 1, 8, 9, 0, 0) // anchorDate + 7 days
        ..recurrence = recurrence.toBuilder()
        ..recurIteration = 1)
          .build();
      final completionDate = DateTime(2024, 1, 10, 14, 30, 0);

      final result = RecurrenceHelper.createNextIteration(taskToIterate, completionDate);

      // New anchorDate will be completionDate (2024, 1, 10, 14,30,0) + 2 days,
      // but with time preserved from original anchor (9,0,0)
      // So, nextAnchorDate = 2024, 1, 12, 9,0,0.
      // Difference from old anchor (2024, 1, 1, 9,0,0) is 11 days.
      expect(result.startDate, DateTime(2024, 1, 5, 9, 0, 0).add(Duration(days: 11))); // 2024, 1, 16, 9:00:00
      expect(result.targetDate, DateTime(2024, 1, 6, 9, 0, 0).add(Duration(days: 11))); // 2024, 1, 17, 9:00:00
      expect(result.urgentDate, DateTime(2024, 1, 7, 9, 0, 0).add(Duration(days: 11))); // 2024, 1, 18, 9:00:00
      expect(result.dueDate, DateTime(2024, 1, 8, 9, 0, 0).add(Duration(days: 11))); // 2024, 1, 19, 9:00:00
    });

    test('should correctly create next iteration when recurWait is false (On Schedule)', () {
      final anchorDate = DateTime(2024, 1, 1, 9, 0, 0);
      final recurrence = (TaskRecurrenceBuilder()
        ..docId = 'recurDocId'
        ..dateAdded = DateTime(2023, 1, 1)
        ..personDocId = 'personDocId'
        ..name = 'Every 3 days on schedule'
        ..recurNumber = 3
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..anchorDate = anchorDate
        ..anchorType = TaskDateTypes.start.label)
          .build();

      final taskToIterate = (TaskItemBuilder()
        ..docId = 'taskDocId'
        ..dateAdded = DateTime(2023,1,1)
        ..personDocId = 'person1'
        ..description = 'Test Task'
        // Dates are relative to the anchorDate
        ..startDate = DateTime(2024, 1, 2, 9, 0, 0) // anchorDate + 1 day
        ..targetDate = DateTime(2024, 1, 3, 9, 0, 0) // anchorDate + 2 days
        ..urgentDate = DateTime(2024, 1, 4, 9, 0, 0) // anchorDate + 3 days
        ..dueDate = DateTime(2024, 1, 5, 9, 0, 0) // anchorDate + 4 days
        ..recurrence = recurrence.toBuilder()
        ..recurIteration = 1)
          .build();
      // Completion date doesn\'t affect the next schedule when recurWait is false
      final completionDate = DateTime(2024, 1, 10, 14, 30, 0);

      final result = RecurrenceHelper.createNextIteration(taskToIterate, completionDate);

      // New anchorDate will be old anchorDate (2024, 1, 1, 9,0,0) + 3 days.
      // So, nextAnchorDate = 2024, 1, 4, 9,0,0.
      // Difference from old anchor (2024, 1, 1, 9,0,0) is 3 days.
      expect(result.startDate, DateTime(2024, 1, 2, 9, 0, 0).add(Duration(days: 3))); // 2024, 1, 5, 9:00:00
      expect(result.targetDate, DateTime(2024, 1, 3, 9, 0, 0).add(Duration(days: 3))); // 2024, 1, 6, 9:00:00
      expect(result.urgentDate, DateTime(2024, 1, 4, 9, 0, 0).add(Duration(days: 3))); // 2024, 1, 7, 9:00:00
      expect(result.dueDate, DateTime(2024, 1, 5, 9, 0, 0).add(Duration(days: 3))); // 2024, 1, 8, 9:00:00
    });

    test('should throw an exception if recurrence is null on TaskItem', () {
      final taskToIterate = (TaskItemBuilder()
        ..docId = 'taskDocId'
        ..dateAdded = DateTime(2023,1,1)
        ..personDocId = 'person1'
        ..description = 'Test Task (no recurrence)'
        ..startDate = DateTime(2024, 1, 1)
        // No recurrence or recurIteration
      ).build();
      final completionDate = DateTime.now();

      expect(() => RecurrenceHelper.createNextIteration(taskToIterate, completionDate),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('No recurrence on task item!'))));
    });

    test('should throw an exception if recurIteration is null on TaskItem but recurrence is not', () {
      final recurrence = (TaskRecurrenceBuilder() // Valid recurrence
        ..docId = 'recurDocId'
        ..dateAdded = DateTime(2023, 1, 1)
        ..personDocId = 'personDocId'
        ..name = 'Daily'
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = true
        ..recurIteration = 1 // Valid iteration on recurrence
        ..anchorDate = DateTime(2024, 1, 1)
        ..anchorType = TaskDateTypes.start.label)
          .build();

      final taskToIterate = (TaskItemBuilder()
        ..docId = 'taskDocId'
        ..dateAdded = DateTime(2023,1,1)
        ..personDocId = 'person1'
        ..description = 'Test Task'
        ..startDate = DateTime(2024, 1, 1)
        ..recurrence = recurrence.toBuilder() // Has recurrence
        // recurIteration is explicitly not set on TaskItem, so it will be null
      ).build();
      final completionDate = DateTime.now();

      expect(() => RecurrenceHelper.createNextIteration(taskToIterate, completionDate),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Recurrence has a value, so recur_iteration should be non-null!'))));
    });
  });

}