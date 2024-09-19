
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';

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

  void syncToTaskItem(TaskItem taskItem) {
    var taskIteration = taskItem.recurIteration;
    if (taskIteration != null) {
      recurIteration = taskIteration;
    }

    var taskAnchor = taskItem.getAnchorDate();
    if (taskAnchor != null) {
      anchorDate = taskAnchor;
    }
  }

  void syncToTaskItemBlueprint(TaskItemBlueprint taskItemBlueprint) {
    var taskIteration = taskItemBlueprint.recurIteration;
    if (taskIteration != null) {
      recurIteration = taskIteration;
    }

    var taskAnchor = taskItemBlueprint.getAnchorDate();
    if (taskAnchor != null) {
      anchorDate = taskAnchor;
    }
  }

}