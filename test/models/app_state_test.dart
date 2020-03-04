import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:test/test.dart';

import '../mocks/mock_data.dart';
import '../mocks/mock_nav_helper.dart';
import '../mocks/mock_task_master_auth.dart';
import '../mocks/mock_task_repository.dart';

void main() {

  TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
  TaskItem birthday = TaskItem.fromJson(birthdayJSON);
  TaskItem future = TaskItem.fromJson(futureJSON);
  TaskItem past = TaskItem.fromJson(pastJSON);

  List<TaskItem> all = [catLitter, birthday, future, past];

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
    var appState = createAppState(all);
    expect(appState.title, 'TaskMaster 3000');
    expect(appState.taskItems.length, 4);
  });

  test('getFilteredTasks no scheduled no completed', () {
    var appState = createAppState(all);
    var filteredTasks = appState.getFilteredTasks(false, false);
    expect(filteredTasks.length, 2);
    expect(filteredTasks, contains(birthday));
    expect(filteredTasks, contains(past));
  });

  test('getFilteredTasks yes scheduled no completed', () {
    var appState = createAppState(all);
    var filteredTasks = appState.getFilteredTasks(true, false);
    expect(filteredTasks.length, 3);
    expect(filteredTasks, contains(birthday));
    expect(filteredTasks, contains(past));
    expect(filteredTasks, contains(future));
  });

  test('getFilteredTasks no scheduled yes completed', () {
    var appState = createAppState(all);
    var filteredTasks = appState.getFilteredTasks(false, true);
    expect(filteredTasks.length, 3);
    expect(filteredTasks, contains(birthday));
    expect(filteredTasks, contains(past));
    expect(filteredTasks, contains(catLitter));
  });

  test('getFilteredTasks yes scheduled yes completed', () {
    var appState = createAppState(all);
    var filteredTasks = appState.getFilteredTasks(true, true);
    expect(filteredTasks.length, 4);
    expect(filteredTasks, contains(birthday));
    expect(filteredTasks, contains(past));
    expect(filteredTasks, contains(catLitter));
    expect(filteredTasks, contains(future));
  });

  test('getFilteredTasks empty list', () {
    var appState = createAppState([]);
    var filteredTasks = appState.getFilteredTasks(true, true);
    expect(filteredTasks.length, 0);
  });


  test('findTaskItemWithId', () {
    var appState = createAppState(all);
    var taskItemWithId = appState.findTaskItemWithId(26);
    expect(taskItemWithId, birthday);
  });

  test('findTaskItemWithId no result', () {
    var appState = createAppState(all);
    var taskItemWithId = appState.findTaskItemWithId(23);
    expect(taskItemWithId, null);
  });

  test('updateTaskListWithUpdatedTask', () {
    var idToReplace = past.id.value;
    var newName = 'Barter';

    var appState = createAppState(all);

    var taskItem = new TaskItem();
    taskItem.id.initializeValue(idToReplace);
    taskItem.name.initializeValue(newName);

    var updated = appState.updateTaskListWithUpdatedTask(taskItem);
    expect(updated, taskItem);
    expect(appState.taskItems.length, all.length);

    var pulled = appState.findTaskItemWithId(idToReplace);
    expect(pulled, updated);
    expect(pulled.name.value, newName);
  });

}
