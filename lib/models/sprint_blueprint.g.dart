// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SprintBlueprint _$SprintBlueprintFromJson(Map<String, dynamic> json) =>
    SprintBlueprint(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      numUnits: (json['num_units'] as num).toInt(),
      unitName: json['unit_name'] as String,
      personId: (json['person_id'] as num).toInt(),
    );

Map<String, dynamic> _$SprintBlueprintToJson(SprintBlueprint instance) =>
    <String, dynamic>{
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'num_units': instance.numUnits,
      'unit_name': instance.unitName,
      'person_id': instance.personId,
    };
