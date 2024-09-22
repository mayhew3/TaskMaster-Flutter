import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/snooze_blueprint.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/task_repository.dart';

import '../actions/task_item_actions.dart';

List<Middleware<AppState>> createStoreTaskItemsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<AppState, VerifyPersonAction>(_verifyPerson(repository)),
    TypedMiddleware<AppState, LoadDataAction>(_loadData(repository)),
    TypedMiddleware<AppState, AddTaskItemAction>(_createNewTaskItem(repository)),
    TypedMiddleware<AppState, UpdateTaskItemAction>(_updateTaskItem(repository)),
    TypedMiddleware<AppState, CompleteTaskItemAction>(_completeTaskItem(repository)),
    TypedMiddleware<AppState, ExecuteSnooze>(_executeSnooze(repository)),
  ];
}

Future<void> Function(
    Store<AppState>,
    VerifyPersonAction action,
    NextDispatcher next,
    ) _verifyPerson(TaskRepository repository) {
  return (Store<AppState> store, VerifyPersonAction action, NextDispatcher next) async {
    next(action);

    var email = store.state.currentUser!.email;
    print("Verify person account for " + email + "...");
    var idToken = await store.state.getIdToken();
    if (idToken == null) {
      throw new Exception("Cannot load tasks without id token.");
    }

    try {
      var personId = await repository.getPersonId(email, idToken);
      if (personId == null) {
        store.dispatch(OnPersonRejectedAction());
      } else {
        store.dispatch(OnPersonVerifiedAction(personId));
      }
    } catch (e) {
      print("Error fetching person for email: $e");
      store.dispatch(OnPersonRejectedAction());
    }

  };
}


Future<void> Function(
    Store<AppState>,
    LoadDataAction action,
    NextDispatcher next,
    ) _loadData(TaskRepository repository) {
  return (Store<AppState> store, LoadDataAction action, NextDispatcher next) async {
    next(action);
    var inputs = await getRequiredInputs(store, "load tasks");
    print("Fetching tasks for person_id ${inputs.personId}...");
    try {
      var dataPayload = await repository.loadTasks(inputs.personId, inputs.idToken);
      store.dispatch(DataLoadedAction(dataPayload: dataPayload));
    } catch (e) {
      print("Error fetching task list: $e");
      store.dispatch(DataNotLoadedAction());
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

    var inputs = await getRequiredInputs(store, "create task");

    action.blueprint.personId = inputs.personId;
    action.blueprint.recurrenceBlueprint?.personId = inputs.personId;

    // var recurrence = await maybeAddRecurrence(action.recurrenceBlueprint, inputs, repository);

    // action.blueprint.recurrenceId = recurrence?.id;
    var payload = await repository.addTask(action.blueprint, inputs.idToken);
    store.dispatch(TaskItemAddedAction(taskItem: payload.taskItem, taskRecurrence: payload.recurrence));
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
    var inputs = await getRequiredInputs(store, "update task");
    action.blueprint.recurrenceBlueprint?.personId = inputs.personId;
    var updated = await repository.updateTask(action.taskItem.id, action.blueprint, inputs.idToken);
    store.dispatch(TaskItemUpdatedAction(updated.taskItem));
  };
}

Future<void> Function(
    Store<AppState>,
    CompleteTaskItemAction action,
    NextDispatcher next,
    ) _completeTaskItem(TaskRepository repository) {
  return (Store<AppState> store, CompleteTaskItemAction action, NextDispatcher next) async {
    next(action);
    var inputs = await getRequiredInputs(store, "complete task");
    var completionDate = action.complete ? DateTime.timestamp() : null;

    var taskItem = action.taskItem;

    var blueprint = taskItem.createBlueprint()..completionDate = completionDate;
    var recurrence = taskItem.recurrence;

    TaskItemRecurPreview? nextScheduledTask;

    if (recurrence != null && completionDate != null && !hasNextIterationAlready(taskItem, store.state.taskItems)) {
      nextScheduledTask = RecurrenceHelper.createNextIteration(taskItem, completionDate);
    }

    var updated = await repository.updateTask(taskItem.id, blueprint, inputs.idToken);

    if (recurrence != null && nextScheduledTask != null) {
      var recurrenceBlueprint = syncBlueprintToMostRecentTaskItem(updated.taskItem, nextScheduledTask, recurrence);
      var updatedRecurrence = await repository.updateTaskRecurrence(recurrence.id, recurrenceBlueprint, inputs.idToken);
      var addedTaskItem = (await repository.addRecurTask(nextScheduledTask, inputs.idToken)).taskItem;
      store.dispatch(RecurringTaskItemCompletedAction(updated.taskItem, addedTaskItem, updatedRecurrence, action.complete));
    } else {
      store.dispatch(TaskItemCompletedAction(updated.taskItem, action.complete));
    }

  };
}

Future<void> Function(
    Store<AppState>,
    ExecuteSnooze action,
    NextDispatcher next,
    ) _executeSnooze(TaskRepository repository) {
  return (Store<AppState> store, ExecuteSnooze action, NextDispatcher next) async {
    next(action);
    var inputs = await getRequiredInputs(store, "snooze");

    RecurrenceHelper.generatePreview(action.blueprint, action.numUnits, action.unitSize, action.dateType);

    DateTime? originalValue = action.dateType.dateFieldGetter(action.taskItem);
    DateTime relevantDateField = action.dateType.dateFieldGetter(action.blueprint)!;

    var updatedTask = await repository.updateTask(action.taskItem.id, action.blueprint, inputs.idToken);

    SnoozeBlueprint snooze = new SnoozeBlueprint(
        taskId: updatedTask.taskItem.id,
        snoozeNumber: action.numUnits,
        snoozeUnits: action.unitSize,
        snoozeAnchor: action.dateType.label,
        previousAnchor: originalValue,
        newAnchor: relevantDateField);

    await repository.addSnooze(snooze, inputs.idToken);
    store.dispatch(SnoozeExecuted(updatedTask.taskItem));
  };
}


// create task iteration

bool hasNextIterationAlready(TaskItem taskItem, BuiltList<TaskItem> allTaskItems) {
  var recurIteration = taskItem.recurIteration!;

  Iterable<TaskItem> nextInLine = allTaskItems.where((TaskItem ti) =>
          ti.recurrenceId == taskItem.recurrenceId &&
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


