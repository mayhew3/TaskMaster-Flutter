
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:taskmaster/models.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TaskRepository {
  AppState appState;

  TaskRepository({@required this.appState});

  Future<List<TaskEntity>> loadTasks() async {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot load tasks before being signed in.");
    }

    final response = await http.get("https://taskmaster-general.herokuapp.com/api/tasks",
      headers: {HttpHeaders.authorizationHeader: appState.idToken},
    );

    if (response.statusCode == 200) {
      try {
        List<TaskEntity> taskList = [];
        List list = json.decode(response.body);
        list.forEach((jsonObj) {
          TaskEntity taskEntity = TaskEntity.fromJson(jsonObj);
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
  }) async {
    if (!appState.isAuthenticated()) {
      throw new Exception("Cannot update task before being signed in.");
    }

    var payload = {
      "task": {
        "id": taskItem.id,
        "name": name,
        "description": description,
        "project": project,
        "context": context,
        "start_date": startDate == null ? null : DateFormat('yyyy-MM-dd HH:mm').format(startDate),
        "target_date": targetDate == null ? null : DateFormat('yyyy-MM-dd HH:mm').format(targetDate),
        "due_date": dueDate == null ? null : DateFormat('yyyy-MM-dd HH:mm').format(dueDate),
        "urgent_date": urgentDate == null ? null : DateFormat('yyyy-MM-dd HH:mm').format(urgentDate),
      }
    };
    var body = utf8.encode(json.encode(payload));

    final response = await http.post("https://taskmaster-general.herokuapp.com/api/tasks",
        headers: {HttpHeaders.authorizationHeader: appState.idToken,
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
        throw Exception('Error parsing updated task from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to update task. Talk to Mayhew.');
    }
  }
}