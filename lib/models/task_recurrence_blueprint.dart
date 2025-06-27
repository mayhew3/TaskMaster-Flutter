
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/json_anchordate_converter.dart';
import 'package:taskmaster/models/sprint_display_task_recurrence.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_recurrence.dart';

part 'task_recurrence_blueprint.g.dart';

/*
* Blueprints use the JsonSerializable annotation to serialize and deserialize
* instead of the built_value annotation. It's a bit annoying I have to use two
* different serialization frameworks, but I can mix built_value with another
* framework, and blueprints need to be editable, so built and not-built need to
* use different ones.
*
* One key difference to note is how to handle included objects. If the included
* object on a JsonSerializable is ALSO a JsonSerializable, we can just use the
* JsonKey annotation, like the recurrenceBlueprint below. If the included object
* is NOT, however, I need a separate JsonConverter class to handle it (see
* JsonAnchorDateConverter as an example.)
* */
@JsonSerializable(includeIfNull: true)
class TaskRecurrenceBlueprint with SprintDisplayTaskRecurrence {

  String? personDocId;

  String? name;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurIteration;

  @JsonAnchorDateConverter()
  AnchorDate? anchorDate;

  String? retired;
  DateTime? retiredDate;

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
        other.anchorDate != anchorDate;
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
        other.anchorDate != anchorDate;
  }

}