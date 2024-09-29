
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;
import 'package:taskmaster/models/data_payload.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/snooze_blueprint.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/typedefs.dart';

import 'models/snooze.dart';

class TaskRepository {
  http.Client client;

  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  TaskRepository({
    required this.client,
  });

  Future<int?> getPersonId(String email, String idToken) async {
    var queryParameters = {
      'email': email
    };

    var jsonObj = await this.executeGetApiAction(
        uriString: '/api/persons',
        queryParameters: queryParameters,
        idToken: idToken,
        operationDescription: "get person id");
    return jsonObj['person']?['id'];
  }

  Future<DataPayload> loadTasks(int personId, String idToken) async {
    var queryParameters = {
      'person_id': personId.toString()
    };

    var jsonObj = await this.executeGetApiAction(
        uriString: '/api/tasks',
        queryParameters: queryParameters,
        idToken: idToken,
        operationDescription: "load tasks");

    List<Sprint> sprints = (jsonObj['sprints'] as List<dynamic>).map((sprintJson) =>
      serializers.deserializeWith(Sprint.serializer, sprintJson)!).toList();

    List<TaskRecurrence> taskRecurrences = (jsonObj['taskRecurrences'] as List<dynamic>).map((recurrenceJson) =>
      serializers.deserializeWith(TaskRecurrence.serializer, recurrenceJson)!).toList();

    List<TaskItem> taskItems = (jsonObj['tasks'] as List<dynamic>).map((taskJson) =>
    serializers.deserializeWith(TaskItem.serializer, taskJson)!).toList();

    return DataPayload(taskItems: taskItems, sprints: sprints, taskRecurrences: taskRecurrences);
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> addTask(TaskItemBlueprint blueprint, String idToken) async {
    var payload = {
      "task": blueprint.toJson()
    };
    return _addOrUpdateTaskItemJSON(payload: payload, idToken: idToken, apiOperation: this.client.post, operationDescription: "create task");
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> addRecurTask(TaskItemRecurPreview blueprint, String idToken) async {
    var taskObj = serializers.serializeWith(TaskItemRecurPreview.serializer, blueprint);
    var payload = {
      "task": taskObj
    };
    return _addOrUpdateTaskItemJSON(payload: payload, idToken: idToken, apiOperation: this.client.post, operationDescription: "create task (with recur)");
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> updateTask(int taskItemId, TaskItemBlueprint taskItemBlueprint, String idToken) async {
    var taskObj = taskItemBlueprint.toJson();

    var payload = {
      "task": taskObj,
      "taskItemId": taskItemId,
    };
    return _addOrUpdateTaskItemJSON(payload: payload, idToken: idToken, apiOperation: this.client.patch, operationDescription: "edit task");
  }

  Future<({Sprint sprint, BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addSprintWithTaskItems(SprintBlueprint blueprint, BuiltList<TaskItem> existingItems, BuiltList<TaskItemRecurPreview> newItems, String idToken) async {
    var list = newItems.map((t) => serializers.serializeWith(TaskItemRecurPreview.serializer, t)).toList();
    var payload = {
      "sprint": blueprint.toJson(),
      "task_ids": existingItems.map((t) => t.id).toList(),
      "taskItems": list
    };

    var jsonObj = await executeBodyApiAction(
        bodyApiOperation: this.client.post,
        payload: payload,
        uriString: "/api/sprintsAndTasks",
        idToken: idToken,
        operationDescription: "add sprint and tasks");

    var sprintObj = jsonObj['sprint'];
    var taskItemsObj = jsonObj['addedTasks'] as List<dynamic>;
    var sprintAssignmentsObj = jsonObj['sprintAssignments'] as List<dynamic>;

    Sprint inboundSprint = serializers.deserializeWith(Sprint.serializer, sprintObj)!;
    BuiltList<TaskItem> taskItems = taskItemsObj.map((obj) => (serializers.deserializeWith(TaskItem.serializer, obj))!).toBuiltList();
    BuiltList<SprintAssignment> sprintAssignments = sprintAssignmentsObj.map((obj) => (serializers.deserializeWith(SprintAssignment.serializer, obj))!).toBuiltList();

    return (sprint: inboundSprint, addedTasks: taskItems, sprintAssignments: sprintAssignments);
  }

  Future<TaskRecurrence> addTaskRecurrence(TaskRecurrenceBlueprint blueprint, String idToken) async {
    var payload = {
      "taskRecurrence": blueprint.toJson()
    };

    var jsonObj = await executeBodyApiAction(
        bodyApiOperation: this.client.post,
        payload: payload,
        uriString: "/api/taskRecurrences",
        idToken: idToken,
        operationDescription: "add recurrence");

    TaskRecurrence inboundTaskRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, jsonObj)!;
    return inboundTaskRecurrence;
  }

  Future<TaskRecurrence> updateTaskRecurrence(int taskRecurrenceId, TaskRecurrenceBlueprint blueprint, String idToken) async {
    var payload = {
      "taskRecurrence": blueprint.toJson(),
      "taskRecurrenceId": taskRecurrenceId,
    };

    var jsonObj = await executeBodyApiAction(
        bodyApiOperation: this.client.patch,
        payload: payload,
        uriString: "/api/taskRecurrences",
        idToken: idToken,
        operationDescription: "update recurrence");

    return serializers.deserializeWith(TaskRecurrence.serializer, jsonObj)!;
  }


  Future<({BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addTasksToSprint(BuiltList<TaskItem> taskItems, BuiltList<TaskItemRecurPreview> taskItemRecurPreviews, Sprint sprint, String idToken) async {
    var list = taskItemRecurPreviews.map((t) => serializers.serializeWith(TaskItemRecurPreview.serializer, t)).toList();

    Map<String, Object> payload = {
      'sprint_id': sprint.id,
      'task_ids': taskItems.map((t) => t.id).toList(),
      'taskItems': list
    };

    var jsonObj = await executeBodyApiAction(
        bodyApiOperation: this.client.post,
        payload: payload,
        uriString: "/api/assignments",
        idToken: idToken,
        operationDescription: "add tasks to existing sprint");

    var taskItemsObj = jsonObj['addedTasks'] as List<dynamic>;
    var sprintAssignmentsObj = jsonObj['sprintAssignments'] as List<dynamic>;

    BuiltList<TaskItem> addedTaskItems = taskItemsObj.map((obj) => (serializers.deserializeWith(TaskItem.serializer, obj))!).toBuiltList();
    BuiltList<SprintAssignment> sprintAssignments = sprintAssignmentsObj.map((obj) => (serializers.deserializeWith(SprintAssignment.serializer, obj))!).toBuiltList();

    return (addedTasks: addedTaskItems, sprintAssignments: sprintAssignments);
  }

  Future<void> deleteTask(TaskItem taskItem, String idToken) async {
    var queryParameters = {
      'task_id': taskItem.id.toString()
    };

    return await executeDeleteApiAction(
        uriString: '/api/tasks',
        queryParameters: queryParameters,
        idToken: idToken,
        operationDescription: "delete task");
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> _addOrUpdateTaskItemJSON({required Map<String, Object?> payload, required String idToken, required BodyApiOperation apiOperation, required String operationDescription}) async {
    var jsonObj = await executeBodyApiAction(
        bodyApiOperation: apiOperation,
        payload: payload,
        uriString: '/api/tasks',
        idToken: idToken,
        operationDescription: operationDescription);

    var recurrenceObj = jsonObj['recurrence'];
    TaskRecurrence? recurrence = (recurrenceObj == null) ? null :
    serializers.deserializeWith(TaskRecurrence.serializer, recurrenceObj);
    TaskItem inboundTask = serializers.deserializeWith(TaskItem.serializer, jsonObj)!;
    return (taskItem: inboundTask, recurrence: recurrence);
  }

  Future<Snooze> addSnooze(SnoozeBlueprint snooze, String idToken) async {
    var payload = {
      'snooze': snooze.toJson()
    };

    var jsonObj = await executeBodyApiAction(
        bodyApiOperation: this.client.post,
        payload: payload,
        uriString: "/api/snoozes",
        idToken: idToken,
        operationDescription: "add snooze");
    return serializers.deserializeWith(Snooze.serializer, jsonObj)!;
  }



  // HELPER METHODS

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

  Future<dynamic> executeGetApiAction({
    required String uriString,
    Map<String, Object>? queryParameters,
    required String idToken,
    required String operationDescription}) async {

    var uri = queryParameters == null ? getUri(uriString) : getUriWithParameters(uriString, queryParameters);

    final response = await this.client.get(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
        HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error $operationDescription from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to $operationDescription. Talk to Mayhew.');
    }
  }

  Future<dynamic> executeBodyApiAction({
    required BodyApiOperation bodyApiOperation,
    required Map<String, Object?> payload,
    required String uriString,
    Map<String, Object>? queryParameters,
    required String idToken,
    required String operationDescription}) async {

    var uri = queryParameters == null ? getUri(uriString) : getUriWithParameters(uriString, queryParameters);

    var body = utf8.encode(json.encode(payload));

    final response = await bodyApiOperation(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
        HttpHeaders.contentTypeHeader: 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error $operationDescription from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to $operationDescription. Talk to Mayhew.');
    }
  }

  Future<void> executeDeleteApiAction({
    required String uriString,
    Map<String, Object>? queryParameters,
    required String idToken,
    required String operationDescription}) async {

    var uri = queryParameters == null ? getUri(uriString) : getUriWithParameters(uriString, queryParameters);

    final response = await this.client.delete(uri,
      headers: {HttpHeaders.authorizationHeader: idToken,
        HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to $operationDescription. Talk to Mayhew.');
    }
  }

  String? formatForJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    } else {
      var utc = dateTime.toUtc();
      return utc.toIso8601String();
    }
  }

}