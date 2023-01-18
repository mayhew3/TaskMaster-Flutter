import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_edit.g.dart';


@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItemEdit extends TaskItemBlueprint {

  int? id;

  int personId;

  DateTime? dateAdded;
  DateTime? completionDate;

  @JsonKey(ignore: true)
  List<Sprint> sprints = [];

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

  bool isCompleted() {
    return completionDate != null;
  }

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var dateTime = taskDateType.dateFieldGetter(this);
    taskDateType.dateFieldSetter(this, dateTime?.add(duration));
  }

  DateTime? getAnchorDate() {
    return getAnchorDateType()?.dateFieldGetter(this);
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
          other is TaskItemEdit &&
              id != null &&
              other.id != null &&
              runtimeType == other.runtimeType &&
              id == other.id;

}