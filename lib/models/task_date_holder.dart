import 'package:taskmaster/models/task_date_type.dart';

import '../date_util.dart';

mixin DateHolder {

  DateTime? get startDate;
  DateTime? get targetDate;
  DateTime? get dueDate;
  DateTime? get urgentDate;
  DateTime? get completionDate;

  int? get recurIteration;

  bool hasPassed(DateTime? dateTime) {
    return dateTime != null && dateTime.isBefore(DateTime.now());
  }

  bool isFuture(DateTime? dateTime) {
    return dateTime != null && dateTime.isAfter(DateTime.now());
  }

  bool isScheduled() {
    return isFuture(startDate);
  }

  bool isPastDue() {
    return hasPassed(dueDate);
  }

  bool isDueBefore(DateTime dateTime) {
    return dueDate != null && dueDate!.isBefore(dateTime);
  }

  bool isUrgentBefore(DateTime dateTime) {
    return urgentDate != null && urgentDate!.isBefore(dateTime);
  }

  bool isTargetBefore(DateTime dateTime) {
    return targetDate != null && targetDate!.isBefore(dateTime);
  }

  bool isScheduledBefore(DateTime dateTime) {
    return startDate != null && startDate!.isBefore(dateTime);
  }

  bool isScheduledAfter(DateTime dateTime) {
    return startDate != null && startDate!.isAfter(dateTime);
  }

  bool isUrgent() {
    return hasPassed(urgentDate);
  }

  bool isTarget() {
    return hasPassed(targetDate);
  }

  bool isCompleted() {
    return completionDate != null;
  }

  DateTime? getLastDateBefore(TaskDateType taskDateType) {
    var allDates = <DateTime?>[startDate, targetDate, urgentDate, dueDate];
    Iterable<DateTime> pastDates = allDates.whereType<DateTime>().where((dateTime) => hasPassed(dateTime));

    return DateUtil.maxDate(pastDates);
  }

  DateTime? getAnchorDate() {
    return getAnchorDateType()?.dateFieldGetter(this);
  }

  TaskDateType? getAnchorDateType() {
    if (dueDate != null) {
      return TaskDateTypes.due;
    } else if (urgentDate != null) {
      return TaskDateTypes.urgent;
    } else if (targetDate != null) {
      return TaskDateTypes.target;
    } else if (startDate != null) {
      return TaskDateTypes.start;
    } else {
      return null;
    }
  }

}