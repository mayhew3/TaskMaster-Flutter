// ignore_for_file: avoid_print
/// Firestore Export CLI Tool
///
/// Exports Firestore collections to CSV files for analysis.
///
/// Usage:
///   dart run bin/firestore_export.dart --emulator
///   dart run bin/firestore_export.dart --emulator --email=other@example.com
///   dart run bin/firestore_export.dart --emulator --person-doc-id=abc123
///   dart run bin/firestore_export.dart --emulator --collections=tasks,taskRecurrences
///   dart run bin/firestore_export.dart --production
///
/// Options:
///   --emulator          Connect to Firestore emulator (localhost:8085)
///   --production        Connect to production Firestore (requires auth)
///   --email             Filter by user email (looks up personDocId)
///   --person-doc-id     Filter by personDocId directly
///   --collections       Comma-separated list of collections to export
///   --output            Output directory (default: ./exports)
///
/// Default email when no filter specified: scorpy@gmail.com

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:csv/csv.dart';

const defaultEmail = 'scorpy@gmail.com';
const allCollections = ['tasks', 'taskRecurrences', 'sprints', 'snoozes', 'persons'];

Future<void> main(List<String> args) async {
  final config = _parseArgs(args);

  if (config.showHelp) {
    _printUsage();
    return;
  }

  print('Firestore Export Tool');
  print('=====================');

  // Initialize Firebase
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  // Configure for emulator if specified
  if (config.useEmulator) {
    firestore.useFirestoreEmulator('127.0.0.1', 8085);
    print('Connected to Firestore emulator at 127.0.0.1:8085');
  } else if (config.useProduction) {
    print('Connected to production Firestore');
  } else {
    print('ERROR: Must specify --emulator or --production');
    _printUsage();
    exit(1);
  }

  // Resolve personDocId
  String? personDocId = config.personDocId;
  final email = config.email ?? (personDocId == null ? defaultEmail : null);

  if (email != null && personDocId == null) {
    print('Looking up personDocId for email: $email');
    personDocId = await _lookupPersonDocId(firestore, email);
    if (personDocId == null) {
      print('ERROR: Could not find person with email: $email');
      exit(1);
    }
    print('Found personDocId: $personDocId');
  }

  // Create output directory
  final outputDir = Directory(config.outputDir);
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    print('Created output directory: ${config.outputDir}');
  }

  // Export collections
  final collectionsToExport = config.collections ?? allCollections;
  print('Exporting collections: ${collectionsToExport.join(', ')}');
  print('Filter: personDocId = $personDocId');
  print('');

  for (final collection in collectionsToExport) {
    await _exportCollection(
      firestore,
      collection,
      personDocId,
      config.outputDir,
    );
  }

  // Export sprintAssignments subcollection if sprints is included
  if (collectionsToExport.contains('sprints')) {
    await _exportSprintAssignments(firestore, personDocId, config.outputDir);
  }

  print('');
  print('Export complete! Files saved to: ${config.outputDir}');
}

class _Config {
  final bool useEmulator;
  final bool useProduction;
  final String? email;
  final String? personDocId;
  final List<String>? collections;
  final String outputDir;
  final bool showHelp;

  _Config({
    this.useEmulator = false,
    this.useProduction = false,
    this.email,
    this.personDocId,
    this.collections,
    this.outputDir = './exports',
    this.showHelp = false,
  });
}

_Config _parseArgs(List<String> args) {
  bool useEmulator = false;
  bool useProduction = false;
  String? email;
  String? personDocId;
  List<String>? collections;
  String outputDir = './exports';
  bool showHelp = false;

  for (final arg in args) {
    if (arg == '--emulator') {
      useEmulator = true;
    } else if (arg == '--production') {
      useProduction = true;
    } else if (arg == '--help' || arg == '-h') {
      showHelp = true;
    } else if (arg.startsWith('--email=')) {
      email = arg.substring('--email='.length);
    } else if (arg.startsWith('--person-doc-id=')) {
      personDocId = arg.substring('--person-doc-id='.length);
    } else if (arg.startsWith('--collections=')) {
      collections = arg.substring('--collections='.length).split(',');
    } else if (arg.startsWith('--output=')) {
      outputDir = arg.substring('--output='.length);
    }
  }

  return _Config(
    useEmulator: useEmulator,
    useProduction: useProduction,
    email: email,
    personDocId: personDocId,
    collections: collections,
    outputDir: outputDir,
    showHelp: showHelp,
  );
}

