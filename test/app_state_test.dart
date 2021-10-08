import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_nav_helper.dart';
import 'mocks/mock_task_master_auth.dart';
import 'mocks/mock_task_repository.dart';

void main() {

  AppState createAppState({
    List<TaskItem>? taskItems,
    List<Sprint>? sprints
  }) {
    var appState = AppState(
      auth: MockTaskMasterAuth(),
      taskItems: taskItems ?? allTasks,
      sprints: sprints ?? allSprints
    );
    var navHelper = MockNavHelperOld(
      appState: appState,
      taskRepository: MockTaskRepository(),
    );
    appState.updateNavHelper(navHelper);
    return appState;
  }

  test('Should be constructed', () {
    var appState = createAppState();
    expect(appState.title, 'TaskMaster 3000');
    expect(appState.taskItems.length, allTasks.length);
    expect(appState.sprints.length, allSprints.length);
  });

  test('findTaskItemWithId', () {
    var appState = createAppState();
    var taskItemWithId = appState.findTaskItemWithId(26);
    expect(taskItemWithId, birthdayTask);
  });

  test('findTaskItemWithId no result', () {
    var appState = createAppState();
    var taskItemWithId = appState.findTaskItemWithId(23);
    expect(taskItemWithId, null);
  });

  test('getActiveSprint with result', () {
    var appState = createAppState();
    var activeSprint = appState.getActiveSprint();
    expect(activeSprint, currentSprint);
  });

  test('getActiveSprint no result', () {
    var appState = createAppState(sprints: [pastSprint]);
    var activeSprint = appState.getActiveSprint();
    expect(activeSprint, null);
  });

  test('getActiveSprint empty set', () {
    var appState = createAppState(sprints: []);
    var activeSprint = appState.getActiveSprint();
    expect(activeSprint, null);
  });

  test('getLastCompletedSprint with result', () {
    var appState = createAppState();
    var activeSprint = appState.getLastCompletedSprint();
    expect(activeSprint, pastSprint);
  });

  test('getLastCompletedSprint no result', () {
    var appState = createAppState(sprints: [currentSprint]);
    var activeSprint = appState.getLastCompletedSprint();
    expect(activeSprint, null);
  });

  test('getLastCompletedSprint empty set', () {
    var appState = createAppState(sprints: []);
    var activeSprint = appState.getLastCompletedSprint();
    expect(activeSprint, null);
  });

  test('getTasksForActiveSprint with result', () {
    var appState = createAppState();
    var taskItems = appState.getTasksForActiveSprint();
    expect(taskItems, [catLitterTask, birthdayTask, burnTask]);
  });

  test('getTasksForActiveSprint no active sprint', () {
    var appState = createAppState(sprints: []);
    var taskItems = appState.getTasksForActiveSprint();
    expect(taskItems, []);
  });

  test('findSprintWithId', () {
    var appState = createAppState();
    var sprintWithId = appState.findSprintWithId(11);
    expect(sprintWithId, currentSprint);
  });

  test('findSprintWithId no result', () {
    var appState = createAppState();
    var sprintWithId = appState.findSprintWithId(23);
    expect(sprintWithId, null);
  });


}
