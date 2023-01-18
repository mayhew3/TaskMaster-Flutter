
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_item_edit.dart';
import 'package:taskmaster/typedefs.dart';

class TaskDateTypes {
  static final TaskDateType start = TaskDateType(
    label: 'Start',
    textColor: Color.fromRGBO(235, 235, 235, 0.8),
    dateFieldGetter: (taskItem) => taskItem.startDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.startDate = newDate,
    listThresholdInDays: -1,
  );

  static final TaskDateType target = TaskDateType(
    label: 'Target',
    textColor: Color.fromRGBO(235, 235, 167, 1.0),
    dateFieldGetter: (taskItem) => taskItem.targetDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.targetDate = newDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType urgent = TaskDateType(
    label: 'Urgent',
    textColor: Color.fromRGBO(235, 200, 167, 1.0),
    dateFieldGetter: (taskItem) => taskItem.urgentDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.urgentDate = newDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType due = TaskDateType(
    label: 'Due',
    textColor: Color.fromRGBO(235, 167, 167, 1.0),
    dateFieldGetter: (taskItem) => taskItem.dueDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.dueDate = newDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType completed = TaskDateType(
    label: 'Completed',
    textColor: Color.fromRGBO(235, 167, 235, 1.0),
    dateFieldGetter: (taskItem) => taskItem.completionDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.completionDate = newDate,
    listThresholdInDays: -1,
  );

  static final List<TaskDateType> allTypes = [
    start, target, urgent, due
  ];

  static TaskDateType? getTypePreceding(TaskDateType taskDateType) {
    int index = allTypes.indexOf(taskDateType);
    if (index < 1) {
      return null;
    } else {
      return allTypes[index - 1];
    }
  }

  static TaskDateType? getTypeWithLabel(String? label) {
    return allTypes.singleWhere((dateType) => dateType.label == label, orElse: null);
  }
}

class TaskDateType {
  final String label;
  final Color textColor;
  final DateFieldGetter dateFieldGetter;
  final DateFieldSetter dateFieldSetter;
  final int listThresholdInDays;

  TaskDateType({
    required this.label,
    required this.textColor,
    required this.dateFieldGetter,
    required this.dateFieldSetter,
    required this.listThresholdInDays,
  });

  bool inListBeforeDisplayThreshold(TaskItemEdit taskItem) {
    DateTime? dateFieldValue = this.dateFieldGetter(taskItem);
    if (dateFieldValue == null ||
        dateFieldValue.isBefore(DateTime.now())) {
      return false;
    }

    if (listThresholdInDays < 0) {
      return true;
    } else {
      DateTime inXDays = DateTime.now().add(Duration(days: this.listThresholdInDays));
      return dateFieldValue.isBefore(inXDays);
    }
  }

  bool inListAfterDisplayThreshold(TaskItemEdit taskItem) {
    DateTime? dateFieldValue = this.dateFieldGetter(taskItem);
    if (dateFieldValue == null ||
        dateFieldValue.isAfter(DateTime.now())) {
      return false;
    }

    return true;
  }
}