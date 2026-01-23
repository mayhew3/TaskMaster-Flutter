/// Test helpers for firestore_repair tests
///
/// Provides utilities to create controlled bad data scenarios for testing
/// the recurrence repair tool.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Test person ID used across all test helpers
const testPersonDocId = 'test-person-123';

/// Creates a test recurrence document in the fake Firestore
///
/// Parameters:
/// - [firestore] - The fake Firestore instance
/// - [docId] - Document ID for the recurrence (optional, auto-generated if null)
/// - [name] - Name of the recurrence
/// - [recurIteration] - Current iteration counter
/// - [personDocId] - Person who owns this recurrence (defaults to testPersonDocId)
/// - [recurNumber] - Repeat interval (defaults to 1)
/// - [recurUnit] - Time unit (defaults to 'Weeks')
/// - [recurWait] - On complete flag (defaults to false)
Future<String> createTestRecurrence(
  FakeFirebaseFirestore firestore, {
  String? docId,
  required String name,
  required int recurIteration,
  String? personDocId,
  int recurNumber = 1,
  String recurUnit = 'Weeks',
  bool recurWait = false,
}) async {
  final collection = firestore.collection('taskRecurrences');
  final doc = docId != null ? collection.doc(docId) : collection.doc();

  await doc.set({
    'name': name,
    'personDocId': personDocId ?? testPersonDocId,
    'recurIteration': recurIteration,
    'recurNumber': recurNumber,
    'recurUnit': recurUnit,
    'recurWait': recurWait,
    'dateAdded': DateTime.now().toUtc(),
    'anchorDate': {},
  });

  return doc.id;
}

/// Creates a test task document in the fake Firestore
///
/// Parameters:
/// - [firestore] - The fake Firestore instance
/// - [docId] - Document ID for the task (optional, auto-generated if null)
/// - [name] - Name of the task
/// - [recurrenceDocId] - Reference to parent recurrence (null for non-recurring)
/// - [recurIteration] - Which iteration of the recurrence this is
/// - [personDocId] - Person who owns this task (defaults to testPersonDocId)
/// - [dateAdded] - When the task was created (defaults to now)
/// - [retired] - Set to docId if soft-deleted (null for active tasks)
/// - [retiredDate] - When the task was deleted (if retired)
/// - [recurNumber] - Repeat interval (optional, for recurrence metadata)
/// - [recurUnit] - Time unit (optional, for recurrence metadata)
/// - [recurWait] - On complete flag (optional, for recurrence metadata)
Future<String> createTestTask(
  FakeFirebaseFirestore firestore, {
  String? docId,
  required String name,
  String? recurrenceDocId,
  int? recurIteration,
  String? personDocId,
  DateTime? dateAdded,
  String? retired,
  DateTime? retiredDate,
  int? recurNumber,
  String? recurUnit,
  bool? recurWait,
}) async {
  final collection = firestore.collection('tasks');
  final doc = docId != null ? collection.doc(docId) : collection.doc();

  await doc.set({
    'name': name,
    'personDocId': personDocId ?? testPersonDocId,
    'dateAdded': dateAdded ?? DateTime.now().toUtc(),
    'recurrenceDocId': recurrenceDocId,
    'recurIteration': recurIteration,
    'recurNumber': recurNumber,
    'recurUnit': recurUnit,
    'recurWait': recurWait,
    'retired': retired,
    'retiredDate': retiredDate,
    'offCycle': false,
  });

  return doc.id;
}

/// Creates a snooze document for a task
///
/// This is used to test that snoozed tasks are protected during repairs.
Future<String> createTestSnooze(
  FakeFirebaseFirestore firestore, {
  String? docId,
  required String taskDocId,
}) async {
  final collection = firestore.collection('snoozes');
  final doc = docId != null ? collection.doc(docId) : collection.doc();

  await doc.set({
    'taskDocId': taskDocId,
    'snoozeNumber': 1,
    'snoozeUnits': 'Days',
    'snoozeAnchor': 'startDate',
    'newAnchor': DateTime.now().add(const Duration(days: 1)).toUtc(),
    'dateAdded': DateTime.now().toUtc(),
  });

  return doc.id;
}

