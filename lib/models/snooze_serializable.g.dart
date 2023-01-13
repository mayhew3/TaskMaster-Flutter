// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_serializable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnoozeSerializable _$SnoozeSerializableFromJson(Map<String, dynamic> json) =>
    SnoozeSerializable()
      ..taskID = json['task_i_d'] as int
      ..snoozeNumber = json['snooze_number'] as int
      ..snoozeUnits = json['snooze_units'] as String
      ..snoozeAnchor = json['snooze_anchor'] as String
      ..previousAnchor = DateTime.parse(json['previous_anchor'] as String)
      ..newAnchor = DateTime.parse(json['new_anchor'] as String);

Map<String, dynamic> _$SnoozeSerializableToJson(SnoozeSerializable instance) =>
    <String, dynamic>{
      'task_i_d': instance.taskID,
      'snooze_number': instance.snoozeNumber,
      'snooze_units': instance.snoozeUnits,
      'snooze_anchor': instance.snoozeAnchor,
      'previous_anchor': instance.previousAnchor.toIso8601String(),
      'new_anchor': instance.newAnchor.toIso8601String(),
    };
