
import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';
import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_nav_helper.dart';
import 'mocks/mock_task_master_auth.dart';
import 'mocks/mock_task_repository.dart';

void main() {

  MockTaskRepository taskRepository = MockTaskRepository();
  MockNavHelper navHelper = MockNavHelper(taskRepository: taskRepository);
  StateSetter stateSetter = (callback) => callback();

  TaskHelper createTaskHelper({List<TaskItem> taskItems, List<Sprint> sprints}) {
    MockAppState mockAppState = MockAppState(
        taskItems: taskItems ?? allTasks,
        sprints: sprints ?? allSprints);
    var taskHelper = TaskHelper(
        appState: mockAppState,
        repository: taskRepository,
        auth: MockTaskMasterAuth(),
        stateSetter: stateSetter);
    taskHelper.navHelper = navHelper;
    return taskHelper;
  }

  test('reloadTasks', () async {
    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    await taskHelper.reloadTasks();
    verify(navHelper.goToLoadingScreen('Reloading tasks...'));
    verify(mockAppState.notificationScheduler.cancelAllNotifications());
    verify(taskRepository.loadTasks(stateSetter));
    verify(mockAppState.finishedLoading());
    verify(mockAppState.notificationScheduler.updateBadge());
    verify(navHelper.goToHomeScreen());
  });

  test('addTask', () async {
    var taskHelper = createTaskHelper(taskItems: [catLitterTask]);
    var mockAppState = taskHelper.appState;
    var taskItem = TaskItem.fromJson(birthdayJSON, allSprints);

    when(taskRepository.addTask(taskItem)).thenAnswer((_) => Future.value(taskItem));
    when(mockAppState.addNewTaskToList(taskItem)).thenReturn(taskItem);

    await taskHelper.addTask(taskItem);
    verify(taskRepository.addTask(taskItem));
    verify(mockAppState.addNewTaskToList(taskItem));
    verify(mockAppState.notificationScheduler.syncNotificationForTask(birthdayTask));
    verify(mockAppState.notificationScheduler.updateBadge());
  });

  test('completeTask no recur', () async {
    var taskHelper = createTaskHelper(taskItems: [birthdayTask]);
    var mockAppState = taskHelper.appState;

    var inboundTask = TaskItem.fromJson(birthdayJSON, mockAppState.sprints);
    var now = DateTime.now();
    inboundTask.completionDate.initializeValue(now);

    when(taskRepository.completeTask(birthdayTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(birthdayTask, true, stateSetter);
    verify(mockAppState.notificationScheduler.syncNotificationForTask(birthdayTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, birthdayTask);
    expect(birthdayTask.pendingCompletion, false);
    expect(birthdayTask.completionDate.originalValue, now);
    expect(birthdayTask.completionDate.value, now);

  });

  test('completeTask uncomplete no recur', () async {
    var originalTask = burnTask;
    var originalJSON = burnJSON;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;

    var inboundTask = TaskItem.fromJson(originalJSON, mockAppState.sprints);
    inboundTask.completionDate.initializeValue(null);

    when(taskRepository.completeTask(originalTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(originalTask, false, stateSetter);
    verify(mockAppState.notificationScheduler.syncNotificationForTask(originalTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, originalTask);
    expect(originalTask.pendingCompletion, false);
    expect(originalTask.completionDate.originalValue, null);
    expect(originalTask.completionDate.value, null);

  });

  test('completeTask recur', () async {
    var originalTask = pastTask;
    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;

    var inboundTask = TaskItem.fromJson(pastJSON, mockAppState.sprints);
    var now = DateTime.now();
    inboundTask.completionDate.initializeValue(now);

    TaskItem addedTask;

    when(taskRepository.completeTask(originalTask)).thenAnswer((_) => Future.value(inboundTask));
    when(taskRepository.addTask(argThat(isA<TaskItem>()))).thenAnswer((invocation) {
      addedTask = invocation.positionalArguments[0];
      return Future.value(addedTask);
    });
    when(mockAppState.addNewTaskToList(argThat(isA<TaskItem>()))).thenAnswer((invocation) => invocation.positionalArguments[0]);

    var returnedTask = await taskHelper.completeTask(originalTask, true, stateSetter);
    verify(mockAppState.notificationScheduler.syncNotificationForTask(originalTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verify(taskRepository.addTask(any));
    verify(mockAppState.addNewTaskToList(any));
    verify(mockAppState.notificationScheduler.syncNotificationForTask(any));

    expect(returnedTask, originalTask);
    expect(originalTask.pendingCompletion, false);
    expect(originalTask.completionDate.originalValue, now);
    expect(originalTask.completionDate.value, now);

    expect(addedTask, isNot(null), reason: 'Expect new task to be created based on recur.');
    expect(addedTask, isNot(returnedTask));
    expect(addedTask.pendingCompletion, false);
    expect(addedTask.completionDate.value, null, reason: 'New recurrence should not have completion date.');
    expect(addedTask.completionDate.originalValue, null, reason: 'New recurrence should not have completion date.');

    var originalStart = DateUtil.withoutMillis(originalTask.startDate.value);
    var newStart = DateUtil.withoutMillis(addedTask.startDate.value);
    var diff = newStart.difference(originalStart).inDays;
    expect(diff, 42, reason: 'Recurrence of 6 weeks should make new task 42 days after original.');
  });

  test('completeTask uncomplete recur should not recur', () async {
    var originalTask = catLitterTask;
    var originalJSON = catLitterJSON;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;

    var inboundTask = TaskItem.fromJson(originalJSON, mockAppState.sprints);
    inboundTask.completionDate.initializeValue(null);

    when(taskRepository.completeTask(originalTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(originalTask, false, stateSetter);
    verify(mockAppState.notificationScheduler.syncNotificationForTask(originalTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, originalTask);
    expect(originalTask.pendingCompletion, false);
    expect(originalTask.completionDate.originalValue, null);
    expect(originalTask.completionDate.value, null);
  });

  test('deleteTask', () async {
    var originalTask = catLitterTask;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;

    await taskHelper.deleteTask(originalTask, stateSetter);
    verify(mockAppState.notificationScheduler.cancelNotificationsForTaskId(originalTask.id.value));
    verify(mockAppState.deleteTaskFromList(originalTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verify(taskRepository.deleteTask(originalTask));

  });


  test('updateTask', () async {
    var originalTask = birthdayTask;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;

    var changedDescription = "Just kidding";
    var changedTarget = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);
    originalTask.description.value = changedDescription;

    originalTask.targetDate.value = changedTarget.toLocal();

    when(taskRepository.updateTask(originalTask)).thenAnswer((realInvocation) => Future.value(TaskItem.fromJson(originalTask.toJSON(), mockAppState.sprints)));

    var returnedItem = await taskHelper.updateTask(originalTask);

    verify(taskRepository.updateTask(originalTask));
    verify(mockAppState.notificationScheduler.syncNotificationForTask(originalTask));
    verify(mockAppState.notificationScheduler.updateBadge());

    expect(returnedItem, originalTask);
    expect(originalTask.description.originalValue, changedDescription);
    expect(originalTask.description.value, changedDescription);
    expect(originalTask.targetDate.originalValue, DateUtil.withoutMillis(changedTarget));
    expect(originalTask.targetDate.value, DateUtil.withoutMillis(changedTarget));
  });

  test('previewSnooze move multiple', () {
    var taskItem = TaskItemBuilder
        .withDates()
        .create();

    var taskHelper = createTaskHelper();

    var originalDue = taskItem.dueDate.value;
    var originalTarget = taskItem.targetDate.value;

    taskHelper.previewSnooze(taskItem, 6, 'Days', TaskDateTypes.target);

    var newTarget = DateUtil.withoutMillis(taskItem.targetDate.value);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');
    expect(taskItem.targetDate.originalValue, originalTarget);

    var newDue = DateUtil.withoutMillis(taskItem.dueDate.value);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be in 13 days.');
    expect(taskItem.dueDate.originalValue, originalDue);

  });


  test('previewSnooze add start', () {
    var taskItem = TaskItemBuilder
        .asDefault()
        .create();

    var taskHelper = createTaskHelper();

    taskHelper.previewSnooze(taskItem, 4, 'Days', TaskDateTypes.start);

    var newStart = DateUtil.withoutMillis(taskItem.startDate.value);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');
    expect(taskItem.startDate.originalValue, null);

  });

  test('snoozeTask move multiple', () async {
    var taskItem = TaskItemBuilder
        .withDates()
        .create();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;

    var originalTarget = taskItem.targetDate.value;

    when(taskRepository.updateTask(taskItem)).thenAnswer((_) => Future.value(TaskItem.fromJson(taskItem.toJSON(), mockAppState.sprints)));

    var returnedItem = await taskHelper.snoozeTask(taskItem, 6, 'Days', TaskDateTypes.target);

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskID.value, returnedItem.id.value);
    expect(snooze.snoozeNumber.value, 6);
    expect(snooze.snoozeUnits.value, 'Days');
    expect(snooze.snoozeAnchor.value, 'Target');
    expect(snooze.previousAnchor.value, originalTarget);
    expect(snooze.newAnchor.value, returnedItem.targetDate.value);

    var newTarget = DateUtil.withoutMillis(returnedItem.targetDate.value);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');
    expect(returnedItem.targetDate.originalValue, newTarget);

    var newDue = DateUtil.withoutMillis(returnedItem.dueDate.value);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be 13 days from now.');
    expect(returnedItem.dueDate.originalValue, newDue);

  });


  test('snooze task add start', () async {
    TaskItem taskItem = TaskItemBuilder
        .asDefault()
        .create();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;

    var originalStart = taskItem.startDate.value;

    when(taskRepository.updateTask(taskItem)).thenAnswer((_) => Future.value(TaskItem.fromJson(taskItem.toJSON(), mockAppState.sprints)));

    var returnedItem = await taskHelper.snoozeTask(taskItem, 4, 'Days', TaskDateTypes.start);

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskID.value, returnedItem.id.value);
    expect(snooze.snoozeNumber.value, 4);
    expect(snooze.snoozeUnits.value, 'Days');
    expect(snooze.snoozeAnchor.value, 'Start');
    expect(snooze.previousAnchor.value, originalStart);
    expect(snooze.newAnchor.value, returnedItem.startDate.value);

    var newStart = DateUtil.withoutMillis(returnedItem.startDate.value);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');
    expect(returnedItem.startDate.originalValue, newStart);

  });

  test('addSprintAndTasks', () async {
    List<TaskItem> taskItems = [
      ((TaskItemBuilder.asDefault()..id=1).create()),
      ((TaskItemBuilder.asDefault()..id=2).create()),
      ((TaskItemBuilder.asDefault()..id=3).create()),
    ];
    Sprint sprint = currentSprint;

    TaskHelper taskHelper = createTaskHelper(taskItems: taskItems, sprints: [pastSprint]);
    MockAppState appState = taskHelper.appState;

    when(taskRepository.addSprint(sprint)).thenAnswer((_) => Future.value(Sprint.fromJson(sprint.toJSON())));

    Sprint returnedSprint = await taskHelper.addSprintAndTasks(sprint, taskItems);

    verify(taskRepository.addSprint(sprint));
    verify(taskRepository.addTasksToSprint(taskItems, returnedSprint));

    expect(appState.sprints, hasLength(2));
    expect(appState.sprints, contains(returnedSprint));

  });

  test('addTaskToSprint', () async {
    List<TaskItem> taskItems = [
      ((TaskItemBuilder.asDefault()..id=1).create()),
      ((TaskItemBuilder.asDefault()..id=2).create()),
      ((TaskItemBuilder.asDefault()..id=3).create()),
    ];
    Sprint sprint = currentSprint;

    TaskHelper taskHelper = createTaskHelper(taskItems: taskItems, sprints: [pastSprint]);
    MockAppState appState = taskHelper.appState;

    Sprint returnedSprint = await taskHelper.addTasksToSprint(sprint, taskItems);

    verifyNever(taskRepository.addSprint(sprint));
    verify(taskRepository.addTasksToSprint(taskItems, returnedSprint));

    expect(appState.sprints, hasLength(1));

  });

}