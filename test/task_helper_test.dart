
import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';
import 'mocks/mock_data.dart';
import 'mocks/mock_nav_helper.dart';
import 'mocks/mock_task_master_auth.dart';
import 'mocks/mock_task_repository.dart';

void main() {

  MockTaskRepository mockTaskRepository = MockTaskRepository();
  MockNavHelper mockNavHelper = MockNavHelper(taskRepository: mockTaskRepository);
  StateSetter stateSetter;

  TaskHelper createTaskHelper() {
    var taskHelper = TaskHelper(
        appState: MockAppState(taskItems: allTasks, sprints: allSprints),
        repository: mockTaskRepository,
        auth: MockTaskMasterAuth(),
        stateSetter: stateSetter);
    taskHelper.navHelper = mockNavHelper;
    return taskHelper;
  }

  test('reloadTasks', () async {
    var taskHelper = createTaskHelper();
    await taskHelper.reloadTasks();
    verify(mockNavHelper.goToLoadingScreen('Reloading tasks...'));
    verify(taskHelper.appState.notificationScheduler.cancelAllNotifications());
    verify(mockTaskRepository.loadTasks(stateSetter));
    verify(taskHelper.appState.finishedLoading());
    verify(taskHelper.appState.notificationScheduler.updateBadge());
    verify(mockNavHelper.goToHomeScreen());
  });
}