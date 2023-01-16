
import 'package:flutter/material.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/task_repository.dart';

import 'auth.dart';
import 'app_state.dart';
import 'models/task_item.dart';
import 'models/task_item_edit.dart';
import 'nav_helper.dart';
import 'package:jiffy/jiffy.dart';

class TaskHelper {
  final AppState appState;
  final TaskRepository repository;
  final TaskMasterAuth auth;
  final StateSetter stateSetter;
  late NavHelper navHelper;

  TaskHelper({
    required this.appState,
    required this.repository,
    required this.auth,
    required this.stateSetter,
  });

  Future<void> reloadTasks() async {
    navHelper.goToLoadingScreen('Reloading tasks...');
    appState.isLoading = true;
    appState.taskItems = [];

    try {
      await repository.loadTasks(stateSetter);
    } finally {
      appState.finishedLoading();
    }
    appState.notificationScheduler.updateBadge();
    navHelper.goToHomeScreen();
    await appState.syncAllNotifications();
  }

  Future<TaskItem> addTask(TaskItemBlueprint taskItem) async {
    TaskItem inboundTask = await repository.addTask(taskItem);
    stateSetter(() {
      var addedTask = appState.addNewTaskToList(inboundTask);
      appState.notificationScheduler.updateNotificationForTask(addedTask);
    });
    appState.notificationScheduler.updateBadge();
    return inboundTask;
  }

  TaskItemEdit? maybeCreateNextIteration(TaskItem taskItem, bool completed, DateTime? completionDate) {

    var recurNumber = taskItem.recurNumber;
    var recurUnit = taskItem.recurUnit;
    var recurWait = taskItem.recurWait;

    if (recurNumber != null && completed) {
      if (recurUnit == null || recurWait == null) {
        throw new Exception('Recur_number has a value, so recur_unit and recur_wait should be non-null!');
      }

      var recurIteration = taskItem.recurIteration!;

      Iterable<TaskItem> sameRecurrence = repository.appState.taskItems.where((TaskItem ti) => ti.recurrenceId == taskItem.recurrenceId);
      Iterable<TaskItem> nextInLine = sameRecurrence.where((TaskItem ti) => ti.recurIteration! > recurIteration);

      if (nextInLine.isEmpty) {
        return createNextIteration(taskItem, completionDate!);
      }
    }

    return null;
  }

  TaskItemEdit createNextIteration(TaskItemEdit taskItem, DateTime completionDate) {

    var recurNumber = taskItem.recurNumber!;
    var recurUnit = taskItem.recurUnit;
    var recurWait = taskItem.recurWait;
    var recurIteration = taskItem.recurIteration;

    if (recurUnit == null || recurWait == null || recurIteration == null) {
      throw new Exception('Recur_number has a value, so recur_unit and recur_wait and recur_iteration should be non-null!');
    }

    DateTime? anchorDate = taskItem.getAnchorDate();
    if (anchorDate == null) {
      throw new Exception('Recur_number exists without anchor date!');
    }
    DateTime nextAnchorDate;

    TaskItemEdit nextScheduledTask = taskItem.createEditTemplate();

    if (recurWait) {
      nextAnchorDate = _getAdjustedDate(completionDate, recurNumber, recurUnit);
    } else {
      nextAnchorDate = _getAdjustedDate(anchorDate, recurNumber, recurUnit);
    }

    DateTime dateWithTime = _getClosestDateForTime(anchorDate, nextAnchorDate);
    Duration duration = dateWithTime.difference(anchorDate);

    nextScheduledTask.startDate = _addToDate(taskItem.startDate, duration);
    nextScheduledTask.targetDate = _addToDate(taskItem.targetDate, duration);
    nextScheduledTask.urgentDate = _addToDate(taskItem.urgentDate, duration);
    nextScheduledTask.dueDate = _addToDate(taskItem.dueDate, duration);

    if (nextScheduledTask.recurIteration != null) {
      nextScheduledTask.recurIteration = nextScheduledTask.recurIteration! + 1;
    }

    return nextScheduledTask;
  }

  Future<TaskItem> completeTask(TaskItem taskItem, bool completed, StateSetter stateSetter) async {
    if (completed && taskItem.completionDate != null) {
      throw new ArgumentError("CompleteTask() called with non-null completion date and completed true.");
    } else if (!completed && taskItem.completionDate == null) {
      throw new ArgumentError("CompleteTask() called with null completion date and completed false.");
    }

    stateSetter(() {
      taskItem.pendingCompletion = true;
    });

    DateTime? completionDate = completed ? DateTime.now() : null;
    TaskItemEdit? nextScheduledTask = maybeCreateNextIteration(taskItem, completed, completionDate);

    stateSetter(() {
      taskItem.completionDate = completionDate;
    });

    var inboundTask = await repository.completeTask(taskItem);

    stateSetter(() {
      _copyChanges(inboundTask, taskItem);
      taskItem.pendingCompletion = false;
      appState.notificationScheduler.updateNotificationForTask(taskItem);
    });
    appState.notificationScheduler.updateBadge();

    if (nextScheduledTask != null) {
      await addTask(nextScheduledTask);
    }

    return taskItem;
  }

