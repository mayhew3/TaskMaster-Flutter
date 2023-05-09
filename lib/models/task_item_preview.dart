import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_recurrence.dart';

/// This allows the `TaskItemBlueprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_preview.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItemPreview extends DateHolder {

  String name;
  String? description;
  String? project;
  String? context;

  DateTime? dateAdded;

  int? urgency;
  int? priority;
  int? duration;

  int? gamePoints;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurrenceId;
  int? recurIteration;

  @JsonKey(ignore: true)
  TaskRecurrence? taskRecurrence;

  @JsonKey(ignore: true)
  late int tmpId;

  TaskItemPreview({required this.name}) {
    tmpId = new Random().nextInt(60000);
  }

  bool isRecurring() {
    return taskRecurrence != null;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemPreviewToJson(this);

  TaskItemPreview createPreview() {

    TaskItemPreview preview = TaskItemPreview(name: name);

    // todo: make more dynamic?
    preview.description = description;
    preview.project = project;
    preview.context = context;
    preview.urgency = urgency;
    preview.priority = priority;
    preview.duration = duration;
    preview.startDate = startDate;
    preview.targetDate = targetDate;
    preview.dueDate = dueDate;
    preview.urgentDate = urgentDate;
    preview.gamePoints = gamePoints;
    preview.recurNumber = recurNumber;
    preview.recurUnit = recurUnit;
    preview.recurWait = recurWait;
    preview.recurrenceId = recurrenceId;
    preview.recurIteration = recurIteration;

    preview.taskRecurrence = taskRecurrence;

    return preview;
  }

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  bool isCompleted() {
    return false;
  }

  bool get pendingCompletion {
    return false;
  }

  @override
  String toString() {
    return 'TaskItemBlueprint{'
        'name: $name';
  }

}