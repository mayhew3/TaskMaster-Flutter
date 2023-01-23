// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SprintAssignment _$SprintAssignmentFromJson(Map<String, dynamic> json) =>
    SprintAssignment()
      ..id = json['id'] as int?
      ..sprintId = json['sprint_id'] as int?;

Map<String, dynamic> _$SprintAssignmentToJson(SprintAssignment instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('sprint_id', instance.sprintId);
  return val;
}
