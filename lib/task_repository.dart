
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:taskmaster/firestore_migrator.dart';
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

class TaskRepository {
  final http.Client client;
  final FirebaseFirestore firestore;

  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  TaskRepository({
    required this.client,
    required this.firestore,
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

  Future<String?> getPersonIdFromFirestore(String email) async {
    var withEmail = await firestore.collection("persons").where("email", isEqualTo: email).get();
    return withEmail.docs.firstOrNull?.id;
  }

  void goOffline() {
    firestore.disableNetwork().then((_) => print('Offline mode.'));
  }

  void goOnline() {
    firestore.enableNetwork().then((_) => print('Online mode.'));
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> createListener<T>({
    required String collectionName,
    String? subCollectionName,
    required String personDocId,
    required Function(Iterable<T>) addCallback,
    Function(Iterable<T>)? modifyCallback,
    Function(Iterable<T>)? deleteCallback,
    required Serializer<T> serializer}
      ) {
    var snapshots = firestore.collection(collectionName).where("personDocId", isEqualTo: personDocId).snapshots();
    var listener = snapshots.listen((event) async {
      print('$collectionName snapshots event!');
      var addedDocs = event.docChanges.where((dc) => dc.type == DocumentChangeType.added).map((dc) => dc.doc);
      List<T> finalList = [];
      for (var doc in addedDocs) {
        var json = doc.data()!;

        // tmp fix code
        if (json['recurrenceId'] != null && json['recurrenceId'] is String) {
          print("WARNING: Found recurrenceId with invalid String value, task docId: ${doc.id}");
          doc.reference.delete();
        } else {
          json['docId'] = doc.id;
          if (subCollectionName != null) {
            var subDocs = (await doc.reference.collection(subCollectionName).get()).docs;
            if (subDocs.isNotEmpty) {
              json[subCollectionName] = subDocs.map((sd) {
                var subJson = sd.data();
                subJson['docId'] = sd.id;
                return subJson;
              });
            }
          }
          var deserialized = serializers.deserializeWith(serializer, json)!;
          finalList.add(deserialized);
        }
      }
      if (finalList.isNotEmpty) {
        addCallback(finalList);
      }

      if (modifyCallback != null) {
        var modifyDocs = event.docChanges.where((dc) =>
        dc.type == DocumentChangeType.modified).map((dc) => dc.doc);
        List<T> modifyList = [];
        for (var doc in modifyDocs) {
          var json = doc.data()!;
          json['docId'] = doc.id;

          var deserialized = serializers.deserializeWith(serializer, json)!;
          modifyList.add(deserialized);
        }
        if (modifyList.isNotEmpty) {
          modifyCallback(modifyList);
        }
      }

    });
    return listener;
  }

  void addTask(TaskItemBlueprint blueprint, String idToken) async {
    var blueprintJson = blueprint.toJson();

    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    if (recurrenceBlueprint != null) {
      var recurrenceDoc = firestore.collection("taskRecurrences").doc();
      var recurrenceJson = recurrenceBlueprint.toJson();
      recurrenceJson['dateAdded'] = DateTime.now().toUtc();
      recurrenceDoc.set(recurrenceJson);
      blueprintJson['recurrenceDocId'] = recurrenceDoc.id;
      blueprintJson.remove('recurrenceBlueprint');
    }

    var addedTaskDoc = firestore.collection("tasks").doc();
    var taskId = addedTaskDoc.id;
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedTaskDoc.set(blueprintJson);
    blueprintJson['docId'] = taskId;
  }

  TaskItem addRecurTask(TaskItemRecurPreview blueprint) {
    Map<String, Object?> blueprintJson = serializers.serializeWith(TaskItemRecurPreview.serializer, blueprint)! as Map<String, Object?>;

    var addedTaskDoc = firestore.collection("tasks").doc();
    var taskId = addedTaskDoc.id;
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedTaskDoc.set(blueprintJson);
    blueprintJson['docId'] = taskId;

    var updatedTask = serializers.deserializeWith(TaskItem.serializer, blueprintJson)!;

    return updatedTask;
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> updateTask(String taskItemDocId, TaskItemBlueprint blueprint) async {
    var blueprintJson = blueprint.toJson();

    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    TaskRecurrence? updatedRecurrence;
    if (recurrenceBlueprint != null) {
      var recurrenceDoc = firestore.collection("taskRecurrences").doc(blueprint.recurrenceDocId);
      var recurrenceJson = recurrenceBlueprint.toJson();
      recurrenceDoc.update(recurrenceJson);

      var recurSnap = await recurrenceDoc.get();
      recurrenceJson['docId'] = blueprint.recurrenceDocId;
      recurrenceJson['dateAdded'] = recurSnap.get('dateAdded');
      updatedRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, recurrenceJson);
      blueprintJson.remove('recurrenceBlueprint');
    }

    var doc = firestore.collection("tasks").doc(taskItemDocId);
    doc.update(blueprintJson);

    var snapshot = await doc.get();
    blueprintJson['docId'] = doc.id;
    blueprintJson['dateAdded'] = snapshot.get('dateAdded');
    var updatedTask = serializers.deserializeWith(TaskItem.serializer, blueprintJson)!;

    return (taskItem: updatedTask, recurrence: updatedRecurrence);
  }

  Future<({Sprint sprint, BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addSprintWithTaskItems(SprintBlueprint blueprint, BuiltList<TaskItem> existingItems, BuiltList<TaskItemRecurPreview> newItems) async {
    var newTaskItemsList = newItems.map((t) => serializers.serializeWith(TaskItemRecurPreview.serializer, t)).toList();

    var blueprintJson = blueprint.toJson();
    var existingIds = existingItems.map((t) => t.docId).toList();

    var addedSprintDoc = firestore.collection("sprints").doc();
    var sprintId = addedSprintDoc.id;
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedSprintDoc.set(blueprintJson);
    blueprintJson['docId'] = sprintId;
    var addedSprint = serializers.deserializeWith(Sprint.serializer, blueprintJson)!;

    var addedTasks = ListBuilder<TaskItem>();
    for (var toAdd in newTaskItemsList) {
      toAdd as Map<String, Object?>;
      var addedTaskDoc = firestore.collection("tasks").doc();
      var taskId = addedTaskDoc.id;
      toAdd['dateAdded'] = DateTime.now().toUtc();
      addedTaskDoc.set(toAdd);
      toAdd['docId'] = taskId;
      addedTasks.add(serializers.deserializeWith(TaskItem.serializer, toAdd)!);
      existingIds.add(taskId);
    }

    var sprintAssignments = ListBuilder<SprintAssignment>();
    for (var existingId in existingIds) {
      var sprintAssignment = firestore.collection("tasks").doc(existingId).collection("sprintAssignments").doc();
      var sprintAssignmentId = sprintAssignment.id;
      var sprintAssignmentJson = {
        "taskDocId": existingId,
        "sprintDocId": sprintId,
        "dateAdded": DateTime.now().toUtc(),
        "retired": null,
        "retiredDate": null,
      };
      sprintAssignment.set(sprintAssignmentJson);
      sprintAssignmentJson["docId"] = sprintAssignmentId;
      sprintAssignments.add(serializers.deserializeWith(SprintAssignment.serializer, sprintAssignmentJson)!);
    }

    return (sprint: addedSprint, addedTasks: addedTasks.build(), sprintAssignments: sprintAssignments.build());
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

  Future<TaskRecurrence> updateTaskRecurrence(String taskRecurrenceDocId, TaskRecurrenceBlueprint blueprint) async {
    var blueprintJson = blueprint.toJson();

    var doc = firestore.collection("taskRecurrences").doc(taskRecurrenceDocId);
    doc.update(blueprintJson);

    var snapshot = await doc.get();
    blueprintJson['docId'] = doc.id;
    blueprintJson['dateAdded'] = snapshot.get('dateAdded');
    var updatedRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, blueprintJson)!;

    return updatedRecurrence;
  }


  Future<({BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addTasksToSprint(BuiltList<TaskItem> taskItems, BuiltList<TaskItemRecurPreview> taskItemRecurPreviews, Sprint sprint, String idToken) async {
    var list = taskItemRecurPreviews.map((t) => serializers.serializeWith(TaskItemRecurPreview.serializer, t)).toList();

    Map<String, Object> payload = {
      'sprint_id': sprint.docId,
      'task_ids': taskItems.map((t) => t.docId).toList(),
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

  void deleteTask(TaskItem taskItem) async {
    var doc = firestore.collection("tasks").doc(taskItem.docId);
    doc.update({"retired": taskItem.docId, "retiredDate": DateTime.now().toUtc()});
  }

  void addSnooze(SnoozeBlueprint snooze) async {
    var blueprintJson = snooze.toJson();

    var addedSnoozeDoc = firestore.collection("snoozes").doc();
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedSnoozeDoc.set(blueprintJson);
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

  Future<void> dataFixAll() async {
    await dataFixCollection(collectionName: "persons");
    await dataFixCollection(collectionName: "snoozes");
    await dataFixCollection(collectionName: "sprints");
    await dataFixCollection(collectionName: "taskRecurrences");
    await dataFixCollection(collectionName: "tasks", subCollectionName: "sprintAssignments");
  }

  Future<void> dataFixCollection({required String collectionName, String? subCollectionName}) async {
    print('Processing $collectionName...');
    var snapshot = await firestore.collection(collectionName).get();
    var docs = snapshot.docs;

    final dateFields = ['startDate', 'targetDate', 'urgentDate', 'dueDate', 'completionDate', 'dateAdded'];

    var totalCount = docs.length;
    var currIndex = 0;
    var updated = 0;
    var updatedDate = 0;
    for (var doc in docs) {

      var taskId = doc.id;

      bool docUpdated = false;
      bool dateUpdated = false;

      if (subCollectionName != null) {
        var subDocs = (await doc.reference.collection(subCollectionName).get()).docs;
        for (var subDoc in subDocs) {
          var data = subDoc.data();
          if (!data.containsKey('retired')) {
            await subDoc.reference.update({'retired': null});
            docUpdated = true;
          }
          for (var dateField in dateFields) {
            if (data.containsKey(dateField)) {
              var dataValue = data[dateField];
              if (dataValue is String) {
                var dateVal = DateTime.parse(dataValue).toUtc();
                await doc.reference.update({dateField: dateVal});
                dateUpdated = true;
              } else if (dataValue is DateTime) {
                var dateVal = dataValue.toUtc();
                await doc.reference.update({dateField: dateVal});
                dateUpdated = true;
              }
            }
          }
        }
      }

      var data = doc.data();
      if (!data.containsKey('retired')) {
        await doc.reference.update({'retired': null});
        docUpdated = true;
      }
      var stringsUpdated = [];
      var datesUpdated = [];
      for (var dateField in dateFields) {
        if (data.containsKey(dateField)) {
          var dataValue = data[dateField];
          if (dataValue is String) {
            var dateVal = DateTime.parse(dataValue).toUtc();
            await doc.reference.update({dateField: dateVal});
            stringsUpdated.add(dateField);
            dateUpdated = true;
          } else if (dataValue is DateTime) {
            var dateVal = dataValue.toUtc();
            await doc.reference.update({dateField: dateVal});
            datesUpdated.add(dateField);
            dateUpdated = true;
          }
        }
      }
      if (docUpdated) {
        updated++;
      }
      if (dateUpdated) {
        updatedDate++;
      }
      currIndex++;
      var percent = (currIndex / totalCount * 100).toStringAsFixed(1);
      var stringsMsg = stringsUpdated.isEmpty ? '' : " Updated string dates: " + stringsUpdated.join(", ") + ".";
      var datesMsg = datesUpdated.isEmpty ? '' : " Updates non-UTC dates: " + datesUpdated.join(", ") + ".";
      print('Processed $collectionName $currIndex/$totalCount ($percent%). Updated $updatedDate/$currIndex.' + stringsMsg + datesMsg + " ID: $taskId");
    }
    print('Finished processing $collectionName. Updated $updated/$currIndex retired values, $updatedDate/$currIndex dates.');
  }

  Future<void> migrateFromApi() async {
    var uri = getUriWithParameters("/api/allTasks", {'email': 'commander.boffo@gmail.com'});

    final response = await this.client.get(uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        var jsonObj = json.decode(response.body);
        await new FirestoreMigrator(client: client, firestore: firestore, jsonObj: jsonObj).migrateFromApi();
      } catch(exception, stackTrace) {
        print(exception);
        print(stackTrace);
        throw Exception('Error migration from the server. Talk to Mayhew.');
      }
    } else {
      throw Exception('Failed to migration. Talk to Mayhew.');
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