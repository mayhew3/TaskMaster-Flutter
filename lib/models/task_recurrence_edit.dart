import 'package:json_annotation/json_annotation.dart';

/// This allows the `TaskRecurrenceBlueprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence_edit.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskRecurrenceEdit {
  int id;
  int personId;

  String name;

  int recurNumber;
  String recurUnit;
  bool? recurWait;

  int recurIteration;

  DateTime anchorDate;
  String anchorType;

  TaskRecurrenceEdit({
    required this.id,
    required this.personId,
    required this.name,
    required this.recurNumber,
    required this.recurUnit,
    this.recurWait,
    required this.recurIteration,
    required this.anchorDate,
    required this.anchorType,
  });

  Map<String, dynamic> toJson() => _$TaskRecurrenceEditToJson(this);
}