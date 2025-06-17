import 'package:meta/meta.dart'; // Make sure this import is present
import 'package:jiffy/jiffy.dart';
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

      DateTime? anchorDate = recurrence.anchorDate;
      DateTime nextAnchorDate;

      if (recurWait) {
        nextAnchorDate = getAdjustedDate(completionDate, recurNumber, recurUnit);
      } else {
        nextAnchorDate = getAdjustedDate(anchorDate, recurNumber, recurUnit);
      }

      DateTime dateWithTime = getClosestDateForTime(anchorDate, nextAnchorDate);
      Duration duration = dateWithTime.difference(anchorDate);

      TaskItemRecurPreview nextScheduledTask = taskItem.createNextRecurPreview(
        startDate: addToDate(taskItem.startDate, duration),
        targetDate: addToDate(taskItem.targetDate, duration),
        urgentDate: addToDate(taskItem.urgentDate, duration),
        dueDate: addToDate(taskItem.dueDate, duration),
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

  static Future<TaskItem> updateTaskAndMaybeRecurrence(TaskRepository repository, ExecuteSnooze action) async {

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
    return DateUtil.adjustToDate(dateTime, recurNumber, recurUnit);
  }

  @visibleForTesting
  static DateTime applyTimeToDate(DateTime dateWithTime, DateTime targetDate) {
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

  @visibleForTesting
  static DateTime getClosestDateForTime(DateTime dateWithTime, DateTime targetDate) {
    DateTime prev = applyTimeToDate(dateWithTime, Jiffy.parseFromDateTime(targetDate).subtract(days:1).dateTime);
    DateTime current = applyTimeToDate(dateWithTime, targetDate);
    DateTime next = applyTimeToDate(dateWithTime, Jiffy.parseFromDateTime(targetDate).add(days:1).dateTime);

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
