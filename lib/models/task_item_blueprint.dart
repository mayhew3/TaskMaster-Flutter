import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

/// This allows the `TaskItemBlueprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_blueprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItemBlueprint extends DateHolder {

  String? name;
  String? description;
  String? project;
  String? context;

  int? urgency;
  int? priority;
  int? duration;

  int? gamePoints;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurrenceId;
  int? recurIteration;

  TaskRecurrenceBlueprint? taskRecurrenceBlueprint;

  @JsonKey(ignore: true)
  late int tmpId;

  TaskItemBlueprint() {
    tmpId = new Random().nextInt(60000);
  }

  bool isRecurring() {
    return taskRecurrenceBlueprint != null;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemBlueprintToJson(this);

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  @override
  String toString() {
    return 'TaskItemBlueprint{'
        'name: $name';
  }

}