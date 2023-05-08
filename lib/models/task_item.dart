import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item_edit.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItem extends TaskItemEdit {

  List<SprintAssignment>? sprintAssignments;

  TaskItem({
    required int id,
    required int personId,
    required String name,
  }): super(id: id, personId: personId, name: name);

  @override
  bool isEditable() {
    return false;
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

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskItem.fromJson(Map<String, dynamic> json) => _$TaskItemFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

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
