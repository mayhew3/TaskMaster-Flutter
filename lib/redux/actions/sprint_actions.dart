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
    return "CreateSprint{sprintBlueprint: $sprintBlueprint, taskItems: $taskItems";
  }
}

class SprintCreatedAction {
  final Sprint sprint;
  final BuiltList<TaskItem> addedTasks;
  final BuiltList<SprintAssignment> sprintAssignments;

  SprintCreatedAction({required this.sprint, required this.addedTasks, required this.sprintAssignments});

  @override
  String toString() {
    return "SprintCreatedAction{sprint: $sprint, sprintAssignments: $sprintAssignments";
  }
}