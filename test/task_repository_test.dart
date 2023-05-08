import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'test_mock_helper.dart';

void main() {
  group('TaskRepository', () {

    final Uri tasksAPI = Uri.parse("https://taskmaster-general.herokuapp.com/api/tasks");

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

    void _validateToken(Invocation invocation, AppState appState) async {
      var headers = invocation.namedArguments[Symbol("headers")];
      var tokenInfo = headers[HttpHeaders.authorizationHeader];
      var expectedToken = await appState.getIdToken();
      expect(tokenInfo, expectedToken);
    }

    // tests

    test('loadTasks with no tasks', () async {
      TaskRepository taskRepository = TestMockHelper.createTaskRepositoryWithoutLoad(taskItems: []);

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = taskRepository.appState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList.length, 0);
    });

    test('loadTasks with tasks', () async {
      TaskRepository taskRepository = TestMockHelper.createTaskRepositoryWithoutLoad();

      await taskRepository.loadTasks((callback) => callback());
      List<TaskItem> taskList = taskRepository.appState.taskItems;
      expect(taskList, const TypeMatcher<List<TaskItem>>());
      expect(taskList, hasLength(allTasks.length));
    });

    test('addTask', () async {
      int id = 2345;

      TaskRepository taskRepository = await TestMockHelper.createTaskRepositoryAndLoad();

      var addedItem = (TaskItemBuilder.asPreCommit()).createBlueprint();

      when(taskRepository.client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((invocation) async {
        _validateToken(invocation, taskRepository.appState);

        var body = invocation.namedArguments[Symbol("body")];
        var payload = _encodeBody(body, id: id, dateTime: DateTime.now());
        return Future<http.Response>.value(http.Response(payload, 200));
      });

      var returnedItem = await taskRepository.addTask(addedItem);

      verify(taskRepository.client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")));

      expect(returnedItem.id, id);
      expect(returnedItem.name, addedItem.name);
      expect(returnedItem.personId, 1);
      expect(returnedItem.dateAdded, isNot(null));
    });

    test('updateTask', () async {
      TaskItem taskItem = TaskItemBuilder.asDefault().create();
      var taskItems = [
        taskItem
      ];
      var blueprint = taskItem.createEditBlueprint();

      TaskRepository taskRepository = TestMockHelper.createTaskRepositoryWithoutLoad(taskItems: taskItems);

      when(taskRepository.client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((invocation) async {
        _validateToken(invocation, taskRepository.appState);

        var body = invocation.namedArguments[Symbol("body")];
        var payload = _encodeBody(body);
        return Future<http.Response>.value(http.Response(payload, 200));
      });

      var newProject = "Groovy Time";
      var newTargetDate = DateTime.now().add(Duration(days: 3));

      blueprint.project = newProject;
      blueprint.targetDate = newTargetDate;

      var returnedItem = await taskRepository.updateTask(taskItem, blueprint);

      verify(taskRepository.client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")));

      expect(returnedItem.project, newProject);
      expect(returnedItem.project, newProject);
      expect(returnedItem.targetDate, newTargetDate);
      expect(returnedItem.targetDate, newTargetDate);

    });

    // todo: updateTask, addSnooze, addSprint
  });


}