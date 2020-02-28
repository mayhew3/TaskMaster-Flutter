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
  TaskFieldInteger id;
  TaskFieldInteger personId;

  TaskFieldString name;
  TaskFieldString description;
  TaskFieldString project;
  TaskFieldString context;

  TaskFieldInteger urgency;
  TaskFieldInteger priority;
  TaskFieldInteger duration;

  TaskFieldDate dateAdded;
  TaskFieldDate startDate;
  TaskFieldDate targetDate;
  TaskFieldDate dueDate;
  TaskFieldDate completionDate;
  TaskFieldDate urgentDate;

  TaskFieldInteger gamePoints;

  TaskFieldInteger recurNumber;
  TaskFieldString recurUnit;
  TaskFieldBoolean recurWait;

  TaskFieldInteger recurrenceId;

  List<TaskField> fields;

  TaskItem() {
    this.id = addIntegerField("id");
    this.personId = addIntegerField("person_id");
    this.name = addStringField("name");
    this.project = addStringField("description");
    this.project = addStringField("project");
    this.context = addStringField("context");
    this.urgency = addIntegerField("urgency");
    this.priority = addIntegerField("priority");
    this.duration = addIntegerField("duration");
    this.dateAdded = addDateField("date_added");
    this.startDate = addDateField("start_date");
    this.targetDate = addDateField("target_date");
    this.dueDate = addDateField("due_date");
    this.completionDate = addDateField("completion_date");
    this.urgentDate = addDateField("urgent_date");
    this.gamePoints = addIntegerField("game_points");
    this.recurNumber = addIntegerField("recur_number");
    this.recurUnit = addStringField("recur_unit");
    this.recurWait = addBoolField("recur_wait");
    this.recurrenceId = addIntegerField("recurrence_id");
  }

  TaskItem.withValues({
    int id,
    int personId,
    String name,
    String description,
    String project,
    String context,
    int urgency,
    int priority,
    int duration,
    DateTime dateAdded,
    DateTime startDate,
    DateTime targetDate,
    DateTime dueDate,
    DateTime completionDate,
    DateTime urgentDate,
    int gamePoints,
    int recurNumber,
    String recurUnit,
    bool recurWait,
    int recurrenceId,
  }) {
    this.id = addIntegerValue("id", id);
    this.personId = addIntegerValue("person_id", personId);
    this.name = addStringValue("name", name);
    this.project = addStringValue("description", project);
    this.project = addStringValue("project", project);
    this.context = addStringValue("context", context);
    this.urgency = addIntegerValue("urgency", urgency);
    this.priority = addIntegerValue("priority", priority);
    this.duration = addIntegerValue("duration", duration);
    this.dateAdded = addDateValue("date_added", dateAdded);
    this.startDate = addDateValue("start_date", startDate);
    this.targetDate = addDateValue("target_date", targetDate);
    this.dueDate = addDateValue("due_date", dueDate);
    this.completionDate = addDateValue("completion_date", completionDate);
    this.urgentDate = addDateValue("urgent_date", urgentDate);
    this.gamePoints = addIntegerValue("game_points", gamePoints);
    this.recurNumber = addIntegerValue("recur_number", recurNumber);
    this.recurUnit = addStringValue("recur_unit", recurUnit);
    this.recurWait = addBoolValue("recur_wait", recurWait);
    this.recurrenceId = addIntegerValue("recurrence_id", recurrenceId);
  }

  TaskItem.fromJson(Map<String, dynamic> json) {
    for (var field in fields) {
      var jsonVal = json[field.fieldName];
      if (jsonVal is String) {
        field.initializeValueFromString(jsonVal);
      } else {
        field.initializeValue(jsonVal);
      }
    }
  }

  TaskItem createCopy() {
    var taskItem = new TaskItem();
    for (var field in fields) {
      if (field.fieldName != 'id' && field.fieldName != 'date_added') {
        var newField = taskItem.getTaskField(field.fieldName);
        newField.initializeValue(field.value);
      }
    }

    return taskItem;
  }

  TaskField getTaskField(String fieldName) {
    return fields.singleWhere((field) => field.fieldName == fieldName);
  }

  void setFieldValue(String fieldName, Object fieldValue) {
    var taskField = getTaskField(fieldName);
    taskField.value = fieldValue;
  }

  bool isCompleted() {
    return completionDate.value != null;
  }

  bool isScheduled() {
    return startDate.value != null && !hasPassed(startDate.value);
  }

  bool isPastDue() {
    return hasPassed(dueDate.value);
  }

  bool isUrgent() {
    return hasPassed(urgentDate.value);
  }

  DateTime getAnchorDate() {
    if (dueDate.value != null) {
      return dueDate.value;
    } else if (urgentDate.value != null) {
      return urgentDate.value;
    } else if (targetDate.value != null) {
      return targetDate.value;
    } else if (startDate.value != null) {
      return startDate.value;
    } else {
      return null;
    }
  }

  String getAnchorDateFieldName() {
    if (dueDate.value != null) {
      return "Due";
    } else if (urgentDate.value != null) {
      return "Urgent";
    } else if (targetDate.value != null) {
      return "Target";
    } else if (startDate.value != null) {
      return "Start";
    } else {
      return null;
    }
  }

  DateTime getDateFromName(String anchorDateFieldName) {
    switch (anchorDateFieldName) {
      case "Due": return dueDate.value;
      case "Urgent": return urgentDate.value;
      case "Target": return targetDate.value;
      case "Start": return startDate.value;
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
              id.value == other.id.value;

  @override
  String toString() {
    return 'TaskItem{'
        'id: ${id.value}, '
        'name: ${name.value}, '
        'personId: ${personId.value}, '
        'dateAdded: ${dateAdded.value}, '
        'completionDate: ${completionDate.value}}';
  }

  // With Values

  TaskFieldString addStringValue(String fieldName, String value) {
    var taskFieldString = TaskFieldString.withValues(fieldName, nullifyEmptyString(value));
    fields.add(taskFieldString);
    return taskFieldString;
  }

  TaskFieldInteger addIntegerValue(String fieldName, int value) {
    var taskFieldInteger = TaskFieldInteger.withValues(fieldName, value);
    fields.add(taskFieldInteger);
    return taskFieldInteger;
  }

  TaskFieldBoolean addBoolValue(String fieldName, bool value) {
    var taskFieldBoolean = TaskFieldBoolean.withValues(fieldName, value);
    fields.add(taskFieldBoolean);
    return taskFieldBoolean;
  }

  TaskFieldDate addDateValue(String fieldName, DateTime value) {
    var taskFieldDate = TaskFieldDate.withValues(fieldName, value);
    fields.add(taskFieldDate);
    return taskFieldDate;
  }

  TaskFieldDate addDateValueFromString(String fieldName, String value) {
    var taskFieldDate = TaskFieldDate(fieldName);
    taskFieldDate.initializeValueFromString(value);
    fields.add(taskFieldDate);
    return taskFieldDate;
  }

  // Empty

  TaskFieldString addStringField(String fieldName) {
    var taskFieldString = TaskFieldString(fieldName);
    fields.add(taskFieldString);
    return taskFieldString;
  }

  TaskFieldInteger addIntegerField(String fieldName) {
    var taskFieldInteger = TaskFieldInteger(fieldName);
    fields.add(taskFieldInteger);
    return taskFieldInteger;
  }

  TaskFieldBoolean addBoolField(String fieldName) {
    var taskFieldBoolean = TaskFieldBoolean(fieldName);
    fields.add(taskFieldBoolean);
    return taskFieldBoolean;
  }

  TaskFieldDate addDateField(String fieldName) {
    var taskFieldDate = TaskFieldDate(fieldName);
    fields.add(taskFieldDate);
    return taskFieldDate;
  }

}
