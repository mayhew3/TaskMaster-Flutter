
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_date_type.dart';
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
    repository.loadTasks().then((loadedTasks) {
      stateSetter(() => appState.finishedLoading(loadedTasks));
      appState.notificationScheduler.updateBadge();
      navHelper.goToHomeScreen();
      appState.taskItems.forEach((taskItem) =>
          appState.notificationScheduler.syncNotificationForTask(taskItem));
    }).catchError((err) {
      stateSetter(() => appState.isLoading = false);
    });
  }

  Future<void> addTask(TaskItem taskItem) async {
    var inboundTask = await repository.addTask(taskItem);
    stateSetter(() {
      var addedTask = appState.addNewTaskToList(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(addedTask);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> completeTask(TaskItem taskItem, bool completed) async {
    TaskItem nextScheduledTask;
    DateTime completionDate = completed ? DateTime.now() : null;
    taskItem.pendingCompletion = true;

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

    var inboundTask = await repository.completeTask(taskItem, completionDate);
    TaskItem updatedTask;
    stateSetter(() {
      // todo: update fields on original task instead of deleting and adding result
      updatedTask = appState.updateTaskListWithUpdatedTask(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(updatedTask);
    });
    appState.notificationScheduler.updateBadge();

    if (nextScheduledTask != null) {
      addTask(nextScheduledTask);
    }

    return updatedTask;
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
    TaskItem updatedTask;
    stateSetter(() {
      // todo: update fields on original task instead of deleting and adding result
      updatedTask = appState.updateTaskListWithUpdatedTask(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(updatedTask);
    });
    appState.notificationScheduler.updateBadge();
    return updatedTask;
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


  // private helpers


  DateTime _addToDate(DateTime previousDate, Duration duration) {
    return previousDate?.add(duration);
  }

  DateTime _getAdjustedDate(DateTime dateTime, int recurNumber, String recurUnit) {
    if (dateTime == null) {
      return null;
    }
    switch (recurUnit) {
      case 'Days': return Jiffy(dateTime).add(days: recurNumber);
      case 'Weeks': return Jiffy(dateTime).add(weeks: recurNumber);
      case 'Months': return Jiffy(dateTime).add(months: recurNumber);
      case 'Years': return Jiffy(dateTime).add(years: recurNumber);
      default: return null;
    }
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

}