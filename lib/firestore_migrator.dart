import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FirestoreMigrator {
  http.Client client;
  FirebaseFirestore firestore;
  dynamic jsonObj;

  FirestoreMigrator({
    required this.client,
    required this.firestore,
    required this.jsonObj,
  });

  Future<void> migrateFromApi() async {
    var persons = await syncPersons(false);
    var recurrences = await syncRecurrences(persons, false);
    var sprints = await syncSprints(persons, false);
    var tasks = await syncTasks(recurrences, sprints, persons, false);
    await syncSnoozes(tasks, false);
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncTasks(
      List<DocumentSnapshot<Map<String, dynamic>>> recurrences,
      List<DocumentSnapshot<Map<String, dynamic>>> sprints,
      List<DocumentSnapshot<Map<String, dynamic>>> persons,
      bool dropFirst,
      ) async {
    var taskCollection = firestore.collection("tasks");
    var querySnapshot = await taskCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, taskCollection, "sprintAssignments");
    }

    List<DocumentSnapshot<Map<String, dynamic>>> taskRefs = [];

    var taskJsons = jsonObj['tasks'] as List<dynamic>;
    var taskCount = taskJsons.length;
    var taskObjs = convertDates(taskJsons);

    var currIndex = 0;
    var added = 0;
    for (Map<String, Object?> taskObj in taskObjs) {
      var existing = querySnapshot.docs.where((t) => t.data()['id'] == taskObj['id']).firstOrNull;
      if (existing == null) {
        taskObj['personDocId'] = persons.where((p) => p.get('id') == taskObj['personId']).first.id;
        taskObj['recurrenceDocId'] = recurrences.where((r) => r.get('id') == taskObj['recurrenceId']).firstOrNull?.id;

        var sprintAssignmentObjs = taskObj['sprintAssignments'] as List<dynamic>;
        taskObj.remove('sprintAssignments');

        var documentRef = await taskCollection.add(taskObj);

        for (Map<String, Object?> sprintAssignmentObj in sprintAssignmentObjs) {
          var sprintDocId = sprints.where((s) => s.get('id') == sprintAssignmentObj['sprintId']).first.id;
          var taskDocId = documentRef.id;
          var originalDate = sprintAssignmentObj['dateAdded']! as String;
          sprintAssignmentObj['dateAdded'] = DateTime.parse(originalDate).toUtc();
          sprintAssignmentObj['sprintDocId'] = sprintDocId;
          sprintAssignmentObj['taskDocId'] = taskDocId;

          documentRef.collection("sprintAssignments").add(sprintAssignmentObj);
        }

        var snapshot = await documentRef.get();
        taskRefs.add(snapshot);

        added++;
        print('Added new task! $added added.');
      } else {
        if (!existing.data().containsKey('retired')) {
          await existing.reference.update({'retired': null});
        }
        taskRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / taskCount * 100;
      print('Processed task $currIndex/$taskCount} ($percent%).');
    }

    print("Finished processing tasks.");

    return taskRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncSprints(
      List<DocumentSnapshot<Map<String, dynamic>>> persons,
      bool dropFirst,) async {
    var sprintCollection = firestore.collection("sprints");
    var querySnapshot = await sprintCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, sprintCollection, null);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> sprintRefs = [];

    var sprintJsons = jsonObj['sprints'] as List<dynamic>;
    var sprintCount = sprintJsons.length;
    var sprintObjs = convertDates(sprintJsons);
    var currIndex = 0;
    var added = 0;
    for (var sprintObj in sprintObjs) {
      var existing = querySnapshot.docs.where((s) => s.data()['id'] == sprintObj['id']).firstOrNull;
      if (existing == null) {
        sprintObj['personDocId'] = persons.where((p) => p.get('id') == sprintObj['personId']).first.id;
        var documentReference = await sprintCollection.add(sprintObj);
        var snapshot = await documentReference.get();
        sprintRefs.add(snapshot);
        added++;
        print('Added new sprint! $added added.');
      } else {
        if (!existing.data().containsKey('retired')) {
          await existing.reference.update({'retired': null});
        }
        sprintRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / sprintCount * 100;
      print('Processed sprint $currIndex/$sprintCount} ($percent%).');
    }

    print("Finished processing sprints.");
    return sprintRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncSnoozes(
      List<DocumentSnapshot<Map<String, dynamic>>> tasks,
      bool dropFirst,) async {
    var snoozeCollection = firestore.collection("snoozes");
    var querySnapshot = await snoozeCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, snoozeCollection, null);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> snoozeRefs = [];

    var snoozeJsons = jsonObj['snoozes'] as List<dynamic>;
    var snoozeCount = snoozeJsons.length;
    var snoozeObjs = convertDates(snoozeJsons);
    var currIndex = 0;
    var added = 0;
    for (var snoozeObj in snoozeObjs) {
      var existing = querySnapshot.docs.where((s) => s.data()['id'] == snoozeObj['id']).firstOrNull;
      if (existing == null) {
        var taskObj = tasks.where((t) => t.get('id') == snoozeObj['taskId']).firstOrNull;
        if (taskObj != null) {
          snoozeObj['taskDocId'] = taskObj.id;
          var documentReference = await snoozeCollection.add(snoozeObj);
          var snapshot = await documentReference.get();
          snoozeRefs.add(snapshot);
          added++;
          print('Added new snooze! $added added.');
        }
      } else {
        if (!existing.data().containsKey('retired')) {
          await existing.reference.update({'retired': null});
        }
        snoozeRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / snoozeCount * 100;
      print('Processed sprint $currIndex/$snoozeCount} ($percent%).');
    }

    print("Finished processing snoozes.");
    return snoozeRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncPersons(bool dropFirst,) async {
    var personCollection = firestore.collection("persons");
    var querySnapshot = await personCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, personCollection, null);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> personRefs = [];

    var personJsons = jsonObj['persons'] as List<dynamic>;
    var personCount = personJsons.length;
    var personObjs = convertDates(personJsons);
    var currIndex = 0;
    var added = 0;
    for (var personObj in personObjs) {
      var existing = querySnapshot.docs.where((p) => p.data()['id'] == personObj['id']).firstOrNull;
      if (existing == null) {
        var documentReference = await personCollection.add(personObj);
        var snapshot = await documentReference.get();
        personRefs.add(snapshot);
        added++;
        print('Added new person! $added added.');
      } else {
        if (!existing.data().containsKey('retired')) {
          await existing.reference.update({'retired': null});
        }
        personRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / personCount * 100;
      print('Processed person $currIndex/$personCount} ($percent%).');
    }

    print("Finished processing persons.");
    return personRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncRecurrences(List<DocumentSnapshot<Map<String, dynamic>>> persons, bool dropFirst,) async {
    var recurrenceCollection = firestore.collection("taskRecurrences");
    var querySnapshot = await recurrenceCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, recurrenceCollection, null);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> recurrenceRefs = [];

    var recurrenceJsons = jsonObj['taskRecurrences'] as List<dynamic>;
    var recurrenceCount = recurrenceJsons.length;
    var recurrenceObjs = convertDates(recurrenceJsons);
    var currIndex = 0;
    var added = 0;
    for (var recurrenceObj in recurrenceObjs) {
      var existing = querySnapshot.docs.where((r) => r.data()['id'] == recurrenceObj['id']).firstOrNull;
      if (existing == null) {
        recurrenceObj['personDocId'] = persons.where((p) => p.get('id') == recurrenceObj['personId']).first.id;
        var docRef = await recurrenceCollection.add(recurrenceObj);
        var snapshot = await docRef.get();
        recurrenceRefs.add(snapshot);
        added++;
        print('Added new recurrence! $added added.');
      } else {
        if (!existing.data().containsKey('retired')) {
          await existing.reference.update({'retired': null});
        }
        recurrenceRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / recurrenceCount * 100;
      print('Processed recurrence $currIndex/$recurrenceCount (${percent.toStringAsFixed(1)}%).');
    }

    print("Finished processing recurrences.");
    return recurrenceRefs;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> dropTable(
      QuerySnapshot<Map<String, dynamic>> querySnapshot,
      CollectionReference<Map<String, dynamic>> collectionReference,
      String? subCollectionName,
      ) async {
    var totalCount = querySnapshot.docs.length;
    var collectionPath = collectionReference.path;
    print("Dropping collection $collectionPath with $totalCount documents...");
    var dropCount = 0;
    for (var document in querySnapshot.docs) {

      var subDocCount = 0;

      if (subCollectionName != null) {
        var subCollectRef = await document.reference.collection(
            subCollectionName).get();
        var docs = subCollectRef.docs;
        subDocCount = docs.length;
        for (var subDoc in docs) {
          subDoc.reference.delete();
        }
      }

      await document.reference.delete();
      dropCount++;

      var percent = (dropCount / totalCount * 100).toStringAsFixed(1);
      var msg = "Dropped document $dropCount/$totalCount ($percent%) from collection $collectionPath";
      if (subDocCount > 0) {
        msg += ", including $subDocCount in subcollection '$subCollectionName'";
      }
      print(msg);
    }
    print("All documents dropped from collection $collectionPath.");
    return await collectionReference.get();
  }

  dynamic maybeConvertDate(MapEntry<String, dynamic> jsonValue) {
    var value = jsonValue.value;
    if (!(value is String)) {
      return jsonValue;
    }
    try {
      var parsed = DateTime.parse(value).toUtc();
      return MapEntry<String, dynamic>(jsonValue.key, parsed);
    } catch (e) {
      return jsonValue;
    }
  }

  BuiltList<Map<String, dynamic>> convertDates(List jsonObjs) {
    var destinationList = ListBuilder<Map<String, dynamic>>();
    for (var jsonObj in jsonObjs) {
      var destinationMap = new Map<String, dynamic>();
      for (var entry in jsonObj.entries) {
        var addedEntry = maybeConvertDate(entry);
        destinationMap.addEntries([addedEntry]);
      }
      destinationList.add(destinationMap);
    }
    return destinationList.build();
  }

}