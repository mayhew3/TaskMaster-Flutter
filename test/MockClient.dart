import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/task_item.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:core';

class MockClient extends Mock implements http.Client {
  String jsonList = '{"person_id": 1, "tasks": []}';
  List<TaskItem> taskList;

  MockClient(this.taskList);

  String _mockTheJSON() {
    var taskObj = {};
    taskObj['person_id'] = 1;
    var mockList = [];
    for (var taskItem in taskList) {
      var mockObj = {};
      for (var field in taskItem.fields) {
        mockObj[field.fieldName] = field.formatForJSON();
      }
      mockList.add(mockObj);
    }
    taskObj['tasks'] = mockList;
    return json.encode(taskObj);
  }

  Future<http.Response> get(url, {Map<String, String> headers}) {
    return Future<http.Response>.value(http.Response(_mockTheJSON(), 200));
  }
}