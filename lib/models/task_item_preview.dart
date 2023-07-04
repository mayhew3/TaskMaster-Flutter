import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_recurrence_preview.dart';

/// This allows the `TaskItemPreview` class to access private members in
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

  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? dueDate;
  final DateTime? urgentDate;
  final DateTime? completionDate;

  final int? recurNumber;
  final String? recurUnit;
  final bool? recurWait;

  final int? recurrenceId;
  final int? recurIteration;

  final bool offCycle;

  @JsonKey(ignore: true)
  TaskRecurrencePreview? taskRecurrencePreview;

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
    this.startDate,
    this.targetDate,
    this.urgentDate,
    this.dueDate,
    this.completionDate,
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
    return taskRecurrencePreview != null;
  }

  TaskRecurrencePreview? getExistingRecurrence() {
    return this.taskRecurrencePreview;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemPreviewToJson(this);

  TaskItemPreview createPreview({
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? urgentDate,
    DateTime? dueDate,
    int? recurIteration,
    bool incrementRecurrence = false,
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
        startDate: startDate ?? this.startDate,
        targetDate: targetDate ?? this.targetDate,
        urgentDate: urgentDate ?? this.urgentDate,
        dueDate: dueDate ?? this.dueDate,
        completionDate: completionDate,
        recurNumber: recurNumber,
        recurUnit: recurUnit,
        recurWait: recurWait,
        recurrenceId: recurrenceId,
        recurIteration: recurIteration ?? this.recurIteration,
        offCycle: offCycle
    );

    var recurrence = this.getExistingRecurrence();
    if (recurrence != null) {
      var recurrencePreview = recurrence.createEditPreview();
      if (incrementRecurrence) {
        recurrencePreview.recurIteration++;
      }
      preview.taskRecurrencePreview = recurrencePreview;
    }

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