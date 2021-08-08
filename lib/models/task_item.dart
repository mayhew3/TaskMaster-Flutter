import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';

class TaskItem extends DataObject {

  TaskFieldInteger personId;

  TaskFieldString/*!*/ name;
  TaskFieldString/*!*/ description;
  TaskFieldString/*!*/ project;
  TaskFieldString/*!*/ context;

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

  List<Sprint> sprints = [];

  bool pendingCompletion = false;

  static List<String> controlledFields = [
    'id',
    'person_id',
    'date_added',
    'completion_date'
  ];

  @override
  TaskItem() : super() {
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

  @override
  List<String> getControlledFields() {
    return controlledFields;
  }

  void addToSprints(Sprint sprint) {
    if (!sprints.contains(sprint)) {
      sprints.add(sprint);
    }
  }

  bool isInActiveSprint() {
    var matching = sprints.where((sprint) => sprint.isActive());
    return matching.isNotEmpty;
  }

  factory TaskItem.fromJson(Map<String, dynamic> json, List<Sprint> sprints) {
    TaskItem taskItem = TaskItem();
    for (var field in taskItem.fields) {
      var jsonVal = json[field.fieldName];
      if (jsonVal is String) {
        field.initializeValueFromString(jsonVal);
      } else {
        field.initializeValue(jsonVal);
      }
    }

    if (json.containsKey('sprint_assignments')) {
      List<dynamic> assignments = json['sprint_assignments'];
      for (var assignment in assignments) {
        int sprintId = assignment['sprint_id'];
        Iterable<Sprint> matching = sprints.where((sprint) => sprint.id.value == sprintId);
        Sprint sprint =  matching.isEmpty ? null : matching.first;
        if (sprint == null) {
          throw new Exception('No sprint found with ID ' + sprintId.toString());
        }
        taskItem.addToSprints(sprint);
        sprint.addToTasks(taskItem);
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

  bool isDueBefore(DateTime dateTime) {
    return dueDate.value != null && dueDate.value.isBefore(dateTime);
  }

  bool isUrgentBefore(DateTime dateTime) {
    return urgentDate.value != null && urgentDate.value.isBefore(dateTime);
  }

  bool isTargetBefore(DateTime dateTime) {
    return targetDate.value != null && targetDate.value.isBefore(dateTime);
  }

  bool isScheduledAfter(DateTime dateTime) {
    return startDate.value != null && startDate.value.isAfter(dateTime);
  }

  bool isUrgent() {
    return urgentDate.hasPassed();
  }

  bool isTarget() {
    return targetDate.hasPassed();
  }


  DateTime getLastDateBefore(TaskDateType taskDateType) {
    var typePreceding = TaskDateTypes.getTypePreceding(taskDateType);
    var lastValue = typePreceding.dateFieldGetter(this).value;

    if (lastValue != null) {
      return lastValue;
    }

    while ((typePreceding = TaskDateTypes.getTypePreceding(typePreceding)) != null) {
      lastValue = typePreceding?.dateFieldGetter(this).value;

      if (lastValue != null) {
        return lastValue;
      }
    }

    return null;
  }

  DateTime getAnchorDate() {
    return getAnchorDateType().dateFieldGetter(this).value;
  }

  bool isScheduledRecurrence() {
    return recurWait.value != null && !recurWait.value;
  }

  TaskDateType getAnchorDateType() {
    if (dueDate.value != null) {
      return TaskDateTypes.due;
    } else if (urgentDate.value != null) {
      return TaskDateTypes.urgent;
    } else if (targetDate.value != null) {
      return TaskDateTypes.target;
    } else if (startDate.value != null) {
      return TaskDateTypes.start;
    } else {
      return null;
    }
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var field = taskDateType.dateFieldGetter(this);
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
