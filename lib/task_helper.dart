
import 'package:flutter/material.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/task_repository.dart';

import 'auth.dart';
import 'models/app_state.dart';
import 'models/snooze.dart';
import 'models/task_item.dart';
import 'nav_helper.dart';
import 'package:jiffy/jiffy.dart';

class TaskHelper {
  final AppState appState;
  final TaskRepository repository;
  final TaskMasterAuth auth;
  final StateSetter stateSetter;
  NavHelper navHelper;

  TaskHelper({
    @required this.appState,
    @required this.repository,
    @required this.auth,
    @required this.stateSetter,
    this.navHelper,
  });

  void reloadTasks() async {
    navHelper.goToLoadingScreen('Reloading tasks...');
    appState.isLoading = true;
    appState.taskItems = [];

    await appState.notificationScheduler.cancelAllNotifications();
    try {
      await repository.loadTasks(stateSetter);
    } finally {
      appState.finishedLoading();
    }
    appState.notificationScheduler.updateBadge();
    navHelper.goToHomeScreen();
    appState.taskItems.forEach((taskItem) =>
        appState.notificationScheduler.syncNotificationForTask(taskItem));
  }

  Future<void> addTask(TaskItem taskItem) async {
    var inboundTask = await repository.addTask(taskItem);
    stateSetter(() {
      var addedTask = appState.addNewTaskToList(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(addedTask);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> completeTask(TaskItem taskItem, bool completed, StateSetter stateSetter) async {
    TaskItem nextScheduledTask;
    DateTime completionDate = completed ? DateTime.now() : null;

    stateSetter(() {
      taskItem.pendingCompletion = true;
    });

    if (taskItem.recurNumber.value != null && completed) {
      DateTime anchorDate = taskItem.getAnchorDate();
      DateTime nextAnchorDate;

      nextScheduledTask = taskItem.createCopy();

      if (taskItem.recurWait.value) {
        nextAnchorDate = _getAdjustedDate(completionDate, taskItem.recurNumber.value, taskItem.recurUnit.value);
      } else {
        nextAnchorDate = _getAdjustedDate(anchorDate, taskItem.recurNumber.value, taskItem.recurUnit.value);
      }

      DateTime dateWithTime = _getClosestDateForTime(anchorDate, nextAnchorDate);
      Duration duration = dateWithTime.difference(anchorDate);

      nextScheduledTask.startDate.initializeValue(_addToDate(taskItem.startDate.value, duration));
      nextScheduledTask.targetDate.initializeValue(_addToDate(taskItem.targetDate.value, duration));
      nextScheduledTask.urgentDate.initializeValue(_addToDate(taskItem.urgentDate.value, duration));
      nextScheduledTask.dueDate.initializeValue(_addToDate(taskItem.dueDate.value, duration));
    }

    stateSetter(() {
      taskItem.completionDate.value = completionDate;
      taskItem.treatAsCommitted();
    });

    var inboundTask = await repository.completeTask(taskItem);

    stateSetter(() {
      _copyChanges(inboundTask, taskItem);
      taskItem.pendingCompletion = false;
      appState.notificationScheduler.syncNotificationForTask(taskItem);
    });
    appState.notificationScheduler.updateBadge();

    if (nextScheduledTask != null) {
      addTask(nextScheduledTask);
    }

    return taskItem;
  }

  Future<void> deleteTask(TaskItem taskItem) async {
    var taskId = taskItem.id.value;
    await repository.deleteTask(taskItem);
    print('Removal of task successful!');
    await appState.notificationScheduler.cancelNotificationsForTaskId(taskId);
    stateSetter(() {
      appState.deleteTaskFromList(taskItem);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> updateTask(TaskItem taskItem) async {
    var inboundTask = await repository.updateTask(taskItem);
    stateSetter(() {
      _copyChanges(inboundTask, taskItem);
      appState.notificationScheduler.syncNotificationForTask(taskItem);
    });
    appState.notificationScheduler.updateBadge();
    return taskItem;
  }

  void previewSnooze(TaskItem taskItem, int numUnits, String unitSize, String dateTypeStr) {
    DateTime snoozeDate = DateTime.now();
    DateTime adjustedDate = _getAdjustedDate(snoozeDate, numUnits, unitSize);

    TaskDateType dateType = TaskItem.typeMap[dateTypeStr];

    var relevantDateField = taskItem.getDateFieldOfType(dateType);
    DateTime relevantDate = relevantDateField.value;

    if (relevantDate == null) {
      relevantDateField.value = adjustedDate;
    } else {
      Duration difference = adjustedDate.difference(relevantDate);
      TaskDateType.values.forEach((taskDateType) => taskItem.incrementDateIfExists(taskDateType, difference));
    }
  }

  Future<TaskItem> snoozeTask(TaskItem taskItem, int numUnits, String unitSize, String dateTypeStr) async {
    DateTime snoozeDate = DateTime.now();
    DateTime adjustedDate = _getAdjustedDate(snoozeDate, numUnits, unitSize);

    TaskDateType dateType = TaskItem.typeMap[dateTypeStr];

    var relevantDateField = taskItem.getDateFieldOfType(dateType);
    DateTime relevantDate = relevantDateField.value;

    if (relevantDate == null) {
      relevantDateField.value = adjustedDate;
    } else {
      Duration difference = adjustedDate.difference(relevantDate);
      TaskDateType.values.forEach((taskDateType) => taskItem.incrementDateIfExists(taskDateType, difference));
    }

    TaskItem updatedTask = await updateTask(taskItem);

    Snooze snooze = new Snooze();
    snooze.taskID.value = updatedTask.id.value;
    snooze.snoozeNumber.value = numUnits;
    snooze.snoozeUnits.value = unitSize;
    snooze.snoozeAnchor.value = dateTypeStr;
    snooze.previousAnchor.value = relevantDateField.originalValue;
    snooze.newAnchor.value = relevantDateField.value;

    await repository.addSnooze(snooze);
    return updatedTask;
  }

  // sprint methods

  Future<Sprint> addSprintAndTasks(Sprint sprint, List<TaskItem> taskItems) async {
    Sprint updatedSprint = await repository.addSprint(sprint);
    stateSetter(() => appState.sprints.add(updatedSprint));
    await repository.addTasksToSprint(taskItems, updatedSprint);
    stateSetter(() => {});
    return updatedSprint;
  }

  // private helpers


  DateTime _addToDate(DateTime previousDate, Duration duration) {
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
    DateTime prev = _applyTimeToDate(dateWithTime, Jiffy(targetDate).subtract(days:1));
    DateTime current = _applyTimeToDate(dateWithTime, targetDate);
    DateTime next = _applyTimeToDate(dateWithTime, Jiffy(targetDate).add(days:1));

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
      var inboundField = inboundTask.getTaskField(field.fieldName);
      field.value = inboundField.value;
    }
    outboundTask.treatAsCommitted();
  }

}