import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/task_repository.dart';

/// TM-328: Tests for addTask recurrence document sync
///
/// When addTask is called with an existing recurrenceDocId and a
/// recurrenceBlueprint, the existing recurrence document should be updated
/// with the new values (anchorDate, recurIteration, recurWait, etc.).
void main() {
  group('TM-328: addTask recurrence sync', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TaskRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = TaskRepository(firestore: fakeFirestore);
    });

    test('addTask with existing recurrenceDocId updates recurrence document', () async {
      // Setup: Pre-populate Firestore with a stale recurrence document
      final recurrenceId = 'existing-recurrence-123';
      final oldAnchorDate = DateTime.utc(2025, 1, 1, 10, 0, 0);
      await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).set({
        'name': 'HelloFresh',
        'personDocId': 'test-person',
        'recurNumber': 2,
        'recurUnit': 'Weeks',
        'recurWait': false, // Stale value - should become true after update
        'recurIteration': 5,
        'anchorDate': {
          'dateValue': oldAnchorDate.toIso8601String(),
          'dateType': 'Due Date',
        },
        'dateAdded': DateTime.now().toUtc(),
      });

      // Create a blueprint with the existing recurrenceDocId and updated recurrence
      final newAnchorDate = DateTime.utc(2025, 2, 1, 10, 0, 0);
      var recurrenceBlueprint = TaskRecurrenceBlueprint()
        ..personDocId = 'test-person'
        ..name = 'HelloFresh'
        ..recurNumber = 2
        ..recurUnit = 'Weeks'
        ..recurWait = true // Updated value
        ..recurIteration = 6
        ..anchorDate = (AnchorDateBuilder()
              ..dateValue = newAnchorDate
              ..dateType = TaskDateTypes.due)
            .build();

      var taskBlueprint = TaskItemBlueprint()
        ..name = 'HelloFresh'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurNumber = 2
        ..recurUnit = 'Weeks'
        ..recurWait = true
        ..recurIteration = 6
        ..recurrenceBlueprint = recurrenceBlueprint;

      // Act: addTask with existing recurrenceDocId
      repository.addTask(taskBlueprint);

      // Allow async operations to complete
      await Future.delayed(Duration(milliseconds: 100));

      // Assert: The recurrence document should be updated
      final recurrenceDoc = await fakeFirestore
          .collection('taskRecurrences')
          .doc(recurrenceId)
          .get();
      final data = recurrenceDoc.data()!;

      expect(data['recurWait'], true,
          reason: 'recurWait should be updated to true');
      expect(data['recurIteration'], 6,
          reason: 'recurIteration should be updated to 6');

      // Assert: A task was also created
      final tasks = await fakeFirestore.collection('tasks').get();
      expect(tasks.docs.length, 1, reason: 'One task should be created');
      expect(tasks.docs.first.data()['recurrenceDocId'], recurrenceId,
          reason: 'Task should reference the existing recurrence');
    });

    test('addTask without recurrenceDocId still creates new recurrence (regression)', () async {
      // Create a blueprint without recurrenceDocId but with a recurrence blueprint
      var recurrenceBlueprint = TaskRecurrenceBlueprint()
        ..personDocId = 'test-person'
        ..name = 'New Recurring Task'
        ..recurNumber = 1
        ..recurUnit = 'Weeks'
        ..recurWait = false
        ..recurIteration = 1
        ..anchorDate = (AnchorDateBuilder()
              ..dateValue = DateTime.utc(2025, 3, 1, 10, 0, 0)
              ..dateType = TaskDateTypes.due)
            .build();

      var taskBlueprint = TaskItemBlueprint()
        ..name = 'New Recurring Task'
        ..personDocId = 'test-person'
        ..recurrenceDocId = null // No existing recurrence
        ..recurNumber = 1
        ..recurUnit = 'Weeks'
        ..recurWait = false
        ..recurIteration = 1
        ..recurrenceBlueprint = recurrenceBlueprint;

      // Act: addTask without recurrenceDocId
      repository.addTask(taskBlueprint);

      // Allow async operations to complete
      await Future.delayed(Duration(milliseconds: 100));

      // Assert: A new recurrence document should be created
      final recurrences = await fakeFirestore.collection('taskRecurrences').get();
      expect(recurrences.docs.length, 1,
          reason: 'A new recurrence document should be created');

      // Assert: The task references the new recurrence
      final tasks = await fakeFirestore.collection('tasks').get();
      expect(tasks.docs.length, 1, reason: 'One task should be created');
      final taskData = tasks.docs.first.data();
      expect(taskData['recurrenceDocId'], recurrences.docs.first.id,
          reason: 'Task should reference the newly created recurrence');
    });
  });
}
