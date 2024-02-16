import '../../models/models.dart';

class LoadTasksAction {}

class TasksNotLoadedAction {}

class TasksLoadedAction {
  final List<ReduxTaskItem> taskItems;

  TasksLoadedAction(this.taskItems);

  @override
  String toString() {
    return 'TasksLoadedAction{taskItems: $taskItems}';
  }
}

class UpdateTaskAction {
  final int id;
  final ReduxTaskItem updatedTaskItem;

  UpdateTaskAction(this.id, this.updatedTaskItem);

  @override
  String toString() {
    return 'UpdateTaskAction{id: $id, updatedTaskItem: $updatedTaskItem}';
  }
}