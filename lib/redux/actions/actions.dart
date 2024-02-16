import '../../models/models.dart';

class LoadTasksAction {}

class TasksNotLoadedAction {}

class TasksLoadedAction {
  final List<TaskItem> taskItems;

  TasksLoadedAction(this.taskItems);

  @override
  String toString() {
    return 'TasksLoadedAction{taskItems: $taskItems}';
  }
}

class UpdateTaskAction {
  final int id;
  final TaskItem updatedTaskItem;

  UpdateTaskAction(this.id, this.updatedTaskItem);

  @override
  String toString() {
    return 'UpdateTaskAction{id: $id, updatedTaskItem: $updatedTaskItem}';
  }
}