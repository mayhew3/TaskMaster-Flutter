import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
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

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }
}

Future<void> executeUpdate(FirebaseFirestore firestore, http.Client client) async {
  var taskSnapshot = await firestore.collection('tasks').get();

  var problems = taskSnapshot.docs.where((t) => t.data()['recurrence'] != null);

  for (var doc in problems) {
    doc.reference.update({'recurrence': null});
    var recurrence = doc.data()['recurrence'];
    var poop = 0;
  }

  print('Problem rows: ${problems.length}/${taskSnapshot.docs.length}.');
}