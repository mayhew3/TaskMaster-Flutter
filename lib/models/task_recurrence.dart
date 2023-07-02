
import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/models/task_recurrence_preview.dart';

/// This allows the `TaskRecurrence` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskRecurrence extends TaskRecurrencePreview {

  TaskRecurrence({
    required int id,
    required int personId,
    required String name,
    required int recurNumber,
    required String recurUnit,
    required bool recurWait,
    required int recurIteration,
    required DateTime anchorDate,
    required String anchorType,
  }) : super(id: id, personId: personId, name: name, recurNumber: recurNumber, recurUnit: recurUnit, recurWait: recurWait, recurIteration: recurIteration, anchorDate: anchorDate, anchorType: anchorType);

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TaskRecurrenceFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory TaskRecurrence.fromJson(Map<String, dynamic> json) => _$TaskRecurrenceFromJson(json);

  Map<String, dynamic> toJson() => _$TaskRecurrenceToJson(this);
}