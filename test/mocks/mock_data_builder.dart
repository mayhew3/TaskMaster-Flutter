
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';

import 'mock_recurrence_builder.dart';

class MockTaskItemBuilder with DateHolder {

  static const String me = 'ADBC1234';

  String? docId;
  late String name;
  late String description;
  late String project;
  late String context;
  late int urgency;
  late int priority;
  late int duration;
  late DateTime dateAdded;
  @override
  DateTime? startDate;
  @override
  DateTime? targetDate;
  @override
  DateTime? urgentDate;
  @override
  DateTime? dueDate;
  @override
  DateTime? completionDate;
  late bool _offCycle;
  late int gamePoints;
  int? recurNumber;
  String? recurUnit;
  bool? recurWait;
  @override
  int? recurIteration;
  String? recurrenceDocId;

  MockTaskRecurrenceBuilder? taskRecurrence;

  MockTaskItemBuilder();

  TaskItemBlueprint createBlueprint() {

    if (docId != null) {
      throw Exception('Cannot create blueprint with docId. Use create() instead.');
    }

    TaskItemBlueprint taskItem = TaskItemBlueprint();

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
    taskItem.offCycle = _offCycle;
    taskItem.gamePoints = gamePoints;
    taskItem.recurNumber = recurNumber;
    taskItem.recurUnit = recurUnit;
    taskItem.recurWait = recurWait;
    taskItem.recurIteration = recurIteration;
    taskItem.recurrenceDocId = recurrenceDocId;

    return taskItem;
  }

  TaskItem create() {

    if (docId == null) {
      throw Exception('Cannot create task item without docId. Use createBlueprint() instead.');
    }

    var taskItemBuilder = TaskItemBuilder()
      ..docId = docId!
      ..dateAdded = DateTime.now().toUtc()
      ..personDocId = me
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
      ..offCycle = _offCycle
      ..recurNumber = recurNumber
      ..recurUnit = recurUnit
      ..recurWait = recurWait
      ..recurIteration = recurIteration
      ..recurrenceDocId = recurrenceDocId
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
      .._offCycle = false
      ..gamePoints = 1;
  }

  factory MockTaskItemBuilder.asDefault() {
    return MockTaskItemBuilder.asPreCommit()
      ..docId = me
      ..dateAdded = DateTime.now()
    ;
  }

  factory MockTaskItemBuilder.withDates({bool offCycle = false, int daysOffset = 0,}) {
    return MockTaskItemBuilder.asDefault()
        ..startDate = DateUtil.nowUtcWithoutMillis().subtract(Duration(days: 4 - daysOffset, hours: 5))
        ..targetDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 1 + daysOffset, hours: 5))
        ..urgentDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 5 + daysOffset, hours: 6))
        ..dueDate = DateUtil.nowUtcWithoutMillis().add(Duration(days: 8 + daysOffset, hours: 8))
        .._offCycle = offCycle;
  }

  MockTaskItemBuilder asCompleted() {
    completionDate = DateTime.now();
    return this;
  }

  MockTaskItemBuilder withRecur({bool recurWait = true, int anchorOffsetInDays = 0}) {
    recurrenceDocId = MockTaskItemBuilder.me;
    recurNumber = 6;
    recurIteration = 1;
    recurUnit = 'Weeks';
    this.recurWait = recurWait;

    taskRecurrence = MockTaskRecurrenceBuilder()
      ..docId = me
      ..name = name
      ..recurNumber = recurNumber!
      ..recurUnit = recurUnit!
      ..recurWait = recurWait
      ..recurIteration = recurIteration!
      ..anchorDate = getAnchorDate()!.add(Duration(days: anchorOffsetInDays))
      ..anchorType = getAnchorDateType()!.label
    ;

    if (_offCycle) {
      dueDate = dueDate!.add(Duration(days: 5));
    }

    return this;
  }

}