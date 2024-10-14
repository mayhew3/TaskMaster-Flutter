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

  Future<void> migrateFromApi(String idToken) async {
    var persons = await syncPersons(false);
    var recurrences = await syncRecurrences(persons, false);
    var sprints = await syncSprints(persons, false);
    var tasks = await syncTasks(recurrences, sprints, persons, false);
    await syncSnoozes(tasks, true);
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
      for (var document in querySnapshot.docs) {
        var assignments = await document.reference.collection(
            "sprintAssignments").get();
        for (var assignment in assignments.docs) {
          assignment.reference.delete();
        }
        await document.reference.delete();
      }
      querySnapshot = await taskCollection.get();
    }

    List<DocumentSnapshot<Map<String, dynamic>>> taskRefs = [];

    var taskObjs = jsonObj['tasks'] as List<dynamic>;
    var taskCount = taskObjs.length;

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
          sprintAssignmentObj['sprintDocId'] = sprintDocId;
          sprintAssignmentObj['taskDocId'] = taskDocId;

          documentRef.collection("sprintAssignments").add(sprintAssignmentObj);
        }

        var snapshot = await documentRef.get();
        taskRefs.add(snapshot);

        added++;
        print('Added new task! $added added.');
      } else {
        taskRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / taskCount * 100;
      print('Processed task $currIndex/$taskCount} ($percent%).');
    }

    return taskRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncSprints(
      List<DocumentSnapshot<Map<String, dynamic>>> persons,
      bool dropFirst,) async {
    var sprintCollection = firestore.collection("sprints");
    var querySnapshot = await sprintCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, sprintCollection);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> sprintRefs = [];

    var sprintObjs = jsonObj['sprints'] as List<dynamic>;
    var sprintCount = sprintObjs.length;
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
        sprintRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / sprintCount * 100;
      print('Processed sprint $currIndex/$sprintCount} ($percent%).');
    }

    return sprintRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncSnoozes(
      List<DocumentSnapshot<Map<String, dynamic>>> tasks,
      bool dropFirst,) async {
    var snoozeCollection = firestore.collection("snoozes");
    var querySnapshot = await snoozeCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, snoozeCollection);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> snoozeRefs = [];

    var snoozeObjs = jsonObj['snoozes'] as List<dynamic>;
    var snoozeCount = snoozeObjs.length;
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
        snoozeRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / snoozeCount * 100;
      print('Processed sprint $currIndex/$snoozeCount} ($percent%).');
    }

    return snoozeRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncPersons(bool dropFirst,) async {
    var personCollection = firestore.collection("persons");
    var querySnapshot = await personCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, personCollection);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> personRefs = [];

    var personObjs = jsonObj['persons'] as List<dynamic>;
    var personCount = personObjs.length;
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
        personRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / personCount * 100;
      print('Processed person $currIndex/$personCount} ($percent%).');
    }

    return personRefs;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> syncRecurrences(List<DocumentSnapshot<Map<String, dynamic>>> persons, bool dropFirst,) async {
    var recurrenceCollection = firestore.collection("taskRecurrences");
    var querySnapshot = await recurrenceCollection.get();

    if (dropFirst) {
      querySnapshot = await dropTable(querySnapshot, recurrenceCollection);
    }

    List<DocumentSnapshot<Map<String, dynamic>>> recurrenceRefs = [];

    var recurrenceObjs = jsonObj['taskRecurrences'] as List<dynamic>;
    var recurrenceCount = recurrenceObjs.length;
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
        recurrenceRefs.add(existing);
      }
      currIndex++;
      var percent = currIndex / recurrenceCount * 100;
      print('Processed recurrence $currIndex/$recurrenceCount} ($percent%).');
    }

    return recurrenceRefs;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> dropTable(
      QuerySnapshot<Map<String, dynamic>> querySnapshot,
      CollectionReference<Map<String, dynamic>> collectionReference) async {
    for (var document in querySnapshot.docs) {
      await document.reference.delete();
    }
    return await collectionReference.get();
  }

}