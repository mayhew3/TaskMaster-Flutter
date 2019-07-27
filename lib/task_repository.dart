
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:taskmaster/models.dart';
import 'package:http/http.dart' as http;

class TaskRepository {
  Future<List<TaskEntity>> loadTasks(String idToken) async {
    final response = await http.get("https://taskmaster-general.herokuapp.com/api/tasks",
      headers: {HttpHeaders.authorizationHeader: idToken},
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
}