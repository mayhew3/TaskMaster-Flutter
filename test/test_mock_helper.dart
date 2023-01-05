import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_task_master_auth.dart';
import 'test_mock_helper.mocks.dart';

@GenerateMocks([http.Client, GoogleSignInAccount])
void main() {

}

class TestMockHelper {

  static TaskRepository createTaskRepositoryWithoutLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
    String email = 'scorpy@gmail.com';
    TaskMasterAuth auth = MockTaskMasterAuth();
    GoogleSignInAccount googleUser = new MockGoogleSignInAccount();
    http.Client client = new MockClient();

    AppState appState = new AppState(auth: auth);
    appState.currentUser = googleUser;
    appState.tokenRetrieved = true;
    TaskRepository taskRepository = TaskRepository(appState: appState, client: client);

    when(client.get(taskRepository.getUriWithParameters('/api/tasks', {'email': email}), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(_mockTheJSON(taskItems: taskItems, sprints: sprints), 200));
    when(googleUser.email)
        .thenAnswer((_) => email);
    return taskRepository;
  }

  static Future<TaskRepository> createTaskRepositoryAndLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) async {
    TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: taskItems, sprints: sprints);
    await taskRepository.loadTasks((callback) => callback());
    return taskRepository;
  }

  // helper methods

  static dynamic _getMockTask(TaskItem taskItem) {
    var mockObj = {};
    for (var field in taskItem.fields) {
      mockObj[field.fieldName] = field.formatForJSON();
    }
    var sprintAssignments = [];
    for (var sprint in taskItem.sprints) {
      var obj = {
        'id': 1234,
        'sprint_id': sprint.id.value
      };
      sprintAssignments.add(obj);
    }
    mockObj['sprint_assignments'] = sprintAssignments;
    return mockObj;
  }

  static String _mockTheJSON({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
    var taskObj = {};
    taskObj['person_id'] = 1;
    var mockPlayerList = [];
    var mockSprintList = [];

    for (var taskItem in taskItems ?? allTasks) {
      mockPlayerList.add(_getMockTask(taskItem));
    }

    for (var sprintItem in sprints ?? allSprints) {
      var mockObj = {};
      for (var field in sprintItem.fields) {
        mockObj[field.fieldName] = field.formatForJSON();
      }
      mockSprintList.add(mockObj);
    }

    taskObj['tasks'] = mockPlayerList;
    taskObj['sprints'] = mockSprintList;
    return json.encode(taskObj);
  }

}
