// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItem _$TaskItemFromJson(Map<String, dynamic> json) => TaskItem(
      id: json['id'] as int,
      personId: json['person_id'] as int,
      name: json['name'] as String,
      offCycle: json['off_cycle'] as bool? ?? false,
    )
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
      ..description = json['description'] as String?
      ..project = json['project'] as String?
      ..context = json['context'] as String?
      ..dateAdded = json['date_added'] == null
          ? null
          : DateTime.parse(json['date_added'] as String)
      ..urgency = json['urgency'] as int?
      ..priority = json['priority'] as int?
      ..duration = json['duration'] as int?
      ..gamePoints = json['game_points'] as int?
      ..recurNumber = json['recur_number'] as int?
      ..recurUnit = json['recur_unit'] as String?
      ..recurWait = json['recur_wait'] as bool?
      ..recurrenceId = json['recurrence_id'] as int?
      ..recurIteration = json['recur_iteration'] as int?
      ..sprintAssignments = (json['sprint_assignments'] as List<dynamic>?)
          ?.map((e) => SprintAssignment.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TaskItemToJson(TaskItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('start_date', instance.startDate?.toIso8601String());
  writeNotNull('target_date', instance.targetDate?.toIso8601String());
  writeNotNull('due_date', instance.dueDate?.toIso8601String());
  writeNotNull('urgent_date', instance.urgentDate?.toIso8601String());
  writeNotNull('completion_date', instance.completionDate?.toIso8601String());
  val['name'] = instance.name;
  writeNotNull('description', instance.description);
  writeNotNull('project', instance.project);
  writeNotNull('context', instance.context);
  writeNotNull('date_added', instance.dateAdded?.toIso8601String());
  writeNotNull('urgency', instance.urgency);
  writeNotNull('priority', instance.priority);
  writeNotNull('duration', instance.duration);
  writeNotNull('game_points', instance.gamePoints);
  writeNotNull('recur_number', instance.recurNumber);
  writeNotNull('recur_unit', instance.recurUnit);
  writeNotNull('recur_wait', instance.recurWait);
  writeNotNull('recurrence_id', instance.recurrenceId);
  writeNotNull('recur_iteration', instance.recurIteration);
  val['off_cycle'] = instance.offCycle;
  val['id'] = instance.id;
  val['person_id'] = instance.personId;
  writeNotNull('sprint_assignments', instance.sprintAssignments);
  return val;
}
