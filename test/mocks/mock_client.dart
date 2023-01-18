import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';

import 'dart:convert';
import 'dart:core';

class MockClientOld extends Fake implements http.Client {
  List<TaskItem> taskList;
  List<Sprint> sprintList;

  MockClientOld(this.taskList, this.sprintList);

  String _mockTheJSON() {
    var taskObj = {};
    taskObj['person_id'] = 1;
    var mockPlayerList = [];
    var mockSprintList = [];

    for (var taskItem in taskList) {
      mockPlayerList.add(_getMockTask(taskItem));
    }

    for (var sprintItem in sprintList) {
      mockSprintList.add(sprintItem.toJson());
    }

    taskObj['tasks'] = mockPlayerList;
    taskObj['sprints'] = mockSprintList;
    return json.encode(taskObj);
  }

  dynamic _getMockTask(TaskItem taskItem) {
    return taskItem.toJson();
  }

  @override
  Future<http.Response> get(url, {Map<String, String>? headers}) {
    return Future<http.Response>.value(http.Response(_mockTheJSON(), 200));
  }

}