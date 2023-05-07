import 'package:json_annotation/json_annotation.dart';

/// This allows the `TaskRecurrenceBlueprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence_blueprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskRecurrenceBlueprint {
  String? name;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  int? recurIteration;

  DateTime? anchorDate;
  String? anchorType;

  TaskRecurrenceBlueprint();

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TaskRecurrenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskRecurrenceBlueprint.fromJson(Map<String, dynamic> json) => _$TaskRecurrenceBlueprintFromJson(json);

  Map<String, dynamic> toJson() => _$TaskRecurrenceBlueprintToJson(this);
}