
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';

class TaskItemBuilder extends DateHolder {
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
  late int gamePoints;
  int? recurNumber;
  String? recurUnit;
  bool? recurWait;
  int? recurIteration;
  int? recurrenceId;

  TaskRecurrence? taskRecurrence;

  TaskItemBuilder();

  TaskItemBlueprint createBlueprint() {
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
    taskItem.gamePoints = gamePoints;
    taskItem.recurNumber = recurNumber;
    taskItem.recurUnit = recurUnit;
    taskItem.recurWait = recurWait;
    taskItem.recurIteration = recurIteration;
    taskItem.recurrenceId = recurrenceId;

    return taskItem;
  }

  TaskItem create() {
    TaskItem taskItem = new TaskItem(
      id: id!,
      personId: 1,
      name: name,
      description: description,
      project: project,
      context: context,
      urgency: urgency,
      priority: priority,
      duration: duration,
      gamePoints: gamePoints,
      startDate: startDate,
      targetDate: targetDate,
      urgentDate: urgentDate,
      dueDate: dueDate,
      completionDate: completionDate,
      recurNumber: recurNumber,
      recurUnit: recurUnit,
      recurWait: recurWait,
      recurIteration: recurIteration,
      recurrenceId: recurrenceId,
    );

    TaskRecurrence? tmpTaskRecurrence = taskRecurrence;
    if (tmpTaskRecurrence != null) {
      tmpTaskRecurrence.addToTaskItems(taskItem);
    }

    return taskItem;
  }

  factory TaskItemBuilder.asPreCommit() {
    return TaskItemBuilder()
      ..name = 'Test Task'
      ..project = 'Maintenance'
      ..description = 'A thing for me to do.'
      ..context = 'Home'
      ..urgency = 3
      ..priority = 5
      ..duration = 15
      ..dateAdded = DateTime.now()
      ..gamePoints = 1;
  }

  factory TaskItemBuilder.asDefault() {
    return TaskItemBuilder.asPreCommit()
      ..id = 1;
  }

  factory TaskItemBuilder.withDates() {
    var now = DateTime.now();
    return TaskItemBuilder.asDefault()
        ..startDate = now.subtract(Duration(days: 4))
        ..targetDate = now.add(Duration(days: 1))
        ..urgentDate = now.add(Duration(days: 5))
        ..dueDate = now.add(Duration(days: 8));
  }

  TaskItemBuilder asCompleted() {
    completionDate = DateTime.now();
    return this;
  }

  TaskItemBuilder withRecur({bool recurWait = true}) {
    recurrenceId = 1;
    recurNumber = 6;
    recurIteration = 1;
    recurUnit = 'Weeks';
    this.recurWait = recurWait;

    taskRecurrence = new TaskRecurrence(
        id: 1,
        personId: 1,
        name: name,
        recurNumber: recurNumber!,
        recurUnit: recurUnit!,
        recurWait: recurWait,
        recurIteration: recurIteration!,
        anchorDate: getAnchorDate()!,
        anchorType: getAnchorDateType()!.label);

    return this;
  }

}