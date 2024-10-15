import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';

import '../../models/task_item_recur_preview.dart';


class CreateSprintWithTaskItems {
  final SprintBlueprint sprintBlueprint;
  final BuiltList<TaskItem> taskItems;
  final BuiltList<TaskItemRecurPreview> taskItemRecurPreviews;

  CreateSprintWithTaskItems({required this.sprintBlueprint, required this.taskItems, required this.taskItemRecurPreviews});

  @override
  String toString() {
    return "CreateSprint{sprintBlueprint: $sprintBlueprint, taskItems: $taskItems, taskItemRecurPreviews: $taskItemRecurPreviews";
  }
}

class SprintsAddedAction {
  final Iterable<Sprint> addedSprints;

  SprintsAddedAction(this.addedSprints);
}

class SprintCreatedAction {
  final Sprint sprint;
  final BuiltList<TaskItem> addedTasks;
  final BuiltList<SprintAssignment> sprintAssignments;

  SprintCreatedAction({required this.sprint, required this.addedTasks, required this.sprintAssignments});

  @override
  String toString() {
    return "SprintCreatedAction{sprint: $sprint, addedTasks: $addedTasks, sprintAssignments: $sprintAssignments";
  }
}

class AddTaskItemsToExistingSprint {
  final Sprint sprint;
  final BuiltList<TaskItem> taskItems;
  final BuiltList<TaskItemRecurPreview> taskItemRecurPreviews;

  AddTaskItemsToExistingSprint({required this.sprint, required this.taskItems, required this.taskItemRecurPreviews});

  @override
  String toString() {
    return "AddTaskItemsToExistingSprint{sprint: $sprint, taskItems: $taskItems, taskItemRecurPreviews: $taskItemRecurPreviews";
  }
}

class TaskItemsAddedToExistingSprint {
  final int sprintId;
  final BuiltList<TaskItem> addedTasks;
  final BuiltList<SprintAssignment> sprintAssignments;

  TaskItemsAddedToExistingSprint({required this.sprintId, required this.addedTasks, required this.sprintAssignments});

  @override
  String toString() {
    return "TaskItemsAddedToExistingSprint{sprint: $sprintId, addedTasks: $addedTasks, sprintAssignments: $sprintAssignments";
  }
}
