import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';

class TaskItem extends DataObject {

  late TaskFieldInteger personId;

  late TaskFieldString/*!*/ name;
  late TaskFieldString/*!*/ description;
  late TaskFieldString/*!*/ project;
  late TaskFieldString/*!*/ context;

  late TaskFieldInteger urgency;
  late TaskFieldInteger priority;
  late TaskFieldInteger duration;

  late TaskFieldDate dateAdded;
  late TaskFieldDate startDate;
  late TaskFieldDate targetDate;
  late TaskFieldDate dueDate;
  late TaskFieldDate completionDate;
  late TaskFieldDate urgentDate;

  late TaskFieldInteger gamePoints;

  late TaskFieldInteger recurNumber;
  late TaskFieldString recurUnit;
  late TaskFieldBoolean recurWait;

  late TaskFieldInteger recurrenceId;

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
        Sprint? sprint = matching.isEmpty ? null : matching.first;
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
        TaskField? newField = taskItem.getTaskField(field.fieldName);
        newField!.initializeValue(field.value);
      }
    }
    taskItem.personId.initializeValue(personId.value);

    return taskItem;
  }

  TaskField? getTaskField(String fieldName) {
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

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate.value;
  }

  bool isScheduled() {
    return startDate.value != null && !startDate.hasPassed();
  }

  bool isPastDue() {
    return dueDate.hasPassed();
  }

  bool isDueBefore(DateTime dateTime) {
    var dueDateValue = dueDate.value;
    return dueDateValue != null && dueDateValue.isBefore(dateTime);
  }

  bool isUrgentBefore(DateTime dateTime) {
    var urgentDateValue = urgentDate.value;
    return urgentDateValue != null && urgentDateValue.isBefore(dateTime);
  }

  bool isTargetBefore(DateTime dateTime) {
    var targetDateValue = targetDate.value;
    return targetDateValue != null && targetDateValue.isBefore(dateTime);
  }

  bool isScheduledAfter(DateTime dateTime) {
    var startDateValue = startDate.value;
    return startDateValue != null && startDateValue.isAfter(dateTime);
  }

  bool isUrgent() {
    return urgentDate.hasPassed();
  }

  bool isTarget() {
    return targetDate.hasPassed();
  }


  DateTime? getLastDateBefore(TaskDateType taskDateType) {
    TaskDateType? typePreceding = TaskDateTypes.getTypePreceding(taskDateType);
    DateTime? lastValue = typePreceding?.dateFieldGetter(this).value;

    if (lastValue != null) {
      return lastValue;
    }

    while (typePreceding != null && (typePreceding = TaskDateTypes.getTypePreceding(typePreceding)) != null) {
      lastValue = typePreceding?.dateFieldGetter(this).value;

      if (lastValue != null) {
        return lastValue;
      }
    }

    return null;
  }

  DateTime? getAnchorDate() {
    return getAnchorDateType()?.dateFieldGetter(this).value;
  }

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait.value;
    return recurWaitValue != null && !recurWaitValue;
  }

  TaskDateType? getAnchorDateType() {
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
