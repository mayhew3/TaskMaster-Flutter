
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';

/// This allows the `TaskItem` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

abstract class TaskItem with DateHolder, SprintDisplayTask implements Built<TaskItem, TaskItemBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskItem> get serializer => _$taskItemSerializer;

  int get id;
  String? get docId;

  int get personId;
  String? get personDocId;

  String get name;

  String? get description;
  String? get project;
  String? get context;

  int? get urgency;
  int? get priority;
  int? get duration;

  int? get gamePoints;

  DateTime? get startDate;
  DateTime? get targetDate;
  DateTime? get dueDate;
  DateTime? get urgentDate;
  DateTime? get completionDate;

  int? get recurNumber;
  String? get recurUnit;
  bool? get recurWait;

  int? get recurrenceId;
  String? get recurrenceDocId;
  int? get recurIteration;

  bool get offCycle;

  BuiltList<SprintAssignment> get sprintAssignments;

  TaskRecurrence? get recurrence;

  // internal fields
  @BuiltValueField(serialize: false)
  bool get pendingCompletion;

  TaskItem._();
  factory TaskItem([Function(TaskItemBuilder) updates]) = _$TaskItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(TaskItemBuilder b) =>
      b
        ..pendingCompletion = false;

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  TaskItemBlueprint createBlueprint() {
    TaskItemBlueprint blueprint = TaskItemBlueprint();

    blueprint.name = name;
    blueprint.description = description;
    blueprint.project = project;
    blueprint.context = context;
    blueprint.urgency = urgency;
    blueprint.priority = priority;
    blueprint.duration = duration;
    blueprint.startDate = startDate;
    blueprint.targetDate = targetDate;
    blueprint.dueDate = dueDate;
    blueprint.urgentDate = urgentDate;
    blueprint.gamePoints = gamePoints;
    blueprint.offCycle = offCycle;
    blueprint.personId = personId;
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurrenceId = recurrenceId;
    blueprint.recurIteration = recurIteration;

    // blueprint.taskRecurrenceBlueprint = TaskRecurrenceBlueprint();

    return blueprint;
  }

  bool isPreview() {
    return false;
  }

  TaskItemRecurPreview createNextRecurPreview({
    required DateTime? startDate,
    required DateTime? targetDate,
    required DateTime? urgentDate,
    required DateTime? dueDate,
  }) {
    return TaskItemRecurPreview((b) => b
      ..id = 0 - new Random().nextInt(60000)
      ..personId = personId
      ..name = name
      ..description = description
      ..project = project
      ..context = context
      ..urgency = urgency
      ..priority = priority
      ..duration = duration
      ..startDate = startDate
      ..targetDate = targetDate
      ..urgentDate = urgentDate
      ..dueDate = dueDate
      ..gamePoints = gamePoints
      ..personId = personId
      ..recurNumber = recurNumber
      ..recurUnit = recurUnit
      ..recurWait = recurWait
      ..recurrenceId = recurrenceId
      ..recurIteration = this.recurIteration! + 1
      ..recurrence = recurrence!.toBuilder()
      ..offCycle = offCycle
    );
  }

  bool hasChanges(TaskItem other) {
    return
      other.name != name ||
          other.description != description ||
          other.project != project ||
          other.context != context ||
          other.urgency != urgency ||
          other.priority != priority ||
          other.duration != duration ||
          other.gamePoints != gamePoints ||
          other.startDate != startDate ||
          other.targetDate != targetDate ||
          other.dueDate != dueDate ||
          other.urgentDate != urgentDate ||
          other.completionDate != completionDate ||
          other.offCycle != offCycle ||
          other.recurNumber != recurNumber ||
          other.recurUnit != recurUnit ||
          other.recurWait != recurWait ||
          other.recurrenceId != recurrenceId ||
          other.recurIteration != recurIteration ||
          (recurrence == null ? other.recurrence != null : recurrence!.hasChanges(other.recurrence));
  }

  bool hasChangesBlueprint(TaskItemBlueprint other) {
    return
      other.name != name ||
          other.description != description ||
          other.project != project ||
          other.context != context ||
          other.urgency != urgency ||
          other.priority != priority ||
          other.duration != duration ||
          other.gamePoints != gamePoints ||
          other.startDate != startDate ||
          other.targetDate != targetDate ||
          other.dueDate != dueDate ||
          other.urgentDate != urgentDate ||
          other.completionDate != completionDate ||
          other.offCycle != offCycle ||
          other.recurNumber != recurNumber ||
          other.recurUnit != recurUnit ||
          other.recurWait != recurWait ||
          other.recurrenceId != recurrenceId ||
          other.recurIteration != recurIteration ||
          (recurrence == null ? other.recurrenceBlueprint != null : recurrence!.hasChangesBlueprint(other.recurrenceBlueprint));
  }

  dynamic toJson() {
    return serializers.serializeWith(TaskItem.serializer, this);
  }

  static TaskItem fromJson(dynamic json) {
    return serializers.deserializeWith(TaskItem.serializer, json)!;
  }
}