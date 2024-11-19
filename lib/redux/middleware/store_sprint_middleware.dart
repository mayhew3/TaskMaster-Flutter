

import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/sprint_actions.dart';
import 'package:taskmaster/task_repository.dart';

import '../app_state.dart';

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

    try {
      action.sprintBlueprint.sprintNumber = computeSprintNumber(store);
      var payload = await repository.addSprintWithTaskItems(action.sprintBlueprint, action.taskItems, action.taskItemRecurPreviews);
      store.dispatch(SprintCreatedAction(sprint: payload.sprint, addedTasks: payload.addedTasks, sprintAssignments: payload.sprintAssignments));
    } catch (e) {
      print("Error creating new sprint: $e");
    }

  };
}

int computeSprintNumber(Store<AppState> store) {
  var sorted = store.state.sprints.toList();
  sorted.sort((s1, s2) => s2.sprintNumber.compareTo(s1.sprintNumber));
  return sorted.first.sprintNumber + 1;
}

Future<void> Function(
    Store<AppState>,
    AddTaskItemsToExistingSprint,
    NextDispatcher,
    ) _addTaskItemsToExistingSprint(TaskRepository repository) {
  return (Store<AppState> store, AddTaskItemsToExistingSprint action, NextDispatcher next) async {
    next(action);

    try {
      var payload = await repository.addTasksToSprint(action.taskItems, action.taskItemRecurPreviews, action.sprint);
      store.dispatch(TaskItemsAddedToExistingSprint(sprintId: action.sprint.docId, addedTasks: payload.addedTasks, sprintAssignments: payload.sprintAssignments));
    } catch (e) {
      print("Error creating new sprint: $e");
    }

  };
}

