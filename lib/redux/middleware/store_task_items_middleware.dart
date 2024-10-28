import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/snooze_blueprint.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/routes.dart';
import 'package:taskmaster/task_repository.dart';

import '../actions/sprint_actions.dart';
import '../actions/task_item_actions.dart';

List<Middleware<AppState>> createStoreTaskItemsMiddleware(
    TaskRepository repository,
    GlobalKey<NavigatorState> navigatorKey,
    ) {
  return [
    TypedMiddleware<AppState, VerifyPersonAction>(_verifyPerson(repository)),
    TypedMiddleware<AppState, LoadDataAction>(loadData(repository, navigatorKey)),
    TypedMiddleware<AppState, DataLoadedAction>(_dataLoaded(navigatorKey)),
    TypedMiddleware<AppState, AddTaskItemAction>(createNewTaskItem(repository)),
    TypedMiddleware<AppState, UpdateTaskItemAction>(_updateTaskItem(repository)),
    TypedMiddleware<AppState, DeleteTaskItemAction>(_deleteTaskItem(repository)),
    TypedMiddleware<AppState, CompleteTaskItemAction>(completeTaskItem(repository)),
    TypedMiddleware<AppState, ExecuteSnooze>(_executeSnooze(repository)),
    TypedMiddleware<AppState, GoOffline>(goOffline(repository)),
    TypedMiddleware<AppState, GoOnline>(goOnline(repository)),
  ];
}

Future<void> Function(
    Store<AppState>,
    VerifyPersonAction action,
    NextDispatcher next,
    ) _verifyPerson(TaskRepository repository) {
  return (Store<AppState> store, VerifyPersonAction action, NextDispatcher next) async {
    next(action);

    // await repository.migrateFromApi();
    // print("Migration complete!");

    // await repository.dataFixAll();

    var email = store.state.currentUser!.email;
    print("Verify person account for " + email + "...");

    try {
      var personDocId = await repository.getPersonIdFromFirestore(email);
      if (personDocId == null) {
        store.dispatch(OnPersonRejectedAction());
      } else {
        store.dispatch(OnPersonVerifiedFirestoreAction(personDocId));
      }
    } catch (e, stack) {
      print("Error fetching person for email: $e");
      print(stack);
      store.dispatch(OnPersonRejectedAction());
    }

  };
}

@visibleForTesting
Future<void> Function(
    Store<AppState>,
    LoadDataAction action,
    NextDispatcher next,
    ) loadData(TaskRepository repository, GlobalKey<NavigatorState> navigatorKey) {
  return (Store<AppState> store, LoadDataAction action, NextDispatcher next) async {
    next(action);
    var inputs = await getRequiredInputs(store, "load tasks");
    print("Fetching tasks for person_id ${inputs.personDocId}...");
    try {

      print("Initializing data listeners...");

      var sprintListener = repository.createListener<Sprint>(
          collectionName: "sprints",
          personDocId: inputs.personDocId,
          addCallback: (sprints) => store.dispatch(SprintsAddedAction(sprints)),
          serializer: Sprint.serializer);
      var recurrenceListener = repository.createListener<TaskRecurrence>(
          collectionName:  "taskRecurrences",
          personDocId: inputs.personDocId,
          addCallback: (taskRecurrences) => store.dispatch(TaskRecurrencesAddedAction(taskRecurrences)),
          modifyCallback: (taskRecurrences) => store.dispatch(TaskRecurrencesModifiedAction(taskRecurrences)),
          serializer: TaskRecurrence.serializer);
      var taskListener = repository.createListener<TaskItem>(
          collectionName: "tasks",
          subCollectionName: "sprintAssignments",
          personDocId: inputs.personDocId,
          addCallback: (taskItems) => store.dispatch(TasksAddedAction(taskItems)),
          modifyCallback: (taskItems) => store.dispatch(TasksModifiedAction(taskItems)),
          serializer: TaskItem.serializer);

      store.dispatch(ListenersInitializedAction(taskListener, sprintListener, recurrenceListener));

    } catch (e, stack) {
      print("Error fetching task list: $e");
      print(stack);
      navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.loadFailed);
      store.dispatch(DataNotLoadedAction());
    }

  };
}

Future<void> Function(
    Store<AppState>,
    DataLoadedAction action,
    NextDispatcher next,
    ) _dataLoaded(GlobalKey<NavigatorState> navigatorKey) {
  return (Store<AppState> store, DataLoadedAction action, NextDispatcher next) async {
    next(action);
    var taskItemCount = store.state.taskItems.length;
    print("Data loaded. Task item count: $taskItemCount");

    navigatorKey.currentState!.pushReplacementNamed(TaskMasterRoutes.home);

    await store.state.notificationHelper.syncNotificationForTasksAndSprint(store.state.taskItems.toList(), activeSprintSelector(store.state.sprints));
  };
}

@visibleForTesting
Future<void> Function(
    Store<AppState>,
    AddTaskItemAction action,
    NextDispatcher next,
    ) createNewTaskItem(TaskRepository repository) {
  return (Store<AppState> store, AddTaskItemAction action, NextDispatcher next) async {
    next(action);

    var inputs = await getRequiredInputs(store, "create task");

    action.blueprint.personDocId = inputs.personDocId;
    action.blueprint.recurrenceBlueprint?.personDocId = inputs.personDocId;

    repository.addTask(action.blueprint);

    // updateNotificationForItem(store, payload.taskItem);
  };
}

/*

Future<TaskRecurrence?> maybeAddRecurrence(TaskRecurrenceBlueprint? recurrenceBlueprint, ({String idToken, int personId}) inputs, TaskRepository repository) async {
  if (recurrenceBlueprint != null) {
    recurrenceBlueprint.personId = inputs.personId;
    return await repository.addTaskRecurrence(recurrenceBlueprint, inputs.idToken);
  }
  return null;
}
*/

