import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaestro/models/json_datetime_converter.dart';
import 'package:taskmaestro/models/models.dart';
import 'package:taskmaestro/models/task_date_holder.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_recurrence_blueprint.dart';

/// This allows the `TaskItemBlueprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_blueprint.g.dart';


/*
* Blueprints use the JsonSerializable annotation to serialize and deserialize
* instead of the built_value annotation. It's a bit annoying I have to use two
* different serialization frameworks, but I can mix built_value with another
* framework, and blueprints need to be editable, so built and not-built need to
* use different ones.
*
* One key difference to note is how to handle included objects. If the included
* object on a JsonSerializable is ALSO a JsonSerializable, we can just use the
* JsonKey annotation, like the recurrenceBlueprint below. If the included object
* is NOT, however, I need a separate JsonConverter class to handle it (see
* JsonAnchorDateConverter as an example.)
* */

@JsonSerializable(includeIfNull: true, createFactory: false)
class TaskItemBlueprint with DateHolder {

  String? name;
  String? description;
  String? area;

  /// TM-181: multi-context list. Defaults to empty so an unset blueprint
  /// doesn't accidentally serialize the legacy single-string field.
  /// Marshalled by `_TaskContextListConverter` so json_serializable accepts
  /// either a list of `{name, value?}` maps OR a legacy bare string in the
  /// pre-181 `context` slot via the renamed accessor in the converter.
  @_TaskContextListConverter()
  List<TaskContext> contexts = <TaskContext>[];

  int? urgency;
  int? priority;
  /// Scale version for [priority]. See `TaskItem.priorityScaleVersion`.
  /// Nullable on the blueprint (new tasks set it to 2 on save; legacy
  /// tasks copy the existing version through `createBlueprint`).
  ///
  /// `includeIfNull: false` so partial-update writes don't overwrite an
  /// existing Firestore value with null when the screen hasn't touched
  /// the field, and so deserialization into `TaskItem` (whose getter is
  /// non-nullable) doesn't trip on a `null` payload.
  @JsonKey(includeIfNull: false)
  int? priorityScaleVersion;
  int? duration;

  int? gamePoints;

  @override
  @JsonDateTimePassThroughConverter()
  DateTime? startDate;
  @override
  @JsonDateTimePassThroughConverter()
  DateTime? targetDate;
  @override
  @JsonDateTimePassThroughConverter()
  DateTime? dueDate;
  @override
  @JsonDateTimePassThroughConverter()
  DateTime? urgentDate;
  @override
  @JsonDateTimePassThroughConverter()
  DateTime? completionDate;

  bool offCycle = false;

  int? recurNumber;
  String? recurUnit;
  bool? recurWait;

  String? recurrenceDocId;
  @override
  int? recurIteration;

  // No @JsonKey needed: createFactory: false above already suppresses any
  // fromJson handling, so the old `includeFromJson: false` is redundant.
  // Keeping an explicit JsonKey here triggers a json_serializable bug that
  // drops the field from toJson entirely.
  TaskRecurrenceBlueprint? recurrenceBlueprint;

  String? retired;
  DateTime? retiredDate;

  String? personDocId;
  String? familyDocId;

  // TM-342: round-tripped through serialization but not edited by the UI.
  // SyncService stamps this on push with FieldValue.serverTimestamp().
  // includeIfNull:false so legacy `doc.update(blueprint.toJson())` paths
  // (TaskRepository) don't write `lastModified: null` and clobber the
  // server-written timestamp, which would defeat TM-342 conflict detection.
  @JsonKey(includeIfNull: false)
  @JsonDateTimePassThroughConverter()
  DateTime? lastModified;

  @JsonKey(includeToJson: false)
  late int tmpId;

