import 'package:built_collection/built_collection.dart';
import 'package:jiffy/jiffy.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/task_repository.dart';

import '../../date_util.dart';
import '../actions/task_item_actions.dart';

List<Middleware<AppState>> createStoreTaskItemsMiddleware(TaskRepository repository) {
  return [
    TypedMiddleware<AppState, VerifyPersonAction>(_verifyPerson(repository)),
    TypedMiddleware<AppState, LoadDataAction>(_loadData(repository)),
    TypedMiddleware<AppState, AddTaskItemAction>(_createNewTaskItem(repository)),
    TypedMiddleware<AppState, UpdateTaskItemAction>(_updateTaskItem(repository)),
    TypedMiddleware<AppState, CompleteTaskItemAction>(_completeTaskItem(repository)),
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
    action.blueprint.taskRecurrenceBlueprint?.personId = inputs.personId;

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
    action.blueprint.taskRecurrenceBlueprint?.personId = inputs.personId;
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

    TaskItemBlueprint? nextScheduledTask;

    if (recurrence != null && completionDate != null && !hasNextIterationAlready(taskItem, store.state.taskItems)) {
      nextScheduledTask = createNextIteration(taskItem, completionDate);
    }

    var updated = await repository.updateTask(taskItem.id, blueprint, inputs.idToken);

    if (recurrence != null && nextScheduledTask != null) {
      var recurrenceBlueprint = syncBlueprintToMostRecentTaskItem(updated.taskItem, nextScheduledTask, recurrence);
      var updatedRecurrence = await repository.updateTaskRecurrence(recurrence.id, recurrenceBlueprint, inputs.idToken);
      var addedTaskItem = (await repository.addTask(nextScheduledTask, inputs.idToken)).taskItem;
      store.dispatch(RecurringTaskItemCompletedAction(updated.taskItem, addedTaskItem, updatedRecurrence, action.complete));
    } else {
      store.dispatch(TaskItemCompletedAction(updated.taskItem, action.complete));
    }

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

TaskItemBlueprint createNextIteration(TaskItem taskItem, DateTime completionDate) {
  var recurrence = taskItem.recurrence;

  if (recurrence != null) {
    var recurIteration = taskItem.recurIteration;

    if (recurIteration == null) {
      throw new Exception(
          'Recurrence has a value, so recur_iteration should be non-null!');
    }

    var recurNumber = recurrence.recurNumber;
    var recurUnit = recurrence.recurUnit;
    var recurWait = recurrence.recurWait;

    DateTime? anchorDate = taskItem.getAnchorDate();
    if (anchorDate == null) {
      throw new Exception('Recur_number exists without anchor date!');
    }
    DateTime nextAnchorDate;

    if (recurWait) {
      nextAnchorDate = _getAdjustedDate(completionDate, recurNumber, recurUnit);
    } else {
      nextAnchorDate = _getAdjustedDate(anchorDate, recurNumber, recurUnit);
    }

    DateTime dateWithTime = _getClosestDateForTime(anchorDate, nextAnchorDate);
    Duration duration = dateWithTime.difference(anchorDate);

    TaskItemBlueprint nextScheduledTask = taskItem.createBlueprint();

    nextScheduledTask.startDate = _addToDate(taskItem.startDate, duration);
    nextScheduledTask.targetDate = _addToDate(taskItem.targetDate, duration);
    nextScheduledTask.urgentDate = _addToDate(taskItem.urgentDate, duration);
    nextScheduledTask.dueDate = _addToDate(taskItem.dueDate, duration);
    nextScheduledTask.recurIteration = recurIteration + 1;

    return nextScheduledTask;
  } else {
    throw Exception("No recurrence on task item!");
  }
}


DateTime? _addToDate(DateTime? previousDate, Duration duration) {
  return previousDate?.add(duration);
}

DateTime _getAdjustedDate(DateTime dateTime, int recurNumber, String recurUnit) {
  return DateUtil.adjustToDate(dateTime, recurNumber, recurUnit);
}

DateTime _applyTimeToDate(DateTime dateWithTime, DateTime targetDate) {
  var jiffy = Jiffy([
    targetDate.year,
    targetDate.month,
    targetDate.day,
    dateWithTime.hour,
    dateWithTime.minute,
    dateWithTime.second]);
  return jiffy.dateTime;
}

DateTime _getClosestDateForTime(DateTime dateWithTime, DateTime targetDate) {
  DateTime prev = _applyTimeToDate(dateWithTime, Jiffy(targetDate).subtract(days:1).dateTime);
  DateTime current = _applyTimeToDate(dateWithTime, targetDate);
  DateTime next = _applyTimeToDate(dateWithTime, Jiffy(targetDate).add(days:1).dateTime);

  var prevDiff = prev.difference(targetDate).abs();
  var currDiff = current.difference(targetDate).abs();
  var nextDiff = next.difference(targetDate).abs();

  if (prevDiff < currDiff && prevDiff < nextDiff) {
    return prev;
  } else if (currDiff < nextDiff) {
    return current;
  } else {
    return next;
  }
}

TaskRecurrenceBlueprint syncBlueprintToMostRecentTaskItem(TaskItem updatedTaskItem, TaskItemBlueprint? taskItemBlueprint, TaskRecurrence originalRecurrence) {
  var recurrenceBlueprint = originalRecurrence.createBlueprint();
  if (taskItemBlueprint == null) {
    recurrenceBlueprint.syncToTaskItem(updatedTaskItem);
  } else {
    recurrenceBlueprint.syncToTaskItem(taskItemBlueprint);
  }
  return recurrenceBlueprint;
}
