// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrencePreview _$TaskRecurrencePreviewFromJson(
        Map<String, dynamic> json) =>
    TaskRecurrencePreview(
      id: json['id'] as int,
      personId: json['person_id'] as int,
      name: json['name'] as String,
      recurNumber: json['recur_number'] as int,
      recurUnit: json['recur_unit'] as String,
      recurWait: json['recur_wait'] as bool,
      recurIteration: json['recur_iteration'] as int,
      anchorDate: DateTime.parse(json['anchor_date'] as String),
      anchorType: json['anchor_type'] as String,
    );

Map<String, dynamic> _$TaskRecurrencePreviewToJson(
        TaskRecurrencePreview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'person_id': instance.personId,
      'name': instance.name,
      'recur_number': instance.recurNumber,
      'recur_unit': instance.recurUnit,
      'recur_wait': instance.recurWait,
      'recur_iteration': instance.recurIteration,
      'anchor_date': instance.anchorDate.toIso8601String(),
      'anchor_type': instance.anchorType,
    };
