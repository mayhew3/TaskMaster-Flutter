// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnoozeBlueprint _$SnoozeBlueprintFromJson(Map<String, dynamic> json) =>
    SnoozeBlueprint(
      taskId: (json['taskId'] as num?)?.toInt(),
      taskDocId: json['taskDocId'] as String,
      snoozeNumber: (json['snoozeNumber'] as num).toInt(),
      snoozeUnits: json['snoozeUnits'] as String,
      snoozeAnchor: json['snoozeAnchor'] as String,
      previousAnchor: _$JsonConverterFromJson<DateTime, DateTime>(
          json['previousAnchor'],
          const JsonDateTimePassThroughConverter().fromJson),
      newAnchor: const JsonDateTimePassThroughConverter()
          .fromJson(json['newAnchor'] as DateTime),
    )
      ..id = (json['id'] as num?)?.toInt()
      ..dateAdded = json['dateAdded'] == null
          ? null
          : DateTime.parse(json['dateAdded'] as String)
      ..retired = json['retired'] as String?
      ..retiredDate = json['retiredDate'] == null
          ? null
          : DateTime.parse(json['retiredDate'] as String);

Map<String, dynamic> _$SnoozeBlueprintToJson(SnoozeBlueprint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dateAdded': instance.dateAdded?.toIso8601String(),
      'taskId': instance.taskId,
      'taskDocId': instance.taskDocId,
      'snoozeNumber': instance.snoozeNumber,
      'snoozeUnits': instance.snoozeUnits,
      'snoozeAnchor': instance.snoozeAnchor,
      'previousAnchor': _$JsonConverterToJson<DateTime, DateTime>(
          instance.previousAnchor,
          const JsonDateTimePassThroughConverter().toJson),
      'newAnchor':
          const JsonDateTimePassThroughConverter().toJson(instance.newAnchor),
      'retired': instance.retired,
      'retiredDate': instance.retiredDate?.toIso8601String(),
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
