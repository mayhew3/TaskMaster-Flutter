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

      String url = 'test';

      String json = '{"person_id": 1, "tasks": []}';
/*

      when(mockClient.get(url))
          .thenAnswer((_) async {
        return http.Response(json, 200);
      });
*/

      expect(await taskRepository.loadTasks(), const TypeMatcher<List<TaskItem>>());
    });

  });
}