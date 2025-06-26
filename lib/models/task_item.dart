

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/sprint_display_task_recurrence.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';

/// This allows the `TaskItem` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

abstract class TaskItem with DateHolder, SprintDisplayTask implements Built<TaskItem, TaskItemBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskItem> get serializer => _$taskItemSerializer;

  @override
  String get docId;
  DateTime get dateAdded;

  String? get personDocId;

  @override
  String get name;

  String? get description;
  @override
  String? get project;
  String? get context;

  int? get urgency;
  int? get priority;
  int? get duration;

  int? get gamePoints;

  @override
  DateTime? get startDate;
  @override
  DateTime? get targetDate;
  @override
  DateTime? get dueDate;
  @override
  DateTime? get urgentDate;
  @override
  DateTime? get completionDate;

  int? get recurNumber;
  String? get recurUnit;
  bool? get recurWait;

  String? get recurrenceDocId;
  @override
  int? get recurIteration;

  String? get retired;
  DateTime? get retiredDate;

  bool get offCycle;

  @override
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
    blueprint.personDocId = personDocId;
    blueprint.recurNumber = recurNumber;
    blueprint.recurUnit = recurUnit;
    blueprint.recurWait = recurWait;
    blueprint.recurrenceDocId = recurrenceDocId;
    blueprint.recurIteration = recurIteration;

    blueprint.recurrenceBlueprint = recurrence?.createBlueprint();

    return blueprint;
  }

  @override
  bool isPreview() {
    return false;
  }

  @override
  TaskItemRecurPreview createNextRecurPreview({
    required Map<TaskDateType, DateTime> dates,
  }) {

    return TaskItemRecurPreview((b) => b
      ..docId = 'ASKLJDH'
      ..personDocId = personDocId
      ..name = name
      ..description = description
      ..project = project
      ..context = context
      ..urgency = urgency
      ..priority = priority
      ..duration = duration
      ..startDate = dates[TaskDateTypes.start]
      ..targetDate = dates[TaskDateTypes.target]
      ..urgentDate = dates[TaskDateTypes.urgent]
      ..dueDate = dates[TaskDateTypes.due]
      ..gamePoints = gamePoints
      ..recurNumber = recurNumber
      ..recurUnit = recurUnit
      ..recurWait = recurWait
      ..recurrenceDocId = recurrenceDocId
      ..recurIteration = recurIteration! + 1
      ..recurrence = recurrence!.createBlueprint()
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
          other.recurrenceDocId != recurrenceDocId ||
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
          other.recurrenceDocId != recurrenceDocId ||
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