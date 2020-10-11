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
    var mockList = [];
    for (var taskItem in taskList) {
      var mockObj = {};
      for (var field in taskItem.fields) {
        mockObj[field.fieldName] = field.formatForJSON();
      }
      var sprint_assignments = [];
      for (var sprint in taskItem.sprints) {
        var obj = {
          'id': 1234,
          'sprint_id': sprint.id
        };
        sprint_assignments.add(obj);
      }
      mockObj['sprint_assignments'] = sprint_assignments;
      mockList.add(mockObj);
    }
    for (var sprintItem in sprintList) {
      var mockObj = {};
      for (var field in sprintItem.fields) {
        mockObj[field.fieldName] = field.formatForJSON();
      }
      mockList.add(mockObj);
    }
    taskObj['tasks'] = mockList;
    taskObj['sprints'] = sprintList;
    return json.encode(taskObj);
  }

  @override
  Future<http.Response> get(url, {Map<String, String> headers}) {
    return Future<http.Response>.value(http.Response(_mockTheJSON(), 200));
  }
}