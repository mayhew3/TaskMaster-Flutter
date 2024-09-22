
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;
import 'package:taskmaster/models/data_payload.dart';
import 'package:taskmaster/models/snooze_blueprint.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

import 'models/snooze.dart';

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
        return Uri.http('10.0.2.2:3000', path, queryParameters);
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

  Future<int?> getPersonId(String email, String idToken) async {

    var queryParameters = {
      'email': email
    };

    var uri = getUriWithParameters('/api/persons', queryParameters);

    final response = await this.client.get(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
        HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);

        return jsonObj['person']?['id'];

      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error retrieving person data from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to fetch person. Talk to Mayhew.');
    }
  }

  Future<DataPayload> loadTasks(int personId, String idToken) async {

    var queryParameters = {
      'person_id': personId.toString()
    };

    var uri = getUriWithParameters('/api/tasks', queryParameters);

    final response = await this.client.get(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
                HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);

        List<Sprint> sprints = [];
        for (var sprintJson in jsonObj['sprints']) {
          var sprint = serializers.deserializeWith(Sprint.serializer, sprintJson)!;
          sprints.add(sprint);
        }

        List<TaskRecurrence> taskRecurrences = [];
        for (var recurrenceJson in jsonObj['taskRecurrences']) {
          var taskRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, recurrenceJson)!;
          taskRecurrences.add(taskRecurrence);
        }

        List<TaskItem> taskItems = [];
        for (var taskJson in jsonObj['tasks']) {
          var taskItem = serializers.deserializeWith(TaskItem.serializer, taskJson)!;
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

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> addTask(TaskItemBlueprint blueprint, String idToken) async {
    var payload = {
      "task": blueprint.toJson()
    };
    return _addOrUpdateTaskItemJSON(payload, 'add', idToken);
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> addRecurTask(TaskItemRecurPreview blueprint, String idToken) async {
    var taskObj = serializers.serializeWith(TaskItemRecurPreview.serializer, blueprint);
    var payload = {
      "task": taskObj
    };
    return _addOrUpdateTaskItemJSON(payload, 'add recur', idToken);
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> updateTask(int taskItemId, TaskItemBlueprint taskItemBlueprint, String idToken) async {
    var taskObj = taskItemBlueprint.toJson();

    var payload = {
      "task": taskObj,
      "taskItemId": taskItemId,
    };
    return _addOrUpdateTaskItemJSON(payload, 'update', idToken);
  }

  String? formatForJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    } else {
      var utc = dateTime.toUtc();
      return utc.toIso8601String();
    }
  }

  Future<Sprint> addSprint(SprintBlueprint blueprint, String idToken) async {
    var payload = {
      "sprint": blueprint.toJson()
    };

    return await (Map<String, Object> payload, String idToken) async {
      var body = utf8.encode(json.encode(payload));

      var uri = getUri("/api/sprints");
      final response = await client.post(uri,
          headers: {HttpHeaders.authorizationHeader: idToken,
            "Content-Type": "application/json"},
          body: body
      );

      if (response.statusCode == 200) {
        try {
          var jsonObj = json.decode(response.body);
          Sprint inboundSprint = serializers.deserializeWith(Sprint.serializer, jsonObj)!;
          return inboundSprint;
        } catch(exception, stackTrace) {
          print(exception);
          print(stackTrace);
          throw Exception('Error parsing snooze from the server. Talk to Mayhew.');
        }
      } else {
        throw Exception('Failed to add snooze. Talk to Mayhew.');
      }
    }(payload, idToken);
  }

  Future<({Sprint sprint, BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addSprintWithTaskItems(SprintBlueprint blueprint, BuiltList<TaskItem> existingItems, BuiltList<TaskItemRecurPreview> newItems, String idToken) async {
    var list = newItems.map((t) => serializers.serializeWith(TaskItemRecurPreview.serializer, t)).toList();
    var payload = {
      "sprint": blueprint.toJson(),
      "task_ids": existingItems.map((t) => t.id).toList(),
      "taskItems": list
    };

    return await (Map<String, Object> payload, String idToken) async {
      var body = utf8.encode(json.encode(payload));

      var uri = getUri("/api/sprintsAndTasks");
      final response = await client.post(uri,
          headers: {HttpHeaders.authorizationHeader: idToken,
            "Content-Type": "application/json"},
          body: body
      );

      if (response.statusCode == 200) {
        try {
          var jsonObj = json.decode(response.body);

          var sprintObj = jsonObj['sprint'];
          var taskItemsObj = jsonObj['addedTasks'] as List<dynamic>;
          var sprintAssignmentsObj = jsonObj['sprintAssignments'] as List<dynamic>;

          Sprint inboundSprint = serializers.deserializeWith(Sprint.serializer, sprintObj)!;
          BuiltList<TaskItem> taskItems = taskItemsObj.map((obj) => (serializers.deserializeWith(TaskItem.serializer, obj))!).toBuiltList();
          BuiltList<SprintAssignment> sprintAssignments = sprintAssignmentsObj.map((obj) => (serializers.deserializeWith(SprintAssignment.serializer, obj))!).toBuiltList();

          return (sprint: inboundSprint, addedTasks: taskItems, sprintAssignments: sprintAssignments);
        } catch(exception, stackTrace) {
          print(exception);
          print(stackTrace);
          throw Exception('Error parsing sprint and tasks from the server. Talk to Mayhew.');
        }
      } else {
        throw Exception('Failed to add sprint and tasks. Talk to Mayhew.');
      }
    }(payload, idToken);
  }

  Future<TaskRecurrence> addTaskRecurrence(TaskRecurrenceBlueprint blueprint, String idToken) async {
    var payload = {
      "taskRecurrence": blueprint.toJson()
    };

    return await (Map<String, Object> payload, String idToken) async {
      var body = utf8.encode(json.encode(payload));

      var uri = getUri("/api/taskRecurrences");
      final response = await client.post(uri,
          headers: {HttpHeaders.authorizationHeader: idToken,
            "Content-Type": "application/json"},
          body: body
      );

      if (response.statusCode == 200) {
        try {
          var jsonObj = json.decode(response.body);
          TaskRecurrence inboundTaskRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, jsonObj)!;
          return inboundTaskRecurrence;
        } catch(exception, stackTrace) {
          print(exception);
          print(stackTrace);
          throw Exception('Error parsing task recurrence from the server. Talk to Mayhew.');
        }
      } else {
        throw Exception('Failed to add task recurrence. Talk to Mayhew.');
      }
    }(payload, idToken);
  }


  Future<TaskRecurrence> updateTaskRecurrence(int taskRecurrenceId, TaskRecurrenceBlueprint blueprint, String idToken) async {
    var payload = {
      "taskRecurrence": blueprint.toJson(),
      "taskRecurrenceId": taskRecurrenceId,
    };

    return await (Map<String, Object> payload, String idToken) async {
      var body = utf8.encode(json.encode(payload));

      var uri = getUri("/api/taskRecurrences");
      final response = await client.post(uri,
          headers: {HttpHeaders.authorizationHeader: idToken,
            "Content-Type": "application/json"},
          body: body
      );

      if (response.statusCode == 200) {
        try {
          var jsonObj = json.decode(response.body);
          TaskRecurrence inboundTaskRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, jsonObj)!;
          return inboundTaskRecurrence;
        } catch(exception, stackTrace) {
          print(exception);
          print(stackTrace);
          throw Exception('Error parsing task recurrence from the server. Talk to Mayhew.');
        }
      } else {
        throw Exception('Failed to update task recurrence. Talk to Mayhew.');
      }
    }(payload, idToken);
  }


  Future<List<SprintAssignment>> addTasksToSprint(List<TaskItem> taskItems, Sprint sprint, String idToken) async {
    Set<int> taskIds = new Set<int>();
    for (TaskItem taskItem in taskItems) {
      taskIds.add(taskItem.id);
    }

    Map<String, Object> payload = {
      'sprint_id': sprint.id,
      'task_ids': taskIds.toList(),
    };

    var body = utf8.encode(json.encode(payload));

    var uri = getUri("/api/assignments");
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        List<SprintAssignment> sprintAssignments = [];
        var jsonArray = json.decode(response.body);
        for (var assignment in jsonArray) {
          var sprintAssignment = serializers.deserializeWith(SprintAssignment.serializer, assignment);
          sprintAssignments.add(sprintAssignment!);
        }
        return sprintAssignments;
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error parsing assignments from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to add assignments. Talk to Mayhew.');
    }
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> _addOrUpdateTaskItemJSON(Map<String, Object?> payload, String addOrUpdate, String idToken) async {
    var body = utf8.encode(json.encode(payload));

    var uri = getUri('/api/tasks');
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        var recurrenceObj = jsonObj['recurrence'];
        TaskRecurrence? recurrence = (recurrenceObj == null) ? null :
            serializers.deserializeWith(TaskRecurrence.serializer, recurrenceObj);
        TaskItem inboundTask = serializers.deserializeWith(TaskItem.serializer, jsonObj)!;
        return (taskItem: inboundTask, recurrence: recurrence);
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error parsing $addOrUpdate task from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to $addOrUpdate task. Talk to Mayhew.');
    }
  }


  Future<Snooze> addSnooze(SnoozeBlueprint snooze, String idToken) async {
    var payload = {
      'snooze': snooze.toJson()
    };
    return _addOrUpdateSnoozeSerializableJSON(payload, idToken);
  }

  Future<Snooze> _addOrUpdateSnoozeSerializableJSON(Map<String, dynamic> payload, String idToken) async {
    var body = utf8.encode(json.encode(payload));

    var uri = getUri('/api/snoozes');
    final response = await client.post(uri,
        headers: {HttpHeaders.authorizationHeader: idToken,
          "Content-Type": "application/json"},
        body: body
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        Snooze inboundSnooze = serializers.deserializeWith(Snooze.serializer, jsonObj)!;
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

}