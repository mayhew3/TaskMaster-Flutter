
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sprint_assignment.g.dart';

abstract class SprintAssignment implements Built<SprintAssignment, SprintAssignmentBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<SprintAssignment> get serializer => _$sprintAssignmentSerializer;

  int get id;
  int get taskId;
  int get sprintId;

  SprintAssignment._();

  factory SprintAssignment([Function(SprintAssignmentBuilder) updates]) = _$SprintAssignment;

}