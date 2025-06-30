
import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
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

class TaskRepository {
  final FirebaseFirestore firestore;

  final log = Logger('TaskRepository');

  TaskRepository({
    required this.firestore,
  });

  Future<String?> getPersonIdFromFirestore(String email) async {
    var withEmail = await firestore.collection('persons').where('email', isEqualTo: email).get();
    return withEmail.docs.firstOrNull?.id;
  }

  void goOffline() {
    firestore.disableNetwork().then((_) => print('Offline mode.'));
  }

  void goOnline() {
    firestore.enableNetwork().then((_) => print('Online mode.'));
  }

  ({StreamSubscription<QuerySnapshot<Map<String, dynamic>>> mainListener, Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> sprintAssignmentListeners}) createListener<T, S>({
    required String collectionName,
    required String personDocId,
    required Function(Iterable<T>) addCallback,
    Function(Iterable<T>)? modifyCallback,
    Function(Iterable<T>)? deleteCallback,
    required Serializer<T> serializer,
    int? limit,
    DateTime? completionFilter,
    String? subCollectionName,
    Function(Iterable<S>)? subAddCallback,
    Serializer<S>? subSerializer,
  }) {
    var sprintAssignmentListeners = <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
    var collectionRef = firestore.collection(collectionName);
    var completionQuery = completionFilter != null ?
      collectionRef.where(
        Filter.or(
          Filter('completionDate', isNull: true),
          Filter('completionDate', isGreaterThan: completionFilter),
        ),
      ) :
      collectionRef;
    var limitQuery = limit == null ?
      completionQuery :
      completionQuery.orderBy('sprintNumber', descending: true)
          .limit(limit);
    var snapshots = limitQuery.where('personDocId', isEqualTo: personDocId).snapshots();
    var listener = snapshots.listen((event) async {
      log.fine('$collectionName snapshots event!');

      var addedDocs = event.docChanges.where((dc) => dc.type == DocumentChangeType.added).map((dc) => dc.doc);

      var i = 0;
      var totalCount = addedDocs.length;
      var startingTime = DateTime.now();
      var rollingTime = DateTime.now();
      var gapTime = DateTime.now();

      var dataTimes = [];
      var dataTime = Duration.zero;
      var subCollectionTime = Duration.zero;
      var deserialTime = Duration.zero;
      var subCollectionTimes = [];
      var deserialTimes = [];

      List<T> finalList = [];
      for (var doc in addedDocs) {

        var json = doc.data()!;

        gapTime = DateTime.now();
        dataTimes.add(gapTime.difference(rollingTime));
        dataTime = dataTime + gapTime.difference(rollingTime);
        rollingTime = gapTime;

        json['docId'] = doc.id;
        var sprintNumber = json['sprintNumber'];

        if (subCollectionName != null && subSerializer != null && subAddCallback != null) {
          var subCollection = doc.reference.collection(subCollectionName);
          var subListener = subCollection.snapshots().listen((subEvent) async {
            var subDocs = subEvent.docChanges.where((dc) => dc.type == DocumentChangeType.added).map((dc) => dc.doc);
            if (subDocs.isNotEmpty) {
              var subObjects = subDocs.map((sd) {
                var subJson = sd.data();
                subJson?['docId'] = sd.id;
                var deserialized = serializers.deserializeWith(subSerializer, subJson) as S;
                return deserialized;
              });
              log.finer('SprintAssignments added! Sprint $sprintNumber, ${subObjects.length} objects.');
              subAddCallback(subObjects);
            }
          });
          var existingListener = sprintAssignmentListeners[doc.id];
          if (existingListener != null) {
            existingListener.cancel();
          }
          sprintAssignmentListeners[doc.id] = subListener;
        }

        gapTime = DateTime.now();
        subCollectionTimes.add(gapTime.difference(rollingTime));
        subCollectionTime = subCollectionTime + gapTime.difference(rollingTime);
        rollingTime = gapTime;

        try {
          var deserialized = serializers.deserializeWith(serializer, json) as T;
          finalList.add(deserialized);
        } on DeserializationError catch (e) {
          log.warning('Error deserializing $collectionName, \'${json['name']}\': $e');
          continue;
        }

        gapTime = DateTime.now();
        deserialTimes.add(gapTime.difference(rollingTime));
        deserialTime = deserialTime + gapTime.difference(rollingTime);
        rollingTime = gapTime;

        if (i % 10 == 0) {
          log.finer('Processed $i/$totalCount (${(i/totalCount*100).toStringAsFixed(1)}%)');
        }

        i++;
      }

      if (totalCount > 0) {
        Duration totalDuration = DateTime.now().difference(startingTime);
        log.fine(
            'Total duration for $collectionName add over $totalCount items: $totalDuration (${totalDuration ~/ totalCount} per item)');
        log.fine(' - data(): $dataTime (${(dataTime.inMilliseconds / totalDuration.inMilliseconds * 100).toStringAsFixed(1)}%)');
        log.fine(' - subCollection: $subCollectionTime (${(subCollectionTime
            .inMilliseconds / totalDuration.inMilliseconds * 100)
            .toStringAsFixed(1)}%)');
        log.fine(
            ' - deserialize: $deserialTime (${(deserialTime.inMilliseconds /
                totalDuration.inMilliseconds * 100).toStringAsFixed(1)}%)');
      }

      if (finalList.isNotEmpty) {
        addCallback(finalList);
      }

      i = 0;
      if (modifyCallback != null) {
        var modifyDocs = event.docChanges.where((dc) =>
        dc.type == DocumentChangeType.modified).map((dc) => dc.doc);
        List<T> modifyList = [];
        for (var doc in modifyDocs) {
          var json = doc.data()!;
          json['docId'] = doc.id;

          var deserialized = serializers.deserializeWith(serializer, json) as T;
          modifyList.add(deserialized);
        }
        if (modifyList.isNotEmpty) {
          modifyCallback(modifyList);
        }
      }

    });
    return (mainListener: listener, sprintAssignmentListeners: sprintAssignmentListeners);
  }

  void addTask(TaskItemBlueprint blueprint) async {
    var blueprintJson = blueprint.toJson();

    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    if (recurrenceBlueprint != null) {
      var recurrenceDoc = firestore.collection('taskRecurrences').doc();
      var recurrenceJson = recurrenceBlueprint.toJson();
      recurrenceJson['dateAdded'] = DateTime.now().toUtc();
      recurrenceDoc.set(recurrenceJson);
      blueprintJson['recurrenceDocId'] = recurrenceDoc.id;
      blueprintJson.remove('recurrenceBlueprint');
    }

    var addedTaskDoc = firestore.collection('tasks').doc();
    var taskId = addedTaskDoc.id;
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedTaskDoc.set(blueprintJson);
    blueprintJson['docId'] = taskId;
  }

  TaskItem addRecurTask(TaskItemRecurPreview blueprint) {
    Map<String, dynamic> blueprintJson = blueprint.toJson();

    var addedTaskDoc = firestore.collection('tasks').doc();
    var taskId = addedTaskDoc.id;
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedTaskDoc.set(blueprintJson);
    blueprintJson['docId'] = taskId;

    var updatedTask = serializers.deserializeWith(TaskItem.serializer, blueprintJson)!;

    return updatedTask;
  }

  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> updateTaskAndRecurrence(String taskItemDocId, TaskItemBlueprint blueprint) async {
    var blueprintJson = blueprint.toJson();

    TaskItem? updatedTask;
    TaskRecurrence? updatedRecurrence;

    try {
      await firestore.runTransaction((transaction) async {

        var taskDoc = firestore.collection('tasks').doc(taskItemDocId);

        var recurrenceBlueprint = blueprint.recurrenceBlueprint;
        if (recurrenceBlueprint != null) {
          var recurrenceDocId = blueprint.recurrenceDocId;
          if (recurrenceDocId != null) {
            var recurrenceDoc = firestore.collection('taskRecurrences').doc(recurrenceDocId);
            var recurrenceJson = recurrenceBlueprint.toJson();
            recurrenceDoc.update(recurrenceJson);

            updatedRecurrence = await updateRecurrence(recurrenceDoc, recurrenceJson, recurrenceDocId, updatedRecurrence, blueprintJson);
          } else {
            var recurrenceDoc = firestore.collection('taskRecurrences').doc();
            recurrenceDocId = recurrenceDoc.id;
            var recurrenceJson = recurrenceBlueprint.toJson();

            recurrenceJson['dateAdded'] = DateTime.now().toUtc();
            recurrenceDoc.set(recurrenceJson);

            updatedRecurrence = await updateRecurrence(recurrenceDoc, recurrenceJson, recurrenceDocId, updatedRecurrence, blueprintJson);
            blueprintJson['recurrenceDocId'] = recurrenceDocId;
          }
        }

        taskDoc.update(blueprintJson);

        var snapshot = await taskDoc.get();
        blueprintJson['docId'] = taskDoc.id;
        blueprintJson['dateAdded'] = snapshot.get('dateAdded');
        updatedTask = serializers.deserializeWith(TaskItem.serializer, blueprintJson)!;
      });

      if (updatedTask == null) {
        throw Exception('No updated task!');
      } else {
        return (taskItem: updatedTask!, recurrence: updatedRecurrence);
      }

    } catch (e) {
      log.warning('Error updating task and recurrence: $e');
      rethrow;
    }

  }

  Future<TaskRecurrence?> updateRecurrence(
      DocumentReference<Map<String, dynamic>> recurrenceDoc,
      Map<String, dynamic> recurrenceJson,
      String recurrenceDocId,
      TaskRecurrence? updatedRecurrence,
      Map<String, dynamic> blueprintJson
      ) async {
    var recurSnap = await recurrenceDoc.get();
    recurrenceJson['docId'] = recurrenceDocId;
    recurrenceJson['dateAdded'] = recurSnap.get('dateAdded');
    updatedRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, recurrenceJson);
    blueprintJson.remove('recurrenceBlueprint');
    return updatedRecurrence;
  }

  Future<({Sprint sprint, BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addSprintWithTaskItems(SprintBlueprint blueprint, BuiltList<TaskItem> existingItems, BuiltList<TaskItemRecurPreview> newItems) async {
    var newTaskItemsList = newItems.map((t) => t.toJson()).toList();

    var personDocId = blueprint.personDocId;

    var blueprintJson = blueprint.toJson();
    var existingIds = existingItems.map((t) => t.docId).toList();

    Sprint? addedSprint;
    var addedTasks = ListBuilder<TaskItem>();
    var sprintAssignments = ListBuilder<SprintAssignment>();

    try {
      await firestore.runTransaction((transaction) async {
        var addedSprintDoc = firestore.collection('sprints').doc();
        var sprintId = addedSprintDoc.id;
        blueprintJson['dateAdded'] = DateTime.now().toUtc();
        transaction.set(addedSprintDoc, blueprintJson);
        blueprintJson['docId'] = sprintId;
        addedSprint =
        serializers.deserializeWith(Sprint.serializer, blueprintJson)!;

        for (var toAdd in newTaskItemsList) {
          toAdd as Map<String, Object?>;
          var addedTaskDoc = firestore.collection('tasks').doc();
          var taskId = addedTaskDoc.id;
          toAdd['dateAdded'] = DateTime.now().toUtc();
          transaction.set(addedTaskDoc, toAdd);
          toAdd['docId'] = taskId;
          addedTasks.add(
              serializers.deserializeWith(TaskItem.serializer, toAdd)!);
          existingIds.add(taskId);
        }

        var sprintAssignmentsCollection = addedSprintDoc
            .collection('sprintAssignments');

        for (var existingId in existingIds) {
          var sprintAssignment = sprintAssignmentsCollection.doc();
          var sprintAssignmentId = sprintAssignment.id;
          var sprintAssignmentJson = {
            'taskDocId': existingId,
            'sprintDocId': sprintId,
            'personDocId': personDocId,
            'dateAdded': DateTime.now().toUtc(),
            'retired': null,
            'retiredDate': null,
          };
          transaction.set(sprintAssignment, sprintAssignmentJson);
          sprintAssignmentJson['docId'] = sprintAssignmentId;
          sprintAssignments.add(serializers.deserializeWith(
              SprintAssignment.serializer, sprintAssignmentJson)!);
        }
      });


      if (addedSprint == null) {
        throw Exception('No added sprint!');
      } else {
        return (sprint: addedSprint!, addedTasks: addedTasks
            .build(), sprintAssignments: sprintAssignments.build());
      }
    } catch (e) {
      log.warning('Error adding sprint: $e');
      rethrow;
    }
  }

  Future<TaskRecurrence> updateTaskRecurrence(String taskRecurrenceDocId, TaskRecurrenceBlueprint blueprint) async {
    var blueprintJson = blueprint.toJson();

    var doc = firestore.collection('taskRecurrences').doc(taskRecurrenceDocId);
    doc.update(blueprintJson);

    var snapshot = await doc.get();
    blueprintJson['docId'] = doc.id;
    blueprintJson['dateAdded'] = snapshot.get('dateAdded');
    var updatedRecurrence = serializers.deserializeWith(TaskRecurrence.serializer, blueprintJson)!;

    return updatedRecurrence;
  }


  Future<({BuiltList<TaskItem> addedTasks, BuiltList<SprintAssignment> sprintAssignments})> addTasksToSprint(BuiltList<TaskItem> existingItems, BuiltList<TaskItemRecurPreview> newItems, Sprint sprint) async {
    var newTaskItemsList = newItems.map((t) => t.toJson()).toList();

    var personDocId = sprint.personDocId;

    var existingIds = existingItems.map((t) => t.docId).toList();

    var addedTasks = ListBuilder<TaskItem>();
    var sprintAssignments = ListBuilder<SprintAssignment>();

    try {
      await firestore.runTransaction((transaction) async {
        var sprintId = sprint.docId;
        var sprintDocRef = firestore.collection('sprints').doc(sprint.docId);

        for (var toAdd in newTaskItemsList) {
          toAdd as Map<String, Object?>;
          var addedTaskDoc = firestore.collection('tasks').doc();
          var taskId = addedTaskDoc.id;
          toAdd['dateAdded'] = DateTime.now().toUtc();
          transaction.set(addedTaskDoc, toAdd);
          toAdd['docId'] = taskId;
          addedTasks.add(
              serializers.deserializeWith(TaskItem.serializer, toAdd)!);
          existingIds.add(taskId);
        }

        var sprintAssignmentsCollection = sprintDocRef
            .collection('sprintAssignments');

        for (var existingId in existingIds) {
          var sprintAssignment = sprintAssignmentsCollection.doc();
          var sprintAssignmentId = sprintAssignment.id;
          var sprintAssignmentJson = {
            'taskDocId': existingId,
            'sprintDocId': sprintId,
            'personDocId': personDocId,
            'dateAdded': DateTime.now().toUtc(),
            'retired': null,
            'retiredDate': null,
          };
          transaction.set(sprintAssignment, sprintAssignmentJson);
          sprintAssignmentJson['docId'] = sprintAssignmentId;
          sprintAssignments.add(serializers.deserializeWith(
              SprintAssignment.serializer, sprintAssignmentJson)!);
        }
      });

      return (addedTasks: addedTasks.build(), sprintAssignments: sprintAssignments.build());

    } catch (e) {
      print('Error adding sprint: $e');
      rethrow;
    }

  }

  void deleteTask(TaskItem taskItem) async {
    var doc = firestore.collection('tasks').doc(taskItem.docId);
    doc.update({'retired': taskItem.docId, 'retiredDate': DateTime.now().toUtc()});
  }

  void addSnooze(SnoozeBlueprint snooze) async {
    var blueprintJson = snooze.toJson();

    var addedSnoozeDoc = firestore.collection('snoozes').doc();
    blueprintJson['dateAdded'] = DateTime.now().toUtc();
    addedSnoozeDoc.set(blueprintJson);
  }



  // HELPER METHODS

  Future<void> dataFixAll() async {
    await dataFixCollection(collectionName: 'persons');
    await dataFixCollection(collectionName: 'snoozes');
    await dataFixCollection(collectionName: 'sprints');
    await dataFixCollection(collectionName: 'taskRecurrences');
    await dataFixCollection(collectionName: 'tasks', subCollectionName: 'sprintAssignments');
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
      var stringsMsg = stringsUpdated.isEmpty ? '' : " Updated string dates: ${stringsUpdated.join(", ")}.";
      var datesMsg = datesUpdated.isEmpty ? '' : " Updates non-UTC dates: ${datesUpdated.join(", ")}.";
      print('Processed $collectionName $currIndex/$totalCount ($percent%). Updated $updatedDate/$currIndex.$stringsMsg$datesMsg ID: $taskId');
    }
    print('Finished processing $collectionName. Updated $updated/$currIndex retired values, $updatedDate/$currIndex dates.');
  }

}