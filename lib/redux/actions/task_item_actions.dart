import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/top_nav_item.dart';

import '../../models/data_payload.dart';
import '../../models/models.dart';
import '../../models/task_date_type.dart';

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

class TaskItemUpdatedAction {
  final TaskItem updatedTaskItem;

  TaskItemUpdatedAction(this.updatedTaskItem);
}

class CompleteTaskItemAction {
  final TaskItem taskItem;
  final bool complete;

  CompleteTaskItemAction(this.taskItem, this.complete);
}

class TaskItemCompletedAction {
  final TaskItem taskItem;
  final bool complete;

  TaskItemCompletedAction(this.taskItem, this.complete);
}

class RecurringTaskItemCompletedAction {
  final TaskItem completedTaskItem;
  final TaskItem addedTaskItem;
  final TaskRecurrence recurrence;
  final bool complete;

  RecurringTaskItemCompletedAction(this.completedTaskItem, this.addedTaskItem, this.recurrence, this.complete);
}

class DeleteTaskItemAction {
  final TaskItem taskItem;

  DeleteTaskItemAction(this.taskItem);

  @override
  String toString() {
    return 'DeleteTaskItemAction{taskItem: $taskItem}';
  }
}

class TaskItemDeletedAction {
  final int deletedTaskId;

  TaskItemDeletedAction(this.deletedTaskId);
}

class AddTaskItemAction {
  final TaskItemBlueprint blueprint;

  AddTaskItemAction({required this.blueprint});

  @override
  String toString() {
    return 'AddTaskItemAction{blueprint: $blueprint}';
  }
}

class TaskItemAddedAction {
  final TaskItem taskItem;
  final TaskRecurrence? taskRecurrence;

  TaskItemAddedAction({required this.taskItem, required this.taskRecurrence});

  @override
  String toString() {
    return 'TaskItemAdded{taskItem: $taskItem}';
  }
}

class ClearRecentlyCompletedAction {}

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

class ToggleTaskListShowCompletedAction {}

class ToggleTaskListShowScheduledAction {}

class ToggleSprintListShowCompletedAction {}

class ToggleSprintListShowScheduledAction {}

class UpdateTabAction {
  final TopNavItem newTab;

  UpdateTabAction(this.newTab);

  @override
  String toString() {
    return 'UpdateTabAction{newTab: $newTab}';
  }
}

class InitTimezoneHelperAction {}

class ExecuteSnooze {
  final TaskItem taskItem;
  final TaskItemBlueprint blueprint;
  final int numUnits;
  final String unitSize;
  final TaskDateType dateType;
  final bool offCycle;

  ExecuteSnooze({
    required this.taskItem,
    required this.blueprint,
    required this.numUnits,
    required this.unitSize,
    required this.dateType,
    required this.offCycle
  });
}

class SnoozeExecuted {
  final TaskItem taskItem;

  SnoozeExecuted(this.taskItem);
}