// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SprintBlueprintToJson(
  SprintBlueprint instance,
) => <String, dynamic>{
  'startDate': const JsonDateTimePassThroughConverter().toJson(
    instance.startDate,
  ),
  'endDate': const JsonDateTimePassThroughConverter().toJson(instance.endDate),
  'closeDate': _$JsonConverterToJson<DateTime, DateTime>(
    instance.closeDate,
    const JsonDateTimePassThroughConverter().toJson,
  ),
  'sprintNumber': instance.sprintNumber,
  'numUnits': instance.numUnits,
  'unitName': instance.unitName,
  'personDocId': instance.personDocId,
  'retired': instance.retired,
  'retiredDate': instance.retiredDate?.toIso8601String(),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
