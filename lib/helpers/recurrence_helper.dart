
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';

import '../date_util.dart';
import '../models/sprint_display_task.dart';
import '../models/task_date_type.dart';
import '../models/task_item_blueprint.dart';

class RecurrenceHelper {

  static TaskItemRecurPreview createNextIteration(SprintDisplayTask taskItem, DateTime completionDate) {
    var recurrence = taskItem.recurrence;

    // todo: handle offCycle

    if (recurrence != null) {
      var recurIteration = taskItem.recurIteration;

      if (recurIteration == null) {
        throw Exception(
            'Recurrence has a value, so recur_iteration should be non-null!');
      }

      var recurNumber = recurrence.recurNumber;
      var recurUnit = recurrence.recurUnit;
      var recurWait = recurrence.recurWait;

      // todo: use recurrence anchor date, not calculated from task item
      DateTime? anchorDate = taskItem.getAnchorDate();
      if (anchorDate == null) {
        throw Exception('Recur_number exists without anchor date!');
      }
      DateTime nextAnchorDate;

      if (recurWait) {
        nextAnchorDate = _getAdjustedDate(completionDate, recurNumber, recurUnit);
      } else {
        nextAnchorDate = _getAdjustedDate(anchorDate, recurNumber, recurUnit);
      }

      DateTime dateWithTime = _getClosestDateForTime(anchorDate, nextAnchorDate);
      Duration duration = dateWithTime.difference(anchorDate);

      TaskItemRecurPreview nextScheduledTask = taskItem.createNextRecurPreview(
        startDate: _addToDate(taskItem.startDate, duration),
        targetDate: _addToDate(taskItem.targetDate, duration),
        urgentDate: _addToDate(taskItem.urgentDate, duration),
        dueDate: _addToDate(taskItem.dueDate, duration),
      );

      return nextScheduledTask;
    } else {
      throw Exception('No recurrence on task item!');
    }
  }



  static void generatePreview(TaskItemBlueprint taskItemEdit, int numUnits, String unitSize, TaskDateType dateType) {
    DateTime snoozeDate = DateTime.now();

    // todo: maintain existing time

    DateTime adjustedDate = _getAdjustedDate(snoozeDate, numUnits, unitSize);

    DateTime? relevantDate = dateType.dateFieldGetter(taskItemEdit);

    if (relevantDate == null) {
      dateType.dateFieldSetter(taskItemEdit, adjustedDate);
    } else {
      Duration difference = adjustedDate.difference(relevantDate);
      for (var taskDateType in TaskDateTypes.allTypes) {
        taskItemEdit.incrementDateIfExists(taskDateType, difference);
      }
    }

  }


  // private helper methods

  static DateTime? _addToDate(DateTime? previousDate, Duration duration) {
    return previousDate?.add(duration);
  }

  static DateTime _getAdjustedDate(DateTime dateTime, int recurNumber, String recurUnit) {
    return DateUtil.adjustToDate(dateTime, recurNumber, recurUnit);
  }

  static DateTime _applyTimeToDate(DateTime dateWithTime, DateTime targetDate) {
    var jiffy = Jiffy.parseFromMap({
      Unit.year: targetDate.year,
      Unit.month: targetDate.month,
      Unit.day: targetDate.day,
      Unit.hour: dateWithTime.hour,
      Unit.minute: dateWithTime.minute,
      Unit.second: dateWithTime.second},
      isUtc: true,
    );
    return jiffy.dateTime;
  }

  static DateTime _getClosestDateForTime(DateTime dateWithTime, DateTime targetDate) {
    DateTime prev = _applyTimeToDate(dateWithTime, Jiffy.parseFromDateTime(targetDate).subtract(days:1).dateTime);
    DateTime current = _applyTimeToDate(dateWithTime, targetDate);
    DateTime next = _applyTimeToDate(dateWithTime, Jiffy.parseFromDateTime(targetDate).add(days:1).dateTime);

    var prevDiff = prev.difference(targetDate).abs();
    var currDiff = current.difference(targetDate).abs();
    var nextDiff = next.difference(targetDate).abs();

    if (prevDiff < currDiff && prevDiff < nextDiff) {
      return prev;
    } else if (currDiff < nextDiff) {
      return current;
    } else {
      return next;
    }
  }


}
