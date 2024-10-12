
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

/// This allows the `TaskRecurrence` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence.g.dart';

abstract class TaskRecurrence implements Built<TaskRecurrence, TaskRecurrenceBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskRecurrence> get serializer => _$taskRecurrenceSerializer;

  int get id;
  String? get docId;

  int get personId;
  String? get personDocId;

  String get name;

  int get recurNumber;
  String get recurUnit;
  bool get recurWait;

  int get recurIteration;

  DateTime get anchorDate;
  String get anchorType;

  TaskRecurrence._();

  factory TaskRecurrence([Function(TaskRecurrenceBuilder) updates]) = _$TaskRecurrence;

  TaskRecurrenceBlueprint createBlueprint() {
    TaskRecurrenceBlueprint blueprint = TaskRecurrenceBlueprint();

    blueprint.personId = personId;
    blueprint.name = name;
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurIteration = recurIteration;
    blueprint.anchorDate = anchorDate;
    blueprint.anchorType = anchorType;

    return blueprint;
  }

  bool hasChanges(TaskRecurrence? other) {
    if (other == null) {
      return true;
    }
    return other.name != name ||
        other.recurNumber != recurNumber ||
        other.recurUnit != recurUnit ||
        other.recurWait != recurWait ||
        other.recurIteration != recurIteration ||
        other.anchorDate != anchorDate ||
        other.anchorType != anchorType;
  }

  bool hasChangesBlueprint(TaskRecurrenceBlueprint? other) {
    if (other == null) {
      return true;
    }
    return other.name != name ||
        other.recurNumber != recurNumber ||
        other.recurUnit != recurUnit ||
        other.recurWait != recurWait ||
        other.recurIteration != recurIteration ||
        other.anchorDate != anchorDate ||
        other.anchorType != anchorType;
  }

  static TaskRecurrence fromJson(dynamic json) {
    return serializers.deserializeWith(TaskRecurrence.serializer, json)!;
  }
}