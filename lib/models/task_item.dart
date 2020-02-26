import 'package:taskmaster/models/task_entity.dart';

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

class TaskItem {
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

  TaskItem({
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

  bool isCompleted() {
    return completionDate != null;
  }

  bool isScheduled() {
    return startDate != null && !hasPassed(startDate);
  }

  bool isPastDue() {
    return hasPassed(dueDate);
  }

  bool isUrgent() {
    return hasPassed(urgentDate);
  }

  DateTime getAnchorDate() {
    if (dueDate != null) {
      return dueDate;
    } else if (urgentDate != null) {
      return urgentDate;
    } else if (targetDate != null) {
      return targetDate;
    } else if (startDate != null) {
      return startDate;
    } else {
      return null;
    }
  }

  String getAnchorDateFieldName() {
    if (dueDate != null) {
      return "Due";
    } else if (urgentDate != null) {
      return "Urgent";
    } else if (targetDate != null) {
      return "Target";
    } else if (startDate != null) {
      return "Start";
    } else {
      return null;
    }
  }
  
  DateTime getDateFromName(String anchorDateFieldName) {
    switch (anchorDateFieldName) {
      case "Due": return dueDate;
      case "Urgent": return urgentDate;
      case "Target": return targetDate;
      case "Start": return startDate;
      default: return null;
    }
  }

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  TaskEntity toEntity() {
    return TaskEntity(
        id: id,
        personId: personId,
        name: name,
        description: description,
        project: project,
        context: context,
        urgency: urgency,
        priority: priority,
        duration: duration,
        dateAdded: dateAdded,
        startDate: startDate,
        targetDate: targetDate,
        dueDate: dueDate,
        completionDate: completionDate,
        urgentDate: urgentDate,
        gamePoints: gamePoints,
        recurNumber: recurNumber,
        recurUnit: recurUnit,
        recurWait: recurWait
    );
  }

  static TaskItem fromEntity(TaskEntity entity) {
    return TaskItem(
        id: entity.id,
        personId: entity.personId,
        name: entity.name,
        description: entity.description,
        project: entity.project,
        context: entity.context,
        urgency: entity.urgency,
        priority: entity.priority,
        duration: entity.duration,
        dateAdded: entity.dateAdded,
        startDate: entity.startDate,
        targetDate: entity.targetDate,
        dueDate: entity.dueDate,
        completionDate: entity.completionDate,
        urgentDate: entity.urgentDate,
        gamePoints: entity.gamePoints,
        recurNumber: entity.recurNumber,
        recurUnit: entity.recurUnit,
        recurWait: entity.recurWait
    );
  }

  @override
  String toString() {
    return 'TaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'completionDate: $completionDate}';
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      personId: json['person_id'],
      name: nullifyEmptyString(json['name']),
      description: nullifyEmptyString(json['description']),
      project: nullifyEmptyString(json['project']),
      context: nullifyEmptyString(json['context']),
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
      dateAdded: DateTime.parse(json['date_added']),
    );
  }

}
