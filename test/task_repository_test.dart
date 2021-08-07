import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'dart:convert';
import 'mocks/mock_app_state.dart';
import 'mocks/mock_client.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';

void main() {
  group('TaskRepository', () {

    http.Client client;
    AppState appState;
    final Uri tasksAPI = Uri.parse("https://taskmaster-general.herokuapp.com/api/tasks");

    TaskRepository createTaskRepository({List<TaskItem> taskItems, List<Sprint> sprints}) {
      appState = new MockAppState();
      client = new MockClient(taskItems ?? allTasks, sprints ?? allSprints);
      return TaskRepository(appState: appState, client: client);
    }

    // helper methods

    dynamic _encodeBody(List<int> body, {int id, DateTime dateTime}) {
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
      TaskRepository taskRepository = createTaskRepository(taskItems: []);

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = appState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 0);
    });

    test('loadTasks with tasks', () async {
      TaskRepository taskRepository = createTaskRepository();

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = appState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList, hasLength(allTasks.length));
    });

    test('addTask', () async {
      int id = 2345;

      TaskRepository taskRepository = createTaskRepository();

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

      TaskRepository taskRepository = createTaskRepository(taskItems: taskItems);

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