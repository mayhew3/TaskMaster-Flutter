import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';

import 'package:json_annotation/json_annotation.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItem {

  int? id;
  int personId;

  String name;
  String? description;
  String? project;
  String? context;

  int urgency;
  int priority;
  int duration;

  DateTime? dateAdded;
  DateTime? startDate;
  DateTime? targetDate;
  DateTime? dueDate;
  DateTime? completionDate;
  DateTime? urgentDate;

  int gamePoints;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurrenceId;
  int? recurIteration;

  List<Sprint> sprints = [];

  @JsonKey(ignore: true)
  bool pendingCompletion = false;

  TaskItem({
    required this.personId,
    required this.name,
    this.description,
    this.project,
    this.context,
    required this.urgency,
    required this.priority,
    required this.duration,
    this.dateAdded,
    this.startDate,
    this.targetDate,
    this.dueDate,
    this.completionDate,
    this.urgentDate,
    required this.gamePoints,
    this.recurNumber,
    this.recurUnit,
    this.recurWait,
    this.recurrenceId,
    this.recurIteration
  });

  void addToSprints(Sprint sprint) {
    if (!sprints.contains(sprint)) {
      sprints.add(sprint);
    }
  }

  bool isInActiveSprint() {
    var matching = sprints.where((sprint) => sprint.isActive());
    return matching.isNotEmpty;
  }

  TaskItem createCopy() {
    var taskItem = new TaskItem(
        personId: this.personId,
        name: this.name,
        description: this.description,
        project:  this.project,
        context: this.context,
        urgency: this.urgency,
        priority: this.priority,
        duration: this.duration,
        dateAdded: this.dateAdded,
        startDate: this.startDate,
        targetDate: this.targetDate,
        dueDate: this.dueDate,
        completionDate: this.completionDate,
        urgentDate: this.urgentDate,
        gamePoints: this.gamePoints,
        recurNumber: this.recurNumber,
        recurUnit: this.recurUnit,
        recurWait: this.recurWait,
        recurrenceId: this.recurrenceId,
        recurIteration: this.recurIteration
    );

    return taskItem;
  }

  TaskField? getTaskField(String fieldName) {
    return null;
  }

  bool isCompleted() {
    return completionDate != null;
  }

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  bool hasPassed(DateTime? dateTime) {
    return dateTime != null && dateTime.isBefore(DateTime.now());
  }

  bool isFuture(DateTime? dateTime) {
    return dateTime != null && dateTime.isAfter(DateTime.now());
  }

  bool isScheduled() {
    return isFuture(startDate);
  }

  bool isPastDue() {
    return hasPassed(dueDate);
  }

  bool isDueBefore(DateTime dateTime) {
    return dueDate != null && dueDate!.isBefore(dateTime);
  }

  bool isUrgentBefore(DateTime dateTime) {
    return urgentDate != null && urgentDate!.isBefore(dateTime);
  }

  bool isTargetBefore(DateTime dateTime) {
    return targetDate != null && targetDate!.isBefore(dateTime);
  }

  bool isScheduledBefore(DateTime dateTime) {
    return startDate != null && startDate!.isBefore(dateTime);
  }

  bool isScheduledAfter(DateTime dateTime) {
    return startDate != null && startDate!.isAfter(dateTime);
  }

  bool isUrgent() {
    return hasPassed(urgentDate);
  }

  bool isTarget() {
    return hasPassed(targetDate);
  }


  DateTime? getLastDateBefore(TaskDateType taskDateType) {

    // todo: implement

    return null;
  }

  DateTime? getAnchorDate() {
    // todo: implement
    return null;
  }

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  TaskDateType? getAnchorDateType() {
    if (dueDate != null) {
      return TaskDateTypes.due;
    } else if (urgentDate != null) {
      return TaskDateTypes.urgent;
    } else if (targetDate != null) {
      return TaskDateTypes.target;
    } else if (startDate != null) {
      return TaskDateTypes.start;
    } else {
      return null;
    }
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    // todo: implement
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

}
