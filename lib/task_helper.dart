
import 'package:flutter/material.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/snooze_serializable.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/task_repository.dart';

import 'auth.dart';
import 'app_state.dart';
import 'models/snooze.dart';
import 'models/task_item.dart';
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

  Future<TaskItem> addTask(TaskItem taskItem) async {
    TaskItem inboundTask = await repository.addTask(taskItem);
    stateSetter(() {
      var addedTask = appState.addNewTaskToList(inboundTask);
      appState.notificationScheduler.updateNotificationForTask(addedTask);
    });
    appState.notificationScheduler.updateBadge();
    return inboundTask;
  }

  TaskItem? maybeCreateNextIteration(TaskItem taskItem, bool completed, DateTime? completionDate) {

    var recurNumber = taskItem.recurNumber.value;
    var recurUnit = taskItem.recurUnit.value;
    var recurWait = taskItem.recurWait.value;

    if (recurNumber != null && completed) {
      if (recurUnit == null || recurWait == null) {
        throw new Exception('Recur_number has a value, so recur_unit and recur_wait should be non-null!');
      }

      var recurIteration = taskItem.recurIteration.value!;

      Iterable<TaskItem> sameRecurrence = repository.appState.taskItems.where((TaskItem ti) => ti.recurrenceId.value == taskItem.recurrenceId.value);
      Iterable<TaskItem> nextInLine = sameRecurrence.where((TaskItem ti) => ti.recurIteration.value! > recurIteration);

      if (nextInLine.isEmpty) {
        return createNextIteration(taskItem, completionDate!);
      }
    }

    return null;
  }

  TaskItem createNextIteration(TaskItem taskItem, DateTime completionDate) {

    var recurNumber = taskItem.recurNumber.value!;
    var recurUnit = taskItem.recurUnit.value;
    var recurWait = taskItem.recurWait.value;
    var recurIteration = taskItem.recurIteration.value;

    if (recurUnit == null || recurWait == null || recurIteration == null) {
      throw new Exception('Recur_number has a value, so recur_unit and recur_wait and recur_iteration should be non-null!');
    }

    DateTime? anchorDate = taskItem.getAnchorDate();
    if (anchorDate == null) {
      throw new Exception('Recur_number exists without anchor date!');
    }
    DateTime nextAnchorDate;

    TaskItem nextScheduledTask = taskItem.createCopy();

    if (recurWait) {
      nextAnchorDate = _getAdjustedDate(completionDate, recurNumber, recurUnit);
    } else {
      nextAnchorDate = _getAdjustedDate(anchorDate, recurNumber, recurUnit);
    }

    DateTime dateWithTime = _getClosestDateForTime(anchorDate, nextAnchorDate);
    Duration duration = dateWithTime.difference(anchorDate);

    nextScheduledTask.startDate.initializeValue(_addToDate(taskItem.startDate.value, duration));
    nextScheduledTask.targetDate.initializeValue(_addToDate(taskItem.targetDate.value, duration));
    nextScheduledTask.urgentDate.initializeValue(_addToDate(taskItem.urgentDate.value, duration));
    nextScheduledTask.dueDate.initializeValue(_addToDate(taskItem.dueDate.value, duration));

    nextScheduledTask.recurIteration.initializeValue(recurIteration + 1);

    return nextScheduledTask;
  }

  Future<TaskItem> completeTask(TaskItem taskItem, bool completed, StateSetter stateSetter) async {
    if (completed && taskItem.completionDate.value != null) {
      throw new ArgumentError("CompleteTask() called with non-null completion date and completed true.");
    } else if (!completed && taskItem.completionDate.value == null) {
      throw new ArgumentError("CompleteTask() called with null completion date and completed false.");
    }

    stateSetter(() {
      taskItem.pendingCompletion = true;
    });

    DateTime? completionDate = completed ? DateTime.now() : null;
    TaskItem? nextScheduledTask = maybeCreateNextIteration(taskItem, completed, completionDate);

    stateSetter(() {
      taskItem.completionDate.value = completionDate;
      taskItem.treatAsCommitted();
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
    int taskId = taskItem.id.value!;
    await repository.deleteTask(taskItem);
    print('Removal of task successful!');
    await appState.notificationScheduler.cancelNotificationsForTaskId(taskId);
    stateSetter(() {
      appState.sprints.forEach((sprint) => sprint.removeFromTasks(taskItem));
      appState.deleteTaskFromList(taskItem);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> updateTask(TaskItem taskItem) async {
    var inboundTask = await repository.updateTask(taskItem);
    stateSetter(() {
      _copyChanges(inboundTask, taskItem);
    });
    await appState.notificationScheduler.updateNotificationForTask(taskItem);
    appState.notificationScheduler.updateBadge();
    return taskItem;
  }

  void previewSnooze(TaskItem taskItem, int numUnits, String unitSize, TaskDateType dateType) {
    _generatePreview(taskItem, numUnits, unitSize, dateType);
  }

  Future<TaskItem> snoozeTask(TaskItem taskItem, int numUnits, String unitSize, TaskDateType dateType) async {
    _generatePreview(taskItem, numUnits, unitSize, dateType);

    var relevantDateField = dateType.dateFieldGetter(taskItem);

    DateTime? originalValue = relevantDateField.originalValue;

    TaskItem updatedTask = await updateTask(taskItem);

    SnoozeSerializable snooze = new SnoozeSerializable(
        taskId: updatedTask.id.value!,
        snoozeNumber: numUnits,
        snoozeUnits: unitSize,
        snoozeAnchor: dateType.label,
        previousAnchor: originalValue,
        newAnchor: relevantDateField.value!);

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

  void _generatePreview(TaskItem taskItem, int numUnits, String unitSize, TaskDateType dateType) {
    DateTime snoozeDate = DateTime.now();
    DateTime adjustedDate = _getAdjustedDate(snoozeDate, numUnits, unitSize);

    var relevantDateField = dateType.dateFieldGetter(taskItem);
    DateTime? relevantDate = relevantDateField.value;

    if (relevantDate == null) {
      relevantDateField.value = adjustedDate;
    } else {
      Duration difference = adjustedDate.difference(relevantDate);
      TaskDateTypes.allTypes.forEach((taskDateType) => taskItem.incrementDateIfExists(taskDateType, difference));
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

  void _copyChanges(TaskItem inboundTask, TaskItem outboundTask) {
    for (TaskField field in outboundTask.fields) {
      var inboundField = inboundTask.getTaskField(field.fieldName)!;
      field.value = inboundField.value;
    }
    outboundTask.treatAsCommitted();
  }

}