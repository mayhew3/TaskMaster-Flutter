// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  if (instance.lastModified?.toIso8601String() case final value?)
    'lastModified': value,
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
