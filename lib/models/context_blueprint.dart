import 'package:json_annotation/json_annotation.dart';

part 'context_blueprint.g.dart';

/// Mutable counterpart of [Context] used when creating or updating a context
/// from the UI. Mirrors the AreaBlueprint pattern.
@JsonSerializable(includeIfNull: true, createFactory: false)
class ContextBlueprint {
  String name;
  int sortOrder;
  String personDocId;

  String? iconName;
  String? color;

  String? retired;
  DateTime? retiredDate;

  ContextBlueprint({
    required this.name,
    required this.sortOrder,
    required this.personDocId,
    this.iconName,
    this.color,
  });

  Map<String, dynamic> toJson() => _$ContextBlueprintToJson(this);
}
