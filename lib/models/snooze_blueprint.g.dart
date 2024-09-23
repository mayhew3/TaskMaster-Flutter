// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnoozeBlueprint _$SnoozeBlueprintFromJson(Map<String, dynamic> json) =>
    SnoozeBlueprint(
      taskId: (json['task_id'] as num).toInt(),
      snoozeNumber: (json['snooze_number'] as num).toInt(),
      snoozeUnits: json['snooze_units'] as String,
      snoozeAnchor: json['snooze_anchor'] as String,
      previousAnchor: json['previous_anchor'] == null
          ? null
          : DateTime.parse(json['previous_anchor'] as String),
      newAnchor: DateTime.parse(json['new_anchor'] as String),
    )
      ..id = (json['id'] as num?)?.toInt()
      ..dateAdded = json['date_added'] == null
          ? null
          : DateTime.parse(json['date_added'] as String);

Map<String, dynamic> _$SnoozeBlueprintToJson(SnoozeBlueprint instance) {
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
