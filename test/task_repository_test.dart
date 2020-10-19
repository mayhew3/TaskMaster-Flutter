import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';
import 'mocks/mock_client.dart';

import 'mocks/mock_data.dart';

void main() {
  group('TaskRepository', () {

    test('loadTasks with no tasks', () async {
      AppState mockAppState = new MockAppState();
      var mockClient = new MockClient([], []);
      TaskRepository taskRepository = TaskRepository(appState: mockAppState, client: mockClient);

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = mockAppState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 0);
    });

    test('loadTasks with tasks', () async {
      List<TaskItem> testItems = [];
      testItems.add(TaskItem.fromJson(catLitterJSON, allSprints));
      testItems.add(TaskItem.fromJson(birthdayJSON, allSprints));

      var mockClient = new MockClient(testItems, allSprints);
      var mockAppState = new MockAppState();
      TaskRepository taskRepository = TaskRepository(appState: mockAppState, client: mockClient);

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = mockAppState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 2);
    });

    // todo: addTask, updateTask, addSnooze, addSprint
  });
}