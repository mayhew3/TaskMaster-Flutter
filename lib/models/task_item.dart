
import 'package:built_value/built_value.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `TaskItem` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
abstract class TaskItem implements Built<TaskItem, TaskItemBuilder> {

  int get id;
  int get personId;

  String get name;

  String? get description;
  String? get project;
  String? get context;

  int? get urgency;
  int? get priority;
  int? get duration;

  int? get gamePoints;

  DateTime? get startDate;
  DateTime? get targetDate;
  DateTime? get dueDate;
  DateTime? get urgentDate;
  DateTime? get completionDate;

  int? get recurNumber;
  String? get recurUnit;
  bool? get recurWait;

  int? get recurrenceId;
  int? get recurIteration;

  bool get offCycle;

  TaskItem._();
  factory TaskItem([Function(TaskItemBuilder) updates]) = _$TaskItem;


  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskItem.fromJson(Map<String, dynamic> json) => _$TaskItemFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

}
