import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';

import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'mocks/mock_task_master_auth.dart';
import 'task_repository_test.mocks.dart';

import 'dart:convert';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';

@GenerateMocks([http.Client, GoogleSignInAccount])
void main() {
  group('TaskRepository', () {

    late http.Client client;
    late AppState appState;
    final Uri tasksAPI = Uri.parse("https://taskmaster-general.herokuapp.com/api/tasks");

    dynamic _getMockTask(TaskItem taskItem) {
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

    String _mockTheJSON({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
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

    TaskRepository createTaskRepositoryWithoutLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
      TaskMasterAuth auth = MockTaskMasterAuth();
      GoogleSignInAccount googleUser = new MockGoogleSignInAccount();
      appState = new AppState(auth: auth);
      appState.currentUser = googleUser;
      appState.tokenRetrieved = true;
      client = new MockClient();
      var taskRepository = TaskRepository(appState: appState, client: client);
      when(client.get(taskRepository.getUriWithParameters('/api/tasks', {'email': 'scorpy@gmail.com'}), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(_mockTheJSON(taskItems: taskItems, sprints: sprints), 200));
      when(googleUser.email)
          .thenAnswer((_) => 'scorpy@gmail.com');
      return taskRepository;
    }

    Future<TaskRepository> createTaskRepositoryAndLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) async {
      TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: taskItems, sprints: sprints);
      await taskRepository.loadTasks((callback) => callback());
      return taskRepository;
    }


    // helper methods

    dynamic _encodeBody(List<int> body, {int? id, DateTime? dateTime}) {
      var utfDecoded = utf8.decode(body);
      var jsonObj = json.decode(utfDecoded);
      var jsonTask = jsonObj["task"];
      if (id != null) {
        jsonTask["id"] = id;
      }
      if (dateTime != null) {
        jsonTask["date_added"] =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toUtc());
      }
      return json.encode(jsonTask);
    }

    void _validateToken(Invocation invocation) async {
      var headers = invocation.namedArguments[Symbol("headers")];
      var tokenInfo = headers[HttpHeaders.authorizationHeader];
      var expectedToken = await appState.getIdToken();
      expect(tokenInfo, expectedToken);
    }


    // tests

    test('loadTasks with no tasks', () async {
      TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: []);

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = appState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 0);
    });

    test('loadTasks with tasks', () async {
      TaskRepository taskRepository = createTaskRepositoryWithoutLoad();

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = appState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList, hasLength(allTasks.length));
    });

    test('addTask', () async {
      int id = 2345;

      TaskRepository taskRepository = await createTaskRepositoryAndLoad();

      var addedItem = (TaskItemBuilder.asPreCommit()).create();

      when(client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((invocation) async {
        _validateToken(invocation);

        var body = invocation.namedArguments[Symbol("body")];
        var payload = _encodeBody(body, id: id, dateTime: DateTime.now());
        return Future<http.Response>.value(http.Response(payload, 200));
      });

      var returnedItem = await taskRepository.addTask(addedItem);

      verify(client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")));

      expect(returnedItem.id.value, id);
      expect(returnedItem.name.value, addedItem.name.value);
      expect(returnedItem.personId.value, 1);
      expect(returnedItem.dateAdded.value, isNot(null));
    });

    test('updateTask', () async {
      TaskItem taskItem = TaskItemBuilder.asDefault().create();
      var taskItems = [
        taskItem
      ];

      TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: taskItems);

      when(client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((invocation) async {
        _validateToken(invocation);

        var body = invocation.namedArguments[Symbol("body")];
        var payload = _encodeBody(body);
        return Future<http.Response>.value(http.Response(payload, 200));
      });

      var newProject = "Groovy Time";
      var newTargetDate = DateTime.now().add(Duration(days: 3));

      taskItem.project.value = newProject;
      taskItem.targetDate.value = newTargetDate;

      var returnedItem = await taskRepository.updateTask(taskItem);

      verify(client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")));

      expect(returnedItem.project.value, newProject);
      expect(returnedItem.project.originalValue, newProject);
      expect(returnedItem.targetDate.value, newTargetDate);
      expect(returnedItem.targetDate.originalValue, newTargetDate);

    });

    // todo: updateTask, addSnooze, addSprint
  });


}