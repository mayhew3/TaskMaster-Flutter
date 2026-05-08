

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaestro/models/models.dart';
import 'package:taskmaestro/models/serializers.dart';
import 'package:taskmaestro/models/sprint_display_task.dart';
import 'package:taskmaestro/models/task_date_holder.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_item_blueprint.dart';
import 'package:taskmaestro/models/task_item_recur_preview.dart';

/// This allows the `TaskItem` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

abstract class TaskItem with DateHolder, SprintDisplayTask implements Built<TaskItem, TaskItemBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskItem> get serializer => _$taskItemSerializer;

  String get docId;
  DateTime get dateAdded;

  String? get personDocId;
  String? get familyDocId;

  @override
  String get name;

  String? get description;
  @override
  String? get area;
  String? get context;

  int? get urgency;
  int? get priority;
  /// Scale version for [priority]. Both versions normalize to a 1–5
  /// display via [displayPriority]; null / non-positive values mean
  /// "unset" on either scale.
  ///   - 1 = legacy 1–10 stored values, mapped to 1–5 via
  ///     `(priority/2).round().clamp(1,5)`.
  ///   - 2 = TM-358 onward, [priority] is stored directly on the 1–5
  ///     scale and rendered unchanged.
  /// Default is 1 (legacy) for backwards compatibility with rows hydrated
  /// before this field existed; new tasks created from the redesigned edit
  /// screen save with version 2.
  int get priorityScaleVersion;
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
  bool? get recurWait; // true = On Complete

  String? get recurrenceDocId;
  @override
  int? get recurIteration;

  String? get retired;
  DateTime? get retiredDate;

  bool get offCycle;
  bool get skipped;

  /// Last modification timestamp written by Firestore via
  /// `FieldValue.serverTimestamp()`. Used by the sync layer to detect
  /// concurrent edits before pushing pending writes (TM-342).
  DateTime? get lastModified;

  @override
  @BuiltValueField(serialize: false)
  TaskRecurrence? get recurrence;

  // internal fields
  @BuiltValueField(serialize: false)
  bool get pendingCompletion;

  TaskItem._();
  factory TaskItem([Function(TaskItemBuilder) updates]) = _$TaskItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(TaskItemBuilder b) =>
      b
        ..pendingCompletion = false
        ..skipped = false
        ..priorityScaleVersion = 1;

  /// Priority value normalized to the 1–5 display scale. Returns `null`
  /// if [priority] is null *or* non-positive (legacy data sometimes carried
  /// 0 / negative as a sentinel for "unset"). For [priorityScaleVersion] ==
  /// 1 (legacy 1–10 data), applies `(priority/2).round().clamp(1,5)`; for
  /// version ≥ 2, returns [priority] clamped to the same 1..5 envelope so
  /// out-of-range stored values (e.g. a corrupted 6+) can never produce an
  /// out-of-range fill count in the UI. Both cards and the redesigned edit
  /// screen read from this getter so they agree on what to render
  /// regardless of the underlying scale.
  int? get displayPriority {
    if (priority == null) return null;
    final p = priority!;
    if (p <= 0) return null;
    if (priorityScaleVersion >= 2) return p.clamp(1, 5);
    return (p / 2).round().clamp(1, 5);
  }

  DateTime? getFinishedCompletionDate() {
    return pendingCompletion ? null : completionDate;
  }

  @override
  String getSprintDisplayTaskKey() {
    return docId;
  }

  TaskItemBlueprint createBlueprint() {
    TaskItemBlueprint blueprint = TaskItemBlueprint();

    blueprint.name = name;
    blueprint.description = description;
    blueprint.area = area;
    blueprint.context = context;
    blueprint.urgency = urgency;
    blueprint.priority = priority;
    blueprint.priorityScaleVersion = priorityScaleVersion;
    blueprint.duration = duration;
    blueprint.startDate = startDate;
    blueprint.targetDate = targetDate;
    blueprint.dueDate = dueDate;
    blueprint.urgentDate = urgentDate;
    blueprint.gamePoints = gamePoints;
    blueprint.offCycle = offCycle;
    blueprint.personDocId = personDocId;
    blueprint.familyDocId = familyDocId;
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

    return new TaskItemRecurPreview(name)
      ..personDocId = personDocId
      ..familyDocId = familyDocId
      ..name = name
      ..description = description
      ..area = area
      ..context = context
      ..urgency = urgency
      ..priority = priority
      ..priorityScaleVersion = priorityScaleVersion
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
    ;
  }

  bool hasChanges(TaskItem other) {
    // `priorityScaleVersion` is intentionally excluded: it's a non-user-
    // editable internal marker, and the lazy-migration path in the edit
    // screen rewrites the user-visible `priority` value at the same time
    // it bumps the version. Including version here would make a mid-flight
    // migration look like a pending edit and falsely enable the Save
    // button. See `TaskAddEditScreen._initializeTask`.
    return
      other.name != name ||
          other.description != description ||
          other.area != area ||
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
    // See `hasChanges` — `priorityScaleVersion` is intentionally excluded.
    return
      other.name != name ||
          other.description != description ||
          other.area != area ||
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