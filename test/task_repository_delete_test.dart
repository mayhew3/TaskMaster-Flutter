import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_repository.dart';

/// TM-324: Tests for deleteTask recurrence.recurIteration maintenance
///
/// When a task with a recurrence is retired (deleted), the recurrence's
/// recurIteration should be updated to the highest non-retired iteration.
/// This prevents duplicate task creation when the retired task was the highest.
void main() {
  group('TM-324: deleteTask recurrence iteration maintenance', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TaskRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = TaskRepository(firestore: fakeFirestore);
    });

    test('should update recurrence.recurIteration when deleting highest iteration task', () async {
      // Setup: Create recurrence with recurIteration = 109
      final recurrenceId = 'test-recurrence-123';
      await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).set({
        'name': 'Take Out Recycling',
        'personDocId': 'test-person',
        'recurIteration': 109,
        'dateAdded': DateTime.now().toUtc(),
      });

      // Setup: Create tasks with iterations 105-109
      for (var i = 105; i <= 109; i++) {
        await fakeFirestore.collection('tasks').doc('task-$i').set({
          'name': 'Take Out Recycling',
          'personDocId': 'test-person',
          'recurrenceDocId': recurrenceId,
          'recurIteration': i,
          'retired': null,
          'dateAdded': DateTime.now().toUtc(),
        });
      }

      // Create TaskItem for iteration 109 (highest)
      final now = DateTime.now().toUtc();
      final task109 = TaskItem((b) => b
        ..docId = 'task-109'
        ..name = 'Take Out Recycling'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurIteration = 109
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);

      // Act: Delete the highest iteration task
      await repository.deleteTask(task109);

      // Assert: Task should be marked as retired
      final retiredTask = await fakeFirestore.collection('tasks').doc('task-109').get();
      expect(retiredTask.data()?['retired'], equals('task-109'));

      // Assert: Recurrence should be updated to 108 (next highest non-retired)
      final recurrence = await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).get();
      expect(recurrence.data()?['recurIteration'], equals(108),
          reason: 'Recurrence should be updated to highest non-retired iteration (108)');
    });

    test('should set recurrence.recurIteration to 0 when all tasks are retired', () async {
      // Setup: Create recurrence with single task
      final recurrenceId = 'single-task-recurrence';
      await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).set({
        'name': 'One-time Recurring',
        'personDocId': 'test-person',
        'recurIteration': 1,
        'dateAdded': DateTime.now().toUtc(),
      });

      await fakeFirestore.collection('tasks').doc('only-task').set({
        'name': 'One-time Recurring',
        'personDocId': 'test-person',
        'recurrenceDocId': recurrenceId,
        'recurIteration': 1,
        'retired': null,
        'dateAdded': DateTime.now().toUtc(),
      });

      final now = DateTime.now().toUtc();
      final task = TaskItem((b) => b
        ..docId = 'only-task'
        ..name = 'One-time Recurring'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurIteration = 1
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);

      // Act: Delete the only task
      await repository.deleteTask(task);

      // Assert: Recurrence should be updated to 0
      final recurrence = await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).get();
      expect(recurrence.data()?['recurIteration'], equals(0),
          reason: 'Recurrence should be 0 when all tasks are retired');
    });

    test('should not change recurrence when deleting non-highest iteration', () async {
      // Setup: Create recurrence with recurIteration = 109
      final recurrenceId = 'test-recurrence-456';
      await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).set({
        'name': 'Weekly Review',
        'personDocId': 'test-person',
        'recurIteration': 109,
        'dateAdded': DateTime.now().toUtc(),
      });

      // Setup: Create tasks with iterations 105-109
      for (var i = 105; i <= 109; i++) {
        await fakeFirestore.collection('tasks').doc('task-$i').set({
          'name': 'Weekly Review',
          'personDocId': 'test-person',
          'recurrenceDocId': recurrenceId,
          'recurIteration': i,
          'retired': null,
          'dateAdded': DateTime.now().toUtc(),
        });
      }

      // Create TaskItem for iteration 106 (NOT highest)
      final now = DateTime.now().toUtc();
      final task106 = TaskItem((b) => b
        ..docId = 'task-106'
        ..name = 'Weekly Review'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurIteration = 106
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);

      // Act: Delete iteration 106
      await repository.deleteTask(task106);

      // Assert: Recurrence should still be 109 (highest non-retired)
      final recurrence = await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).get();
      expect(recurrence.data()?['recurIteration'], equals(109),
          reason: 'Recurrence should remain at 109 since task 109 is still active');
    });

    test('should handle deleting multiple high iterations correctly', () async {
      // Setup: Create recurrence with recurIteration = 109
      final recurrenceId = 'multi-delete-recurrence';
      await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).set({
        'name': 'Code Review',
        'personDocId': 'test-person',
        'recurIteration': 109,
        'dateAdded': DateTime.now().toUtc(),
      });

      // Setup: Create tasks with iterations 105-109
      for (var i = 105; i <= 109; i++) {
        await fakeFirestore.collection('tasks').doc('task-$i').set({
          'name': 'Code Review',
          'personDocId': 'test-person',
          'recurrenceDocId': recurrenceId,
          'recurIteration': i,
          'retired': null,
          'dateAdded': DateTime.now().toUtc(),
        });
      }

      final now = DateTime.now().toUtc();

      // Delete 109
      final task109 = TaskItem((b) => b
        ..docId = 'task-109'
        ..name = 'Code Review'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurIteration = 109
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);
      await repository.deleteTask(task109);

      var recurrence = await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).get();
      expect(recurrence.data()?['recurIteration'], equals(108));

      // Delete 108
      final task108 = TaskItem((b) => b
        ..docId = 'task-108'
        ..name = 'Code Review'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurIteration = 108
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);
      await repository.deleteTask(task108);

      recurrence = await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).get();
      expect(recurrence.data()?['recurIteration'], equals(107));

      // Delete 107
      final task107 = TaskItem((b) => b
        ..docId = 'task-107'
        ..name = 'Code Review'
        ..personDocId = 'test-person'
        ..recurrenceDocId = recurrenceId
        ..recurIteration = 107
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);
      await repository.deleteTask(task107);

      recurrence = await fakeFirestore.collection('taskRecurrences').doc(recurrenceId).get();
      expect(recurrence.data()?['recurIteration'], equals(106));
    });

    test('should not update recurrence for non-recurring task', () async {
      // Setup: Create a non-recurring task (no recurrenceDocId)
      await fakeFirestore.collection('tasks').doc('non-recurring-task').set({
        'name': 'One-off Task',
        'personDocId': 'test-person',
        'recurrenceDocId': null,
        'retired': null,
        'dateAdded': DateTime.now().toUtc(),
      });

      final now = DateTime.now().toUtc();
      final task = TaskItem((b) => b
        ..docId = 'non-recurring-task'
        ..name = 'One-off Task'
        ..personDocId = 'test-person'
        ..recurrenceDocId = null
        ..dateAdded = now
        ..offCycle = false
        ..pendingCompletion = false);

      // Act: Delete the task
      await repository.deleteTask(task);

      // Assert: Task should be retired
      final retiredTask = await fakeFirestore.collection('tasks').doc('non-recurring-task').get();
      expect(retiredTask.data()?['retired'], equals('non-recurring-task'));

      // Assert: No recurrence documents should be modified (verify nothing crashed)
      final recurrences = await fakeFirestore.collection('taskRecurrences').get();
      expect(recurrences.docs.length, equals(0));
    });
  });
}
