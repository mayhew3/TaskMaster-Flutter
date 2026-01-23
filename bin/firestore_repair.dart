// ignore_for_file: avoid_print
/// Firestore Recurrence Repair CLI Tool
///
/// Detects and repairs bad data from the recurring task duplication bug (TM-324).
/// The bug caused duplicate recurrence documents and mismatched iteration values
/// during sprint creation.
///
/// Usage:
///   dart run bin/firestore_repair.dart --emulator
///   dart run bin/firestore_repair.dart --emulator --apply
///   dart run bin/firestore_repair.dart --emulator --email=other@example.com
///   dart run bin/firestore_repair.dart --emulator --person-doc-id=abc123
///
/// Options:
///   --emulator          Connect to Firestore emulator (localhost:8085)
///   --production        Connect to production Firestore (requires auth)
///   --email             Filter by user email (looks up personDocId)
///   --person-doc-id     Filter by personDocId directly
///   --apply             Apply repairs (default is dry-run)
///
/// Default email when no filter specified: scorpy@gmail.com

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

const defaultEmail = 'scorpy@gmail.com';

/// Entry point for CLI execution
Future<void> main(List<String> args) async {
  final config = _parseArgs(args);

  if (config.showHelp) {
    _printUsage();
    return;
  }

  print('Recurrence Data Repair Tool');
  print('===========================');

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

  print('Mode: ${config.applyRepairs ? "APPLY" : "DRY-RUN (use --apply to make changes)"}');
  print('');

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
  }

  print('Target: ${email ?? "unknown email"} (personDocId: $personDocId)');
  print('');

  // Run the repair tool
  final repairTool = RecurrenceRepairTool(
    firestore: firestore,
    personDocId: personDocId!,
    applyRepairs: config.applyRepairs,
  );

  await repairTool.run();
}

/// Configuration parsed from command line arguments
class _Config {
  final bool useEmulator;
  final bool useProduction;
  final String? email;
  final String? personDocId;
  final bool applyRepairs;
  final bool showHelp;

  _Config({
    this.useEmulator = false,
    this.useProduction = false,
    this.email,
    this.personDocId,
    this.applyRepairs = false,
    this.showHelp = false,
  });
}

_Config _parseArgs(List<String> args) {
  bool useEmulator = false;
  bool useProduction = false;
  String? email;
  String? personDocId;
  bool applyRepairs = false;
  bool showHelp = false;

  for (final arg in args) {
    if (arg == '--emulator') {
      useEmulator = true;
    } else if (arg == '--production') {
      useProduction = true;
    } else if (arg == '--apply') {
      applyRepairs = true;
    } else if (arg == '--help' || arg == '-h') {
      showHelp = true;
    } else if (arg.startsWith('--email=')) {
      email = arg.substring('--email='.length);
    } else if (arg.startsWith('--person-doc-id=')) {
      personDocId = arg.substring('--person-doc-id='.length);
    }
  }

  return _Config(
    useEmulator: useEmulator,
    useProduction: useProduction,
    email: email,
    personDocId: personDocId,
    applyRepairs: applyRepairs,
    showHelp: showHelp,
  );
}

