import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../firebase_options.dart';

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
  var taskCollection = firestore.collection('tasks');
  var originalCount = (await taskCollection.get()).docs.length;

  var problems = (await taskCollection.where('recurrence', isNotEqualTo: '').get()).docs;

  for (var doc in problems) {
    await doc.reference.update({'recurrence': FieldValue.delete()});
  }

  var problemsAfter = (await taskCollection.where('recurrence', isNotEqualTo: '').get()).docs;

  if (problemsAfter.isNotEmpty) {
    print('FIX FAILED! Problem rows before: ${problems.length}/${originalCount}, problem rows after: ${problemsAfter.length}/${originalCount}.');
  } else {
    print('Problem rows: ${problems.length}/${originalCount}.');
  }
}