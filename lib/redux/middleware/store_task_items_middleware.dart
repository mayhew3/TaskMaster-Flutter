import 'package:redux/redux.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/task_repository.dart';

import '../actions/actions.dart';

List<Middleware<AppState>> createStoreTaskItemsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<AppState, LoadTaskItemsAction>(_createLoadTaskItems(repository)),
    TypedMiddleware<AppState, AddTaskItemAction>(_createNewTaskItem(repository))
  ];
}

Middleware<AppState> _createLoadTaskItems(TaskRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {
    var email = store.state.currentUser!.email;
    print("Fetching tasks for " + email);
    repository.loadTasksRedux(email).then(
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

void Function(
    Store<AppState>,
    AddTaskItemAction action,
    NextDispatcher next,
    ) _createNewTaskItem(TaskRepository repository) {
  return (Store<AppState> store, AddTaskItemAction action, NextDispatcher next) async {
    next(action);
    await repository.addTaskRedux(action.taskItem);
  };
}