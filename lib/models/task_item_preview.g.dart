// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItemPreview _$TaskItemPreviewFromJson(Map<String, dynamic> json) =>
    TaskItemPreview(
      name: json['name'] as String,
      description: json['description'] as String?,
      project: json['project'] as String?,
      context: json['context'] as String?,
      urgency: json['urgency'] as int?,
      priority: json['priority'] as int?,
      duration: json['duration'] as int?,
      gamePoints: json['game_points'] as int?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      targetDate: json['target_date'] == null
          ? null
          : DateTime.parse(json['target_date'] as String),
      urgentDate: json['urgent_date'] == null
          ? null
          : DateTime.parse(json['urgent_date'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      completionDate: json['completion_date'] == null
          ? null
          : DateTime.parse(json['completion_date'] as String),
      recurNumber: json['recur_number'] as int?,
      recurUnit: json['recur_unit'] as String?,
      recurWait: json['recur_wait'] as bool?,
      recurrenceId: json['recurrence_id'] as int?,
      recurIteration: json['recur_iteration'] as int?,
      offCycle: json['off_cycle'] as bool? ?? false,
    );

Map<String, dynamic> _$TaskItemPreviewToJson(TaskItemPreview instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('project', instance.project);
  writeNotNull('context', instance.context);
  writeNotNull('urgency', instance.urgency);
  writeNotNull('priority', instance.priority);
  writeNotNull('duration', instance.duration);
  writeNotNull('game_points', instance.gamePoints);
  writeNotNull('start_date', instance.startDate?.toIso8601String());
  writeNotNull('target_date', instance.targetDate?.toIso8601String());
  writeNotNull('due_date', instance.dueDate?.toIso8601String());
  writeNotNull('urgent_date', instance.urgentDate?.toIso8601String());
  writeNotNull('completion_date', instance.completionDate?.toIso8601String());
  writeNotNull('recur_number', instance.recurNumber);
  writeNotNull('recur_unit', instance.recurUnit);
  writeNotNull('recur_wait', instance.recurWait);
  writeNotNull('recurrence_id', instance.recurrenceId);
  writeNotNull('recur_iteration', instance.recurIteration);
  val['off_cycle'] = instance.offCycle;
  return val;
}
