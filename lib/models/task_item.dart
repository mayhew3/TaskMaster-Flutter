
import 'package:taskmaster/models/task_field.dart';

bool hasPassed(DateTime dateTime) {
  var now = DateTime.now();
  return dateTime == null ? false : dateTime.isBefore(now);
}

String nullifyEmptyString(String inputString) {
  return inputString == null || inputString.isEmpty ? null : inputString.trim();
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

  final int recurrenceId;

  List<TaskField> fields;

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
    this.recurWait,
    this.recurrenceId,
  }) {
    fields.add(TaskFieldInteger.withValues("id", this.id));
    fields.add(TaskFieldInteger.withValues("person_id", this.personId));
    fields.add(TaskFieldString.withValues("name", this.name));
    fields.add(TaskFieldString.withValues("description", this.project));
    fields.add(TaskFieldString.withValues("project", this.project));
    fields.add(TaskFieldString.withValues("context", this.context));
    fields.add(TaskFieldInteger.withValues("urgency", this.urgency));
    fields.add(TaskFieldInteger.withValues("priority", this.priority));
    fields.add(TaskFieldInteger.withValues("duration", this.duration));
    fields.add(TaskFieldDate.withValues("date_added", this.dateAdded));
    fields.add(TaskFieldDate.withValues("start_date", this.startDate));
    fields.add(TaskFieldDate.withValues("target_date", this.targetDate));
    fields.add(TaskFieldDate.withValues("due_date", this.dueDate));
    fields.add(TaskFieldDate.withValues("completion_date", this.completionDate));
    fields.add(TaskFieldDate.withValues("urgent_date", this.urgentDate));
    fields.add(TaskFieldInteger.withValues("game_points", this.gamePoints));
    fields.add(TaskFieldInteger.withValues("recur_number", this.recurNumber));
    fields.add(TaskFieldString.withValues("recur_unit", this.recurUnit));
    fields.add(TaskFieldBoolean.withValues("recur_wait", this.recurWait));
    fields.add(TaskFieldInteger.withValues("recurrence_id", this.recurrenceId));
  }

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

  @override
  String toString() {
    return 'TaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'completionDate: $completionDate}';
  }

  TaskItem._fromJSONEntities({
    int id,
    int personId,
    String name,
    String description,
    String project,
    String context,
    int urgency,
    int priority,
    int duration,
    String dateAdded,
    String startDate,
    String targetDate,
    String dueDate,
    String completionDate,
    String urgentDate,
    int gamePoints,
    int recurNumber,
    String recurUnit,
    bool recurWait,
    int recurrenceId,
  }) : this.id = id,
        this.personId = personId,
        this.name = name,
        this.description = description,
        this.project = project,
        this.context = context,
        this.urgency = urgency,
        this.priority = priority,
        this.duration = duration,
        this.dateAdded = nullSafeParseJSON(dateAdded),
        this.startDate = nullSafeParseJSON(startDate),
        this.targetDate = nullSafeParseJSON(targetDate),
        this.dueDate = nullSafeParseJSON(dueDate),
        this.completionDate = nullSafeParseJSON(completionDate),
        this.urgentDate = nullSafeParseJSON(urgentDate),
        this.gamePoints = gamePoints,
        this.recurNumber = recurNumber,
        this.recurUnit = recurUnit,
        this.recurWait = recurWait,
        this.recurrenceId = recurrenceId
  {
    addIntegerValue("id", id);
    addIntegerValue("person_id", personId);
    addStringValue("name", name);
    addStringValue("description", description);
    addStringValue("project", project);
    addStringValue("context", context);
    addIntegerValue("urgency", urgency);
    addIntegerValue("priority", priority);
    addIntegerValue("duration", duration);
    addDateValueFromString("date_added", dateAdded);
    addDateValueFromString("start_date", startDate);
    addDateValueFromString("target_date", targetDate);
    addDateValueFromString("due_date", dueDate);
    addDateValueFromString("completion_date", completionDate);
    addDateValueFromString("urgent_date", urgentDate);
    addIntegerValue("game_points", gamePoints);
    addIntegerValue("recur_number", recurNumber);
    addStringValue("recur_unit", recurUnit);
    addBoolValue("recur_wait", recurWait);
    addIntegerValue("recurrence_id", recurrenceId);
  }

  void addStringValue(String fieldName, String value) {
    fields.add(TaskFieldString.withValues(fieldName, nullifyEmptyString(value)));
  }

  void addIntegerValue(String fieldName, int value) {
    fields.add(TaskFieldInteger.withValues(fieldName, value));
  }

  void addBoolValue(String fieldName, bool value) {
    fields.add(TaskFieldBoolean.withValues(fieldName, value));
  }

  void addDateValueFromString(String fieldName, String value) {
    var taskFieldDate = TaskFieldDate(fieldName);
    taskFieldDate.setValuefromJSON(value);
    fields.add(taskFieldDate);
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem._fromJSONEntities(
      id: json['id'],
      personId: json['person_id'],
      name: nullifyEmptyString(json['name']),
      description: nullifyEmptyString(json['description']),
      project: nullifyEmptyString(json['project']),
      context: nullifyEmptyString(json['context']),
      urgency: json['urgency'],
      priority: json['priority'],
      duration: json['duration'],
      startDate: json['start_date'],
      targetDate: json['target_date'],
      dueDate: json['due_date'],
      completionDate: json['completion_date'],
      urgentDate: json['urgent_date'],
      gamePoints: json['game_points'],
      recurNumber: json['recur_number'],
      recurUnit: json['recur_unit'],
      recurWait: json['recur_wait'],
      recurrenceId: json['recurrence_id'],
      dateAdded: json['date_added'],
    );
  }

}