/// Creates a test person document
Future<String> createTestPerson(
  FakeFirebaseFirestore firestore, {
  String? docId,
  required String email,
}) async {
  final collection = firestore.collection('persons');
  final doc = docId != null ? collection.doc(docId) : collection.doc();

  await doc.set({
    'email': email,
    'dateAdded': DateTime.now().toUtc(),
  });

  return doc.id;
}

/// Sets up all 4 bad data scenarios in a single fake Firestore instance
///
/// Returns a map with keys to help identify the created documents:
/// - 'outOfSyncRecurrence' - Recurrence with iteration < max task iteration
/// - 'duplicateIterationRecurrence' - Recurrence with multiple tasks at same iteration
/// - 'duplicateTasks' - List of task IDs with duplicate iterations
/// - 'orphanedTask' - Task referencing non-existent recurrence
/// - 'duplicateRecurrences' - List of recurrence IDs with same name
Future<Map<String, dynamic>> createBadDataScenario(
  FakeFirebaseFirestore firestore,
) async {
  final results = <String, dynamic>{};

  // Create a person
  await createTestPerson(
    firestore,
    docId: testPersonDocId,
    email: 'test@example.com',
  );

  // ========================================
  // Scenario 1: Out-of-sync recurrence
  // Recurrence says iteration 5, but tasks go up to 8
  // ========================================
  final outOfSyncRecId = await createTestRecurrence(
    firestore,
    docId: 'out-of-sync-rec',
    name: 'Take Out Recycling',
    recurIteration: 5, // Says 5 but tasks go higher
  );
  results['outOfSyncRecurrence'] = outOfSyncRecId;

  // Create tasks for out-of-sync recurrence
  await createTestTask(
    firestore,
    name: 'Take Out Recycling',
    recurrenceDocId: outOfSyncRecId,
    recurIteration: 6,
    dateAdded: DateTime.now().subtract(const Duration(days: 14)),
  );
  await createTestTask(
    firestore,
    name: 'Take Out Recycling',
    recurrenceDocId: outOfSyncRecId,
    recurIteration: 7,
    dateAdded: DateTime.now().subtract(const Duration(days: 7)),
  );
  await createTestTask(
    firestore,
    name: 'Take Out Recycling',
    recurrenceDocId: outOfSyncRecId,
    recurIteration: 8, // Highest iteration
    dateAdded: DateTime.now(),
  );

  // ========================================
  // Scenario 2: Duplicate iterations
  // Multiple non-retired tasks with same recurIteration
  // ========================================
  final dupIterRecId = await createTestRecurrence(
    firestore,
    docId: 'dup-iter-rec',
    name: 'Weekly Review',
    recurIteration: 10,
  );
  results['duplicateIterationRecurrence'] = dupIterRecId;

  // Create duplicate tasks at iteration 10
  final dupTask1 = await createTestTask(
    firestore,
    docId: 'dup-task-1',
    name: 'Weekly Review',
    recurrenceDocId: dupIterRecId,
    recurIteration: 10, // Same iteration!
    dateAdded: DateTime.now().subtract(const Duration(hours: 2)), // Older
  );
  final dupTask2 = await createTestTask(
    firestore,
    docId: 'dup-task-2',
    name: 'Weekly Review',
    recurrenceDocId: dupIterRecId,
    recurIteration: 10, // Same iteration!
    dateAdded: DateTime.now().subtract(const Duration(hours: 1)), // Newer
  );
  results['duplicateTasks'] = [dupTask1, dupTask2];

  // ========================================
  // Scenario 3: Orphaned task
  // Task references a recurrence that doesn't exist
  // ========================================
  final orphanedTask = await createTestTask(
    firestore,
    docId: 'orphaned-task',
    name: 'Orphaned Task',
    recurrenceDocId: 'non-existent-recurrence-123',
    recurIteration: 5,
    // Has recurrence metadata, so should create new recurrence
    recurNumber: 1,
    recurUnit: 'Days',
    recurWait: false,
  );
  results['orphanedTask'] = orphanedTask;

  // Also create an orphaned task WITHOUT recurrence metadata
  final orphanedTaskNoMeta = await createTestTask(
    firestore,
    docId: 'orphaned-task-no-meta',
    name: 'Orphaned Without Metadata',
    recurrenceDocId: 'another-non-existent-recurrence',
    recurIteration: 3,
    // No recurNumber/recurUnit, so should clear reference
  );
  results['orphanedTaskNoMetadata'] = orphanedTaskNoMeta;

  // ========================================
  // Scenario 4: Duplicate recurrences
  // Multiple recurrence docs with same (personDocId, name)
  // ========================================
  final dupRec1 = await createTestRecurrence(
    firestore,
    docId: 'dup-rec-1',
    name: 'Code Review',
    recurIteration: 15, // Lower - will be merged into dup-rec-2
  );
  final dupRec2 = await createTestRecurrence(
    firestore,
    docId: 'dup-rec-2',
    name: 'Code Review',
    recurIteration: 20, // Higher - will be canonical
  );
  results['duplicateRecurrences'] = [dupRec1, dupRec2];

  // Create a task for each duplicate recurrence
  await createTestTask(
    firestore,
    docId: 'task-dup-rec-1',
    name: 'Code Review',
    recurrenceDocId: dupRec1,
    recurIteration: 15,
  );
  await createTestTask(
    firestore,
    docId: 'task-dup-rec-2',
    name: 'Code Review',
    recurrenceDocId: dupRec2,
    recurIteration: 20,
  );

  return results;
}

