import 'package:json_annotation/json_annotation.dart';

import 'json_datetime_converter.dart';

part 'sprint_blueprint.g.dart';

@JsonSerializable(includeIfNull: true)
class SprintBlueprint {

  @JsonDateTimePassThroughConverter()
  DateTime startDate;
  @JsonDateTimePassThroughConverter()
  DateTime endDate;
  @JsonDateTimePassThroughConverter()
  DateTime? closeDate;

  int? sprintNumber;

  int numUnits;
  String unitName;

  String personDocId;

  String? retired;
  DateTime? retiredDate;

  SprintBlueprint({
    required this.startDate,
    required this.endDate,
    required this.numUnits,
    required this.unitName,
    required this.personDocId,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$SprintBlueprintToJson(this);
}