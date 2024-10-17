
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_recurrence.dart';

import 'json_datetime_converter.dart';

part 'task_recurrence_blueprint.g.dart';

@JsonSerializable()
class TaskRecurrenceBlueprint {

  String? personDocId;

  String? name;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurIteration;

  @JsonDateTimePassThroughConverter()
  DateTime? anchorDate;
  String? anchorType;

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskRecurrenceBlueprintToJson(this);

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  @override
  String toString() {
    return 'TaskRecurrenceBlueprint{'
        'name: $name';
  }

  void syncToTaskItem(DateHolder dateHolder) {
    var taskIteration = dateHolder.recurIteration;
    if (taskIteration != null) {
      recurIteration = taskIteration;
    }

    var taskAnchor = dateHolder.getAnchorDate();
    if (taskAnchor != null) {
      anchorDate = taskAnchor;
    }
  }

  bool hasChanges(TaskRecurrence? other) {
    if (other == null) {
      return true;
    }
    return other.name != name ||
        other.recurNumber != recurNumber ||
        other.recurUnit != recurUnit ||
        other.recurWait != recurWait ||
        other.recurIteration != recurIteration ||
        other.anchorDate != anchorDate ||
        other.anchorType != anchorType;
  }

  bool hasChangesBlueprint(TaskRecurrenceBlueprint? other) {
    if (other == null) {
      return true;
    }
    return other.name != name ||
        other.recurNumber != recurNumber ||
        other.recurUnit != recurUnit ||
        other.recurWait != recurWait ||
        other.recurIteration != recurIteration ||
        other.anchorDate != anchorDate ||
        other.anchorType != anchorType;
  }

}