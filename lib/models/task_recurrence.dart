
import 'package:built_value/built_value.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `TaskRecurrence` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
abstract class TaskRecurrence implements Built<TaskRecurrence, TaskRecurrenceBuilder> {

  int get id;
  int get personId;

  String get name;

  int get recurNumber;
  String get recurUnit;
  bool get recurWait;

  int get recurIteration;

  DateTime get anchorDate;
  String get anchorType;

  TaskRecurrence._();

  factory TaskRecurrence([Function(TaskRecurrenceBuilder) updates]) = _$TaskRecurrence;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TaskRecurrenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskRecurrence.fromJson(Map<String, dynamic> json) => _$TaskRecurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$TaskRecurrenceToJson(this);
}