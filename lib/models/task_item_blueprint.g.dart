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
      ..gamePoints = (json['game_points'] as num?)?.toInt()
      ..startDate = json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String)
      ..targetDate = json['target_date'] == null
          ? null
          : DateTime.parse(json['target_date'] as String)
      ..dueDate = json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String)
      ..urgentDate = json['urgent_date'] == null
          ? null
          : DateTime.parse(json['urgent_date'] as String)
      ..completionDate = json['completion_date'] == null
          ? null
          : DateTime.parse(json['completion_date'] as String)
      ..recurrenceId = (json['recurrence_id'] as num?)?.toInt()
      ..personId = (json['person_id'] as num?)?.toInt()
      ..tmpId = (json['tmp_id'] as num).toInt();

Map<String, dynamic> _$TaskItemBlueprintToJson(TaskItemBlueprint instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'project': instance.project,
      'context': instance.context,
      'urgency': instance.urgency,
      'priority': instance.priority,
      'duration': instance.duration,
      'game_points': instance.gamePoints,
      'start_date': instance.startDate?.toIso8601String(),
      'target_date': instance.targetDate?.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'urgent_date': instance.urgentDate?.toIso8601String(),
      'completion_date': instance.completionDate?.toIso8601String(),
      'recurrence_id': instance.recurrenceId,
      'task_recurrence_blueprint': instance.taskRecurrenceBlueprint,
      'person_id': instance.personId,
    };