void _printUsage() {
  print('''
Firestore Export Tool
=====================

Exports Firestore collections to CSV files for analysis.

Usage:
  dart run bin/firestore_export.dart --emulator
  dart run bin/firestore_export.dart --emulator --email=user@example.com
  dart run bin/firestore_export.dart --emulator --person-doc-id=abc123
  dart run bin/firestore_export.dart --emulator --collections=tasks,taskRecurrences

Options:
  --emulator          Connect to Firestore emulator (localhost:8085)
  --production        Connect to production Firestore (requires auth)
  --email=<email>     Filter by user email (looks up personDocId)
  --person-doc-id=<id> Filter by personDocId directly
  --collections=<list> Comma-separated list of collections to export
                       Default: ${allCollections.join(',')}
  --output=<dir>       Output directory (default: ./exports)
  --help, -h          Show this help message

Default behavior:
  - Uses email: $defaultEmail when no filter is specified
  - Exports all collections: ${allCollections.join(', ')}

Examples:
  # Export from emulator with default email (scorpy@gmail.com)
  dart run bin/firestore_export.dart --emulator

  # Export specific collections
  dart run bin/firestore_export.dart --emulator --collections=tasks,taskRecurrences

  # Export by specific email
  dart run bin/firestore_export.dart --emulator --email=other@example.com
''');
}

Future<String?> _lookupPersonDocId(
  FirebaseFirestore firestore,
  String email,
) async {
  final snapshot = await firestore
      .collection('persons')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return null;
  return snapshot.docs.first.id;
}

Future<void> _exportCollection(
  FirebaseFirestore firestore,
  String collectionName,
  String? personDocId,
  String outputDir,
) async {
  print('Exporting $collectionName...');

  Query query = firestore.collection(collectionName);

  // Apply personDocId filter if available (not for persons collection)
  if (personDocId != null && collectionName != 'persons') {
    query = query.where('personDocId', isEqualTo: personDocId);
  } else if (collectionName == 'persons' && personDocId != null) {
    // For persons, filter by doc ID
    final doc = await firestore.collection('persons').doc(personDocId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['docId'] = doc.id;
      final rows = _convertToRows([data]);
      await _writeCsv(outputDir, collectionName, rows);
      print('  -> Exported 1 document');
      return;
    } else {
      print('  -> No documents found');
      return;
    }
  }

  final snapshot = await query.get();
  print('  -> Found ${snapshot.docs.length} documents');

  if (snapshot.docs.isEmpty) {
    print('  -> Skipping (no data)');
    return;
  }

  final data = snapshot.docs.map((doc) {
    final json = doc.data() as Map<String, dynamic>;
    json['docId'] = doc.id;
    return json;
  }).toList();

  final rows = _convertToRows(data);
  await _writeCsv(outputDir, collectionName, rows);
}

Future<void> _exportSprintAssignments(
  FirebaseFirestore firestore,
  String? personDocId,
  String outputDir,
) async {
  print('Exporting sprintAssignments (subcollection)...');

  // First get all sprints for this person
  Query sprintQuery = firestore.collection('sprints');
  if (personDocId != null) {
    sprintQuery = sprintQuery.where('personDocId', isEqualTo: personDocId);
  }

  final sprintsSnapshot = await sprintQuery.get();
  print('  -> Found ${sprintsSnapshot.docs.length} sprints to scan');

  final allAssignments = <Map<String, dynamic>>[];

  for (final sprintDoc in sprintsSnapshot.docs) {
    final assignmentsSnapshot = await firestore
        .collection('sprints')
        .doc(sprintDoc.id)
        .collection('sprintAssignments')
        .get();

    for (final assignmentDoc in assignmentsSnapshot.docs) {
      final json = assignmentDoc.data();
      json['docId'] = assignmentDoc.id;
      json['sprintDocId'] = sprintDoc.id;
      allAssignments.add(json);
    }
  }

  print('  -> Found ${allAssignments.length} total assignments');

  if (allAssignments.isEmpty) {
    print('  -> Skipping (no data)');
    return;
  }

  final rows = _convertToRows(allAssignments);
  await _writeCsv(outputDir, 'sprintAssignments', rows);
}

List<List<dynamic>> _convertToRows(List<Map<String, dynamic>> data) {
  if (data.isEmpty) return [];

  // Collect all unique keys across all documents
  final allKeys = <String>{};
  for (final doc in data) {
    allKeys.addAll(doc.keys);
  }

  // Sort keys for consistent column order
  final sortedKeys = allKeys.toList()..sort();

  // Create header row
  final rows = <List<dynamic>>[sortedKeys];

  // Create data rows
  for (final doc in data) {
    final row = sortedKeys.map((key) {
      final value = doc[key];
      return _formatValue(value);
    }).toList();
    rows.add(row);
  }

  return rows;
}

dynamic _formatValue(dynamic value) {
  if (value == null) return '';
  if (value is Timestamp) {
    return value.toDate().toUtc().toIso8601String();
  }
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }
  if (value is Map || value is List) {
    return value.toString();
  }
  return value;
}

Future<void> _writeCsv(
  String outputDir,
  String collectionName,
  List<List<dynamic>> rows,
) async {
  final csv = const ListToCsvConverter().convert(rows);
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
  final filename = '${collectionName}_$timestamp.csv';
  final file = File('$outputDir/$filename');
  await file.writeAsString(csv);
  print('  -> Written to: $outputDir/$filename');
}
