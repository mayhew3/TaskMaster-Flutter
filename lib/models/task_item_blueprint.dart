import 'dart:math';

import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_date_type.dart';

class TaskItemBlueprint with DateHolder {

  String? name;
  String? description;
  String? project;
  String? context;

  int? urgency;
  int? priority;
  int? duration;

  int? gamePoints;

  DateTime? startDate;
  DateTime? targetDate;
  DateTime? dueDate;
  DateTime? urgentDate;
  DateTime? completionDate;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurrenceId;
  int? recurIteration;

  late int tmpId;

  TaskItemBlueprint() {
    tmpId = new Random().nextInt(60000);
  }

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var dateTime = taskDateType.dateFieldGetter(this);
    taskDateType.dateFieldSetter(this, dateTime?.add(duration));
  }

  @override
  String toString() {
    return 'TaskItemBlueprint{'
        'name: $name';
  }

}