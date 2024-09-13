import 'package:built_collection/built_collection.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';

import '../../models/task_item.dart';

class CreateSprintWithTaskItems {
  final SprintBlueprint sprintBlueprint;
  final BuiltList<TaskItem> taskItems;

  CreateSprintWithTaskItems({required this.sprintBlueprint, required this.taskItems});

  @override
  String toString() {
    return "CreateSprint{sprint: $sprintBlueprint, taskItems: $taskItems";
  }
}
