import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_recurrence_builder.dart';
import 'mocks/mock_task_master_auth.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
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
    var mockTaskRepository = MockTaskRepository();
    var navHelper = MockNavHelper();
    when(navHelper.appState).thenReturn(appState);
    when(navHelper.taskRepository).thenReturn(mockTaskRepository);
    appState.updateNavHelper(navHelper);
    return appState;
  }

  resetAppState(AppState appState, Iterable<TaskRecurrence> recurrences) {
    for (var taskItem in appState.taskItems) {
      for (var recurrence in recurrences) {
        recurrence.removeFromTaskItems(taskItem);
      }
    }
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

  test('updateTasksAndSprints', () {
    var appState = createAppState();

    expect(catLitterTask.recurrenceId, 1, reason: 'Task data should have recurrence_id.');
    expect(catLitterTask.recurrence, null, reason: 'Task data has recurrence_id but no attached object yet.');

    appState.updateTasksAndSprints(allTasks, allSprints, [onlyRecurrence]);

    expect(catLitterTask.recurrence, isNot(null), reason: 'updateTasksAndSprints should attach taskRecurrence to matching tasks.');

    resetAppState(appState, [onlyRecurrence]);
  });

  test('replaceTaskItem', () {
    var appState = createAppState();
    appState.updateTasksAndSprints(allTasks, allSprints, [onlyRecurrence]);

    var oldTaskItem = catLitterTask;
    var newId = 756;
    var newTaskItem = (TaskItemBuilder.asDefault()
      ..id = newId
      ..recurNumber = 6
      ..recurUnit = 'Weeks'
      ..recurWait = false
      ..recurIteration = 1
      ..recurrenceId = 1
    ).create();

    var oldId = oldTaskItem.id;
    appState.replaceTaskItem(oldTaskItem, newTaskItem);

    expect(appState.findTaskItemWithId(oldId), null);
    expect(appState.findTaskItemWithId(newId), newTaskItem);

    var activeSprint = appState.getActiveSprint()!;
    expect(activeSprint.taskItems.indexOf(oldTaskItem), -1);
    expect(activeSprint.taskItems.indexOf(newTaskItem), 0);

    resetAppState(appState, [onlyRecurrence]);
  });

  test('replaceTaskRecurrence', () {
    var appState = createAppState();
    appState.updateTasksAndSprints(allTasks, allSprints, [onlyRecurrence]);

    TaskRecurrence secondRecurrence = (TaskRecurrenceBuilder.asPreCommit()..id = 2).create();

    expect(onlyRecurrence.taskItems.length, 2, reason: 'SANITY: Expect 2 task items on original recurrence.');
    expect(secondRecurrence.taskItems.length, 0, reason: 'SANITY: Expect no task items yet on new recurrence.');

    appState.replaceTaskRecurrence(onlyRecurrence, secondRecurrence);

    expect(appState.findRecurrenceWithId(onlyRecurrence.id), null);
    expect(appState.findRecurrenceWithId(secondRecurrence.id), secondRecurrence);

    expect(secondRecurrence.taskItems.length, 2, reason: 'Expect both items to be copied from original recurrence.');

    resetAppState(appState, [onlyRecurrence, secondRecurrence]);
  });

  test('syncAllNotifications', () async {
    var appState = createAppState();
    appState.updateTasksAndSprints(allTasks, allSprints, [onlyRecurrence]);

    NotificationScheduler scheduler = MockNotificationScheduler();
    appState.updateNotificationScheduler(scheduler);

    var activeSprint = appState.getActiveSprint();

    await appState.syncAllNotifications();

    verify(scheduler.cancelAllNotifications());
    verify(scheduler.syncNotificationForTasksAndSprint(appState.taskItems, activeSprint));
  });

}