  TaskItemBlueprint() {
    tmpId = Random().nextInt(60000);
  }

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskItemFormToJson`.
  Map<String, dynamic> toJson() => _$TaskItemBlueprintToJson(this);

  bool isScheduledRecurrence() {
    var recurWaitValue = recurWait;
    return recurWaitValue != null && !recurWaitValue;
  }

  void incrementDateIfExists(TaskDateType taskDateType, Duration duration) {
    var dateTime = taskDateType.dateFieldGetter(this);
    taskDateType.dateFieldSetter(this, dateTime?.add(duration));
  }

  bool hasChanges(TaskItem other) {
    // `priorityScaleVersion` is intentionally excluded: it's a non-user-
    // editable internal marker, and the lazy-migration path in the edit
    // screen rewrites the user-visible `priority` value at the same time
    // it bumps the version. Including version here would make a mid-flight
    // migration look like a pending edit and falsely enable the Save
    // button. Source of truth: `TaskItem.hasChanges`.
    var allMismatch = other.name != name ||
        other.description != description ||
        other.area != area ||
        !_taskContextsEqual(other.contexts, contexts) ||
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
        (recurrenceBlueprint == null ? other.recurrence != null : recurrenceBlueprint!.hasChanges(other.recurrence));
    // print("All mismatch: $allMismatch");
    return
      allMismatch;
  }

  bool hasChangesBlueprint(TaskItemBlueprint other) {
    return
      other.name != name ||
          other.description != description ||
          other.area != area ||
          !_taskContextsEqual(other.contexts, contexts) ||
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
          (recurrenceBlueprint == null ? other.recurrenceBlueprint != null : recurrenceBlueprint!.hasChangesBlueprint(other.recurrenceBlueprint));
  }

  @override
  String toString() {
    return 'TaskItemBlueprint{'
        'name: $name';
  }

}

/// Order-sensitive equality for two [TaskContext] lists. Mirror of the
/// helper in `task_item.dart` so the blueprint's hasChanges paths stay in
/// sync with the immutable model's.
bool _taskContextsEqual(
    Iterable<TaskContext>? a, Iterable<TaskContext>? b) {
  final aList = a?.toList() ?? const <TaskContext>[];
  final bList = b?.toList() ?? const <TaskContext>[];
  if (aList.length != bList.length) return false;
  for (var i = 0; i < aList.length; i++) {
    if (aList[i].name != bList[i].name) return false;
    if (aList[i].value != bList[i].value) return false;
  }
  return true;
}

/// JsonConverter that round-trips a `List<TaskContext>` for the blueprint's
/// JsonSerializable layer. Built_value's `TaskContext` doesn't ship a
/// `fromJson`/`toJson` constructor pair compatible with json_serializable,
/// so we hand-roll the conversion. Mirrors [parseTaskContexts] in
/// `core/database/converters.dart` (single source of truth for the legacy
/// bare-string fallback). Behavior:
/// - `fromJson(null)` → empty list (the blueprint's `contexts` field is
///   non-nullable, so null on the wire deserializes as `[]`).
/// - `fromJson(String)` → single-element list (legacy pre-181 Firestore
///   docs whose `context: "Phone"` field slipped past the runtime fallback).
/// - `toJson(list)` → always returns a `List` (possibly empty); never null.
class _TaskContextListConverter
    implements JsonConverter<List<TaskContext>, Object?> {
  const _TaskContextListConverter();

  @override
  List<TaskContext> fromJson(Object? json) {
    if (json == null) return <TaskContext>[];
    if (json is String) {
      // Legacy bare-string Firestore field.
      return [TaskContext.named(json)];
    }
    if (json is List) {
      final out = <TaskContext>[];
      for (final entry in json) {
        if (entry is Map) {
          final name = entry['name'];
          if (name is! String || name.isEmpty) continue;
          final v = entry['value'];
          out.add(TaskContext((b) => b
            ..name = name
            ..value = v is int ? v : (v is num ? v.toInt() : null)));
        } else if (entry is String && entry.isNotEmpty) {
          out.add(TaskContext.named(entry));
        }
      }
      return out;
    }
    return <TaskContext>[];
  }

  @override
  Object? toJson(List<TaskContext> object) {
    return object
        .map((c) => {
              'name': c.name,
              if (c.value != null) 'value': c.value,
            })
        .toList(growable: false);
  }
}