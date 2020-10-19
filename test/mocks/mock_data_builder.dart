
import 'package:taskmaster/models/task_item.dart';

class TaskItemBuilder {
  int id;
  String name;
  String description;
  String project;
  String context;
  int urgency;
  int priority;
  int duration;
  DateTime dateAdded;
  DateTime startDate;
  DateTime targetDate;
  DateTime urgentDate;
  DateTime dueDate;
  DateTime completionDate;
  int gamePoints;
  int recurNumber;
  String recurUnit;
  bool recurWait;
  int recurrenceId;

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

  factory TaskItemBuilder.asDefault() {
    return TaskItemBuilder()
      ..id = 1
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

  factory TaskItemBuilder.withDates() {
    var now = DateTime.now();
    return TaskItemBuilder.asDefault()
        ..startDate = now.subtract(Duration(days: 4))
        ..targetDate = now.add(Duration(days: 1))
        ..urgentDate = now.add(Duration(days: 5))
        ..dueDate = now.add(Duration(days: 8));
  }
}