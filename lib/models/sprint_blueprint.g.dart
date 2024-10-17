// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SprintBlueprint _$SprintBlueprintFromJson(Map<String, dynamic> json) =>
    SprintBlueprint(
      startDate: const JsonDateTimePassThroughConverter()
          .fromJson(json['startDate'] as DateTime),
      endDate: const JsonDateTimePassThroughConverter()
          .fromJson(json['endDate'] as DateTime),
      numUnits: (json['numUnits'] as num).toInt(),
      unitName: json['unitName'] as String,
      personDocId: json['personDocId'] as String,
    );

Map<String, dynamic> _$SprintBlueprintToJson(SprintBlueprint instance) =>
    <String, dynamic>{
      'startDate':
          const JsonDateTimePassThroughConverter().toJson(instance.startDate),
      'endDate':
          const JsonDateTimePassThroughConverter().toJson(instance.endDate),
      'numUnits': instance.numUnits,
      'unitName': instance.unitName,
      'personDocId': instance.personDocId,
    };
