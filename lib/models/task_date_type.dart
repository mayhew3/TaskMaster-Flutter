
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/typedefs.dart';

class TaskDateTypes {
  static final TaskDateType start = TaskDateType(
    label: 'Start',
    textColor: TaskColors.startText,
    dateFieldGetter: (taskItem) => taskItem.startDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.startDate = newDate,
    listThresholdInDays: -1,
  );

  static final TaskDateType target = TaskDateType(
    label: 'Target',
    textColor: TaskColors.targetText,
    dateFieldGetter: (taskItem) => taskItem.targetDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.targetDate = newDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType urgent = TaskDateType(
    label: 'Urgent',
    textColor: TaskColors.urgentText,
    dateFieldGetter: (taskItem) => taskItem.urgentDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.urgentDate = newDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType due = TaskDateType(
    label: 'Due',
    textColor: TaskColors.dueText,
    dateFieldGetter: (taskItem) => taskItem.dueDate,
    dateFieldSetter: (taskItem, newDate) => taskItem.dueDate = newDate,
    listThresholdInDays: 10,
  );

  static final TaskDateType completed = TaskDateType(
    label: 'Completed',
    textColor: TaskColors.completedText,
    dateFieldGetter: (taskItem) => taskItem is TaskItem ? taskItem.completionDate : null,
    dateFieldSetter: (taskItem, newDate) => taskItem is TaskItem ? taskItem.completionDate = newDate : {},
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

  static List<TaskDateType> getTypesPreceding(TaskDateType taskDateType) {
    int index = allTypes.indexOf(taskDateType);
    return allTypes.sublist(0, index);
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

  bool inListBeforeDisplayThreshold(DateHolder dateHolder) {
    DateTime? dateFieldValue = this.dateFieldGetter(dateHolder);
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

  bool inListAfterDisplayThreshold(DateHolder dateHolder) {
    DateTime? dateFieldValue = this.dateFieldGetter(dateHolder);
    if (dateFieldValue == null ||
        dateFieldValue.isAfter(DateTime.now())) {
      return false;
    }

    return true;
  }
}