// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_recur_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$TaskItemRecurPreviewToJson(
  TaskItemRecurPreview instance,
) => <String, dynamic>{
  'key': instance.key,
  'personDocId': instance.personDocId,
  'familyDocId': instance.familyDocId,
  'name': instance.name,
  'description': instance.description,
  'project': instance.project,
  'context': instance.context,
  'urgency': instance.urgency,
  'priority': instance.priority,
  'duration': instance.duration,
  'gamePoints': instance.gamePoints,
  'startDate': instance.startDate?.toIso8601String(),
  'targetDate': instance.targetDate?.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
  'urgentDate': instance.urgentDate?.toIso8601String(),
  'completionDate': instance.completionDate?.toIso8601String(),
  'recurNumber': instance.recurNumber,
  'recurUnit': instance.recurUnit,
  'recurWait': instance.recurWait,
  'retired': instance.retired,
  'retiredDate': instance.retiredDate?.toIso8601String(),
  'recurrenceDocId': instance.recurrenceDocId,
  'recurIteration': instance.recurIteration,
  'offCycle': instance.offCycle,
};
