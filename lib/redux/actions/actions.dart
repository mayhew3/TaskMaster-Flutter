import '../../models/models.dart';

class LoadTaskItemsAction {}

class TaskItemsNotLoadedAction {}

class TaskItemsLoadedAction {
  final List<TaskItem> taskItems;

  TaskItemsLoadedAction(this.taskItems);

  @override
  String toString() {
    return 'TaskItemsLoadedAction{taskItems: $taskItems}';
  }
}

class UpdateTaskItemAction {
  final TaskItem updatedTaskItem;

  UpdateTaskItemAction(this.updatedTaskItem);

  @override
  String toString() {
    return 'UpdateTaskItemAction{updatedTaskItem: $updatedTaskItem}';
  }
}

class DeleteTaskItemAction {
  final int id;

  DeleteTaskItemAction(this.id);

  @override
  String toString() {
    return 'DeleteTaskItemAction{id: $id}';
  }
}

class AddTaskItemAction {
  final TaskItem taskItem;

  AddTaskItemAction(this.taskItem);

  @override
  String toString() {
    return 'AddTaskItemAction{taskItem: $taskItem}';
  }
}

class UpdateSprintFilterAction {
  final VisibilityFilter newFilter;

  UpdateSprintFilterAction(this.newFilter);

  @override
  String toString() {
    return 'UpdateSprintFilterAction{newFilter: $newFilter}';
  }
}

class UpdateTaskFilterAction {
  final VisibilityFilter newFilter;

  UpdateTaskFilterAction(this.newFilter);

  @override
  String toString() {
    return 'UpdateTaskFilterAction{newFilter: $newFilter}';
  }
}

class ToggleTaskListShowCompleted {}

class ToggleTaskListShowScheduled {}

class UpdateTabAction {
  final AppTab newTab;

  UpdateTabAction(this.newTab);

  @override
  String toString() {
    return 'UpdateTabAction{newTab: $newTab}';
  }
}
