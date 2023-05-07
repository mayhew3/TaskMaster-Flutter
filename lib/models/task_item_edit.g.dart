// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_edit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItemEdit _$TaskItemEditFromJson(Map<String, dynamic> json) => TaskItemEdit(
      id: json['id'] as int,
      personId: json['person_id'] as int,
    )
      ..name = json['name'] as String?
      ..description = json['description'] as String?
      ..project = json['project'] as String?
      ..context = json['context'] as String?
      ..urgency = json['urgency'] as int?
      ..priority = json['priority'] as int?
      ..duration = json['duration'] as int?
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
      ..gamePoints = json['game_points'] as int?
      ..recurNumber = json['recur_number'] as int?
      ..recurUnit = json['recur_unit'] as String?
      ..recurWait = json['recur_wait'] as bool?
      ..recurrenceId = json['recurrence_id'] as int?
      ..recurIteration = json['recur_iteration'] as int?
      ..taskRecurrenceBlueprint = json['task_recurrence_blueprint'] == null
          ? null
          : TaskRecurrenceBlueprint.fromJson(
              json['task_recurrence_blueprint'] as Map<String, dynamic>)
      ..dateAdded = json['date_added'] == null
          ? null
          : DateTime.parse(json['date_added'] as String)
      ..completionDate = json['completion_date'] == null
          ? null
          : DateTime.parse(json['completion_date'] as String);

Map<String, dynamic> _$TaskItemEditToJson(TaskItemEdit instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'project': instance.project,
      'context': instance.context,
      'urgency': instance.urgency,
      'priority': instance.priority,
      'duration': instance.duration,
      'start_date': instance.startDate?.toIso8601String(),
      'target_date': instance.targetDate?.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'urgent_date': instance.urgentDate?.toIso8601String(),
      'game_points': instance.gamePoints,
      'recur_number': instance.recurNumber,
      'recur_unit': instance.recurUnit,
      'recur_wait': instance.recurWait,
      'recurrence_id': instance.recurrenceId,
      'recur_iteration': instance.recurIteration,
      'task_recurrence_blueprint': instance.taskRecurrenceBlueprint,
      'id': instance.id,
      'person_id': instance.personId,
      'date_added': instance.dateAdded?.toIso8601String(),
      'completion_date': instance.completionDate?.toIso8601String(),
    };
