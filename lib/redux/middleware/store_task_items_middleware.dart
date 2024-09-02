import 'package:redux/redux.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/task_repository.dart';

import '../actions/actions.dart';

List<Middleware<AppState>> createStoreTaskItemsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<AppState, LoadTaskItemsAction>(_createLoadTaskItems(repository)),
    TypedMiddleware<AppState, AddTaskItemAction>(_createNewTaskItem(repository)),
    TypedMiddleware<AppState, UpdateTaskItemAction>(_updateTaskItem(repository)),
  ];
}

Future<void> Function(
    Store<AppState>,
    LoadTaskItemsAction action,
    NextDispatcher next,
    ) _createLoadTaskItems(TaskRepository repository) {
  return (Store<AppState> store, LoadTaskItemsAction action, NextDispatcher next) async {
    var email = store.state.currentUser!.email;
    print("Fetching tasks for " + email);
    var idToken = await store.state.getIdToken();
    if (idToken == null) {
      throw new Exception("Cannot load tasks without id token.");
    }
    repository.loadTasksRedux(email, idToken).then(
          (dataPayload) {
        store.dispatch(
          TaskItemsLoadedAction(
            dataPayload.taskItems,
          ),
        );
      },
    ).catchError((_) => store.dispatch(TaskItemsNotLoadedAction()));

    next(action);
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
    await repository.addTaskRedux(action.taskItem, idToken);
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
    await repository.updateTask(action.updatedTaskItem, idToken);
  };
}

