import 'package:taskmaster/models/task_field.dart';

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

  List<TaskField> fields = [];

  TaskItem() {
    this.id = addIntegerField("id");
    this.personId = addIntegerField("person_id");
    this.name = addStringField("name");
    this.description = addStringField("description");
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

  revertAllChanges() {
    for (var field in fields) {
      field.revert();
    }
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    TaskItem taskItem = TaskItem();
    for (var field in taskItem.fields) {
      var jsonVal = json[field.fieldName];
      if (jsonVal is String) {
        field.initializeValueFromString(jsonVal);
      } else {
        field.initializeValue(jsonVal);
      }
    }
    return taskItem;
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
    return startDate.value != null && !startDate.hasPassed();
  }

  bool isPastDue() {
    return dueDate.hasPassed();
  }

  bool isUrgent() {
    return urgentDate.hasPassed();
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
