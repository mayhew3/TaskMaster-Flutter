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

  final String name;

  final String? description;
  final String? project;
  final String? context;

  final int? urgency;
  final int? priority;
  final int? duration;

  final int? gamePoints;

  final int? recurNumber;
  final String? recurUnit;
  final bool? recurWait;

  final int? recurrenceId;
  final int? recurIteration;

  final bool offCycle;

  @JsonKey(ignore: true)
  TaskRecurrence? taskRecurrence;

  @JsonKey(ignore: true)
  late int tmpId;

  TaskItemPreview({
    required this.name,
    this.description,
    this.project,
    this.context,
    this.urgency,
    this.priority,
    this.duration,
    this.gamePoints,
    this.recurNumber,
    this.recurUnit,
    this.recurWait,
    this.recurrenceId,
    this.recurIteration,
    this.offCycle = false
  }) {
    tmpId = new Random().nextInt(60000);
  }

  bool isRecurring() {
    return taskRecurrence != null;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemPreviewToJson(this);

  TaskItemPreview createPreview({
    int? recurIteration,
  }) {

    // todo: make more dynamic?
    TaskItemPreview preview = TaskItemPreview(
        name: name,
        description: description,
        project: project,
        context: context,
        urgency: urgency,
        priority: priority,
        duration: duration,
        gamePoints: gamePoints,
        recurNumber: recurNumber,
        recurUnit: recurUnit,
        recurWait: recurWait,
        recurrenceId: recurrenceId,
        recurIteration: recurIteration ?? this.recurIteration,
        offCycle: offCycle
    );

    preview.startDate = startDate;
    preview.targetDate = targetDate;
    preview.dueDate = dueDate;
    preview.urgentDate = urgentDate;

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