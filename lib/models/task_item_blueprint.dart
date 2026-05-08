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
  String? context;

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
    var allMismatch = other.name != name ||
        other.description != description ||
        other.area != area ||
        other.context != context ||
        other.urgency != urgency ||
        other.priority != priority ||
        other.priorityScaleVersion != priorityScaleVersion ||
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
          (recurrenceBlueprint == null ? other.recurrenceBlueprint != null : recurrenceBlueprint!.hasChangesBlueprint(other.recurrenceBlueprint));
  }

  @override
  String toString() {
    return 'TaskItemBlueprint{'
        'name: $name';
  }

}