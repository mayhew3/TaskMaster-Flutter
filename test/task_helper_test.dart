
import 'package:flutter/cupertino.dart';
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
    var now = DateTime.now();
    birthdayTask.completionDate.initializeValue(now);
    birthdayJSON['completion_date'] = now;

    var taskHelper = createTaskHelper(taskItems: [birthdayTask]);
    var mockAppState = taskHelper.appState;

    var inboundTask = TaskItem.fromJson(birthdayJSON, mockAppState.sprints);
    inboundTask.completionDate.initializeValue(null);

    when(taskRepository.completeTask(birthdayTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(birthdayTask, false, stateSetter);
    verify(mockAppState.notificationScheduler.syncNotificationForTask(birthdayTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, birthdayTask);
    expect(birthdayTask.pendingCompletion, false);
    expect(birthdayTask.completionDate.originalValue, null);
    expect(birthdayTask.completionDate.value, null);

  });

  test('completeTask recur', () async {
    var taskHelper = createTaskHelper(taskItems: [catLitterTask]);
    var mockAppState = taskHelper.appState;

    var inboundTask = TaskItem.fromJson(catLitterJSON, mockAppState.sprints);
    var now = DateTime.now();
    inboundTask.completionDate.initializeValue(now);

    when(taskRepository.completeTask(catLitterTask)).thenAnswer((_) => Future.value(inboundTask));
    when(taskRepository.addTask(argThat(isA<TaskItem>()))).thenAnswer((invocation) => Future.value(invocation.positionalArguments[0]));
    when(mockAppState.addNewTaskToList(argThat(isA<TaskItem>()))).thenAnswer((invocation) => invocation.positionalArguments[0]);

    var returnedTask = await taskHelper.completeTask(catLitterTask, true, stateSetter);
    verify(mockAppState.notificationScheduler.syncNotificationForTask(catLitterTask));
    verify(mockAppState.notificationScheduler.updateBadge());
    verify(taskRepository.addTask(any));
    verify(mockAppState.addNewTaskToList(any));
    verify(mockAppState.notificationScheduler.syncNotificationForTask(any));
    // verify(mockAppState.notificationScheduler.updateBadge());

    expect(returnedTask, catLitterTask);
    expect(catLitterTask.pendingCompletion, false);
    expect(catLitterTask.completionDate.originalValue, now);
    expect(catLitterTask.completionDate.value, now);

  });


}