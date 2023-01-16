import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_type.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_form.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItemForm {

  int? id;

  String? name;
  String? description;
  String? project;
  String? context;

  int? urgency;
  int? priority;
  int? duration;

  DateTime? dateAdded;
  DateTime? startDate;
  DateTime? targetDate;
  DateTime? dueDate;
  DateTime? completionDate;
  DateTime? urgentDate;

  int? gamePoints;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurrenceId;
  int? recurIteration;

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemFormToJson(this);

  TaskItemForm createChangeTemplate() {

    TaskItemForm fields = TaskItemForm();

    // todo: make more dynamic?
    fields.id = id;
    fields.name = name;
    fields.description = description;
    fields.project = project;
    fields.context = context;
    fields.urgency = urgency;
    fields.priority = priority;
    fields.duration = duration;
    fields.dateAdded = dateAdded;
    fields.startDate = startDate;
    fields.targetDate = targetDate;
    fields.dueDate = dueDate;
    fields.completionDate = completionDate;
    fields.urgentDate = urgentDate;
    fields.gamePoints = gamePoints;
    fields.recurNumber = recurNumber;
    fields.recurUnit = recurUnit;
    fields.recurWait = recurWait;
    fields.recurrenceId = recurrenceId;
    fields.recurIteration = recurIteration;

    return fields;
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var dateTime = taskDateType.dateFieldGetter(this);
    dateTime = dateTime?.add(duration);
  }

  bool isCompleted() {
    return completionDate != null;
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

  DateTime? getAnchorDate() {
    return getAnchorDateType()?.dateFieldGetter(this);
  }

}