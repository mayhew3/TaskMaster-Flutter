// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
        const JsonDateTimePassThroughConverter().toJson,
      ),
      'newAnchor': const JsonDateTimePassThroughConverter().toJson(
        instance.newAnchor,
      ),
      'retired': instance.retired,
      'retiredDate': instance.retiredDate?.toIso8601String(),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
