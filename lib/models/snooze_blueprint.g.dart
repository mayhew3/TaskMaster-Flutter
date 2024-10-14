// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnoozeBlueprint _$SnoozeBlueprintFromJson(Map<String, dynamic> json) =>
    SnoozeBlueprint(
      taskId: json['taskId'] as String,
      snoozeNumber: (json['snoozeNumber'] as num).toInt(),
      snoozeUnits: json['snoozeUnits'] as String,
      snoozeAnchor: json['snoozeAnchor'] as String,
      previousAnchor: json['previousAnchor'] == null
          ? null
          : DateTime.parse(json['previousAnchor'] as String),
      newAnchor: DateTime.parse(json['newAnchor'] as String),
    )
      ..id = (json['id'] as num?)?.toInt()
      ..dateAdded = json['dateAdded'] == null
          ? null
          : DateTime.parse(json['dateAdded'] as String);

Map<String, dynamic> _$SnoozeBlueprintToJson(SnoozeBlueprint instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('dateAdded', instance.dateAdded?.toIso8601String());
  val['taskId'] = instance.taskId;
  val['snoozeNumber'] = instance.snoozeNumber;
  val['snoozeUnits'] = instance.snoozeUnits;
  val['snoozeAnchor'] = instance.snoozeAnchor;
  writeNotNull('previousAnchor', instance.previousAnchor?.toIso8601String());
  val['newAnchor'] = instance.newAnchor.toIso8601String();
  return val;
}
