import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_edit.g.dart';


@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItemEdit extends TaskItemBlueprint {

  int? id;

  int personId;

  @JsonKey(ignore: true)
  List<Sprint> sprintAssignments = [];

  @JsonKey(ignore: true)
  bool pendingCompletion = false;

  TaskItemEdit({
    required this.personId
  });


  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemEditToJson(this);

  TaskItemEdit createEditTemplate() {

    TaskItemEdit fields = TaskItemEdit(personId: this.personId);

    // todo: make more dynamic?
    fields.id = id;
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

    return fields;
  }

  bool isEditable() {
    return true;
  }

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  void addToSprints(Sprint sprint) {
    if (!sprintAssignments.contains(sprint)) {
      sprintAssignments.add(sprint);
    }
  }

  bool isInActiveSprint() {
    var matching = sprintAssignments.where((sprint) => sprint.isActive());
    return matching.isNotEmpty;
  }


}