  Future<void> deleteTask(TaskItem taskItem, StateSetter stateSetter) async {
    int taskId = taskItem.id!;
    await repository.deleteTask(taskItem);
    print('Removal of task successful!');
    await appState.notificationScheduler.cancelNotificationsForTaskId(taskId);
    stateSetter(() {
      appState.sprints.forEach((sprint) => sprint.removeFromTasks(taskItem));
      appState.deleteTaskFromList(taskItem);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> updateTask(TaskItem taskItem, TaskItemEdit changes) async {
    var inboundTask = await repository.updateTask(changes);
    stateSetter(() {
      _copyChanges(inboundTask, taskItem);
    });
    await appState.notificationScheduler.updateNotificationForTask(taskItem);
    appState.notificationScheduler.updateBadge();
    return taskItem;
  }

  TaskItemEdit previewSnooze(TaskItem taskItem, int numUnits, String unitSize, TaskDateType dateType) {
    return _generatePreview(taskItem, numUnits, unitSize, dateType);
  }

  Future<TaskItem> snoozeTask(TaskItem taskItem, int numUnits, String unitSize, TaskDateType dateType) async {
    TaskItemEdit changes = _generatePreview(taskItem, numUnits, unitSize, dateType);

    var relevantDateField = dateType.dateFieldGetter(changes);

    DateTime? originalValue = relevantDateField;

    TaskItem updatedTask = await updateTask(taskItem, changes);

    Snooze snooze = new Snooze(
        taskId: updatedTask.id!,
        snoozeNumber: numUnits,
        snoozeUnits: unitSize,
        snoozeAnchor: dateType.label,
        previousAnchor: originalValue,
        newAnchor: relevantDateField!);

    await repository.addSnoozeSerializable(snooze);
    return updatedTask;
  }

  // sprint methods

  Future<Sprint> addSprintAndTasks(Sprint sprint, List<TaskItem> taskItems) async {
    Sprint updatedSprint = await repository.addSprint(sprint);
    stateSetter(() => appState.sprints.add(updatedSprint));
    return await addTasksToSprint(updatedSprint, taskItems);
  }

  Future<Sprint> addTasksToSprint(Sprint sprint, List<TaskItem> taskItems) async {
    await repository.addTasksToSprint(taskItems, sprint);
    stateSetter(() => {});
    return sprint;
  }

  // private helpers

  TaskItemEdit _generatePreview(TaskItem taskItem, int numUnits, String unitSize, TaskDateType dateType) {
    TaskItemEdit taskItemForm = taskItem.createEditTemplate();

    DateTime snoozeDate = DateTime.now();
    DateTime adjustedDate = _getAdjustedDate(snoozeDate, numUnits, unitSize);

    var relevantDateField = dateType.dateFieldGetter(taskItemForm);
    DateTime? relevantDate = relevantDateField;

    if (relevantDate == null) {
      relevantDateField = adjustedDate;
    } else {
      Duration difference = adjustedDate.difference(relevantDate);
      TaskDateTypes.allTypes.forEach((taskDateType) => taskItemForm.incrementDateIfExists(taskDateType, difference));
    }

    return taskItemForm;
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

  // todo: make more dynamic?
  void _copyChanges(TaskItem inboundTask, TaskItem outboundTask) {
    outboundTask.id = inboundTask.id;
    outboundTask.personId = inboundTask.personId;
    outboundTask.name = inboundTask.name;
    outboundTask.description = inboundTask.description;
    outboundTask.project = inboundTask.project;
    outboundTask.context = inboundTask.context;
    outboundTask.urgency = inboundTask.urgency;
    outboundTask.priority = inboundTask.priority;
    outboundTask.duration = inboundTask.duration;
    outboundTask.dateAdded = inboundTask.dateAdded;
    outboundTask.startDate = inboundTask.startDate;
    outboundTask.targetDate = inboundTask.targetDate;
    outboundTask.dueDate = inboundTask.dueDate;
    outboundTask.completionDate = inboundTask.completionDate;
    outboundTask.urgentDate = inboundTask.urgentDate;
    outboundTask.gamePoints = inboundTask.gamePoints;
    outboundTask.recurNumber = inboundTask.recurNumber;
    outboundTask.recurUnit = inboundTask.recurUnit;
    outboundTask.recurWait = inboundTask.recurWait;
    outboundTask.recurrenceId = inboundTask.recurrenceId;
    outboundTask.recurIteration = inboundTask.recurIteration;
  }

}