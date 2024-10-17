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
      previousAnchor: _$JsonConverterFromJson<DateTime, DateTime>(
          json['previousAnchor'],
          const JsonDateTimePassThroughConverter().fromJson),
      newAnchor: const JsonDateTimePassThroughConverter()
          .fromJson(json['newAnchor'] as DateTime),
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
  writeNotNull(
      'previousAnchor',
      _$JsonConverterToJson<DateTime, DateTime>(instance.previousAnchor,
          const JsonDateTimePassThroughConverter().toJson));
  val['newAnchor'] =
      const JsonDateTimePassThroughConverter().toJson(instance.newAnchor);
  return val;
}

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
