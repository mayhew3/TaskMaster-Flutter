// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_blueprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItemBlueprint _$TaskItemBlueprintFromJson(Map<String, dynamic> json) =>
    TaskItemBlueprint()
      ..name = json['name'] as String?
      ..description = json['description'] as String?
      ..project = json['project'] as String?
      ..context = json['context'] as String?
      ..urgency = (json['urgency'] as num?)?.toInt()
      ..priority = (json['priority'] as num?)?.toInt()
      ..duration = (json['duration'] as num?)?.toInt()
      ..gamePoints = (json['gamePoints'] as num?)?.toInt()
      ..startDate = _$JsonConverterFromJson<DateTime, DateTime>(
          json['startDate'], const JsonDateTimePassThroughConverter().fromJson)
      ..targetDate = _$JsonConverterFromJson<DateTime, DateTime>(
          json['targetDate'], const JsonDateTimePassThroughConverter().fromJson)
      ..dueDate = _$JsonConverterFromJson<DateTime, DateTime>(
          json['dueDate'], const JsonDateTimePassThroughConverter().fromJson)
      ..urgentDate = _$JsonConverterFromJson<DateTime, DateTime>(
          json['urgentDate'], const JsonDateTimePassThroughConverter().fromJson)
      ..completionDate = _$JsonConverterFromJson<DateTime, DateTime>(
          json['completionDate'],
          const JsonDateTimePassThroughConverter().fromJson)
      ..offCycle = json['offCycle'] as bool
      ..recurNumber = (json['recurNumber'] as num?)?.toInt()
      ..recurUnit = json['recurUnit'] as String?
      ..recurWait = json['recurWait'] as bool?
      ..recurrenceId = (json['recurrenceId'] as num?)?.toInt()
      ..recurrenceDocId = json['recurrenceDocId'] as String?
      ..recurIteration = (json['recurIteration'] as num?)?.toInt()
      ..retired = json['retired'] as String?
      ..retiredDate = json['retiredDate'] == null
          ? null
          : DateTime.parse(json['retiredDate'] as String)
      ..personDocId = json['personDocId'] as String?
      ..tmpId = (json['tmpId'] as num).toInt();

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
          instance.startDate, const JsonDateTimePassThroughConverter().toJson),
      'targetDate': _$JsonConverterToJson<DateTime, DateTime>(
          instance.targetDate, const JsonDateTimePassThroughConverter().toJson),
      'dueDate': _$JsonConverterToJson<DateTime, DateTime>(
          instance.dueDate, const JsonDateTimePassThroughConverter().toJson),
      'urgentDate': _$JsonConverterToJson<DateTime, DateTime>(
          instance.urgentDate, const JsonDateTimePassThroughConverter().toJson),
      'completionDate': _$JsonConverterToJson<DateTime, DateTime>(
          instance.completionDate,
          const JsonDateTimePassThroughConverter().toJson),
      'offCycle': instance.offCycle,
      'recurNumber': instance.recurNumber,
      'recurUnit': instance.recurUnit,
      'recurWait': instance.recurWait,
      'recurrenceId': instance.recurrenceId,
      'recurrenceDocId': instance.recurrenceDocId,
      'recurIteration': instance.recurIteration,
      'recurrenceBlueprint': instance.recurrenceBlueprint,
      'retired': instance.retired,
      'retiredDate': instance.retiredDate?.toIso8601String(),
      'personDocId': instance.personDocId,
    };

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
