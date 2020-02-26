
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_entity.dart';
import 'package:taskmaster/models/task_item.dart';

class TaskRepository {
  AppState appState;

  TaskRepository({@required this.appState});

  Future<List<TaskEntity>> loadTasks() async {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot load tasks before being signed in.");
    }

    var queryParameters = {
      'email': appState.currentUser.email
    };

    var uri = Uri.https('taskmaster-general.herokuapp.com', '/api/tasks', queryParameters);

    var idToken = await appState.getIdToken();

    final response = await http.get(uri,
      headers: {HttpHeaders.authorizationHeader: idToken.token,
                HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        List<TaskEntity> taskList = [];
        var jsonObj = json.decode(response.body);
        int personId = jsonObj['person_id'];
        appState.personId = personId;
        List tasks = jsonObj['tasks'];
        tasks.forEach((taskJson) {
          TaskEntity taskEntity = TaskEntity.fromJson(taskJson);
          taskList.add(taskEntity);
        });
        return taskList;
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error retrieving task data from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to load task list. Talk to Mayhew.');
    }
  }

  Future<TaskEntity> addTask(TaskItem taskItem) async {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot add task before being signed in.");
    }
    if (appState.personId == null) {
      throw new Exception("Cannot add task with no personId.");
    }

    var payload = {
      "task": {
        "name": taskItem.name,
        "person_id": appState.personId,
        "description": nullifyEmptyString(taskItem.description),
        "project": nullifyEmptyString(taskItem.project),
        "context": nullifyEmptyString(taskItem.context),
        "urgency": taskItem.urgency,
        "priority": taskItem.priority,
        "duration": taskItem.duration,
        "start_date": wrapDate(taskItem.startDate),
        "target_date": wrapDate(taskItem.targetDate),
        "due_date": wrapDate(taskItem.dueDate),
        "urgent_date": wrapDate(taskItem.urgentDate),
        "game_points": taskItem.gamePoints,
        "recur_number": taskItem.recurNumber,
        "recur_unit": taskItem.recurUnit,
        "recur_wait": taskItem.recurWait,
        "recurrence_id": taskItem.recurrenceId,
      }
    };
    return _addOrUpdateJSON(payload, 'add');
  }

  Future<TaskEntity> completeTask(TaskItem taskItem, DateTime completionDate) {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot update task before being signed in.");
    }

    var payload = {
      "task": {
        "id": taskItem.id,
        "completion_date": wrapDate(completionDate),
        "recurrence_id": taskItem.recurrenceId,
      }
    };

    return _addOrUpdateJSON(payload, 'update');
  }

  Future<TaskEntity> updateTask({
    TaskItem taskItem,
    String name,
    String description,
    String project,
    String context,
    int urgency,
    int priority,
    int duration,
    DateTime startDate,
    DateTime targetDate,
    DateTime dueDate,
    DateTime urgentDate,
    int gamePoints,
    int recurNumber,
    String recurUnit,
    bool recurWait,
    int recurrenceId,
  }) async {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot update task before being signed in.");
    }

    var payload = {
      "task": {
        "id": taskItem.id,
        "name": nullifyEmptyString(name),
        "description": nullifyEmptyString(description),
        "project": nullifyEmptyString(project),
        "context": nullifyEmptyString(context),
        "urgency": urgency,
        "priority": priority,
        "duration": duration,
        "start_date": wrapDate(startDate),
        "target_date": wrapDate(targetDate),
        "due_date": wrapDate(dueDate),
        "urgent_date": wrapDate(urgentDate),
        "game_points": gamePoints,
        "recur_number": recurNumber,
        "recur_unit": recurUnit,
        "recur_wait": recurWait,
        "recurrence_id": recurrenceId,
      }
    };
    return _addOrUpdateJSON(payload, 'update');
  }

  String nullifyEmptyString(String inputString) {
    return inputString == null || inputString.isEmpty ? null : inputString.trim();
  }

  Future<void> deleteTask(TaskItem taskItem) async {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot delete task before being signed in.");
    }

    var queryParameters = {
      'task_id': taskItem.id.toString()
    };

    var uri = Uri.https('taskmaster-general.herokuapp.com', '/api/tasks', queryParameters);

    var idToken = await appState.getIdToken();

    final response = await http.delete(uri,
      headers: {HttpHeaders.authorizationHeader: idToken.token,
        HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task. Talk to Mayhew.');
    }
  }

  String wrapDate(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    } else {
      var utc = dateTime.toUtc();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(utc);
    }
  }

  Future<TaskEntity> _addOrUpdateJSON(Map<String, Object> payload, String addOrUpdate) async {
    var body = utf8.encode(json.encode(payload));

    var idToken = await appState.getIdToken();

    final response = await http.post("https://taskmaster-general.herokuapp.com/api/tasks",
        headers: {HttpHeaders.authorizationHeader: idToken.token,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        TaskEntity inboundTask = TaskEntity.fromJson(jsonObj);
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
}