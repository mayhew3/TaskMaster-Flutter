import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:flutter/foundation.dart';
import 'package:taskmaster/models/task_item.dart';


bool hasPassed(DateTime dateTime) {
  var now = DateTime.now();
  return dateTime == null ? false : dateTime.isBefore(now);
}

String nullifyEmptyString(String inputString) {
  return inputString.isEmpty ? null : inputString.trim();
}

DateTime nullSafeParseJSON(dynamic jsonVal) {
  if (jsonVal == null) {
    return null;
  } else {
    return DateTime.parse(jsonVal).toLocal();
  }
}

class TaskEntity {
  final int id;
  final int personId;

  final String name;
  final String description;
  final String project;
  final String context;

  final int urgency;
  final int priority;
  final int duration;

  final DateTime dateAdded;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime dueDate;
  final DateTime completionDate;
  final DateTime urgentDate;

  final int gamePoints;

  final int recurNumber;
  final String recurUnit;
  final bool recurWait;

  TaskEntity({
    this.id,
    this.personId,
    this.name,
    this.description,
    this.project,
    this.context,
    this.urgency,
    this.priority,
    this.duration,
    this.dateAdded,
    this.startDate,
    this.targetDate,
    this.dueDate,
    this.completionDate,
    this.urgentDate,
    this.gamePoints,
    this.recurNumber,
    this.recurUnit,
    this.recurWait
  });

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  String toString() {
    return 'TaskEntity{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'completionDate: $completionDate}';
  }

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'],
      personId: json['person_id'],
      name: json['name'],
      description: json['description'],
      project: json['project'],
      context: json['context'],
      urgency: json['urgency'],
      priority: json['priority'],
      duration: json['duration'],
      startDate: nullSafeParseJSON(json['start_date']),
      targetDate: nullSafeParseJSON(json['target_date']),
      dueDate: nullSafeParseJSON(json['due_date']),
      completionDate: nullSafeParseJSON(json['completion_date']),
      urgentDate: nullSafeParseJSON(json['urgent_date']),
      gamePoints: json['game_points'],
      recurNumber: json['recur_number'],
      recurUnit: json['recur_unit'],
      recurWait: json['recur_wait'],
      dateAdded: nullSafeParseJSON(json['date_added']),
    );
  }
}