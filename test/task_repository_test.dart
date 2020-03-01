import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'MockAppState.dart';
import 'MockClient.dart';

void main() {
  group('TaskRepository', () {

    test('Should be constructed', () async {
      AppState mockAppState = new MockAppState();
      var mockClient = new MockClient();
      TaskRepository taskRepository = TaskRepository(appState: mockAppState, client: mockClient);

      List<TaskItem> taskList = await taskRepository.loadTasks();
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 0);
    });

  });
}