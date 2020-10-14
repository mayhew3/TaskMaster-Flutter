
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

  test('addTask', () {
    var taskHelper = createTaskHelper(taskItems: [catLitterTask]);
    var mockAppState = taskHelper.appState;
    var taskItem = TaskItem.fromJson(birthdayJSON, allSprints);

    when(taskRepository.addTask(taskItem)).thenAnswer((_) => Future.value(taskItem));
    when(mockAppState.addNewTaskToList(taskItem)).thenReturn(taskItem);

    taskHelper.addTask(taskItem).then((_) {
      verify(taskRepository.addTask(taskItem));
      verify(mockAppState.addNewTaskToList(taskItem));
      verify(mockAppState.notificationScheduler.syncNotificationForTask(birthdayTask));
      verify(mockAppState.notificationScheduler.updateBadge());
    });

  });


}