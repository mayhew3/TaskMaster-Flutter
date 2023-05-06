// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_edit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskRecurrenceEdit _$TaskRecurrenceEditFromJson(Map<String, dynamic> json) =>
    TaskRecurrenceEdit(
      id: json['id'] as int,
      personId: json['person_id'] as int,
      name: json['name'] as String,
      recurNumber: json['recur_number'] as int,
      recurUnit: json['recur_unit'] as String,
      recurWait: json['recur_wait'] as bool?,
      recurIteration: json['recur_iteration'] as int,
      anchorDate: DateTime.parse(json['anchor_date'] as String),
      anchorType: json['anchor_type'] as String,
    );

Map<String, dynamic> _$TaskRecurrenceEditToJson(TaskRecurrenceEdit instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'person_id': instance.personId,
    'name': instance.name,
    'recur_number': instance.recurNumber,
    'recur_unit': instance.recurUnit,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recur_wait', instance.recurWait);
  val['recur_iteration'] = instance.recurIteration;
  val['anchor_date'] = instance.anchorDate.toIso8601String();
  val['anchor_type'] = instance.anchorType;
  return val;
}
