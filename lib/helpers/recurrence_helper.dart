import 'package:meta/meta.dart'; // Make sure this import is present
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/task_repository.dart';

import '../date_util.dart';
import '../models/sprint_display_task.dart';
import '../models/task_date_type.dart';
import '../models/task_item_blueprint.dart';

class RecurrenceHelper {

  static TaskItemRecurPreview createNextIteration(SprintDisplayTask taskItem, DateTime completionDate) {
    var recurrence = taskItem.recurrence;

    if (recurrence != null) {
      var recurIteration = taskItem.recurIteration;

      if (recurIteration == null) {
        throw Exception(
            'Recurrence has a value, so recur_iteration should be non-null!');
      }

      var recurNumber = recurrence.recurNumber!;
      var recurUnit = recurrence.recurUnit!;
      var recurWait = recurrence.recurWait!;

      AnchorDate anchorDate = recurrence.anchorDate!;
      DateTime nextAnchorDate;

      if (recurWait) {
        nextAnchorDate = getAdjustedDate(completionDate, recurNumber, recurUnit);
      } else {
        nextAnchorDate = getAdjustedDate(anchorDate.dateValue, recurNumber, recurUnit);
      }

      TaskItemRecurPreview nextScheduledTask = taskItem.createNextRecurPreview(
        dates: incrementWithMatchingDateIntervals(taskItem, anchorDate.dateValue, nextAnchorDate),
      );

      var recurrenceBlueprint = nextScheduledTask.recurrence!;

      var anchorDateBuilder = AnchorDateBuilder()
        ..dateValue = nextAnchorDate.toUtc()
        ..dateType = anchorDate.dateType;
      recurrenceBlueprint.anchorDate = anchorDateBuilder.build();
      recurrenceBlueprint.recurIteration = recurIteration + 1;

      return nextScheduledTask;
    } else {
      throw Exception('No recurrence on task item!');
    }
  }



  static void generatePreview(TaskItemBlueprint taskItemEdit, int numUnits, String unitSize, TaskDateType dateType) {
    DateTime snoozeDate = DateTime.now();

    DateTime adjustedDate = getAdjustedDate(snoozeDate, numUnits, unitSize);

    DateTime? relevantDate = dateType.dateFieldGetter(taskItemEdit);

    if (relevantDate == null) {
      dateType.dateFieldSetter(taskItemEdit, adjustedDate);
    } else {
      var diff = Jiffy.parseFromDateTime(adjustedDate).diff(Jiffy.parseFromDateTime(relevantDate), unit: Unit.day, asFloat: true);
      var rounded = num.parse(diff.toStringAsFixed(0)) as int;
      Duration difference = Duration(days: rounded);
      for (var taskDateType in TaskDateTypes.allTypes) {
        taskItemEdit.incrementDateIfExists(taskDateType, difference);
      }
    }

  }

  static Future<({TaskRecurrence? recurrence, TaskItem taskItem})> updateTaskAndMaybeRecurrenceForSnooze({
    required TaskRepository repository,
    required TaskItem taskItem,
    required TaskItemBlueprint blueprint,
  }) async {

    var recurrence = blueprint.recurrenceBlueprint;
    if (recurrence != null) {
      var recurWait = recurrence.recurWait;
      var offCycle = blueprint.offCycle;
      if (recurWait != null && !recurWait && !offCycle) {
        recurrence.anchorDate = blueprint.getAnchorDate();
      }
    }

    return (await repository.updateTaskAndRecurrence(taskItem.docId, blueprint));

  }


  // private helper methods

  @visibleForTesting
  static DateTime? addToDate(DateTime? previousDate, Duration duration) {
    return previousDate?.add(duration);
  }

  @visibleForTesting
  static DateTime getAdjustedDate(DateTime dateTime, int recurNumber, String recurUnit) {
    List<String> acceptableUnits = ['Days', 'Weeks', 'Months', 'Years'];
    if (!acceptableUnits.contains(recurUnit)) {
      throw new ArgumentError('Recurrence unit must be one of: $acceptableUnits');
    }
    return DateUtil.adjustToDate(dateTime, recurNumber, recurUnit);
  }

  @visibleForTesting
  static DateTime getNextDateInSequenceAfterDate(DateTime anchorDate, int recurNumber, String recurUnit, DateTime minimumDate) {
    DateTime nextDate = anchorDate;
    while (nextDate.isBefore(minimumDate)) {
      nextDate = getAdjustedDate(nextDate, recurNumber, recurUnit);
    }
    return nextDate;
  }

  @visibleForTesting
  static DateTime applyTimeToDate(DateTime dateWithTime, DateTime targetDate) {
    var jiffy = Jiffy.parseFromMap({
      Unit.year: targetDate.year,
      Unit.month: targetDate.month,
      Unit.day: targetDate.day,
      Unit.hour: dateWithTime.hour,
      Unit.minute: dateWithTime.minute,
      Unit.second: dateWithTime.second,
      Unit.millisecond: dateWithTime.millisecond,
      Unit.microsecond: dateWithTime.microsecond,
    },
      isUtc: true,
    );
    return jiffy.dateTime;
  }

  static Map<TaskDateType, DateTime> incrementWithMatchingDateIntervals(SprintDisplayTask taskItem, DateTime originalAnchorDate, DateTime newAnchorDate) {
    TaskDateType? taskDateType = taskItem.getAnchorDateType();
    if (taskDateType == null) {
      throw new Exception('Expected task to have an anchor date type');
    }

    Map<TaskDateType, DateTime> originalDateSet = new Map();
    for (var dateType in TaskDateTypes.allTypes) {
      DateTime? dateValue = dateType.dateFieldGetter(taskItem);
      if (dateValue != null) {
        originalDateSet[dateType] = dateValue;
      }
    }

    var resultSet = new Map<TaskDateType, DateTime>();

    // Determine which anchor date to use for calculating offsets:
    // - Off cycle tasks: Use task's anchor date to preserve the offset from schedule
    // - On cycle tasks: Use recurrence's anchor date for correct date increments
    var taskAnchorDate = originalDateSet[taskDateType]!;
    var baseAnchorDate = taskItem.offCycle ? taskAnchorDate : originalAnchorDate;

    for (var dateType in TaskDateTypes.allTypes) {
      var dateValue = originalDateSet[dateType];
      if (dateValue != null) {
        var difference = dateValue.difference(baseAnchorDate);
        var newDateValue = newAnchorDate.add(difference);
        resultSet[dateType] = newDateValue;
      }
    }
    return resultSet;
  }

}
