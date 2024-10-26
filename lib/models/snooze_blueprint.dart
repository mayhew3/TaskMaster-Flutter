import 'package:json_annotation/json_annotation.dart';

import 'json_datetime_converter.dart';

/// This allows the `Snooze` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'snooze_blueprint.g.dart';

@JsonSerializable(includeIfNull: false)
class SnoozeBlueprint {

  int? id;
  DateTime? dateAdded;

  int? taskId;
  String taskDocId;
  int snoozeNumber;
  String snoozeUnits;
  String snoozeAnchor;

  @JsonDateTimePassThroughConverter()
  DateTime? previousAnchor;
  @JsonDateTimePassThroughConverter()
  DateTime newAnchor;

  SnoozeBlueprint({
    this.taskId,
    required this.taskDocId,
    required this.snoozeNumber,
    required this.snoozeUnits,
    required this.snoozeAnchor,
    this.previousAnchor,
    required this.newAnchor
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SnoozeBlueprintToJson(this);
}
