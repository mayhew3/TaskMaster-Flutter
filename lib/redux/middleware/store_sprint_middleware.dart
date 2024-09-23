

import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/sprint_actions.dart';
import 'package:taskmaster/task_repository.dart';

import '../app_state.dart';
import '../selectors/selectors.dart';

List<Middleware<AppState>> createStoreSprintsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<AppState, CreateSprintWithTaskItems>(_createSprintWithTaskItems(repository)),
    TypedMiddleware<AppState, AddTaskItemsToExistingSprint>(_addTaskItemsToExistingSprint(repository)),
  ];
}

Future<void> Function(
    Store<AppState>,
    CreateSprintWithTaskItems,
    NextDispatcher,
    ) _createSprintWithTaskItems(TaskRepository repository) {
  return (Store<AppState> store, CreateSprintWithTaskItems action, NextDispatcher next) async {
    next(action);

    var inputs = await getRequiredInputs(store, "create sprint");

    try {
      var payload = await repository.addSprintWithTaskItems(action.sprintBlueprint, action.taskItems, action.taskItemRecurPreviews, inputs.idToken);
      store.dispatch(SprintCreatedAction(sprint: payload.sprint, addedTasks: payload.addedTasks, sprintAssignments: payload.sprintAssignments));
    } catch (e) {
      print("Error creating new sprint: $e");
    }

  };
}

Future<void> Function(
    Store<AppState>,
    AddTaskItemsToExistingSprint,
    NextDispatcher,
    ) _addTaskItemsToExistingSprint(TaskRepository repository) {
  return (Store<AppState> store, AddTaskItemsToExistingSprint action, NextDispatcher next) async {
    next(action);

    var inputs = await getRequiredInputs(store, "create sprint");

    try {
      var payload = await repository.addTasksToSprint(action.taskItems, action.taskItemRecurPreviews, action.sprint, inputs.idToken);
      store.dispatch(TaskItemsAddedToExistingSprint(sprintId: action.sprint.id, addedTasks: payload.addedTasks, sprintAssignments: payload.sprintAssignments));
    } catch (e) {
      print("Error creating new sprint: $e");
    }

  };
}

