
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';

import 'mock_recurrence_builder.dart';

class MockTaskItemBuilder with DateHolder {
  int? id;
  late String name;
  late String description;
  late String project;
  late String context;
  late int urgency;
  late int priority;
  late int duration;
  late DateTime dateAdded;
  DateTime? startDate;
  DateTime? targetDate;
  DateTime? urgentDate;
  DateTime? dueDate;
  DateTime? completionDate;
  late bool offCycle;
  late int gamePoints;
  int? recurNumber;
  String? recurUnit;
  bool? recurWait;
  int? recurIteration;
  int? recurrenceId;

  MockTaskRecurrenceBuilder? taskRecurrence;

  MockTaskItemBuilder();

  TaskItemBlueprint createBlueprint() {

    if (id != null) {
      throw Exception('Cannot create blueprint with id. Use create() instead.');
    }

    TaskItemBlueprint taskItem = new TaskItemBlueprint();

    taskItem.name = name;
    taskItem.description = description;
    taskItem.project = project;
    taskItem.context = context;
    taskItem.urgency = urgency;
    taskItem.priority = priority;
    taskItem.duration = duration;
    taskItem.startDate = startDate;
    taskItem.targetDate = targetDate;
    taskItem.urgentDate = urgentDate;
    taskItem.dueDate = dueDate;
    taskItem.offCycle = offCycle;
    taskItem.gamePoints = gamePoints;
    taskItem.recurNumber = recurNumber;
    taskItem.recurUnit = recurUnit;
    taskItem.recurWait = recurWait;
    taskItem.recurIteration = recurIteration;
    taskItem.recurrenceId = recurrenceId;

    return taskItem;
  }

  TaskItem create() {

    if (id == null) {
      throw Exception('Cannot create task item without id. Use createBlueprint() instead.');
    }

    var taskItemBuilder = new TaskItemBuilder()
      ..id = id!
      ..personId = 1
      ..name = name
      ..description = description
      ..project = project
      ..context = context
      ..urgency = urgency
      ..priority = priority
      ..duration = duration
      ..gamePoints = gamePoints
      ..startDate = startDate
      ..targetDate = targetDate
      ..urgentDate = urgentDate
      ..dueDate = dueDate
      ..completionDate = completionDate
      ..offCycle = offCycle
      ..recurNumber = recurNumber
      ..recurUnit = recurUnit
      ..recurWait = recurWait
      ..recurIteration = recurIteration
      ..recurrenceId = recurrenceId
      ..recurrence = taskRecurrence?.create().toBuilder()
    ;

    var taskItem = taskItemBuilder.build();

    return taskItem;
  }

  factory MockTaskItemBuilder.asPreCommit() {
    return MockTaskItemBuilder()
      ..name = 'Test Task'
      ..project = 'Maintenance'
      ..description = 'A thing for me to do.'
      ..context = 'Home'
      ..urgency = 3
      ..priority = 5
      ..duration = 15
      ..dateAdded = DateTime.now()
      ..offCycle = false
      ..gamePoints = 1;
  }

  factory MockTaskItemBuilder.asDefault() {
    return MockTaskItemBuilder.asPreCommit()
      ..id = 1;
  }

  factory MockTaskItemBuilder.withDates() {
    var now = DateTime.now();
    return MockTaskItemBuilder.asDefault()
        ..startDate = now.subtract(Duration(days: 4))
        ..targetDate = now.add(Duration(days: 1))
        ..urgentDate = now.add(Duration(days: 5))
        ..dueDate = now.add(Duration(days: 8));
  }

  MockTaskItemBuilder asCompleted() {
    completionDate = DateTime.now();
    return this;
  }

  MockTaskItemBuilder withRecur({bool recurWait = true}) {
    recurrenceId = 1;
    recurNumber = 6;
    recurIteration = 1;
    recurUnit = 'Weeks';
    this.recurWait = recurWait;

    taskRecurrence = new MockTaskRecurrenceBuilder()
      ..id = 1
      ..name = name
      ..recurNumber = recurNumber!
      ..recurUnit = recurUnit!
      ..recurWait = recurWait
      ..recurIteration = recurIteration!
      ..anchorDate = getAnchorDate()!
      ..anchorType = getAnchorDateType()!.label
    ;

    return this;
  }

}