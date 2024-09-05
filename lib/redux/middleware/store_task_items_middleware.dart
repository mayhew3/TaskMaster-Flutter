import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/task_repository.dart';

import '../actions/actions.dart';

List<Middleware<AppState>> createStoreTaskItemsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<AppState, LoadTaskItemsAction>(_createLoadTaskItems(repository)),
    TypedMiddleware<AppState, AddTaskItemAction>(_createNewTaskItem(repository)),
    TypedMiddleware<AppState, UpdateTaskItemAction>(_updateTaskItem(repository)),
    TypedMiddleware<AppState, CompleteTaskItemAction>(_completeTaskItem(repository)),
  ];
}

Future<void> Function(
    Store<AppState>,
    LoadTaskItemsAction action,
    NextDispatcher next,
    ) _createLoadTaskItems(TaskRepository repository) {
  return (Store<AppState> store, LoadTaskItemsAction action, NextDispatcher next) async {
    next(action);

    var email = store.state.currentUser!.email;
    print("Fetching tasks for " + email);
    var idToken = await store.state.getIdToken();
    if (idToken == null) {
      throw new Exception("Cannot load tasks without id token.");
    }

    try {
      var dataPayload = await repository.loadTasksRedux(email, idToken);
      store.dispatch(TaskItemsLoadedAction(dataPayload.taskItems));
    } catch (e) {
      store.dispatch(TaskItemsNotLoadedAction());
    }

  };
}

Future<void> Function(
    Store<AppState>,
    AddTaskItemAction action,
    NextDispatcher next,
    ) _createNewTaskItem(TaskRepository repository) {
  return (Store<AppState> store, AddTaskItemAction action, NextDispatcher next) async {
    next(action);
    var idToken = await store.state.getIdToken();
    if (idToken == null) {
      throw new Exception("Cannot load tasks without id token.");
    }
    var taskItem = await repository.addTaskRedux(action.blueprint, idToken, store.state.personId);
    store.dispatch(TaskItemAdded(taskItem: taskItem));
  };
}

Future<void> Function(
    Store<AppState>,
    UpdateTaskItemAction action,
    NextDispatcher next,
    ) _updateTaskItem(TaskRepository repository) {
  return (Store<AppState> store, UpdateTaskItemAction action, NextDispatcher next) async {
    next(action);
    var idToken = await store.state.getIdToken();
    if (idToken == null) {
      throw new Exception("Cannot load tasks without id token.");
    }
    var b = action.blueprint;
    var toUpdate = action.taskItem.rebuild((t) => _fromBlueprint(t, b));
    var updated = await repository.updateTask(toUpdate, idToken);
    store.dispatch(TaskItemUpdated(updated));
  };
}

Future<void> Function(
    Store<AppState>,
    CompleteTaskItemAction action,
    NextDispatcher next,
    ) _completeTaskItem(TaskRepository repository) {
  return (Store<AppState> store, CompleteTaskItemAction action, NextDispatcher next) async {
    next(action);
    var idToken = await store.state.getIdToken();
    if (idToken == null) {
      throw new Exception("Cannot load tasks without id token.");
    }
    var completed = action.taskItem.rebuild((t) => t
      ..completionDate = action.complete ? DateTime.timestamp() : null);
    var updated = await repository.updateTask(completed, idToken);
    store.dispatch(TaskItemCompleted(updated, action.complete));
  };
}


// helper methods

TaskItemBuilder _fromBlueprint(TaskItemBuilder t, TaskItemBlueprint b) {
  return t
    ..name = b.name
    ..description = b.description
    ..project = b.project
    ..context = b.context
    ..urgency = b.urgency
    ..priority = b.priority
    ..duration = b.duration
    ..gamePoints = b.gamePoints
    ..startDate = b.startDate?.toUtc()
    ..targetDate = b.targetDate?.toUtc()
    ..dueDate = b.dueDate?.toUtc()
    ..urgentDate = b.urgentDate?.toUtc()
    ..completionDate = b.completionDate?.toUtc()
    ..recurNumber = b.recurNumber
    ..recurUnit = b.recurUnit
    ..recurWait = b.recurWait
    ..recurrenceId = b.recurrenceId
    ..recurIteration = b.recurIteration;
}

