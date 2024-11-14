
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/task_date_holder.dart';

/// This allows the `TaskItemRecurPreview` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item_recur_preview.g.dart';

abstract class TaskItemRecurPreview with DateHolder, SprintDisplayTask implements Built<TaskItemRecurPreview, TaskItemRecurPreviewBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<TaskItemRecurPreview> get serializer => _$taskItemRecurPreviewSerializer;

  @BuiltValueField(serialize: false)
  String get docId;

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

  String? get retired;
  DateTime? get retiredDate;

  String? get recurrenceDocId;

  int? get recurIteration;

  bool get offCycle;

  BuiltList<SprintAssignment> get sprintAssignments;

  TaskRecurrence? get recurrence;

  TaskItemRecurPreview._();
  factory TaskItemRecurPreview([Function(TaskItemRecurPreviewBuilder) updates]) = _$TaskItemRecurPreview;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(TaskItemRecurPreviewBuilder b) =>
      b
        ..docId = (0 - new Random().nextInt(60000)).toString()
  ;

  TaskItemRecurPreview createNextRecurPreview({
    required DateTime? startDate,
    required DateTime? targetDate,
    required DateTime? urgentDate,
    required DateTime? dueDate,
  }) {
    return this.rebuild((t) => t
      ..startDate = startDate
      ..targetDate = targetDate
      ..urgentDate = urgentDate
      ..dueDate = dueDate
      ..recurIteration = t.recurIteration! + 1
    );
  }

  bool isPreview() {
    return true;
  }

}
