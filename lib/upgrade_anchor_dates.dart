import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {

  print('Hello world!');

  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var firestore = FirebaseFirestore.instance;

  const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  if (serverEnv == 'local') {
    firestore.useFirestoreEmulator('127.0.0.1', 8085);
    firestore.settings = const Settings(
      persistenceEnabled: false,
    );
  } else {
    firestore.settings = const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  await executeUpdate(firestore, http.Client());

  print('Migration complete!');

  exit(0);
}

Future<void> executeUpdate(FirebaseFirestore firestore, http.Client client) async {
  var recurrenceCollection = firestore.collection('taskRecurrences');
  var querySnapshot = await recurrenceCollection.get();

  var problems = querySnapshot.docs.where((t) => t.data()['anchorDate'] is Timestamp);
  var docSnapshot = await firestore.collection('tasks').get();
  var tasks = docSnapshot.docs;
  var updatedToNull = 0;

  for (var doc in problems) {
    var recurrence = doc.data();

    var tasksForRecurrence = tasks.where((t) => t.data()['recurrenceDocId'] == doc.id).toList();
    tasksForRecurrence.sort((a, b) => b.data()['recurIteration'].compareTo(a.data()['recurIteration']));

    var anchorType = recurrence['anchorType'];
    var fullAnchorName = anchorType.toLowerCase() + 'Date';
    if (tasksForRecurrence.isEmpty) {
      // todo: log all empty ones, and maybe delete them?

      doc.reference.update({'anchorDate': null, 'anchorType': FieldValue.delete()});
      updatedToNull++;
      continue;
    }

    var withAnchor = tasksForRecurrence.where((t) => t.data()[fullAnchorName] != null).toList();

    // DEBUG ONLY
    /*
    var datesOnly = withAnchor.map((t) {
      Timestamp timestamp = t.data()[fullAnchorName];
      var millisecondsSinceEpoch = timestamp.millisecondsSinceEpoch;
      return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    }).toList();
    var iterations = withAnchor.map((t) => t.data()['recurIteration']).toList();
*/

    var mostRecentTask = withAnchor.first.data();
    var anchorDate = mostRecentTask[fullAnchorName];
    var newAnchorDate = {
      'dateValue': anchorDate,
      'dateType': anchorType,
    };
    doc.reference.update({'anchorDate': newAnchorDate, 'anchorType': FieldValue.delete(), 'recurIteration': mostRecentTask['recurIteration']});
  }

  print('Problem rows: ${problems.length}/${querySnapshot.docs.length}. Null rows: $updatedToNull.');
}