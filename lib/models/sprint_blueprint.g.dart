// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SprintBlueprint _$SprintBlueprintFromJson(Map<String, dynamic> json) =>
    SprintBlueprint(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      numUnits: (json['numUnits'] as num).toInt(),
      unitName: json['unitName'] as String,
      personDocId: json['personDocId'] as String,
    );

Map<String, dynamic> _$SprintBlueprintToJson(SprintBlueprint instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'numUnits': instance.numUnits,
      'unitName': instance.unitName,
      'personDocId': instance.personDocId,
    };
