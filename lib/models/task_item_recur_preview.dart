
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:random_string/random_string.dart';

/// This allows the `TaskItemRecurPreview` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_recur_preview.g.dart';

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
class TaskItemRecurPreview with DateHolder, SprintDisplayTask {

  String key;

  String? personDocId;

  @override
  String name;

  String? description;
  @override
  String? project;
  String? context;

  int? urgency;
  int? priority;
  int? duration;

  int? gamePoints;

  @override
  DateTime? startDate;
  @override
  DateTime? targetDate;
  @override
  DateTime? dueDate;
  @override
  DateTime? urgentDate;
  @override
  DateTime? completionDate;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  String? retired;
  DateTime? retiredDate;

  String? recurrenceDocId;

  @override
  int? recurIteration;

  bool offCycle;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  TaskRecurrenceBlueprint? recurrence;

  TaskItemRecurPreview(this.name): key = 'TEMP_' + randomString(10), offCycle = false;

  @override
  TaskItemRecurPreview createNextRecurPreview({
    required Map<TaskDateType, DateTime> dates,
  }) {
    return new TaskItemRecurPreview(name)
      ..personDocId = personDocId
      ..name = name
      ..description = description
      ..project = project
      ..context = context
      ..urgency = urgency
      ..priority = priority
      ..duration = duration
      ..startDate = dates[TaskDateTypes.start]
      ..targetDate = dates[TaskDateTypes.target]
      ..urgentDate = dates[TaskDateTypes.urgent]
      ..dueDate = dates[TaskDateTypes.due]
      ..gamePoints = gamePoints
      ..recurNumber = recurNumber
      ..recurUnit = recurUnit
      ..recurWait = recurWait
      ..recurrenceDocId = recurrenceDocId
      ..recurIteration = recurIteration! + 1
      ..recurrence = recurrence;
  }

  @override
  bool isPreview() {
    return true;
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemRecurPreviewToJson(this);

  @override
  String getSprintDisplayTaskKey() {
    return key;
  }

  TaskItemBlueprint toBlueprint() {
    TaskItemBlueprint blueprint = TaskItemBlueprint();

    blueprint.name = name;
    blueprint.description = description;
    blueprint.project = project;
    blueprint.context = context;
    blueprint.urgency = urgency;
    blueprint.priority = priority;
    blueprint.duration = duration;
    blueprint.startDate = startDate;
    blueprint.targetDate = targetDate;
    blueprint.dueDate = dueDate;
    blueprint.urgentDate = urgentDate;
    blueprint.gamePoints = gamePoints;
    blueprint.offCycle = offCycle;
    blueprint.personDocId = personDocId;
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurrenceDocId = recurrenceDocId;
    blueprint.recurIteration = recurIteration;

    blueprint.recurrenceBlueprint = recurrence;

    return blueprint;
  }

}
