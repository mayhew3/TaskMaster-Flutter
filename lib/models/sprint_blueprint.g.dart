// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SprintBlueprint _$SprintBlueprintFromJson(Map<String, dynamic> json) =>
    SprintBlueprint(
        startDate: const JsonDateTimePassThroughConverter().fromJson(
          json['startDate'] as DateTime,
        ),
        endDate: const JsonDateTimePassThroughConverter().fromJson(
          json['endDate'] as DateTime,
        ),
        numUnits: (json['numUnits'] as num).toInt(),
        unitName: json['unitName'] as String,
        personDocId: json['personDocId'] as String,
      )
      ..closeDate = _$JsonConverterFromJson<DateTime, DateTime>(
        json['closeDate'],
        const JsonDateTimePassThroughConverter().fromJson,
      )
      ..sprintNumber = (json['sprintNumber'] as num?)?.toInt()
      ..retired = json['retired'] as String?
      ..retiredDate = json['retiredDate'] == null
          ? null
          : DateTime.parse(json['retiredDate'] as String);

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

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
