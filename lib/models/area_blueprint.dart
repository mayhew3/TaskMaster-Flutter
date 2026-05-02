import 'package:json_annotation/json_annotation.dart';

part 'area_blueprint.g.dart';

/// Mutable counterpart of [Area] used when creating or updating an area
/// from the UI. Mirrors the SprintBlueprint pattern.
@JsonSerializable(includeIfNull: true, createFactory: false)
class AreaBlueprint {
  String name;
  int sortOrder;
  String personDocId;

  String? retired;
  DateTime? retiredDate;

  AreaBlueprint({
    required this.name,
    required this.sortOrder,
    required this.personDocId,
  });

  Map<String, dynamic> toJson() => _$AreaBlueprintToJson(this);
}
