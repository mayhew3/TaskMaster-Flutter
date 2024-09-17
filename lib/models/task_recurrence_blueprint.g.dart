// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrenceBlueprint _$TaskRecurrenceBlueprintFromJson(
        Map<String, dynamic> json) =>
    TaskRecurrenceBlueprint()
      ..personId = (json['person_id'] as num?)?.toInt()
      ..name = json['name'] as String?
      ..recurNumber = (json['recur_number'] as num?)?.toInt()
      ..recurUnit = json['recur_unit'] as String?
      ..recurWait = json['recur_wait'] as bool?
      ..recurIteration = (json['recur_iteration'] as num?)?.toInt()
      ..anchorDate = json['anchor_date'] == null
          ? null
          : DateTime.parse(json['anchor_date'] as String)
      ..anchorType = json['anchor_type'] as String?;

Map<String, dynamic> _$TaskRecurrenceBlueprintToJson(
        TaskRecurrenceBlueprint instance) =>
    <String, dynamic>{
      'person_id': instance.personId,
      'name': instance.name,
      'recur_number': instance.recurNumber,
      'recur_unit': instance.recurUnit,
      'recur_wait': instance.recurWait,
      'recur_iteration': instance.recurIteration,
      'anchor_date': instance.anchorDate?.toIso8601String(),
      'anchor_type': instance.anchorType,
    };
