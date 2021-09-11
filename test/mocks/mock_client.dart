import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:core';

class MockClient extends Mock implements http.Client {
  List<TaskItem> taskList;
  List<Sprint> sprintList;

  MockClient(this.taskList, this.sprintList);

  String _mockTheJSON() {
    var taskObj = {};
    taskObj['person_id'] = 1;
    var mockPlayerList = [];
    var mockSprintList = [];

    for (var taskItem in taskList) {
      mockPlayerList.add(_getMockTask(taskItem));
    }

    for (var sprintItem in sprintList) {
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

  @override
  Future<http.Response> get(url, {Map<String, String>? headers}) {
    return Future<http.Response>.value(http.Response(_mockTheJSON(), 200));
  }

}