Future<void> Function(
    Store<AppState>,
    UpdateTaskItemAction action,
    NextDispatcher next,
    ) _updateTaskItem(TaskRepository repository) {
  return (Store<AppState> store, UpdateTaskItemAction action, NextDispatcher next) async {
    next(action);
    action.blueprint.recurrenceBlueprint?.personDocId = action.taskItem.personDocId;
    repository.updateTask(action.taskItem.docId, action.blueprint);

    // updateNotificationForItem(store, updated.taskItem);

    // store.dispatch(TaskItemUpdatedAction(updated.taskItem));
  };
}

@visibleForTesting
Future<void> Function(
    Store<AppState>,
    CompleteTaskItemAction action,
    NextDispatcher next,
    ) completeTaskItem(TaskRepository repository) {
  return (Store<AppState> store, CompleteTaskItemAction action, NextDispatcher next) async {
    next(action);
    var completionDate = action.complete ? DateTime.timestamp() : null;

    var taskItem = action.taskItem;

    var blueprint = taskItem.createBlueprint()..completionDate = completionDate;
    var recurrence = taskItem.recurrence;

    TaskItemRecurPreview? nextScheduledTask;

    if (recurrence != null && completionDate != null && !hasNextIterationAlready(taskItem, store.state.taskItems)) {
      nextScheduledTask = RecurrenceHelper.createNextIteration(taskItem, completionDate);
    }

    var updated = await repository.updateTask(taskItem.docId, blueprint);

    updateNotificationForItem(store, updated.taskItem);

    if (recurrence != null && nextScheduledTask != null) {
      var recurrenceBlueprint = syncBlueprintToMostRecentTaskItem(updated.taskItem, nextScheduledTask, recurrence);
      var updatedRecurrence = await repository.updateTaskRecurrence(recurrence.docId, recurrenceBlueprint);
      var addedTaskItem = repository.addRecurTask(nextScheduledTask);
      store.dispatch(RecurringTaskItemCompletedAction(updated.taskItem, addedTaskItem, updatedRecurrence, action.complete));
    } else {
      store.dispatch(TaskItemCompletedAction(updated.taskItem, action.complete));
    }

  };
}

Future<void> Function(
    Store<AppState>,
    DeleteTaskItemAction action,
    NextDispatcher next,
    ) _deleteTaskItem(TaskRepository repository) {
  return (Store<AppState> store, DeleteTaskItemAction action, NextDispatcher next) async {
    next(action);

    repository.deleteTask(action.taskItem);

    // deleteNotificationForItem(store, taskItemId);
  };
}

Future<void> Function(
    Store<AppState>,
    ExecuteSnooze action,
    NextDispatcher next,
    ) _executeSnooze(TaskRepository repository) {
  return (Store<AppState> store, ExecuteSnooze action, NextDispatcher next) async {
    next(action);

    RecurrenceHelper.generatePreview(action.blueprint, action.numUnits, action.unitSize, action.dateType);

    DateTime? originalValue = action.dateType.dateFieldGetter(action.taskItem);
    DateTime relevantDateField = action.dateType.dateFieldGetter(action.blueprint)!;

    var updatedTask = await repository.updateTask(action.taskItem.docId, action.blueprint);

    SnoozeBlueprint snooze = new SnoozeBlueprint(
        taskDocId: updatedTask.taskItem.docId,
        snoozeNumber: action.numUnits,
        snoozeUnits: action.unitSize,
        snoozeAnchor: action.dateType.label,
        previousAnchor: originalValue,
        newAnchor: relevantDateField);

    repository.addSnooze(snooze);
    store.dispatch(SnoozeExecuted(updatedTask.taskItem));
  };
}

@visibleForTesting
Future<void> Function(
    Store<AppState>,
    GoOffline action,
    NextDispatcher next,
    ) goOffline(TaskRepository repository) {
  return (Store<AppState> store, GoOffline action, NextDispatcher next) async {
    next(action);
    repository.goOffline();
  };
}

@visibleForTesting
Future<void> Function(
    Store<AppState>,
    GoOnline action,
    NextDispatcher next,
    ) goOnline(TaskRepository repository) {
  return (Store<AppState> store, GoOnline action, NextDispatcher next) async {
    next(action);
    repository.goOnline();
  };
}



// create task iteration

bool hasNextIterationAlready(TaskItem taskItem, BuiltList<TaskItem> allTaskItems) {
  var recurIteration = taskItem.recurIteration!;

  Iterable<TaskItem> nextInLine = allTaskItems.where((TaskItem ti) =>
          ti.recurrenceDocId == taskItem.recurrenceDocId &&
          ti.recurIteration! > recurIteration);

  return nextInLine.isNotEmpty;
}


TaskRecurrenceBlueprint syncBlueprintToMostRecentTaskItem(TaskItem updatedTaskItem, TaskItemRecurPreview? taskItemBlueprint, TaskRecurrence originalRecurrence) {
  var recurrenceBlueprint = originalRecurrence.createBlueprint();
  if (taskItemBlueprint == null) {
    recurrenceBlueprint.syncToTaskItem(updatedTaskItem);
  } else {
    recurrenceBlueprint.syncToTaskItem(taskItemBlueprint);
  }
  return recurrenceBlueprint;
}

void updateNotificationForItem(Store<AppState> store, TaskItem taskItem) {
  store.state.notificationHelper.updateNotificationForTask(taskItem);
}

void deleteNotificationForItem(Store<AppState> store, String taskItemId) {
  store.state.notificationHelper.cancelNotificationsForTaskId(taskItemId);
}
