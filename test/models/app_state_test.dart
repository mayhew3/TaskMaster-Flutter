import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:test/test.dart';

import '../mocks/mock_data.dart';
import '../mocks/mock_nav_helper.dart';
import '../mocks/mock_task_master_auth.dart';
import '../mocks/mock_task_repository.dart';

void main() {

  AppState createAppState(List<TaskItem> taskItems) {
    var appState = AppState(
      auth: MockTaskMasterAuth(),
      taskItems: taskItems,
    );
    var navHelper = MockNavHelper(
      taskRepository: MockTaskRepository(),
    );
    appState.updateNavHelper(navHelper);
    return appState;
  }

  test('Should be constructed', () {
    var appState = createAppState(allTasks);
    expect(appState.title, 'TaskMaster 3000');
    expect(appState.taskItems.length, 4);
  });

  test('getFilteredTasks no scheduled no completed', () {
    var appState = createAppState(allTasks);
    var filteredTasks = appState.getFilteredTasks(false, false, []);
    expect(filteredTasks.length, 2);
    expect(filteredTasks, contains(birthdayTask));
    expect(filteredTasks, contains(pastTask));
  });

  test('getFilteredTasks yes scheduled no completed', () {
    var appState = createAppState(allTasks);
    var filteredTasks = appState.getFilteredTasks(true, false, []);
    expect(filteredTasks.length, 3);
    expect(filteredTasks, contains(birthdayTask));
    expect(filteredTasks, contains(pastTask));
    expect(filteredTasks, contains(futureTask));
  });

  test('getFilteredTasks no scheduled yes completed', () {
    var appState = createAppState(allTasks);
    var filteredTasks = appState.getFilteredTasks(false, true, []);
    expect(filteredTasks.length, 3);
    expect(filteredTasks, contains(birthdayTask));
    expect(filteredTasks, contains(pastTask));
    expect(filteredTasks, contains(catLitterTask));
  });

  test('getFilteredTasks yes scheduled yes completed', () {
    var appState = createAppState(allTasks);
    var filteredTasks = appState.getFilteredTasks(true, true, []);
    expect(filteredTasks.length, 4);
    expect(filteredTasks, contains(birthdayTask));
    expect(filteredTasks, contains(pastTask));
    expect(filteredTasks, contains(catLitterTask));
    expect(filteredTasks, contains(futureTask));
  });

  test('getFilteredTasks empty list', () {
    var appState = createAppState([]);
    var filteredTasks = appState.getFilteredTasks(true, true, []);
    expect(filteredTasks.length, 0);
  });


  test('findTaskItemWithId', () {
    var appState = createAppState(allTasks);
    var taskItemWithId = appState.findTaskItemWithId(26);
    expect(taskItemWithId, birthdayTask);
  });

  test('findTaskItemWithId no result', () {
    var appState = createAppState(allTasks);
    var taskItemWithId = appState.findTaskItemWithId(23);
    expect(taskItemWithId, null);
  });

  test('updateTaskListWithUpdatedTask', () {
    var idToReplace = pastTask.id.value;
    var newName = 'Barter';

    var appState = createAppState(allTasks);

    var taskItem = new TaskItem();
    taskItem.id.initializeValue(idToReplace);
    taskItem.name.initializeValue(newName);

    var updated = appState.updateTaskListWithUpdatedTask(taskItem);
    expect(updated, taskItem);
    expect(appState.taskItems.length, allTasks.length);

    var pulled = appState.findTaskItemWithId(idToReplace);
    expect(pulled, updated);
    expect(pulled.name.value, newName);
  });

}
