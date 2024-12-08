import 'dart:io';

import 'package:test/test.dart';


void main() {
  group('TaskRepository', () {

    final Uri tasksAPI = Uri.parse('https://taskmaster-general.herokuapp.com/api/tasks');

    final personId = 1;
    final token = 'token';

    // helper methods

    void validateToken(Invocation invocation) async {
      var headers = invocation.namedArguments[Symbol('headers')];
      var tokenInfo = headers[HttpHeaders.authorizationHeader];
      expect(tokenInfo, token);
    }

    // tests
/*

    test('addTask', () async {
      int id = 2345;

      TaskRepository taskRepository = await TestMockHelper.createTaskRepositoryAndLoad();

      var blueprint = (MockTaskItemBuilder.asPreCommit()).createBlueprint();
      blueprint.personDocId = personId;


      when(taskRepository.client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((invocation) async {
        _validateToken(invocation);

        var addedItem = TestMockHelper.mockAddTask(blueprint, id, null);
        var payload = jsonEncode(addedItem.toJson());
        return Future<http.Response>.value(http.Response(payload, 200));
      });


      var returnedItem = (await taskRepository.addTask(blueprint)).taskItem;

      verify(taskRepository.client.post(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")));

      expect(returnedItem.id, id);
      expect(returnedItem.name, blueprint.name);
      expect(returnedItem.personId, 1);
    });

    test('updateTask', () async {
      TaskItem taskItem = MockTaskItemBuilder.asDefault().create();
      var taskItems = [
        taskItem
      ];
      var blueprint = taskItem.createBlueprint();

      TaskRepository taskRepository = TestMockHelper.createTaskRepositoryWithoutLoad(taskItems: taskItems);

      var newProject = "Groovy Time";
      var newTargetDate = DateTime.now().add(Duration(days: 3)).toUtc();

      blueprint.project = newProject;
      blueprint.targetDate = newTargetDate;

      when(taskRepository.client.patch(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")))
          .thenAnswer((invocation) async {
        _validateToken(invocation);

        var editedItem = TestMockHelper.mockEditTask(taskItem, blueprint);
        var payload = jsonEncode(editedItem.toJson());
        return Future<http.Response>.value(http.Response(payload, 200));
      });

      var returnedItem = (await taskRepository.updateTask(taskItem.id, blueprint, token)).taskItem;

      verify(taskRepository.client.patch(tasksAPI, headers: anyNamed("headers"), body: anyNamed("body")));

      expect(returnedItem.project, newProject);
      expect(returnedItem.targetDate, newTargetDate);

    });
*/


  });


}