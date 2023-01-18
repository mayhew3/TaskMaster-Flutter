
import 'package:taskmaster/models/task_item.dart';

class TaskItemBuilder {
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
  int? recurrenceId;

  TaskItemBuilder();

  TaskItem create() {
    TaskItem taskItem = new TaskItem(personId: 1);

    taskItem.id = id;
    taskItem.name = name;
    taskItem.description = description;
    taskItem.project = project;
    taskItem.context = context;
    taskItem.urgency = urgency;
    taskItem.priority = priority;
    taskItem.duration = duration;
    taskItem.dateAdded = dateAdded;
    taskItem.startDate = startDate;
    taskItem.targetDate = targetDate;
    taskItem.urgentDate = urgentDate;
    taskItem.dueDate = dueDate;
    taskItem.completionDate = completionDate;
    taskItem.gamePoints = gamePoints;
    taskItem.recurNumber = recurNumber;
    taskItem.recurUnit = recurUnit;
    taskItem.recurWait = recurWait;
    taskItem.recurrenceId = recurrenceId;

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
}