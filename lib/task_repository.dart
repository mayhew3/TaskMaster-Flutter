
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_edit.dart';

class TaskRepository {
  AppState appState;
  http.Client client;

  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  TaskRepository({
    required this.appState,
    required this.client,
  });

  Uri getUriWithParameters(String path, Map<String, dynamic>? queryParameters) {
    if (serverEnv == "") {
      throw new Exception('Missing required SERVER environment variable.');
    }
    switch(serverEnv) {
      case 'local':
        return Uri.http('localhost:3000', path, queryParameters);
      case 'staging':
        return Uri.https('taskmaster-staging.herokuapp.com', path, queryParameters);
      case 'heroku':
        return Uri.https('taskmaster-general.herokuapp.com', path, queryParameters);
      default:
        throw new Exception('Unknown SERVER environment variable: ' + serverEnv);
    }
  }

  Uri getUri(String path) {
    return getUriWithParameters(path, null);
  }

  Future<void> loadTasks(StateSetter stateSetter) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot load tasks before being signed in.");
    }

    var queryParameters = {
      'email': appState.currentUser!.email
    };

    var uri = getUriWithParameters('/api/tasks', queryParameters);

    String idToken = await appState.getIdToken();

    final response = await this.client.get(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
                HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);

        appState.personId = jsonObj['person_id'];

        stateSetter(() {
          List<Sprint> sprints = [];

          for (var sprintJson in jsonObj['sprints']) {
            var sprint = Sprint.fromJson(sprintJson);
            sprints.add(sprint);
          }

          List<TaskItem> taskItems = [];
          for (var taskJson in jsonObj['tasks']) {
            var taskItem = TaskItem.fromJson(taskJson);
            taskItems.add(taskItem);
          }

          appState.updateTasksAndSprints(taskItems, sprints);
        });

      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error retrieving task data from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to load task list. Talk to Mayhew.');
    }
  }

  Future<TaskItem> addTask(TaskItemBlueprint taskItemForm) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot add task before being signed in.");
    }

    var taskObj = taskItemForm.toJson();
    taskObj['person_id'] = appState.personId;

    var payload = {
      "task": taskObj
    };
    return _addOrUpdateJSON(payload, 'add');
  }

  Future<Snooze> addSnooze(Snooze snooze) async {
    var payload = {
      'snooze': snooze.toJson()
    };
    return _addOrUpdateSnoozeSerializableJSON(payload);
  }

  Future<Sprint> addSprint(Sprint sprint) async {
    var payload = {
      'sprint': sprint.toJson()
    };
    return _addSprintJSON(payload);
  }

  Future<void> addTasksToSprint(List<TaskItemEdit> taskItems, Sprint sprint) async {
    Set<int> taskIds = new Set<int>();
    for (TaskItemEdit taskItem in taskItems) {
      taskIds.add(taskItem.id);
    }

    Map<String, Object> payload = {
      'sprint_id': sprint.id!,
      'task_ids': taskIds.toList(),
    };

    return _addTaskListJSON(payload);
  }


  String? formatForJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    } else {
      var utc = dateTime.toUtc();
      return utc.toIso8601String();
    }
  }

  Future<TaskItem> completeTask(TaskItem taskItem) {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot update task before being signed in.");
    }

    var payload = {
      "task": {
        "id": taskItem.id,
        "completion_date": formatForJson(taskItem.completionDate),
        "recurrence_id": taskItem.recurrenceId,
      }
    };

    return _addOrUpdateJSON(payload, 'update');
  }

  Future<TaskItem> updateTask(TaskItemEdit taskItemForm) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot update task before being signed in.");
    }

    var taskObj = taskItemForm.toJson();

    var payload = {
      "task": taskObj
    };
    return _addOrUpdateJSON(payload, 'update');
  }

  Future<void> deleteTask(TaskItem taskItem) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot delete task before being signed in.");
    }

    var queryParameters = {
      'task_id': taskItem.id.toString()
    };

    var uri = getUriWithParameters('/api/tasks', queryParameters);

    var idToken = await appState.getIdToken();

    final response = await client.delete(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
        HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task. Talk to Mayhew.');
    }
  }

  Future<TaskItem> _addOrUpdateJSON(Map<String, Object> payload, String addOrUpdate) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    var uri = getUri('/api/tasks');
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        TaskItem inboundTask = TaskItem.fromJson(jsonObj);
        return inboundTask;
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error parsing $addOrUpdate task from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to $addOrUpdate task. Talk to Mayhew.');
    }
  }

  Future<Snooze> _addOrUpdateSnoozeSerializableJSON(Map<String, dynamic> payload) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    var uri = getUri('/api/snoozes');
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        Snooze inboundSnooze = Snooze.fromJson(jsonObj);
        return inboundSnooze;
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error parsing snooze from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to add snooze. Talk to Mayhew.');
    }
  }

  Future<Sprint> _addSprintJSON(Map<String, Object> payload) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    var uri = getUri("/api/sprints");
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        Sprint inboundSprint = Sprint.fromJson(jsonObj);
        return inboundSprint;
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error parsing snooze from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to add snooze. Talk to Mayhew.');
    }
  }

  Future<void> _addTaskListJSON(Map<String, Object> payload) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    var uri = getUri("/api/assignments");
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonArray = json.decode(response.body);
        for (var assignment in jsonArray) {
          var sprintId = assignment['sprint_id'];
          var taskId = assignment['task_id'];
          TaskItem taskItem = appState.findTaskItemWithId(taskId)!;
          Sprint sprint = appState.findSprintWithId(sprintId)!;
          taskItem.addToSprints(sprint);
          sprint.addToTasks(taskItem);
        }
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error parsing assignments from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to add assignments. Talk to Mayhew.');
    }
  }
}