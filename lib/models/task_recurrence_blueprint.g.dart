// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrenceBlueprint _$TaskRecurrenceBlueprintFromJson(
  Map<String, dynamic> json,
) => TaskRecurrenceBlueprint()
  ..personDocId = json['personDocId'] as String?
  ..name = json['name'] as String?
  ..recurNumber = (json['recurNumber'] as num?)?.toInt()
  ..recurUnit = json['recurUnit'] as String?
  ..recurWait = json['recurWait'] as bool?
  ..recurIteration = (json['recurIteration'] as num?)?.toInt()
  ..anchorDate = _$JsonConverterFromJson<Map<String, dynamic>, AnchorDate>(
    json['anchorDate'],
    const JsonAnchorDateConverter().fromJson,
  )
  ..retired = json['retired'] as String?
  ..retiredDate = json['retiredDate'] == null
      ? null
      : DateTime.parse(json['retiredDate'] as String);

Map<String, dynamic> _$TaskRecurrenceBlueprintToJson(
  TaskRecurrenceBlueprint instance,
) => <String, dynamic>{
  'personDocId': instance.personDocId,
  'name': instance.name,
  'recurNumber': instance.recurNumber,
  'recurUnit': instance.recurUnit,
  'recurWait': instance.recurWait,
  'recurIteration': instance.recurIteration,
  'anchorDate': _$JsonConverterToJson<Map<String, dynamic>, AnchorDate>(
    instance.anchorDate,
    const JsonAnchorDateConverter().toJson,
  ),
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
