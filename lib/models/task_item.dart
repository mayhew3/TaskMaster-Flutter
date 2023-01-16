import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_item_form.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskItem extends TaskItemForm {

  int personId;

  List<Sprint> sprintAssignments = [];

  @JsonKey(ignore: true)
  bool pendingCompletion = false;

  TaskItem({
    required this.personId
  });

  void addToSprints(Sprint sprint) {
    if (!sprintAssignments.contains(sprint)) {
      sprintAssignments.add(sprint);
    }
  }

  bool isInActiveSprint() {
    var matching = sprintAssignments.where((sprint) => sprint.isActive());
    return matching.isNotEmpty;
  }

  TaskItem createCopy() {
    var fields = new TaskItem(
        personId: this.personId,
    );

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

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  DateTime? getLastDateBefore(TaskDateType taskDateType) {
    var allDates = [startDate, targetDate, urgentDate, dueDate];
    var pastDates = allDates.where((dateTime) => dateTime != null && hasPassed(dateTime));

    return pastDates.reduce((a, b) => a!.isAfter(b!) ? a : b);
  }

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
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
