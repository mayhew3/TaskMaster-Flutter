// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Snooze _$SnoozeFromJson(Map<String, dynamic> json) => Snooze(
      taskId: json['task_id'] as int,
      snoozeNumber: json['snooze_number'] as int,
      snoozeUnits: json['snooze_units'] as String,
      snoozeAnchor: json['snooze_anchor'] as String,
      previousAnchor: json['previous_anchor'] == null
          ? null
          : DateTime.parse(json['previous_anchor'] as String),
      newAnchor: DateTime.parse(json['new_anchor'] as String),
    )
      ..id = json['id'] as int?
      ..dateAdded = json['date_added'] == null
          ? null
          : DateTime.parse(json['date_added'] as String);

Map<String, dynamic> _$SnoozeToJson(Snooze instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('date_added', instance.dateAdded?.toIso8601String());
  val['task_id'] = instance.taskId;
  val['snooze_number'] = instance.snoozeNumber;
  val['snooze_units'] = instance.snoozeUnits;
  val['snooze_anchor'] = instance.snoozeAnchor;
  writeNotNull('previous_anchor', instance.previousAnchor?.toIso8601String());
  val['new_anchor'] = instance.newAnchor.toIso8601String();
  return val;
}
