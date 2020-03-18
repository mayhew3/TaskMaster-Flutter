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

  bool pendingCompletion = false;

  static List<String> controlledFields = ['id', 'person_id', 'date_added', 'completion_date'];

  TaskItem() {
    this.id = _addIntegerField("id");
    this.personId = _addIntegerField("person_id");
    this.name = _addStringField("name");
    this.description = _addStringField("description");
    this.project = _addStringField("project");
    this.context = _addStringField("context");
    this.urgency = _addIntegerField("urgency");
    this.priority = _addIntegerField("priority");
    this.duration = _addIntegerField("duration");
    this.dateAdded = _addDateField("date_added");
    this.startDate = _addDateField("start_date");
    this.targetDate = _addDateField("target_date");
    this.dueDate = _addDateField("due_date");
    this.completionDate = _addDateField("completion_date");
    this.urgentDate = _addDateField("urgent_date");
    this.gamePoints = _addIntegerField("game_points");
    this.recurNumber = _addIntegerField("recur_number");
    this.recurUnit = _addStringField("recur_unit");
    this.recurWait = _addBoolField("recur_wait");
    this.recurrenceId = _addIntegerField("recurrence_id");
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
      if (!controlledFields.contains(field.fieldName)) {
        var newField = taskItem.getTaskField(field.fieldName);
        newField.initializeValue(field.value);
      }
    }
    taskItem.personId.initializeValue(personId.value);

    return taskItem;
  }

  TaskField getTaskField(String fieldName) {
    var matching = fields.where((field) => field.fieldName == fieldName);
    if (matching.isEmpty) {
      return null;
    } else if (matching.length > 1) {
      throw Exception("Bad state: multiple matches for fieldName $fieldName");
    } else {
      return matching.first;
    }
  }

  bool isCompleted() {
    return completionDate.value != null;
  }

  DateTime getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate.value;
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

  // Private

  TaskFieldString _addStringField(String fieldName) {
    var taskFieldString = TaskFieldString(fieldName);
    fields.add(taskFieldString);
    return taskFieldString;
  }

  TaskFieldInteger _addIntegerField(String fieldName) {
    var taskFieldInteger = TaskFieldInteger(fieldName);
    fields.add(taskFieldInteger);
    return taskFieldInteger;
  }

  TaskFieldBoolean _addBoolField(String fieldName) {
    var taskFieldBoolean = TaskFieldBoolean(fieldName);
    fields.add(taskFieldBoolean);
    return taskFieldBoolean;
  }

  TaskFieldDate _addDateField(String fieldName) {
    var taskFieldDate = TaskFieldDate(fieldName);
    fields.add(taskFieldDate);
    return taskFieldDate;
  }

}
