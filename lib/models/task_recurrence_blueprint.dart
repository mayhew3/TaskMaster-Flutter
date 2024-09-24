
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_holder.dart';

part 'task_recurrence_blueprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskRecurrenceBlueprint {

  int? personId;

  String? name;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurIteration;

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

}