void _printUsage() {
  print('''
Recurrence Data Repair Tool
============================

Detects and repairs bad data from the recurring task duplication bug (TM-324).

Usage:
  dart run bin/firestore_repair.dart --emulator
  dart run bin/firestore_repair.dart --emulator --apply
  dart run bin/firestore_repair.dart --emulator --email=user@example.com

Options:
  --emulator            Connect to Firestore emulator (localhost:8085)
  --production          Connect to production Firestore (requires auth)
  --email=<email>       Filter by user email (looks up personDocId)
  --person-doc-id=<id>  Filter by personDocId directly
  --apply               Apply repairs (default is dry-run analysis only)
  --help, -h            Show this help message

Default behavior:
  - Uses email: $defaultEmail when no filter is specified
  - Runs in dry-run mode (analysis only) unless --apply is specified

Bad Data Scenarios Detected:
  1. Out-of-sync iterations - recurrence.recurIteration < highest task iteration
  2. Duplicate iterations - Multiple non-retired tasks with same recurIteration
  3. Orphaned tasks - Task has recurrenceDocId but recurrence doesn't exist
  4. Duplicate recurrences - Multiple recurrence docs for same task family

Examples:
  # Analyze data on emulator (dry-run)
  dart run bin/firestore_repair.dart --emulator

  # Apply repairs on emulator
  dart run bin/firestore_repair.dart --emulator --apply

  # Analyze specific user
  dart run bin/firestore_repair.dart --emulator --email=other@example.com
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

// ============================================================================
// Data Classes for Analysis Results
// ============================================================================

/// Represents a recurrence that is out of sync with its tasks
class OutOfSyncRecurrence {
  final String recurrenceDocId;
  final String name;
  final int currentIteration;
  final int maxTaskIteration;

  OutOfSyncRecurrence({
    required this.recurrenceDocId,
    required this.name,
    required this.currentIteration,
    required this.maxTaskIteration,
  });

  @override
  String toString() =>
      '"$name" ($recurrenceDocId): expects $currentIteration, found tasks up to $maxTaskIteration';
}

/// Represents duplicate tasks with the same iteration
class DuplicateIteration {
  final String recurrenceDocId;
  final String recurrenceName;
  final int iteration;
  final List<TaskInfo> tasks;

  DuplicateIteration({
    required this.recurrenceDocId,
    required this.recurrenceName,
    required this.iteration,
    required this.tasks,
  });

  @override
  String toString() {
    final taskIds = tasks.map((t) => t.docId).join(', ');
    return '"$recurrenceName" ($recurrenceDocId), iteration #$iteration: ${tasks.length} tasks ($taskIds)';
  }
}

/// Basic task info used in analysis
class TaskInfo {
  final String docId;
  final String name;
  final DateTime dateAdded;
  final int? recurIteration;
  final String? recurrenceDocId;
  final bool hasRecurrenceMetadata;
  final bool hasSnoozePending;

  TaskInfo({
    required this.docId,
    required this.name,
    required this.dateAdded,
    this.recurIteration,
    this.recurrenceDocId,
    required this.hasRecurrenceMetadata,
    this.hasSnoozePending = false,
  });
}

/// Represents a task with orphaned recurrence reference
class OrphanedTask {
  final TaskInfo task;
  final String missingRecurrenceDocId;

  OrphanedTask({
    required this.task,
    required this.missingRecurrenceDocId,
  });

  @override
  String toString() =>
      '"${task.name}" (${task.docId}): references missing recurrence $missingRecurrenceDocId';
}

/// Represents a family of duplicate recurrences
class DuplicateRecurrenceFamily {
  final String name;
  final String personDocId;
  final List<RecurrenceInfo> recurrences;
  late final RecurrenceInfo canonical;

  DuplicateRecurrenceFamily({
    required this.name,
    required this.personDocId,
    required this.recurrences,
  }) {
    // Select canonical as the one with highest iteration
    recurrences.sort((a, b) => b.recurIteration.compareTo(a.recurIteration));
    canonical = recurrences.first;
  }

  List<RecurrenceInfo> get nonCanonical =>
      recurrences.where((r) => r.docId != canonical.docId).toList();

  @override
  String toString() {
    final ids = recurrences.map((r) => r.docId).join(', ');
    return '"$name": ${recurrences.length} recurrences ($ids)';
  }
}

/// Basic recurrence info used in analysis
class RecurrenceInfo {
  final String docId;
  final String name;
  final String personDocId;
  final int recurIteration;
  final int? recurNumber;
  final String? recurUnit;
  final bool? recurWait;

  RecurrenceInfo({
    required this.docId,
    required this.name,
    required this.personDocId,
    required this.recurIteration,
    this.recurNumber,
    this.recurUnit,
    this.recurWait,
  });
}

/// Corrupted recurrence with null required fields
class CorruptedRecurrence {
  final String docId;
  final String? name;
  final String? personDocId;
  final String issue;

  CorruptedRecurrence({
    required this.docId,
    this.name,
    this.personDocId,
    required this.issue,
  });

  @override
  String toString() => '$docId: $issue';
}

// ============================================================================
// Main Repair Tool
// ============================================================================

/// The main repair tool class that can be used both from CLI and tests
class RecurrenceRepairTool {
  final FirebaseFirestore firestore;
  final String personDocId;
  final bool applyRepairs;

  // Analysis results
  List<OutOfSyncRecurrence> outOfSyncRecurrences = [];
  List<DuplicateIteration> duplicateIterations = [];
  List<OrphanedTask> orphanedTasks = [];
  List<DuplicateRecurrenceFamily> duplicateRecurrenceFamilies = [];
  List<CorruptedRecurrence> corruptedRecurrences = [];

  // Cached data
  Map<String, RecurrenceInfo> _recurrencesById = {};
  Map<String, List<TaskInfo>> _tasksByRecurrenceId = {};
  Set<String> _snoozedTaskIds = {};

  RecurrenceRepairTool({
    required this.firestore,
    required this.personDocId,
    this.applyRepairs = false,
  });

  /// Run the full analysis and optional repair
  Future<void> run() async {
    await _loadData();
    await _analyze();

    if (_hasIssues()) {
      _printRepairPlan();
      if (applyRepairs) {
        await _executeRepairs();
        print('');
        print('Repairs complete! Re-run without --apply to verify.');
      } else {
        print('');
        print('Run with --apply to execute repairs.');
      }
    } else {
      print('No issues found. Data is clean!');
    }
  }

  bool _hasIssues() {
    return outOfSyncRecurrences.isNotEmpty ||
        duplicateIterations.isNotEmpty ||
        orphanedTasks.isNotEmpty ||
        duplicateRecurrenceFamilies.isNotEmpty ||
        corruptedRecurrences.isNotEmpty;
  }

  /// Load all relevant data from Firestore
  Future<void> _loadData() async {
    print('Loading data...');

    // Load recurrences
    final recurrencesSnapshot = await firestore
        .collection('taskRecurrences')
        .where('personDocId', isEqualTo: personDocId)
        .get();

    _recurrencesById = {};
    for (final doc in recurrencesSnapshot.docs) {
      final data = doc.data();
      _recurrencesById[doc.id] = RecurrenceInfo(
        docId: doc.id,
        name: data['name'] as String? ?? '',
        personDocId: data['personDocId'] as String? ?? '',
        recurIteration: data['recurIteration'] as int? ?? 0,
        recurNumber: data['recurNumber'] as int?,
        recurUnit: data['recurUnit'] as String?,
        recurWait: data['recurWait'] as bool?,
      );
    }
    print('  Loaded ${_recurrencesById.length} recurrences');

    // Load tasks
    final tasksSnapshot = await firestore
        .collection('tasks')
        .where('personDocId', isEqualTo: personDocId)
        .get();

    _tasksByRecurrenceId = {};
    int recurringTaskCount = 0;
    for (final doc in tasksSnapshot.docs) {
      final data = doc.data();
      final retired = data['retired'];
      if (retired != null) continue; // Skip retired tasks

      final recurrenceDocId = data['recurrenceDocId'] as String?;
      if (recurrenceDocId == null) continue; // Skip non-recurring tasks

      recurringTaskCount++;
      final task = TaskInfo(
        docId: doc.id,
        name: data['name'] as String? ?? '',
        dateAdded: _parseDateTime(data['dateAdded']),
        recurIteration: data['recurIteration'] as int?,
        recurrenceDocId: recurrenceDocId,
        hasRecurrenceMetadata: data['recurNumber'] != null &&
            data['recurUnit'] != null,
      );

      _tasksByRecurrenceId.putIfAbsent(recurrenceDocId, () => []).add(task);
    }
    print('  Loaded $recurringTaskCount non-retired recurring tasks');

    // Load snoozes to identify snoozed tasks
    final snoozesSnapshot = await firestore.collection('snoozes').get();
    _snoozedTaskIds = {};
    for (final doc in snoozesSnapshot.docs) {
      final taskDocId = doc.data()['taskDocId'] as String?;
      if (taskDocId != null) {
        _snoozedTaskIds.add(taskDocId);
      }
    }
    print('  Found ${_snoozedTaskIds.length} snoozed tasks');
    print('');
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now().toUtc();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now().toUtc();
  }

  /// Analyze the data for all bad data scenarios
  Future<void> _analyze() async {
    print('ANALYSIS RESULTS');
    print('----------------');

    _findOutOfSyncRecurrences();
    _findDuplicateIterations();
    await _findOrphanedTasks();
    _findDuplicateRecurrences();
    _findCorruptedRecurrences();
  }

  void _findOutOfSyncRecurrences() {
    outOfSyncRecurrences = [];

    for (final recurrence in _recurrencesById.values) {
      final tasks = _tasksByRecurrenceId[recurrence.docId] ?? [];
      if (tasks.isEmpty) continue;

      final maxTaskIteration = tasks
          .map((t) => t.recurIteration ?? 0)
          .reduce((a, b) => a > b ? a : b);

      if (recurrence.recurIteration < maxTaskIteration) {
        outOfSyncRecurrences.add(OutOfSyncRecurrence(
          recurrenceDocId: recurrence.docId,
          name: recurrence.name,
          currentIteration: recurrence.recurIteration,
          maxTaskIteration: maxTaskIteration,
        ));
      }
    }

    print('Out-of-sync recurrences: ${outOfSyncRecurrences.length}');
    for (final item in outOfSyncRecurrences) {
      print('  - $item');
    }
    print('');
  }

  void _findDuplicateIterations() {
    duplicateIterations = [];

    for (final entry in _tasksByRecurrenceId.entries) {
      final recurrenceDocId = entry.key;
      final tasks = entry.value;
      final recurrence = _recurrencesById[recurrenceDocId];

      // Group tasks by iteration
      final byIteration = <int, List<TaskInfo>>{};
      for (final task in tasks) {
        final iteration = task.recurIteration;
        if (iteration != null) {
          byIteration.putIfAbsent(iteration, () => []).add(task);
        }
      }

      // Find iterations with duplicates
      for (final iterEntry in byIteration.entries) {
        if (iterEntry.value.length > 1) {
          // Sort by dateAdded so oldest is first
          iterEntry.value.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
          duplicateIterations.add(DuplicateIteration(
            recurrenceDocId: recurrenceDocId,
            recurrenceName: recurrence?.name ?? 'Unknown',
            iteration: iterEntry.key,
            tasks: iterEntry.value,
          ));
        }
      }
    }

    print('Duplicate iterations: ${duplicateIterations.length}');
    for (final item in duplicateIterations) {
      print('  - $item');
    }
    print('');
  }

  Future<void> _findOrphanedTasks() async {
    orphanedTasks = [];

    // Check all tasks for references to non-existent recurrences
    for (final tasks in _tasksByRecurrenceId.values) {
      for (final task in tasks) {
        if (task.recurrenceDocId != null &&
            !_recurrencesById.containsKey(task.recurrenceDocId)) {
          orphanedTasks.add(OrphanedTask(
            task: task,
            missingRecurrenceDocId: task.recurrenceDocId!,
          ));
        }
      }
    }

    print('Orphaned tasks: ${orphanedTasks.length}');
    for (final item in orphanedTasks) {
      print('  - $item');
    }
    print('');
  }

  void _findDuplicateRecurrences() {
    duplicateRecurrenceFamilies = [];

    // Group recurrences by (personDocId, name)
    final byKey = <String, List<RecurrenceInfo>>{};
    for (final recurrence in _recurrencesById.values) {
      final key = '${recurrence.personDocId}::${recurrence.name}';
      byKey.putIfAbsent(key, () => []).add(recurrence);
    }

    // Find families with duplicates
    for (final entry in byKey.entries) {
      if (entry.value.length > 1) {
        final parts = entry.key.split('::');
        duplicateRecurrenceFamilies.add(DuplicateRecurrenceFamily(
          personDocId: parts[0],
          name: parts.length > 1 ? parts[1] : '',
          recurrences: entry.value,
        ));
      }
    }

    print('Duplicate recurrence families: ${duplicateRecurrenceFamilies.length}');
    for (final item in duplicateRecurrenceFamilies) {
      print('  - $item');
    }
    print('');
  }

  void _findCorruptedRecurrences() {
    corruptedRecurrences = [];

    for (final recurrence in _recurrencesById.values) {
      if (recurrence.name.isEmpty) {
        corruptedRecurrences.add(CorruptedRecurrence(
          docId: recurrence.docId,
          name: recurrence.name,
          personDocId: recurrence.personDocId,
          issue: 'null or empty name',
        ));
      } else if (recurrence.personDocId.isEmpty) {
        corruptedRecurrences.add(CorruptedRecurrence(
          docId: recurrence.docId,
          name: recurrence.name,
          personDocId: recurrence.personDocId,
          issue: 'null or empty personDocId',
        ));
      }
    }

    if (corruptedRecurrences.isNotEmpty) {
      print('Corrupted recurrences: ${corruptedRecurrences.length}');
      for (final item in corruptedRecurrences) {
        print('  - $item');
      }
      print('');
    }
  }

  void _printRepairPlan() {
    print('REPAIR PLAN');
    print('-----------');

    // Phase 1: Sync iterations
    print('Phase 1: Would update ${outOfSyncRecurrences.length} recurrence iterations');

    // Phase 2: Resolve duplicate iterations
    final tasksToRetire = duplicateIterations
        .expand((d) => d.tasks.skip(1)) // Skip oldest (keep it)
        .where((t) => !_snoozedTaskIds.contains(t.docId))
        .toList();
    print('Phase 2: Would retire ${tasksToRetire.length} duplicate tasks');

    // Phase 3: Fix orphaned tasks
    final orphansToFix = orphanedTasks
        .where((o) => !_snoozedTaskIds.contains(o.task.docId))
        .toList();
    final orphansWithMetadata = orphansToFix.where((o) => o.task.hasRecurrenceMetadata).length;
    final orphansWithoutMetadata = orphansToFix.length - orphansWithMetadata;
    if (orphansToFix.isEmpty) {
      print('Phase 3: No orphaned tasks to fix');
    } else {
      print('Phase 3: Would create $orphansWithMetadata recurrences, clear $orphansWithoutMetadata task references');
    }

    // Phase 4: Merge duplicate recurrences
    final recurrencesToDelete = duplicateRecurrenceFamilies
        .expand((f) => f.nonCanonical)
        .length;
    if (duplicateRecurrenceFamilies.isEmpty) {
      print('Phase 4: No duplicate recurrences to merge');
    } else {
      print('Phase 4: Would merge ${duplicateRecurrenceFamilies.length} recurrence families (delete $recurrencesToDelete recurrences)');
    }
  }

  /// Execute all repair phases
  Future<void> _executeRepairs() async {
    print('');
    print('EXECUTING REPAIRS');
    print('-----------------');

    await _phase1SyncIterations();
    await _phase2ResolveDuplicateIterations();
    await _phase3FixOrphanedTasks();
    await _phase4MergeDuplicateRecurrences();
  }

  /// Phase 1: Sync recurrence iterations to match highest task iteration
  Future<void> _phase1SyncIterations() async {
    if (outOfSyncRecurrences.isEmpty) {
      print('Phase 1: No out-of-sync recurrences to fix');
      return;
    }

    print('Phase 1: Syncing ${outOfSyncRecurrences.length} recurrence iterations...');

    final batch = firestore.batch();
    int operationCount = 0;

    for (final item in outOfSyncRecurrences) {
      final docRef = firestore.collection('taskRecurrences').doc(item.recurrenceDocId);
      batch.update(docRef, {'recurIteration': item.maxTaskIteration});
      operationCount++;

      // Firestore batch limit is 500 operations
      if (operationCount >= 450) {
        await batch.commit();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }

    print('  Updated ${outOfSyncRecurrences.length} recurrences');
  }

  /// Phase 2: Retire duplicate iteration tasks, keeping the oldest
  Future<void> _phase2ResolveDuplicateIterations() async {
    if (duplicateIterations.isEmpty) {
      print('Phase 2: No duplicate iterations to fix');
      return;
    }

    print('Phase 2: Resolving ${duplicateIterations.length} duplicate iteration groups...');

    var batch = firestore.batch();
    int operationCount = 0;
    int retiredCount = 0;

    for (final dup in duplicateIterations) {
      // Skip the oldest task (first after sort), retire the rest
      final tasksToRetire = dup.tasks.skip(1).toList();

      for (final task in tasksToRetire) {
        // Don't retire snoozed tasks
        if (_snoozedTaskIds.contains(task.docId)) {
          print('  Skipping snoozed task: ${task.docId}');
          continue;
        }

        final docRef = firestore.collection('tasks').doc(task.docId);
        batch.update(docRef, {
          'retired': task.docId,
          'retiredDate': DateTime.now().toUtc(),
        });
        retiredCount++;
        operationCount++;

        if (operationCount >= 450) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }

    print('  Retired $retiredCount duplicate tasks');

    // After retiring duplicates, re-sync iterations (they may have changed)
    if (retiredCount > 0) {
      print('  Re-syncing iterations after retiring duplicates...');
      await _loadData();
      _findOutOfSyncRecurrences();
      await _phase1SyncIterations();
    }
  }

  /// Phase 3: Fix orphaned tasks
  Future<void> _phase3FixOrphanedTasks() async {
    if (orphanedTasks.isEmpty) {
      print('Phase 3: No orphaned tasks to fix');
      return;
    }

    print('Phase 3: Fixing ${orphanedTasks.length} orphaned tasks...');

    var batch = firestore.batch();
    int operationCount = 0;
    int createdRecurrences = 0;
    int clearedReferences = 0;

    for (final orphan in orphanedTasks) {
      // Don't modify snoozed tasks
      if (_snoozedTaskIds.contains(orphan.task.docId)) {
        print('  Skipping snoozed task: ${orphan.task.docId}');
        continue;
      }

      final taskRef = firestore.collection('tasks').doc(orphan.task.docId);

      if (orphan.task.hasRecurrenceMetadata) {
        // Create a new recurrence document
        final recurrenceRef = firestore.collection('taskRecurrences').doc();

        // We need to read the task to get full metadata
        final taskDoc = await firestore.collection('tasks').doc(orphan.task.docId).get();
        final taskData = taskDoc.data()!;

        batch.set(recurrenceRef, {
          'name': orphan.task.name,
          'personDocId': personDocId,
          'recurNumber': taskData['recurNumber'],
          'recurUnit': taskData['recurUnit'],
          'recurWait': taskData['recurWait'] ?? false,
          'recurIteration': orphan.task.recurIteration ?? 1,
          'dateAdded': DateTime.now().toUtc(),
          'anchorDate': taskData['anchorDate'] ?? {},
        });
        operationCount++;

        // Update task to point to new recurrence
        batch.update(taskRef, {'recurrenceDocId': recurrenceRef.id});
        operationCount++;
        createdRecurrences++;
      } else {
        // Clear the invalid recurrence reference
        batch.update(taskRef, {'recurrenceDocId': null});
        operationCount++;
        clearedReferences++;
      }

      if (operationCount >= 450) {
        await batch.commit();
        batch = firestore.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }

    print('  Created $createdRecurrences new recurrences');
    print('  Cleared $clearedReferences invalid references');
  }

  /// Phase 4: Merge duplicate recurrences
  Future<void> _phase4MergeDuplicateRecurrences() async {
    if (duplicateRecurrenceFamilies.isEmpty) {
      print('Phase 4: No duplicate recurrences to merge');
      return;
    }

    print('Phase 4: Merging ${duplicateRecurrenceFamilies.length} duplicate recurrence families...');

    int mergedFamilies = 0;
    int deletedRecurrences = 0;
    int retargetedTasks = 0;

    for (final family in duplicateRecurrenceFamilies) {
      var batch = firestore.batch();
      int operationCount = 0;

      // Retarget all tasks from non-canonical recurrences to canonical
      for (final nonCanonical in family.nonCanonical) {
        final tasks = _tasksByRecurrenceId[nonCanonical.docId] ?? [];

        for (final task in tasks) {
          final taskRef = firestore.collection('tasks').doc(task.docId);
          batch.update(taskRef, {'recurrenceDocId': family.canonical.docId});
          operationCount++;
          retargetedTasks++;

          if (operationCount >= 450) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
          }
        }

        // Delete the non-canonical recurrence
        final recurrenceRef = firestore.collection('taskRecurrences').doc(nonCanonical.docId);
        batch.delete(recurrenceRef);
        operationCount++;
        deletedRecurrences++;

        if (operationCount >= 450) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }

      // Update canonical recurrence iteration to be the max
      final allIterations = family.recurrences.map((r) => r.recurIteration).toList();
      final maxIteration = allIterations.reduce((a, b) => a > b ? a : b);
      final canonicalRef = firestore.collection('taskRecurrences').doc(family.canonical.docId);
      batch.update(canonicalRef, {'recurIteration': maxIteration});
      operationCount++;

      if (operationCount > 0) {
        await batch.commit();
      }

      mergedFamilies++;
    }

    print('  Merged $mergedFamilies families');
    print('  Retargeted $retargetedTasks tasks');
    print('  Deleted $deletedRecurrences duplicate recurrences');
  }
}
