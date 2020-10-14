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
      sprints: sprints
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
    expect(appState.sprints.length, 2);
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
