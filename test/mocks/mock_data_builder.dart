
import 'package:taskmaster/models/task_item.dart';

class TaskItemBuilder {
  late int id;
  late String name;
  late String description;
  late String project;
  late String context;
  late int urgency;
  late int priority;
  late int duration;
  late DateTime dateAdded;
  late DateTime startDate;
  late DateTime targetDate;
  late DateTime urgentDate;
  late DateTime dueDate;
  late DateTime completionDate;
  late int gamePoints;
  late int recurNumber;
  late String recurUnit;
  late bool recurWait;
  late int recurrenceId;

  TaskItemBuilder();

  TaskItem create() {
    TaskItem taskItem = new TaskItem();

    taskItem.id.value = id;
    taskItem.name.value = name;
    taskItem.description.value = description;
    taskItem.project.value = project;
    taskItem.context.value = context;
    taskItem.urgency.value = urgency;
    taskItem.priority.value = priority;
    taskItem.duration.value = duration;
    taskItem.dateAdded.value = dateAdded;
    taskItem.startDate.value = startDate;
    taskItem.targetDate.value = targetDate;
    taskItem.urgentDate.value = urgentDate;
    taskItem.dueDate.value = dueDate;
    taskItem.completionDate.value = completionDate;
    taskItem.gamePoints.value = gamePoints;
    taskItem.recurNumber.value = recurNumber;
    taskItem.recurUnit.value = recurUnit;
    taskItem.recurWait.value = recurWait;
    taskItem.recurrenceId.value = recurrenceId;

    taskItem.treatAsCommitted();

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