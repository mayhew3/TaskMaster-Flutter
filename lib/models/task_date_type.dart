
import 'package:flutter/material.dart';

class TaskDateTypes {
  static final TaskDateType start = TaskDateType(label: 'Start');
  static final TaskDateType target = TaskDateType(label: 'Target');
  static final TaskDateType urgent = TaskDateType(label: 'Urgent');
  static final TaskDateType due = TaskDateType(label: 'Due');

  static final List<TaskDateType> allTypes = [
    start, target, urgent, due
  ];

  static TaskDateType getTypeWithLabel(String label) {
    return allTypes.singleWhere((dateType) => dateType.label == label, orElse: null);
  }
}

class TaskDateType {
  String label;

  TaskDateType({@required this.label});
}