// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_serializable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnoozeSerializable _$SnoozeSerializableFromJson(Map<String, dynamic> json) =>
    SnoozeSerializable()
      ..taskId = json['task_id'] as int
      ..snoozeNumber = json['snooze_number'] as int?
      ..snoozeUnits = json['snooze_units'] as String?
      ..snoozeAnchor = json['snooze_anchor'] as String?
      ..previousAnchor = json['previous_anchor'] == null
          ? null
          : DateTime.parse(json['previous_anchor'] as String)
      ..newAnchor = json['new_anchor'] == null
          ? null
          : DateTime.parse(json['new_anchor'] as String);

Map<String, dynamic> _$SnoozeSerializableToJson(SnoozeSerializable instance) {
  final val = <String, dynamic>{
    'task_id': instance.taskId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('snooze_number', instance.snoozeNumber);
  writeNotNull('snooze_units', instance.snoozeUnits);
  writeNotNull('snooze_anchor', instance.snoozeAnchor);
  writeNotNull('previous_anchor', instance.previousAnchor?.toIso8601String());
  writeNotNull('new_anchor', instance.newAnchor?.toIso8601String());
  return val;
}
