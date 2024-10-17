// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrenceBlueprint _$TaskRecurrenceBlueprintFromJson(
        Map<String, dynamic> json) =>
    TaskRecurrenceBlueprint()
      ..personDocId = json['personDocId'] as String?
      ..name = json['name'] as String?
      ..recurNumber = (json['recurNumber'] as num?)?.toInt()
      ..recurUnit = json['recurUnit'] as String?
      ..recurWait = json['recurWait'] as bool?
      ..recurIteration = (json['recurIteration'] as num?)?.toInt()
      ..anchorDate = _$JsonConverterFromJson<DateTime, DateTime>(
          json['anchorDate'], const JsonDateTimePassThroughConverter().fromJson)
      ..anchorType = json['anchorType'] as String?;

Map<String, dynamic> _$TaskRecurrenceBlueprintToJson(
        TaskRecurrenceBlueprint instance) =>
    <String, dynamic>{
      'personDocId': instance.personDocId,
      'name': instance.name,
      'recurNumber': instance.recurNumber,
      'recurUnit': instance.recurUnit,
      'recurWait': instance.recurWait,
      'recurIteration': instance.recurIteration,
      'anchorDate': _$JsonConverterToJson<DateTime, DateTime>(
          instance.anchorDate, const JsonDateTimePassThroughConverter().toJson),
      'anchorType': instance.anchorType,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
