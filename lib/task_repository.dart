
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';

class TaskRepository {
  AppState appState;
  http.Client client;

  TaskRepository({
    @required this.appState,
    @required this.client,
  });

  Future<void> loadTasks(StateSetter stateSetter) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot load tasks before being signed in.");
    }

    var queryParameters = {
      'email': appState.currentUser.email
    };

    var uri = Uri.https('taskmaster-general.herokuapp.com', '/api/tasks', queryParameters);

    IdTokenResult idToken = await appState.getIdToken();

    final response = await this.client.get(uri,
      headers: {HttpHeaders.authorizationHeader: idToken.token,
                HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        List<TaskItem> taskList = [];
        List<Sprint> sprintList = [];

        var jsonObj = json.decode(response.body);

        int personId = jsonObj['person_id'];
        appState.personId = personId;

        List sprints = jsonObj['sprints'];
        for (var sprintJson in sprints) {
          Sprint sprint = Sprint.fromJson(sprintJson);
          sprintList.add(sprint);
        }

        stateSetter(() {
          appState.sprints = sprintList;
        });

        List tasks = jsonObj['tasks'];
        for (var taskJson in tasks) {
          TaskItem taskItem = TaskItem.fromJson(taskJson, this.appState);
          taskList.add(taskItem);
        }

        stateSetter(() {
          appState.taskItems = taskList;
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

  Future<TaskItem> addTask(TaskItem taskItem) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot add task before being signed in.");
    }
    if (appState.personId == null) {
      throw Exception("Cannot add task with no personId.");
    }

    var taskObj = {};
    for (var field in taskItem.fields) {
      if (!TaskItem.controlledFields.contains(field.fieldName)) {
        taskObj[field.fieldName] = field.formatForJSON();
      }
    }
    taskObj['person_id'] = appState.personId;

    var payload = {
      "task": taskObj
    };
    return _addOrUpdateJSON(payload, 'add');
  }

  Future<Snooze> addSnooze(Snooze snooze) async {
    var snoozeObj = {};
    snooze.fields.forEach((field) {
      if (!Snooze.controlledFields.contains(field.fieldName)) {
        snoozeObj[field.fieldName] = field.formatForJSON();
      }
    });

    var payload = {
      'snooze': snoozeObj
    };
    return _addOrUpdateSnoozeJSON(payload, 'add');
  }


  Future<TaskItem> completeTask(TaskItem taskItem, DateTime completionDate) {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot update task before being signed in.");
    }

    taskItem.completionDate.value = completionDate;

    var payload = {
      "task": {
        "id": taskItem.id.formatForJSON(),
        "completion_date": taskItem.completionDate.formatForJSON(),
        "recurrence_id": taskItem.recurrenceId.formatForJSON(),
      }
    };

    return _addOrUpdateJSON(payload, 'update');
  }

  Future<TaskItem> updateTask(TaskItem taskItem) async {
    if (!appState.isAuthenticated()) {
      throw Exception("Cannot update task before being signed in.");
    }

    var taskObj = {};
    taskObj['id'] = taskItem.id.value;
    for (var field in taskItem.fields) {
      if (!TaskItem.controlledFields.contains(field.fieldName) && field.isChanged()) {
        taskObj[field.fieldName] = field.formatForJSON();
      }
    }

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
      'task_id': taskItem.id.value.toString()
    };

    var uri = Uri.https('taskmaster-general.herokuapp.com', '/api/tasks', queryParameters);

    var idToken = await appState.getIdToken();

    final response = await client.delete(uri,
      headers: {HttpHeaders.authorizationHeader: idToken.token,
        HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task. Talk to Mayhew.');
    }
  }

  Future<TaskItem> _addOrUpdateJSON(Map<String, Object> payload, String addOrUpdate) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    final response = await client.post("https://taskmaster-general.herokuapp.com/api/tasks",
        headers: {HttpHeaders.authorizationHeader: idToken.token,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        TaskItem inboundTask = TaskItem.fromJson(jsonObj, this.appState);
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

  Future<Snooze> _addOrUpdateSnoozeJSON(Map<String, Object> payload, String addOrUpdate) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    final response = await client.post("https://taskmaster-general.herokuapp.com/api/snoozes",
        headers: {HttpHeaders.authorizationHeader: idToken.token,
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
        throw Exception('Error parsing $addOrUpdate snooze from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to $addOrUpdate snooze. Talk to Mayhew.');
    }
  }
}