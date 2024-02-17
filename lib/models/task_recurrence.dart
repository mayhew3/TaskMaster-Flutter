
import 'package:json_annotation/json_annotation.dart';

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

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TaskRecurrenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskRecurrence.fromJson(Map<String, dynamic> json) => _$TaskRecurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$TaskRecurrenceToJson(this);
}