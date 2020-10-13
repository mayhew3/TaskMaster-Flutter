
import 'package:flutter/material.dart';

class TaskDateTypes {
  static final TaskDateType start = TaskDateType(label: 'Start', textColor: Color.fromRGBO(235, 235, 235, 1.0));
  static final TaskDateType target = TaskDateType(label: 'Target', textColor: Color.fromRGBO(235, 235, 167, 1.0));
  static final TaskDateType urgent = TaskDateType(label: 'Urgent', textColor: Color.fromRGBO(235, 200, 167, 1.0));
  static final TaskDateType due = TaskDateType(label: 'Due', textColor: Color.fromRGBO(235, 167, 167, 1.0));

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

  TaskDateType({
    @required this.label,
    @required this.textColor,
  });
}