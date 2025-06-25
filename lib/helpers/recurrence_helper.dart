import 'package:meta/meta.dart'; // Make sure this import is present
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
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

      var recurNumber = recurrence.recurNumber;
      var recurUnit = recurrence.recurUnit;
      var recurWait = recurrence.recurWait;

      DateTime? anchorDate = recurrence.anchorDate.dateValue;
      DateTime nextAnchorDate;

      if (recurWait) {
        nextAnchorDate = getAdjustedDate(completionDate, recurNumber, recurUnit);
      } else {
        nextAnchorDate = getAdjustedDate(anchorDate, recurNumber, recurUnit);
      }

      TaskItemRecurPreview nextScheduledTask = taskItem.createNextRecurPreview(
        dates: incrementWithMatchingDateIntervals(taskItem, anchorDate, nextAnchorDate),
      );

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

  static Future<TaskItem> updateTaskAndMaybeRecurrenceForSnooze(TaskRepository repository, ExecuteSnooze action) async {

    var recurrence = action.blueprint.recurrenceBlueprint;
    if (recurrence != null) {
      var recurWait = recurrence.recurWait;
      var offCycle = action.blueprint.offCycle;
      if (recurWait != null && recurWait && !offCycle) {
        recurrence.anchorDate = action.blueprint.getAnchorDate();
      }
    }

    return (await repository.updateTaskAndRecurrence(action.taskItem.docId, action.blueprint)).taskItem;

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
  /*
  @visibleForTesting
  static DateTime getLastExpectedAnchorDate(SprintDisplayTask taskItem, int recurNumber, String recurUnit) {

  }
  */
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
    var taskAnchorDate = originalDateSet[taskDateType];
    if (taskAnchorDate == null) {
      throw new Exception('Expected supplied date set to include date with taskDateType');
    }
    for (var dateType in TaskDateTypes.allTypes) {
      var dateValue = originalDateSet[dateType];
      if (dateValue != null) {
        var difference = dateValue.difference(taskAnchorDate);
        var newDateValue = newAnchorDate.add(difference);
        resultSet[dateType] = newDateValue;
      }
    }
    return resultSet;
  }

}
