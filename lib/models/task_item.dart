import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';

class TaskItem extends DataObject {
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

  @override
  TaskItem(): super() {
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
    return getDateFieldOfType(getAnchorDateType()).value;
  }

  TaskFieldDate getDateFieldOfType(TaskDateType taskDateType) {
    if (TaskDateType.START == taskDateType) {
      return startDate;
    } else if (TaskDateType.TARGET == taskDateType) {
      return targetDate;
    } else if (TaskDateType.URGENT == taskDateType) {
      return urgentDate;
    } else if (TaskDateType.DUE == taskDateType) {
      return dueDate;
    } else {
      return null;
    }
  }

  TaskDateType getAnchorDateType() {
    if (dueDate.value != null) {
      return TaskDateType.DUE;
    } else if (urgentDate.value != null) {
      return TaskDateType.URGENT;
    } else if (targetDate.value != null) {
      return TaskDateType.TARGET;
    } else if (startDate.value != null) {
      return TaskDateType.START;
    } else {
      return null;
    }
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var field = getDateFieldOfType(taskDateType);
    field.value = field.value?.add(duration);
  }

  @override
  String toString() {
    return 'TaskItem{'
        'id: ${id.value}, '
        'name: ${name.value}, '
        'personId: ${personId.value}, '
        'dateAdded: ${dateAdded.value}, '
        'completionDate: ${completionDate.value}}';
  }

}
