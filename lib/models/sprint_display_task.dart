import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';

mixin SprintDisplayTask implements DateHolder {
  int get id;
  String get name;

  String? get project;

  DateTime? get startDate;
  DateTime? get targetDate;
  DateTime? get urgentDate;
  DateTime? get dueDate;
  DateTime? get completionDate;

  TaskRecurrence? get recurrence;
  int? get recurIteration;

  BuiltList<SprintAssignment> get sprintAssignments;

  DateTime? getAnchorDate();
  bool isScheduled();
  bool isPastDue();
  bool isCompleted();

  bool isPreview();

  TaskItemRecurPreview createNextRecurPreview({
    required DateTime? startDate,
    required DateTime? targetDate,
    required DateTime? urgentDate,
    required DateTime? dueDate,
  });
}