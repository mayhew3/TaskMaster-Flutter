
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

/// This allows the `TaskRecurrence` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskRecurrence {

  int id;
  int personId;

  String name;

  int recurNumber;
  String recurUnit;
  bool recurWait;

  int recurIteration;

  DateTime anchorDate;
  String anchorType;

  @JsonKey(ignore: true)
  List<TaskItem> taskItems = [];

  TaskRecurrence({
    required this.id,
    required this.personId,
    required this.name,
    required this.recurNumber,
    required this.recurUnit,
    required this.recurWait,
    required this.recurIteration,
    required this.anchorDate,
    required this.anchorType,
  });

  void addToTaskItems(TaskItem taskItem) {
    taskItems.add(taskItem);
    taskItem.taskRecurrence = this;
  }

  TaskRecurrenceBlueprint createEditBlueprint() {
    TaskRecurrenceBlueprint blueprint = TaskRecurrenceBlueprint();

    blueprint.name = name;
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurIteration = recurIteration;
    blueprint.anchorDate = anchorDate;
    blueprint.anchorType = anchorType;

    return blueprint;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TaskRecurrenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskRecurrence.fromJson(Map<String, dynamic> json) => _$TaskRecurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$TaskRecurrenceToJson(this);
}