import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_preview.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItem extends TaskItemPreview {

  int id;
  int personId;

  @JsonKey(ignore: true)
  List<Sprint> sprints = [];

  @JsonKey(ignore: true)
  bool pendingCompletion = false;

  List<SprintAssignment>? sprintAssignments;

  TaskItem({
    required this.id,
    required this.personId,
    required String name,
  }): super(name: name);

  bool isRecurring() {
    return taskRecurrence != null;
  }

  TaskItem createCopy() {
    var fields = new TaskItem(id: id, personId: personId, name: name);

    // todo: make more dynamic?
    fields.name = name;
    fields.description = description;
    fields.project = project;
    fields.context = context;
    fields.urgency = urgency;
    fields.priority = priority;
    fields.duration = duration;
    fields.dateAdded = dateAdded;
    fields.startDate = startDate;
    fields.targetDate = targetDate;
    fields.dueDate = dueDate;
    fields.completionDate = completionDate;
    fields.urgentDate = urgentDate;
    fields.gamePoints = gamePoints;
    fields.recurNumber = recurNumber;
    fields.recurUnit = recurUnit;
    fields.recurWait = recurWait;
    fields.recurrenceId = recurrenceId;
    fields.recurIteration = recurIteration;

    fields.taskRecurrence = taskRecurrence;

    return fields;
  }

  TaskItemBlueprint createEditBlueprint() {
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
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurrenceId = recurrenceId;
    blueprint.recurIteration = recurIteration;

    return blueprint;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskItem.fromJson(Map<String, dynamic> json) => _$TaskItemFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

  @override
  bool isCompleted() {
    return completionDate != null;
  }

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  void addToSprints(Sprint sprint) {
    if (!sprints.contains(sprint)) {
      sprints.add(sprint);
    }
  }

  bool isInActiveSprint() {
    var matching = sprints.where((sprint) => sprint.isActive());
    return matching.isNotEmpty;
  }

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  String toString() {
    return 'TaskItem{'
        'id: $id, '
        'name: $name, '
        'personId: $personId, '
        'dateAdded: $dateAdded, '
        'completionDate: $completionDate}';
  }

}
