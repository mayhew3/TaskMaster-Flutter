import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

/// This allows the `TaskItemBlueprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_blueprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskItemBlueprint with DateHolder {

  String? name;
  String? description;
  String? project;
  String? context;

  int? urgency;
  int? priority;
  int? duration;

  int? gamePoints;

  DateTime? startDate;
  DateTime? targetDate;
  DateTime? dueDate;
  DateTime? urgentDate;
  DateTime? completionDate;

  bool? offCycle;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurrenceId;
  int? recurIteration;

  @JsonKey(includeFromJson: false, includeToJson: true)
  TaskRecurrenceBlueprint? recurrenceBlueprint;

  int? personId;

  @JsonKey(includeToJson: false)
  late int tmpId;

  TaskItemBlueprint() {
    tmpId = new Random().nextInt(60000);
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemBlueprintToJson(this);

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var dateTime = taskDateType.dateFieldGetter(this);
    taskDateType.dateFieldSetter(this, dateTime?.add(duration));
  }

  bool hasChanges(TaskItem other) {
    var allMismatch = other.name != name ||
        other.description != description ||
        other.project != project ||
        other.context != context ||
        other.urgency != urgency ||
        other.priority != priority ||
        other.duration != duration ||
        other.gamePoints != gamePoints ||
        other.startDate != startDate ||
        other.targetDate != targetDate ||
        other.dueDate != dueDate ||
        other.urgentDate != urgentDate ||
        other.completionDate != completionDate ||
        other.offCycle != offCycle ||
        other.recurNumber != recurNumber ||
        other.recurUnit != recurUnit ||
        other.recurWait != recurWait ||
        other.recurrenceId != recurrenceId ||
        other.recurIteration != recurIteration ||
        (recurrenceBlueprint == null ? other.recurrence != null : recurrenceBlueprint!.hasChanges(other.recurrence));
    print("All mismatch: $allMismatch");
    return
      allMismatch;
  }

  bool hasChangesBlueprint(TaskItemBlueprint other) {
    return
      other.name != name ||
          other.description != description ||
          other.project != project ||
          other.context != context ||
          other.urgency != urgency ||
          other.priority != priority ||
          other.duration != duration ||
          other.gamePoints != gamePoints ||
          other.startDate != startDate ||
          other.targetDate != targetDate ||
          other.dueDate != dueDate ||
          other.urgentDate != urgentDate ||
          other.completionDate != completionDate ||
          other.offCycle != offCycle ||
          other.recurNumber != recurNumber ||
          other.recurUnit != recurUnit ||
          other.recurWait != recurWait ||
          other.recurrenceId != recurrenceId ||
          other.recurIteration != recurIteration ||
          (recurrenceBlueprint == null ? other.recurrenceBlueprint != null : recurrenceBlueprint!.hasChangesBlueprint(other.recurrenceBlueprint));
  }

  @override
  String toString() {
    return 'TaskItemBlueprint{'
        'name: $name';
  }

}