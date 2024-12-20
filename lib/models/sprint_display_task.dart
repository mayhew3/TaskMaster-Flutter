import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';

mixin SprintDisplayTask implements DateHolder {
  String get docId;
  String get name;

  String? get project;

  @override
  DateTime? get startDate;
  @override
  DateTime? get targetDate;
  @override
  DateTime? get urgentDate;
  @override
  DateTime? get dueDate;
  @override
  DateTime? get completionDate;

  TaskRecurrence? get recurrence;
  @override
  int? get recurIteration;

  @override
  DateTime? getAnchorDate();
  @override
  bool isScheduled();
  @override
  bool isPastDue();
  @override
  bool isCompleted();

  bool isPreview();

  TaskItemRecurPreview createNextRecurPreview({
    required DateTime? startDate,
    required DateTime? targetDate,
    required DateTime? urgentDate,
    required DateTime? dueDate,
  });
}