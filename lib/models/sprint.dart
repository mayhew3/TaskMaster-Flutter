import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';

import 'package:json_annotation/json_annotation.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'sprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class Sprint {

  int? id;
  DateTime? dateAdded;

  DateTime startDate;
  DateTime endDate;
  DateTime? closeDate;

  int numUnits;
  String unitName;

  int personId;

  @JsonKey(ignore: true)
  List<TaskItem> taskItems = [];

  Sprint({
    required this.startDate,
    required this.endDate,
    this.closeDate,
    required this.numUnits,
    required this.unitName,
    required this.personId
  });

  bool isActive() {
    var now = DateTime.now();
    return this.startDate.isBefore(now) &&
        this.endDate.isAfter(now);
  }

  void addToTasks(TaskItem taskItem) {
    if (!taskItems.contains(taskItem)) {
      taskItems.add(taskItem);
    }
  }

  void removeFromTasks(TaskItem taskItem) {
    taskItems.remove(taskItem);
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Sprint.fromJson(Map<String, dynamic> json) => _$SprintFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SprintToJson(this);
}
