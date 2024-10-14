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
      ..offCycle = json['offCycle'] as bool
      ..recurNumber = (json['recurNumber'] as num?)?.toInt()
      ..recurUnit = json['recurUnit'] as String?
      ..recurWait = json['recurWait'] as bool?
      ..recurrenceId = (json['recurrenceId'] as num?)?.toInt()
      ..recurIteration = (json['recurIteration'] as num?)?.toInt()
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
      'startDate': instance.startDate?.toIso8601String(),
      'targetDate': instance.targetDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'urgentDate': instance.urgentDate?.toIso8601String(),
      'completionDate': instance.completionDate?.toIso8601String(),
      'offCycle': instance.offCycle,
      'recurNumber': instance.recurNumber,
      'recurUnit': instance.recurUnit,
      'recurWait': instance.recurWait,
      'recurrenceId': instance.recurrenceId,
      'recurIteration': instance.recurIteration,
      'recurrenceBlueprint': instance.recurrenceBlueprint,
      'personDocId': instance.personDocId,
    };
