
import 'package:flutter/cupertino.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';
import 'mocks/mock_data.dart';
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

    var originalStart = Jiffy(originalTask.startDate.value).startOf(Units.SECOND);
    var newStart = Jiffy(addedTask.startDate.value).startOf(Units.SECOND);
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


}