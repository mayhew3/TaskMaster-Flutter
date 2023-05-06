// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrenceBlueprint _$TaskRecurrenceBlueprintFromJson(
        Map<String, dynamic> json) =>
    TaskRecurrenceBlueprint()
      ..name = json['name'] as String?
      ..recurNumber = json['recur_number'] as int?
      ..recurUnit = json['recur_unit'] as String?
      ..recurWait = json['recur_wait'] as bool?
      ..recurIteration = json['recur_iteration'] as int?
      ..anchorDate = json['anchor_date'] == null
          ? null
          : DateTime.parse(json['anchor_date'] as String)
      ..anchorType = json['anchor_type'] as String?;

Map<String, dynamic> _$TaskRecurrenceBlueprintToJson(
    TaskRecurrenceBlueprint instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('recur_number', instance.recurNumber);
  writeNotNull('recur_unit', instance.recurUnit);
  writeNotNull('recur_wait', instance.recurWait);
  writeNotNull('recur_iteration', instance.recurIteration);
  writeNotNull('anchor_date', instance.anchorDate?.toIso8601String());
  writeNotNull('anchor_type', instance.anchorType);
  return val;
}
