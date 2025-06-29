// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_recur_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItemRecurPreview _$TaskItemRecurPreviewFromJson(
        Map<String, dynamic> json) =>
    TaskItemRecurPreview(
      json['name'] as String,
    )
      ..key = json['key'] as String
      ..personDocId = json['personDocId'] as String?
      ..description = json['description'] as String?
      ..project = json['project'] as String?
      ..context = json['context'] as String?
      ..urgency = (json['urgency'] as num?)?.toInt()
      ..priority = (json['priority'] as num?)?.toInt()
      ..duration = (json['duration'] as num?)?.toInt()
      ..gamePoints = (json['gamePoints'] as num?)?.toInt()
      ..startDate = json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String)
      ..targetDate = json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String)
      ..dueDate = json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String)
      ..urgentDate = json['urgentDate'] == null
          ? null
          : DateTime.parse(json['urgentDate'] as String)
      ..completionDate = json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String)
      ..recurNumber = (json['recurNumber'] as num?)?.toInt()
      ..recurUnit = json['recurUnit'] as String?
      ..recurWait = json['recurWait'] as bool?
      ..retired = json['retired'] as String?
      ..retiredDate = json['retiredDate'] == null
          ? null
          : DateTime.parse(json['retiredDate'] as String)
      ..recurrenceDocId = json['recurrenceDocId'] as String?
      ..recurIteration = (json['recurIteration'] as num?)?.toInt()
      ..offCycle = json['offCycle'] as bool;

Map<String, dynamic> _$TaskItemRecurPreviewToJson(
        TaskItemRecurPreview instance) =>
    <String, dynamic>{
      'key': instance.key,
      'personDocId': instance.personDocId,
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
      'recurrence': instance.recurrence,
    };