/// Creates a clean, valid data scenario for testing no-op behavior
Future<void> createCleanDataScenario(FakeFirebaseFirestore firestore) async {
  // Create person
  await createTestPerson(
    firestore,
    docId: testPersonDocId,
    email: 'test@example.com',
  );

  // Create a valid recurrence with matching iteration
  final recId = await createTestRecurrence(
    firestore,
    name: 'Valid Recurring Task',
    recurIteration: 5,
  );

  // Create tasks with sequential iterations
  for (var i = 1; i <= 5; i++) {
    await createTestTask(
      firestore,
      name: 'Valid Recurring Task',
      recurrenceDocId: recId,
      recurIteration: i,
      dateAdded: DateTime.now().subtract(Duration(days: 5 - i)),
    );
  }
}

/// Gets the current iteration value for a recurrence
Future<int> getRecurrenceIteration(
  FakeFirebaseFirestore firestore,
  String recurrenceDocId,
) async {
  final doc = await firestore.collection('taskRecurrences').doc(recurrenceDocId).get();
  return doc.data()?['recurIteration'] as int? ?? 0;
}

/// Checks if a task is retired (soft deleted)
Future<bool> isTaskRetired(
  FakeFirebaseFirestore firestore,
  String taskDocId,
) async {
  final doc = await firestore.collection('tasks').doc(taskDocId).get();
  return doc.data()?['retired'] != null;
}

/// Gets the recurrenceDocId for a task
Future<String?> getTaskRecurrenceDocId(
  FakeFirebaseFirestore firestore,
  String taskDocId,
) async {
  final doc = await firestore.collection('tasks').doc(taskDocId).get();
  return doc.data()?['recurrenceDocId'] as String?;
}

/// Counts the number of recurrence documents for a given name
Future<int> countRecurrencesByName(
  FakeFirebaseFirestore firestore,
  String name,
  String personDocId,
) async {
  final snapshot = await firestore
      .collection('taskRecurrences')
      .where('personDocId', isEqualTo: personDocId)
      .where('name', isEqualTo: name)
      .get();
  return snapshot.docs.length;
}

/// Checks if a recurrence document exists
Future<bool> recurrenceExists(
  FakeFirebaseFirestore firestore,
  String recurrenceDocId,
) async {
  final doc = await firestore.collection('taskRecurrences').doc(recurrenceDocId).get();
  return doc.exists;
}

/// Gets the count of non-retired tasks for a recurrence
Future<int> getNonRetiredTaskCount(
  FakeFirebaseFirestore firestore,
  String recurrenceDocId,
) async {
  final snapshot = await firestore
      .collection('tasks')
      .where('recurrenceDocId', isEqualTo: recurrenceDocId)
      .get();

  return snapshot.docs.where((doc) => doc.data()['retired'] == null).length;
}
