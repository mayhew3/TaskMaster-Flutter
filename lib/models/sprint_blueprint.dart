import 'package:json_annotation/json_annotation.dart';

part 'sprint_blueprint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SprintBlueprint {

  DateTime startDate;
  DateTime endDate;

  int numUnits;
  String unitName;

  int personId;

  SprintBlueprint({
    required this.startDate,
    required this.endDate,
    required this.numUnits,
    required this.unitName,
    required this.personId
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$SprintBlueprintToJson(this);
}