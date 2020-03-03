import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mock_app_state.dart';
import 'mock_client.dart';

import 'mock_data.dart';

void main() {
  group('TaskRepository', () {

    test('loadTasks with no tasks', () async {
      AppState mockAppState = new MockAppState();
      var mockClient = new MockClient([]);
      TaskRepository taskRepository = TaskRepository(appState: mockAppState, client: mockClient);

      List<TaskItem> taskList = await taskRepository.loadTasks();
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 0);
    });

    test('loadTasks with tasks', () async {
      List<TaskItem> testItems = [];
      testItems.add(TaskItem.fromJson(catLitterJSON));
      testItems.add(TaskItem.fromJson(birthdayJSON));

      AppState mockAppState = new MockAppState();
      var mockClient = new MockClient(testItems);
      TaskRepository taskRepository = TaskRepository(appState: mockAppState, client: mockClient);

      List<TaskItem> taskList = await taskRepository.loadTasks();
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 2);
    });

  });
}