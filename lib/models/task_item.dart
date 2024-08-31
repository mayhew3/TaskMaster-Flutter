
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/task_date_holder.dart';

/// This allows the `TaskItem` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'task_item.g.dart';

abstract class TaskItem with DateHolder implements Built<TaskItem, TaskItemBuilder> {
  static Serializer<TaskItem> get serializer => _$taskItemSerializer;

  int get id;
  int get personId;

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

  @BuiltValueField(serialize: false)
  bool get pendingCompletion;

  int? get recurNumber;
  String? get recurUnit;
  bool? get recurWait;

  int? get recurrenceId;
  int? get recurIteration;

  bool get offCycle;

  TaskItem._();
  factory TaskItem([Function(TaskItemBuilder) updates]) = _$TaskItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(TaskItemBuilder b) =>
      b
        ..pendingCompletion = false;

  bool isCompleted() {
    return this.completionDate != null;
  }
}
