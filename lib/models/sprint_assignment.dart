import 'package:json_annotation/json_annotation.dart';

part 'sprint_assignment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class SprintAssignment {
  int? id;
  int? sprintId;

  SprintAssignment();

  factory SprintAssignment.fromJson(Map<String, dynamic> json) => _$SprintAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$SprintAssignmentToJson(this);
}