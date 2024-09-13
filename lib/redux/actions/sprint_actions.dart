import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';


class CreateSprintWithTaskItems {
  final SprintBlueprint sprintBlueprint;
  final BuiltList<TaskItem> taskItems;

  CreateSprintWithTaskItems({required this.sprintBlueprint, required this.taskItems});

  @override
  String toString() {
    return "CreateSprint{sprintBlueprint: $sprintBlueprint, taskItems: $taskItems";
  }
}

class SprintCreatedAction {
  final Sprint sprint;
  final List<SprintAssignment> sprintAssignments;

  SprintCreatedAction({required this.sprint, required this.sprintAssignments});

  @override
  String toString() {
    return "SprintCreatedAction{sprint: $sprint, sprintAssignments: $sprintAssignments";
  }
}