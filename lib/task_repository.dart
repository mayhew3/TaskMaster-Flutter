
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:taskmaster/models/data_payload.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:built_value/standard_json_plugin.dart';

class TaskRepository {
  http.Client client;

  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  TaskRepository({
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

  Future<DataPayload> loadTasksRedux() async {
    final standardSerializers =
      (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

    var queryParameters = {
      'email': "scorpy@gmail.com"
    };

    var uri = getUriWithParameters('/api/tasks', queryParameters);

    final response = await this.client.get(uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);

        List<Sprint> sprints = [];
        for (var sprintJson in jsonObj['sprints']) {
          var sprint = standardSerializers.deserializeWith(Sprint.serializer, sprintJson)!;
          sprints.add(sprint);
        }

        List<TaskRecurrence> taskRecurrences = [];
        for (var taskJson in jsonObj['taskRecurrences']) {
          var taskRecurrence = TaskRecurrence.fromJson(taskJson);
          taskRecurrences.add(taskRecurrence);
        }

        List<TaskItem> taskItems = [];
        for (var taskJson in jsonObj['tasks']) {
          var taskItem = TaskItem.fromJson(taskJson);
          taskItems.add(taskItem);
        }

        return DataPayload(taskItems: taskItems, sprints: sprints, taskRecurrences: taskRecurrences);

      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error retrieving task data from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to load task list. Talk to Mayhew.');
    }
  }

  Future<TaskItem> addTaskRedux(TaskItem taskItem) async {

    var taskObj = taskItem.toJson();
    taskObj['person_id'] = 1;

    var payload = {
      "task": taskObj
    };
    return _addOrUpdateJSON(payload, 'add');
  }

  String? formatForJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    } else {
      var utc = dateTime.toUtc();
      return utc.toIso8601String();
    }
  }

  Future<TaskItem> _addOrUpdateJSON(Map<String, Object> payload, String addOrUpdate) async {
    var body = utf8.encode(json.encode(payload));

    var uri = getUri('/api/tasks');
    final response = await client.post(uri,
        headers: {"Content-Type": "application/json"},
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

}