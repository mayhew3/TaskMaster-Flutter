import 'package:redux/redux.dart';
import 'package:taskmaster/redux/redux_app_state.dart';
import 'package:taskmaster/task_repository.dart';

import '../actions/actions.dart';

List<Middleware<ReduxAppState>> createStoreTaskItemsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<ReduxAppState, LoadTaskItemsAction>(_createLoadTaskItems(repository)),
    TypedMiddleware<ReduxAppState, AddTaskItemAction>(_createNewTaskItem(repository))
  ];
}


Middleware<ReduxAppState> _createLoadTaskItems(TaskRepository repository) {
  return (Store<ReduxAppState> store, action, NextDispatcher next) {
    repository.loadTasksRedux().then(
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
    Store<ReduxAppState>,
    AddTaskItemAction action,
    NextDispatcher next,
    ) _createNewTaskItem(TaskRepository repository) {
  return (Store<ReduxAppState> store, AddTaskItemAction action, NextDispatcher next) async {
    next(action);
    await repository.addTaskRedux(action.taskItem);
  };
}