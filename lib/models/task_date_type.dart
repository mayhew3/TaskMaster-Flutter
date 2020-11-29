
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/typedefs.dart';

class TaskDateTypes {
  static final TaskDateType start = TaskDateType(
    label: 'Start',
    textColor: Color.fromRGBO(235, 235, 235, 1.0),
    dateFieldGetter: (taskItem) => taskItem.startDate,
    listThresholdInDays: -1,
  );

  static final TaskDateType target = TaskDateType(
    label: 'Target',
    textColor: Color.fromRGBO(235, 235, 167, 1.0),
    dateFieldGetter: (taskItem) => taskItem.targetDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType urgent = TaskDateType(
    label: 'Urgent',
    textColor: Color.fromRGBO(235, 200, 167, 1.0),
    dateFieldGetter: (taskItem) => taskItem.urgentDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType due = TaskDateType(
    label: 'Due',
    textColor: Color.fromRGBO(235, 167, 167, 1.0),
    dateFieldGetter: (taskItem) => taskItem.dueDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType completed = TaskDateType(
    label: 'Completed',
    textColor: Color.fromRGBO(235, 167, 235, 1.0),
    dateFieldGetter: (taskItem) => taskItem.completionDate,
    listThresholdInDays: -1,
  );

  static final List<TaskDateType> allTypes = [
    start, target, urgent, due
  ];

  static TaskDateType getTypeWithLabel(String label) {
    return allTypes.singleWhere((dateType) => dateType.label == label, orElse: null);
  }
}

class TaskDateType {
  final String label;
  final Color textColor;
  final DateFieldGetter dateFieldGetter;
  final int listThresholdInDays;

  TaskDateType({
    @required this.label,
    @required this.textColor,
    @required this.dateFieldGetter,
    @required this.listThresholdInDays,
  });

  bool inListBeforeDisplayThreshold(TaskItem taskItem) {
    TaskFieldDate dateField = this.dateFieldGetter(taskItem);
    if (dateField.value == null ||
        dateField.value.isBefore(DateTime.now())) {
      return false;
    }

    if (listThresholdInDays < 0) {
      return true;
    } else {
      DateTime inXDays = DateTime.now().add(Duration(days: this.listThresholdInDays));
      return dateField.value.isBefore(inXDays);
    }
  }

  bool inListAfterDisplayThreshold(TaskItem taskItem) {
    TaskFieldDate dateField = this.dateFieldGetter(taskItem);
    if (dateField.value == null ||
        dateField.value.isAfter(DateTime.now())) {
      return false;
    }

    return true;
  }
}