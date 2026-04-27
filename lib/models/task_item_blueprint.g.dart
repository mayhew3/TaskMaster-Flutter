// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$TaskItemBlueprintToJson(TaskItemBlueprint instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'project': instance.project,
      'context': instance.context,
      'urgency': instance.urgency,
      'priority': instance.priority,
      'duration': instance.duration,
      'gamePoints': instance.gamePoints,
      'startDate': _$JsonConverterToJson<DateTime, DateTime>(
        instance.startDate,
        const JsonDateTimePassThroughConverter().toJson,
      ),
      'targetDate': _$JsonConverterToJson<DateTime, DateTime>(
        instance.targetDate,
        const JsonDateTimePassThroughConverter().toJson,
      ),
      'dueDate': _$JsonConverterToJson<DateTime, DateTime>(
        instance.dueDate,
        const JsonDateTimePassThroughConverter().toJson,
      ),
      'urgentDate': _$JsonConverterToJson<DateTime, DateTime>(
        instance.urgentDate,
        const JsonDateTimePassThroughConverter().toJson,
      ),
      'completionDate': _$JsonConverterToJson<DateTime, DateTime>(
        instance.completionDate,
        const JsonDateTimePassThroughConverter().toJson,
      ),
      'offCycle': instance.offCycle,
      'recurNumber': instance.recurNumber,
      'recurUnit': instance.recurUnit,
      'recurWait': instance.recurWait,
      'recurrenceDocId': instance.recurrenceDocId,
      'recurIteration': instance.recurIteration,
      'recurrenceBlueprint': instance.recurrenceBlueprint,
      'retired': instance.retired,
      'retiredDate': instance.retiredDate?.toIso8601String(),
      'personDocId': instance.personDocId,
      'familyDocId': instance.familyDocId,
      'lastModified': _$JsonConverterToJson<DateTime, DateTime>(
        instance.lastModified,
        const JsonDateTimePassThroughConverter().toJson,
      ),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
