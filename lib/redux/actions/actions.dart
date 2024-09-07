import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/top_nav_item.dart';

import '../../models/data_payload.dart';
import '../../models/models.dart';

class LoadDataAction {}

class DataNotLoadedAction {}

class DataLoadedAction {
  final DataPayload dataPayload;

  DataLoadedAction({required this.dataPayload});

  @override
  String toString() {
    return 'DataLoadedAction{dataPayload: $dataPayload}';
  }
}

class UpdateTaskItemAction {
  final TaskItem taskItem;
  final TaskItemBlueprint blueprint;

  UpdateTaskItemAction({required this.taskItem, required this.blueprint});

  @override
  String toString() {
    return 'UpdateTaskItemAction{taskItem: $taskItem, blueprint: $blueprint}';
  }
}

class TaskItemUpdated {
  final TaskItem updatedTaskItem;

  TaskItemUpdated(this.updatedTaskItem);
}

class CompleteTaskItemAction {
  final TaskItem taskItem;
  final bool complete;

  CompleteTaskItemAction(this.taskItem, this.complete);
}

class TaskItemCompleted {
  final TaskItem taskItem;
  final bool complete;

  TaskItemCompleted(this.taskItem, this.complete);
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
  final TaskItemBlueprint blueprint;

  AddTaskItemAction({required this.blueprint});

  @override
  String toString() {
    return 'AddTaskItemAction{blueprint: $blueprint}';
  }
}

class TaskItemAdded {
  final TaskItem taskItem;

  TaskItemAdded({required this.taskItem});

  @override
  String toString() {
    return 'TaskItemAdded{taskItem: $taskItem}';
  }
}

class ClearRecentlyCompleted {}

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
  final TopNavItem newTab;

  UpdateTabAction(this.newTab);

  @override
  String toString() {
    return 'UpdateTabAction{newTab: $newTab}';
  }
}

class InitTimezoneHelper {}