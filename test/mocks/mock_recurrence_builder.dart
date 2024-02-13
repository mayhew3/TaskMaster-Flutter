import 'package:taskmaster/models/task_recurrence.dart';

class TaskRecurrenceBuilder {
  int? id;
  late String name;
  late int recurNumber;
  late String recurUnit;
  late bool recurWait;
  late int recurIteration;
  late DateTime anchorDate;
  late String anchorType;

  TaskRecurrenceBuilder();

  TaskRecurrence create() {
    TaskRecurrence taskRecurrence = new TaskRecurrence(
        id: id!,
        personId: 1,
        name: name,
        recurNumber: recurNumber,
        recurUnit: recurUnit,
        recurWait: recurWait,
        recurIteration: recurIteration,
        anchorDate: anchorDate,
        anchorType: anchorType
    );
    return taskRecurrence;
  }

  factory TaskRecurrenceBuilder.asPreCommit() {
    return TaskRecurrenceBuilder()
      ..name = 'Test Recurrence'
      ..recurNumber = 6
      ..recurIteration = 1
      ..recurUnit = 'Weeks'
      ..recurWait = false
      ..anchorDate = DateTime.now()
      ..anchorType = 'target'
    ;
  }

  factory TaskRecurrenceBuilder.asDefault() {
    return TaskRecurrenceBuilder.asPreCommit()
        ..id = 1;
  }
}