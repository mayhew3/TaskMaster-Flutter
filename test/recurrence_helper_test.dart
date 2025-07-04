
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data_builder.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
void main() {

  int daysBetween(DateTime earlierDate, DateTime laterDate) {
    return DateUtil.withoutMillis(laterDate).difference(DateUtil.withoutMillis(earlierDate)).inDays;
  }

  int daysFromNow(DateTime date) {
    var now = DateTime.now();
    return daysBetween(now, date);
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

      expect(daysFromNow(newDue), 13,
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

      expect(daysFromNow(newStart), 4,
          reason: 'Expect Start date to be 4 days from now.');
    });

  });


  group('updateTaskAndMaybeRecurrenceForSnooze', () {

    test('updateTaskAndMaybeRecurrenceForSnooze with no recurrence', () {
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

      RecurrenceHelper.updateTaskAndMaybeRecurrenceForSnooze(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, resultingBlueprint));
    });

    test('updateTaskAndMaybeRecurrenceForSnooze with On Complete recurrence', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates()
          .withRecur(recurWait: true) // Mimics "On Complete"
          .create();
      var originalAnchorDate = taskItem.recurrence!.anchorDate;
      var blueprint = taskItem.createBlueprint();
      blueprint.incrementDateIfExists(TaskDateTypes.due, Duration(days: 3));

      var action = ExecuteSnooze(
          taskItem: taskItem,
          blueprint: blueprint,
          numUnits: 3,
          unitSize: 'Days',
          dateType: TaskDateTypes.due
      );

      TaskItem? resultTask;
      TaskItemBlueprint? resultingBlueprint;

      when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any))
          .thenAnswer((invocation) {
        resultingBlueprint = invocation.positionalArguments[1];
        resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
        return Future.value((taskItem: resultTask!, recurrence: null));
      });

      RecurrenceHelper.updateTaskAndMaybeRecurrenceForSnooze(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, resultingBlueprint));
      expect(resultingBlueprint!.recurrenceBlueprint!.anchorDate, originalAnchorDate);
    });

    test('updateTaskAndMaybeRecurrenceForSnooze with On Schedule recurrence, on cycle', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates()
          .withRecur(recurWait: false) // Mimics "On Schedule"
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

      RecurrenceHelper.updateTaskAndMaybeRecurrenceForSnooze(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(
          taskItem.docId, resultingBlueprint));
      expect(resultingBlueprint!.recurrenceBlueprint!.anchorDate, isNot(originalAnchorDate));
    });

    test('updateTaskAndMaybeRecurrenceForSnooze with On Schedule recurrence, off cycle', () {
      var mockTaskRepository = MockTaskRepository();

      var taskItem = MockTaskItemBuilder
          .withDates()
          .withRecur(recurWait: false) // Mimics "On Schedule"
          .create();
      var originalAnchorDate = taskItem.recurrence!.anchorDate;
      var blueprint = taskItem.createBlueprint();
      blueprint.offCycle = true; // Snooze should knock task off cycle
      blueprint.incrementDateIfExists(TaskDateTypes.due, Duration(days: 3));

      var action = ExecuteSnooze(
          taskItem: taskItem,
          blueprint: blueprint,
          numUnits: 3,
          unitSize: 'Days',
          dateType: TaskDateTypes.due
      );

      TaskItem? resultTask;
      TaskItemBlueprint? resultingBlueprint;

      when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any))
          .thenAnswer((invocation) {
        resultingBlueprint = invocation.positionalArguments[1];
        resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
        return Future.value((taskItem: resultTask!, recurrence: null));
      });

      RecurrenceHelper.updateTaskAndMaybeRecurrenceForSnooze(mockTaskRepository, action);

      expect(resultingBlueprint, blueprint);
      verify(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, resultingBlueprint));
      expect(resultingBlueprint!.recurrenceBlueprint!.anchorDate, originalAnchorDate);
    });

  });


  group('createNextIteration', () {

    test('on complete increments dates', () {
      var taskItem = MockTaskItemBuilder
          .withDates(offCycle: false)
          .withRecur(recurWait: true) // Mimics "On Complete"
          .create();
      final completionDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 5));
      // save off diffs between due date and the other dates, assert they remain consistent on the new iteration

      final result = RecurrenceHelper.createNextIteration(taskItem, completionDate);

      expect(daysBetween(completionDate, result.dueDate!), 42);
    });

    test('on scheduled dates increments dates', () {
      var taskItem = MockTaskItemBuilder
          .withDates(offCycle: false)
          .withRecur(recurWait: false) // Mimics "On Schedule"
          .create();
      final completionDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 5));
      final originalRecurrenceAnchorDate = taskItem.recurrence!.anchorDate.dateValue;
      final originalRecurIteration = taskItem.recurrence!.recurIteration;

      final result = RecurrenceHelper.createNextIteration(taskItem, completionDate);

      expect(daysBetween(taskItem.dueDate!, result.dueDate!), 42);
      expect(daysBetween(originalRecurrenceAnchorDate, result.recurrence!.anchorDate!.dateValue), 42);
      expect(result.recurrence!.recurIteration, originalRecurIteration + 1);
    });

    test('on scheduled dates (off cycle) increments dates', () {
      var taskItem = MockTaskItemBuilder
          .withDates(offCycle: true)
          .withRecur(recurWait: false) // Mimics "On Schedule"
          .create();
      final completionDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 5));
      final originalRecurrenceAnchorDate = taskItem.recurrence!.anchorDate.dateValue;
      final originalRecurIteration = taskItem.recurrence!.recurIteration;

      final result = RecurrenceHelper.createNextIteration(taskItem, completionDate);

      expect(daysBetween(taskItem.dueDate!, result.dueDate!), 37);
      expect(daysBetween(originalRecurrenceAnchorDate, result.recurrence!.anchorDate!.dateValue), 42);
      expect(result.recurrence!.recurIteration, originalRecurIteration + 1);
    });

    test('on scheduled dates (off cycle) increments dates (urgent anchor)', () {
      var taskItem = MockTaskItemBuilder
          .asDefault()
          .withUrgentDateAnchor(offCycle: true)
          .withRecur(recurWait: false) // Mimics "On Schedule"
          .create();
      final completionDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 5));
      final originalRecurrenceAnchorDate = taskItem.recurrence!.anchorDate.dateValue;
      final originalRecurIteration = taskItem.recurrence!.recurIteration;

      final result = RecurrenceHelper.createNextIteration(taskItem, completionDate);

      expect(result.dueDate, isNull);
      expect(daysBetween(taskItem.urgentDate!, result.urgentDate!), 37);
      expect(daysBetween(originalRecurrenceAnchorDate, result.recurrence!.anchorDate!.dateValue), 42);
      expect(result.recurrence!.recurIteration, originalRecurIteration + 1);
    });

    // test different anchor dates
    // test calling this method on a task item with no recurrence
    // test exception for no recur_iteration
    // test calling this method on a recur preview
    // test snoozing to offCycle, removing due date, then creating
  });


  group('incrementWithMatchingDateIntervals', () {

    test('should increment dates with due date as anchor', () {
      final builder = MockTaskItemBuilder.withDates();
      // No need to nullify other dates; dueDate from withDates() is the default anchor if present.
      final taskItem = builder.create();

      final originalAnchorDate = taskItem.dueDate!;
      final newAnchorDate = originalAnchorDate.add(Duration(days: 7));

      final result = RecurrenceHelper.incrementWithMatchingDateIntervals(
          taskItem, originalAnchorDate, newAnchorDate);

      expect(result[TaskDateTypes.start]!.difference(newAnchorDate),
          taskItem.startDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.target]!.difference(newAnchorDate),
          taskItem.targetDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.urgent]!.difference(newAnchorDate),
          taskItem.urgentDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.due], newAnchorDate);
      expect(result[TaskDateTypes.completed], isNull); // completionDate is null from withDates()
    });

    test('should increment dates with urgent date as anchor', () {
      final builder = MockTaskItemBuilder
          .withDates();
      builder.dueDate = null; // Due date is null
      final taskItem = builder.create();

      final originalAnchorDate = taskItem.urgentDate!;
      final newAnchorDate = originalAnchorDate.add(Duration(days: 7));

      final result = RecurrenceHelper.incrementWithMatchingDateIntervals(
          taskItem, originalAnchorDate, newAnchorDate);

      expect(result[TaskDateTypes.start]!.difference(newAnchorDate),
          taskItem.startDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.target]!.difference(newAnchorDate),
          taskItem.targetDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.urgent], newAnchorDate);
      expect(result[TaskDateTypes.due], isNull);
      expect(result[TaskDateTypes.completed], isNull);
    });

    test('should increment dates with target date as anchor', () {
      final builder = MockTaskItemBuilder.withDates();
      builder.dueDate = null;    // Ensure targetDate is the anchor
      builder.urgentDate = null;
      final taskItem = builder.create();

      final originalAnchorDate = taskItem.targetDate!;
      final newAnchorDate = originalAnchorDate.add(Duration(days: 7));

      final result = RecurrenceHelper.incrementWithMatchingDateIntervals(
          taskItem, originalAnchorDate, newAnchorDate);

      expect(result[TaskDateTypes.start]!.difference(newAnchorDate),
          taskItem.startDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.target], newAnchorDate);
      expect(result[TaskDateTypes.urgent], isNull); // Was explicitly nulled
      expect(result[TaskDateTypes.due], isNull);    // Was explicitly nulled
      expect(result[TaskDateTypes.completed], isNull);
    });

    test('should increment dates with start date as anchor', () {
      final builder = MockTaskItemBuilder.withDates();
      builder.dueDate = null;    // Ensure startDate is the anchor
      builder.urgentDate = null;
      builder.targetDate = null;
      final taskItem = builder.create();

      final originalAnchorDate = taskItem.startDate!;
      final newAnchorDate = originalAnchorDate.add(Duration(days: 7));

      final result = RecurrenceHelper.incrementWithMatchingDateIntervals(
          taskItem, originalAnchorDate, newAnchorDate);

      expect(result[TaskDateTypes.start], newAnchorDate);
      expect(result[TaskDateTypes.target], isNull); // Was explicitly nulled
      expect(result[TaskDateTypes.urgent], isNull); // Was explicitly nulled
      expect(result[TaskDateTypes.due], isNull);    // Was explicitly nulled
      expect(result[TaskDateTypes.completed], isNull);
    });

    test('should handle null non-anchor dates gracefully', () {
      final builder = MockTaskItemBuilder.withDates();
      builder.startDate = null; // Make startDate a null non-anchor date
      final taskItem = builder.create();

      final originalAnchorDate = taskItem.dueDate!;
      final newAnchorDate = originalAnchorDate.add(Duration(days: 7));

      final result = RecurrenceHelper.incrementWithMatchingDateIntervals(
          taskItem, originalAnchorDate, newAnchorDate);

      expect(result[TaskDateTypes.start], isNull); // Was explicitly nulled

      expect(result[TaskDateTypes.target]!.difference(newAnchorDate),
          taskItem.targetDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.urgent]!.difference(newAnchorDate),
          taskItem.urgentDate!.difference(originalAnchorDate));
      expect(result[TaskDateTypes.due], newAnchorDate); // Anchor date
      expect(result[TaskDateTypes.completed], isNull);
    });

    test('should throw exception if task item has no anchor date', () {
      final builder = MockTaskItemBuilder.asDefault(); // Start with a blank slate
      builder.startDate = null;
      builder.targetDate = null;
      builder.urgentDate = null;
      builder.dueDate = null;
      // completionDate is already null by default with asDefault()
      final taskItem = builder.create();

      // These dates are nominal as the function should throw before using them to calculate shifts,
      // because taskItem.getAnchorDateType()! (or similar internal logic) should fail.
      final nominalOriginalAnchorDate = DateTime(2024, 1, 15, 10, 0, 0);
      final nominalNewAnchorDate = nominalOriginalAnchorDate.add(Duration(days: 7));

      expect(
              () => RecurrenceHelper.incrementWithMatchingDateIntervals(
              taskItem, nominalOriginalAnchorDate, nominalNewAnchorDate),
          throwsException);
    });

    test('should preserve time of day for all dates', () {
      final originalStartDate = DateTime(2024, 2, 1, 9, 15, 0);    // 9:15:00
      final originalTargetDate = DateTime(2024, 2, 2, 12, 0, 30);  // 12:00:30
      final originalUrgentDate = DateTime(2024, 2, 2, 10, 45, 15); // 10:45:15
      final originalAnchorDate = DateTime(2024, 2, 3, 15, 30, 45); // Due Date, 15:30:45
      final newAnchorDate = DateTime(2024, 2, 10, 15, 30, 45);   // 7 days later, same time for anchor

      final builder = MockTaskItemBuilder.asDefault();
      builder.startDate = originalStartDate;
      builder.targetDate = originalTargetDate;
      builder.urgentDate = originalUrgentDate;
      builder.dueDate = originalAnchorDate;
      builder.completionDate = null;
      final taskItem = builder.create();

      final result = RecurrenceHelper.incrementWithMatchingDateIntervals(
          taskItem, originalAnchorDate, newAnchorDate);

      expect(result[TaskDateTypes.start], DateTime(2024, 2, 8, 9, 15, 0));
      expect(result[TaskDateTypes.target], DateTime(2024, 2, 9, 12, 0, 30));
      expect(result[TaskDateTypes.urgent], DateTime(2024, 2, 9, 10, 45, 15));
      expect(result[TaskDateTypes.due], newAnchorDate);
      expect(result[TaskDateTypes.completed], isNull);
    });

  });

  
  group('addToDate', () {
    
    test('should add duration to a non-null date', () {
      final date = DateTime(2024, 1, 1, 10, 0, 0);
      final duration = Duration(days: 5, hours: 2);
      final expectedDate = DateTime(2024, 1, 6, 12, 0, 0);
      expect(RecurrenceHelper.addToDate(date, duration), expectedDate);
    });

    test('should return same date when adding zero duration to a non-null date', () {
      final date = DateTime(2024, 1, 1, 10, 0, 0);
      final duration = Duration.zero;
      expect(RecurrenceHelper.addToDate(date, duration), date);
    });

    test('should return null when adding duration to a null date', () {
      final DateTime? date = null;
      final duration = Duration(days: 5, hours: 2);
      expect(RecurrenceHelper.addToDate(date, duration), isNull);
    });

    test('should return null when adding zero duration to a null date', () {
      final DateTime? date = null;
      final duration = Duration.zero;
      expect(RecurrenceHelper.addToDate(date, duration), isNull);
    });
    
  });

  
  group('getAdjustedDate', () {
    final baseDate = DateTime(2024, 1, 15, 14, 30, 0); // January 15, 2024, 2:30 PM

    // Test adding units
    test('should add days to date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 5, 'Days'), DateTime(2024, 1, 20, 14, 30, 0));
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 1, 'Days'), DateTime(2024, 1, 16, 14, 30, 0));
    });

    test('should add weeks to date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 2, 'Weeks'), DateTime(2024, 1, 29, 14, 30, 0));
       expect(RecurrenceHelper.getAdjustedDate(baseDate, 1, 'Weeks'), DateTime(2024, 1, 22, 14, 30, 0));
    });

    test('should add months to date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 1, 'Months'), DateTime(2024, 2, 15, 14, 30, 0));
      // Handles month overflow
      final endOfMonth = DateTime(2024, 1, 31, 0, 0, 0); // Ensure time is 00:00:00 for direct comparison
      expect(RecurrenceHelper.getAdjustedDate(endOfMonth, 1, 'Months'), DateTime(2024, 2, 29, 0, 0, 0)); 
    });

    test('should add years to date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 3, 'Years'), DateTime(2027, 1, 15, 14, 30, 0));
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 1, 'Years'), DateTime(2025, 1, 15, 14, 30, 0));
    });

    // Test subtracting units (negative numUnits)
    test('should subtract days from date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, -5, 'Days'), DateTime(2024, 1, 10, 14, 30, 0));
    });

    test('should subtract weeks from date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, -2, 'Weeks'), DateTime(2024, 1, 1, 14, 30, 0));
    });

    test('should subtract months from date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, -1, 'Months'), DateTime(2023, 12, 15, 14, 30, 0));
    });

    test('should subtract years from date', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, -3, 'Years'), DateTime(2021, 1, 15, 14, 30, 0));
    });

    // Test zero units
    test('should return same date when numUnits is zero', () {
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 0, 'Days'), baseDate);
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 0, 'Weeks'), baseDate);
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 0, 'Months'), baseDate);
      expect(RecurrenceHelper.getAdjustedDate(baseDate, 0, 'Years'), baseDate);
    });

    // Test invalid unit
    test('should throw argument error for invalid unit', () {
       expect(() => RecurrenceHelper.getAdjustedDate(baseDate, 1, 'Fortnights'), throwsArgumentError);
    });
  });

  
  group('applyTimeToDate', () {
    final dateOnly = DateTime(2024, 5, 15).toUtc(); // May 15, 2024, 00:00:00
    final dateWithTime = DateTime(2024, 5, 15, 10, 30, 45, 123).toUtc();
    final timeHolder = DateTime(2000, 8, 1, 16, 45, 50, 567).toUtc(); // Different date, specific time
    final combinationDate = DateTime(2024, 5, 15, 16, 45, 50, 567).toUtc();

    test('should apply time from timeHolder to date', () {
      final result = RecurrenceHelper.applyTimeToDate(timeHolder, dateOnly);
      expect(result, combinationDate);

      final result2 = RecurrenceHelper.applyTimeToDate(timeHolder, dateWithTime);
      expect(result2, combinationDate);
    });

  });

}
