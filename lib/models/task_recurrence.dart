
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

/// This allows the `TaskRecurrence` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_recurrence.g.dart';

abstract class TaskRecurrence implements Built<TaskRecurrence, TaskRecurrenceBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskRecurrence> get serializer => _$taskRecurrenceSerializer;

  String get docId;

  DateTime get dateAdded;

  String get personDocId;

  String get name;

  int get recurNumber;
  String get recurUnit;
  bool get recurWait;

  int get recurIteration;

  AnchorDate get anchorDate;

  TaskRecurrence._();

  factory TaskRecurrence([Function(TaskRecurrenceBuilder) updates]) = _$TaskRecurrence;

  TaskRecurrenceBlueprint createBlueprint() {
    TaskRecurrenceBlueprint blueprint = TaskRecurrenceBlueprint();
    var anchorDateBuilder = AnchorDateBuilder()
      ..dateValue = anchorDate.dateValue
      ..dateType = anchorDate.dateType;

    blueprint.personDocId = personDocId;
    blueprint.name = name;
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurIteration = recurIteration;
    blueprint.anchorDate = anchorDateBuilder.build();

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
        other.anchorDate.dateValue != anchorDate.dateValue ||
        other.anchorDate.dateType != anchorDate.dateType;
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
        other.anchorDate?.dateValue != anchorDate.dateValue ||
        other.anchorDate?.dateType != anchorDate.dateType;
  }

  static TaskRecurrence fromJson(dynamic json) {
    return serializers.deserializeWith(TaskRecurrence.serializer, json)!;
  }
}