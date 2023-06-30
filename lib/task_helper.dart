
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_preview.dart';
import 'package:taskmaster/task_repository.dart';

import 'app_state.dart';
import 'auth.dart';
import 'models/task_item.dart';
import 'nav_helper.dart';

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
    appState.updateTasksAndSprints([], appState.sprints, []);

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
    return updateTaskList(inboundTask);
  }

  Future<TaskItem> addTaskIteration(TaskItemPreview taskItem, int personId) async {
    TaskItem inboundTask = await repository.addTaskIteration(taskItem, personId);
    return updateTaskList(inboundTask);
  }

  TaskItem updateTaskList(TaskItem committedTask) {
    stateSetter(() {
      var addedTask = appState.addNewTaskToList(committedTask);
      appState.notificationScheduler.updateNotificationForTask(addedTask);
    });
    appState.notificationScheduler.updateBadge();
    return committedTask;
  }

  TaskItemPreview? maybeCreateNextIteration(TaskItem taskItem, bool completed, DateTime? completionDate) {

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

  TaskItemPreview createNextIteration(TaskItemPreview taskItem, DateTime completionDate) {

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

    if (recurWait) {
      nextAnchorDate = _getAdjustedDate(completionDate, recurNumber, recurUnit);
    } else {
      nextAnchorDate = _getAdjustedDate(anchorDate, recurNumber, recurUnit);
    }

    DateTime dateWithTime = _getClosestDateForTime(anchorDate, nextAnchorDate);
    Duration duration = dateWithTime.difference(anchorDate);

    TaskItemPreview nextScheduledTask = taskItem.createPreview(
        startDate: _addToDate(taskItem.startDate, duration),
        targetDate: _addToDate(taskItem.targetDate, duration),
        urgentDate: _addToDate(taskItem.urgentDate, duration),
        dueDate: _addToDate(taskItem.dueDate, duration),
        recurIteration: recurIteration + 1
    );

    return nextScheduledTask;
  }

  Future<TaskItem> completeTask(TaskItem taskItem, bool completed, StateSetter stateSetter) async {
    if (completed && taskItem.completionDate != null) {
      throw new ArgumentError("CompleteTask() called with non-null completion date and completed true.");
    } else if (!completed && taskItem.completionDate == null) {
      throw new ArgumentError("CompleteTask() called with null completion date and completed false.");
    }

    int personId = taskItem.personId;

    stateSetter(() {
      taskItem.pendingCompletion = true;
    });

    DateTime? completionDate = completed ? DateTime.now() : null;
    TaskItemPreview? nextScheduledTask = maybeCreateNextIteration(taskItem, completed, completionDate);

    var inboundTask = await repository.completeTask(taskItem, completionDate);

    stateSetter(() {
      appState.replaceTaskItem(taskItem, inboundTask);
      appState.notificationScheduler.updateNotificationForTask(inboundTask);
    });
    appState.notificationScheduler.updateBadge();

    if (nextScheduledTask != null) {
      await addTaskIteration(nextScheduledTask, personId);
    }

    return inboundTask;
  }

  Future<void> deleteTask(TaskItem taskItem, StateSetter stateSetter) async {
    int taskId = taskItem.id;
    await repository.deleteTask(taskItem);
    print('Removal of task successful!');
    await appState.notificationScheduler.cancelNotificationsForTaskId(taskId);
    stateSetter(() {
      appState.sprints.forEach((sprint) => sprint.removeFromTasks(taskItem));
      appState.deleteTaskFromList(taskItem);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> updateTask(TaskItem taskItem, TaskItemBlueprint changes, StateSetter stateSetter) async {
    var inboundTask = await repository.updateTask(taskItem, changes);
    stateSetter(() {
      appState.replaceTaskItem(taskItem, inboundTask);
    });
    await appState.notificationScheduler.updateNotificationForTask(taskItem);
    appState.notificationScheduler.updateBadge();
    return inboundTask;
  }

  void previewSnooze(TaskItemBlueprint taskItemEdit, int numUnits, String unitSize, TaskDateType dateType) {
    _generatePreview(taskItemEdit, numUnits, unitSize, dateType);
  }

  Future<TaskItem> snoozeTask(TaskItem taskItem, TaskItemBlueprint taskItemEdit, int numUnits, String unitSize, TaskDateType dateType, StateSetter stateSetter) async {
    _generatePreview(taskItemEdit, numUnits, unitSize, dateType);

    DateTime? originalValue = dateType.dateFieldGetter(taskItem);
    DateTime relevantDateField = dateType.dateFieldGetter(taskItemEdit)!;

    TaskItem updatedTask = await updateTask(taskItem, taskItemEdit, stateSetter);

    Snooze snooze = new Snooze(
        taskId: updatedTask.id,
        snoozeNumber: numUnits,
        snoozeUnits: unitSize,
        snoozeAnchor: dateType.label,
        previousAnchor: originalValue,
        newAnchor: relevantDateField);

    await repository.addSnooze(snooze);
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

  void _generatePreview(TaskItemBlueprint taskItemEdit, int numUnits, String unitSize, TaskDateType dateType) {
    DateTime snoozeDate = DateTime.now();
    DateTime adjustedDate = _getAdjustedDate(snoozeDate, numUnits, unitSize);

    DateTime? relevantDate = dateType.dateFieldGetter(taskItemEdit);

    if (relevantDate == null) {
      dateType.dateFieldSetter(taskItemEdit, adjustedDate);
    } else {
      Duration difference = adjustedDate.difference(relevantDate);
      TaskDateTypes.allTypes.forEach((taskDateType) => taskItemEdit.incrementDateIfExists(taskDateType, difference));
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

}