/// Tests for the Firestore Recurrence Repair Tool (TM-324)
///
/// Uses fake_cloud_firestore to create controlled bad data scenarios
/// and verify the repair logic works correctly.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bin/firestore_repair.dart';
import 'repair_test_helpers.dart';

void main() {
  group('Firestore Recurrence Repair Tool', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Phase 1: Sync Iterations', () {
      test('syncs recurrence iteration to highest task iteration', () async {
        // Setup: Recurrence at iteration 5, but task at iteration 8
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Take Out Recycling',
          recurIteration: 5, // Lower than tasks
        );

        await createTestTask(
          fakeFirestore,
          name: 'Take Out Recycling',
          recurrenceDocId: recId,
          recurIteration: 6,
        );
        await createTestTask(
          fakeFirestore,
          name: 'Take Out Recycling',
          recurrenceDocId: recId,
          recurIteration: 8, // Highest
        );

        // Run repair with apply
        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Verify recurrence was updated
        final newIteration = await getRecurrenceIteration(fakeFirestore, recId);
        expect(newIteration, equals(8),
            reason: 'Recurrence should be synced to highest task iteration');
      });

      test('ignores retired tasks when finding max iteration', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Test Recurrence',
          recurIteration: 3,
        );

        // Active task at iteration 5
        await createTestTask(
          fakeFirestore,
          name: 'Test Task',
          recurrenceDocId: recId,
          recurIteration: 5,
        );

        // Retired task at iteration 10 (should be ignored)
        await createTestTask(
          fakeFirestore,
          docId: 'retired-task',
          name: 'Retired Task',
          recurrenceDocId: recId,
          recurIteration: 10,
          retired: 'retired-task',
          retiredDate: DateTime.now(),
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Should sync to 5, not 10
        final newIteration = await getRecurrenceIteration(fakeFirestore, recId);
        expect(newIteration, equals(5),
            reason: 'Should ignore retired tasks and sync to highest active task');
      });

      test('no-op when recurrence is already in sync', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'In Sync Recurrence',
          recurIteration: 5,
        );

        await createTestTask(
          fakeFirestore,
          name: 'In Sync Task',
          recurrenceDocId: recId,
          recurIteration: 5,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Should detect no issues
        expect(repairTool.outOfSyncRecurrences, isEmpty,
            reason: 'Should detect no out-of-sync recurrences');
      });
    });

    group('Phase 2: Duplicate Iterations', () {
      test('retires newer duplicate, keeps oldest by dateAdded', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Weekly Review',
          recurIteration: 10,
        );

        // Older task (should be kept)
        final olderId = await createTestTask(
          fakeFirestore,
          docId: 'older-task',
          name: 'Weekly Review',
          recurrenceDocId: recId,
          recurIteration: 10,
          dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
        );

        // Newer task (should be retired)
        final newerId = await createTestTask(
          fakeFirestore,
          docId: 'newer-task',
          name: 'Weekly Review',
          recurrenceDocId: recId,
          recurIteration: 10,
          dateAdded: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Verify older is kept, newer is retired
        final olderRetired = await isTaskRetired(fakeFirestore, olderId);
        final newerRetired = await isTaskRetired(fakeFirestore, newerId);

        expect(olderRetired, isFalse, reason: 'Older task should be kept');
        expect(newerRetired, isTrue, reason: 'Newer task should be retired');
      });

      test('handles multiple duplicates (3+ tasks same iteration)', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Multi Dup',
          recurIteration: 5,
        );

        // Create 4 tasks at same iteration
        final task1 = await createTestTask(
          fakeFirestore,
          docId: 'task-1',
          name: 'Multi Dup',
          recurrenceDocId: recId,
          recurIteration: 5,
          dateAdded: DateTime.now().subtract(const Duration(hours: 4)), // Oldest
        );
        final task2 = await createTestTask(
          fakeFirestore,
          docId: 'task-2',
          name: 'Multi Dup',
          recurrenceDocId: recId,
          recurIteration: 5,
          dateAdded: DateTime.now().subtract(const Duration(hours: 3)),
        );
        final task3 = await createTestTask(
          fakeFirestore,
          docId: 'task-3',
          name: 'Multi Dup',
          recurrenceDocId: recId,
          recurIteration: 5,
          dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
        );
        final task4 = await createTestTask(
          fakeFirestore,
          docId: 'task-4',
          name: 'Multi Dup',
          recurrenceDocId: recId,
          recurIteration: 5,
          dateAdded: DateTime.now().subtract(const Duration(hours: 1)), // Newest
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Only oldest should be kept
        expect(await isTaskRetired(fakeFirestore, task1), isFalse);
        expect(await isTaskRetired(fakeFirestore, task2), isTrue);
        expect(await isTaskRetired(fakeFirestore, task3), isTrue);
        expect(await isTaskRetired(fakeFirestore, task4), isTrue);
      });

      test('skips snoozed tasks when retiring', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Snoozed Dup',
          recurIteration: 7,
        );

        // Older task
        final olderId = await createTestTask(
          fakeFirestore,
          docId: 'older-task',
          name: 'Snoozed Dup',
          recurrenceDocId: recId,
          recurIteration: 7,
          dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
        );

        // Newer task that is snoozed (should NOT be retired)
        final snoozedId = await createTestTask(
          fakeFirestore,
          docId: 'snoozed-task',
          name: 'Snoozed Dup',
          recurrenceDocId: recId,
          recurIteration: 7,
          dateAdded: DateTime.now().subtract(const Duration(hours: 1)),
        );
        await createTestSnooze(fakeFirestore, taskDocId: snoozedId);

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Neither should be retired - snoozed task is protected
        expect(await isTaskRetired(fakeFirestore, olderId), isFalse);
        expect(await isTaskRetired(fakeFirestore, snoozedId), isFalse,
            reason: 'Snoozed task should be protected from retirement');
      });

      test('updates recurrence iteration after retiring duplicates', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Recurrence at lower iteration than tasks
        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Dual Fix',
          recurIteration: 8, // Lower than tasks
        );

        // Duplicate tasks at iteration 10
        await createTestTask(
          fakeFirestore,
          name: 'Dual Fix',
          recurrenceDocId: recId,
          recurIteration: 10,
          dateAdded: DateTime.now().subtract(const Duration(hours: 2)),
        );
        await createTestTask(
          fakeFirestore,
          name: 'Dual Fix',
          recurrenceDocId: recId,
          recurIteration: 10,
          dateAdded: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Recurrence should be synced to 10 after retiring duplicates
        final newIteration = await getRecurrenceIteration(fakeFirestore, recId);
        expect(newIteration, equals(10),
            reason: 'Recurrence should be synced after retiring duplicates');
      });
    });

    group('Phase 3: Orphaned Tasks', () {
      test('creates recurrence for orphan with recurrence metadata', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Task with recurrence metadata but missing recurrence doc
        final taskId = await createTestTask(
          fakeFirestore,
          docId: 'orphan-with-meta',
          name: 'Orphaned With Meta',
          recurrenceDocId: 'non-existent-rec',
          recurIteration: 5,
          recurNumber: 2,
          recurUnit: 'Days',
          recurWait: true,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Task should now have a valid recurrence reference
        final newRecId = await getTaskRecurrenceDocId(fakeFirestore, taskId);
        expect(newRecId, isNotNull, reason: 'Task should have new recurrence');
        expect(newRecId, isNot(equals('non-existent-rec')),
            reason: 'Task should point to new recurrence');

        // New recurrence should exist
        final exists = await recurrenceExists(fakeFirestore, newRecId!);
        expect(exists, isTrue, reason: 'New recurrence should exist');
      });

      test('clears recurrenceDocId for orphan without metadata', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Task without recurrence metadata
        final taskId = await createTestTask(
          fakeFirestore,
          docId: 'orphan-no-meta',
          name: 'Orphaned No Meta',
          recurrenceDocId: 'missing-rec',
          recurIteration: 3,
          // No recurNumber, recurUnit, recurWait
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Task should have null recurrenceDocId
        final recId = await getTaskRecurrenceDocId(fakeFirestore, taskId);
        expect(recId, isNull, reason: 'Orphan without metadata should have cleared reference');
      });

      test('new recurrence gets correct iteration from task', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final taskId = await createTestTask(
          fakeFirestore,
          name: 'Orphan Iteration Test',
          recurrenceDocId: 'missing-rec',
          recurIteration: 42, // Specific iteration
          recurNumber: 1,
          recurUnit: 'Weeks',
          recurWait: false,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Get the new recurrence
        final newRecId = await getTaskRecurrenceDocId(fakeFirestore, taskId);
        final newIteration = await getRecurrenceIteration(fakeFirestore, newRecId!);

        expect(newIteration, equals(42),
            reason: 'New recurrence should have iteration from task');
      });
    });

    group('Phase 4: Merge Duplicates', () {
      test('retargets tasks to canonical recurrence', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Create duplicate recurrences
        final recId1 = await createTestRecurrence(
          fakeFirestore,
          docId: 'dup-rec-1',
          name: 'Code Review',
          recurIteration: 15, // Lower
        );
        final recId2 = await createTestRecurrence(
          fakeFirestore,
          docId: 'dup-rec-2',
          name: 'Code Review',
          recurIteration: 20, // Higher - will be canonical
        );

        // Tasks for each recurrence
        final task1 = await createTestTask(
          fakeFirestore,
          docId: 'task-rec-1',
          name: 'Code Review',
          recurrenceDocId: recId1,
          recurIteration: 15,
        );
        final task2 = await createTestTask(
          fakeFirestore,
          docId: 'task-rec-2',
          name: 'Code Review',
          recurrenceDocId: recId2,
          recurIteration: 20,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Both tasks should now point to canonical (recId2)
        final task1RecId = await getTaskRecurrenceDocId(fakeFirestore, task1);
        final task2RecId = await getTaskRecurrenceDocId(fakeFirestore, task2);

        expect(task1RecId, equals(recId2), reason: 'Task 1 should point to canonical');
        expect(task2RecId, equals(recId2), reason: 'Task 2 should point to canonical');
      });

      test('deletes non-canonical recurrence documents', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId1 = await createTestRecurrence(
          fakeFirestore,
          docId: 'non-canonical',
          name: 'Duplicate Name',
          recurIteration: 5,
        );
        final recId2 = await createTestRecurrence(
          fakeFirestore,
          docId: 'canonical',
          name: 'Duplicate Name',
          recurIteration: 10, // Higher = canonical
        );

        // Create tasks
        await createTestTask(
          fakeFirestore,
          name: 'Duplicate Name',
          recurrenceDocId: recId1,
          recurIteration: 5,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Non-canonical should be deleted
        expect(await recurrenceExists(fakeFirestore, recId1), isFalse,
            reason: 'Non-canonical recurrence should be deleted');
        expect(await recurrenceExists(fakeFirestore, recId2), isTrue,
            reason: 'Canonical recurrence should still exist');
      });

      test('selects recurrence with highest iteration as canonical', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Three recurrences with same name, different iterations
        final recId1 = await createTestRecurrence(
          fakeFirestore,
          docId: 'rec-iter-5',
          name: 'Triple Dup',
          recurIteration: 5,
        );
        final recId2 = await createTestRecurrence(
          fakeFirestore,
          docId: 'rec-iter-25',
          name: 'Triple Dup',
          recurIteration: 25, // Highest - should be canonical
        );
        final recId3 = await createTestRecurrence(
          fakeFirestore,
          docId: 'rec-iter-15',
          name: 'Triple Dup',
          recurIteration: 15,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Only rec-iter-25 should exist
        expect(await recurrenceExists(fakeFirestore, recId1), isFalse);
        expect(await recurrenceExists(fakeFirestore, recId2), isTrue,
            reason: 'Highest iteration recurrence should be canonical');
        expect(await recurrenceExists(fakeFirestore, recId3), isFalse);
      });

      test('handles tasks split across multiple duplicate recurrences', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId1 = await createTestRecurrence(
          fakeFirestore,
          name: 'Split Tasks',
          recurIteration: 10,
        );
        final recId2 = await createTestRecurrence(
          fakeFirestore,
          name: 'Split Tasks',
          recurIteration: 20, // Canonical
        );

        // Multiple tasks per recurrence
        final taskIds1 = <String>[];
        final taskIds2 = <String>[];

        for (var i = 1; i <= 3; i++) {
          taskIds1.add(await createTestTask(
            fakeFirestore,
            name: 'Split Tasks',
            recurrenceDocId: recId1,
            recurIteration: i,
          ));
        }
        for (var i = 11; i <= 13; i++) {
          taskIds2.add(await createTestTask(
            fakeFirestore,
            name: 'Split Tasks',
            recurrenceDocId: recId2,
            recurIteration: i,
          ));
        }

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // All tasks should now point to recId2 (canonical)
        for (final taskId in [...taskIds1, ...taskIds2]) {
          final recId = await getTaskRecurrenceDocId(fakeFirestore, taskId);
          expect(recId, equals(recId2),
              reason: 'All tasks should point to canonical recurrence');
        }
      });
    });

    group('Integration Tests', () {
      test('dry-run mode reports issues without making changes', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Create out-of-sync recurrence
        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Dry Run Test',
          recurIteration: 5,
        );
        await createTestTask(
          fakeFirestore,
          name: 'Dry Run Test',
          recurrenceDocId: recId,
          recurIteration: 10,
        );

        // Run in dry-run mode (applyRepairs = false)
        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: false, // Dry run!
        );
        await repairTool.run();

        // Should detect the issue
        expect(repairTool.outOfSyncRecurrences.length, equals(1),
            reason: 'Should detect out-of-sync recurrence');

        // But NOT fix it
        final iteration = await getRecurrenceIteration(fakeFirestore, recId);
        expect(iteration, equals(5),
            reason: 'Dry-run should not modify data');
      });

      test('full repair flow fixes all issue types', () async {
        // Setup all bad data scenarios
        final badData = await createBadDataScenario(fakeFirestore);

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Verify out-of-sync fixed
        final outOfSyncIter = await getRecurrenceIteration(
          fakeFirestore,
          badData['outOfSyncRecurrence'],
        );
        expect(outOfSyncIter, equals(8),
            reason: 'Out-of-sync recurrence should be fixed');

        // Verify duplicates retired (keep oldest)
        final dupTasks = badData['duplicateTasks'] as List<String>;
        expect(await isTaskRetired(fakeFirestore, dupTasks[0]), isFalse,
            reason: 'Older duplicate should be kept');
        expect(await isTaskRetired(fakeFirestore, dupTasks[1]), isTrue,
            reason: 'Newer duplicate should be retired');

        // Verify orphaned task with metadata got new recurrence
        final orphanedTask = badData['orphanedTask'] as String;
        final orphanRecId = await getTaskRecurrenceDocId(fakeFirestore, orphanedTask);
        expect(orphanRecId, isNotNull);
        expect(orphanRecId, isNot(equals('non-existent-recurrence-123')));
        expect(await recurrenceExists(fakeFirestore, orphanRecId!), isTrue);

        // Verify orphaned task without metadata has cleared reference
        final orphanNoMeta = badData['orphanedTaskNoMetadata'] as String;
        final orphanNoMetaRecId = await getTaskRecurrenceDocId(fakeFirestore, orphanNoMeta);
        expect(orphanNoMetaRecId, isNull,
            reason: 'Orphan without metadata should have cleared reference');

        // Verify duplicate recurrences merged
        final dupRecs = badData['duplicateRecurrences'] as List<String>;
        final countAfter = await countRecurrencesByName(
          fakeFirestore,
          'Code Review',
          testPersonDocId,
        );
        expect(countAfter, equals(1),
            reason: 'Duplicate recurrences should be merged into one');

        // The canonical (higher iteration) should remain
        expect(await recurrenceExists(fakeFirestore, dupRecs[1]), isTrue,
            reason: 'Canonical recurrence should remain');
      });

      test('re-running repair on clean data is no-op', () async {
        await createCleanDataScenario(fakeFirestore);

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Should detect no issues
        expect(repairTool.outOfSyncRecurrences, isEmpty);
        expect(repairTool.duplicateIterations, isEmpty);
        expect(repairTool.orphanedTasks, isEmpty);
        expect(repairTool.duplicateRecurrenceFamilies, isEmpty);
        expect(repairTool.corruptedRecurrences, isEmpty);
      });

      test('repairs are idempotent - running twice has same result', () async {
        await createBadDataScenario(fakeFirestore);

        // First repair
        final repairTool1 = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool1.run();

        // Capture state after first repair
        final recurrences1 = await fakeFirestore.collection('taskRecurrences').get();
        final tasks1 = await fakeFirestore.collection('tasks').get();

        // Second repair
        final repairTool2 = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool2.run();

        // Should detect no issues after first repair
        expect(repairTool2.outOfSyncRecurrences, isEmpty,
            reason: 'No out-of-sync after first repair');
        expect(repairTool2.duplicateIterations, isEmpty,
            reason: 'No duplicates after first repair');
        expect(repairTool2.duplicateRecurrenceFamilies, isEmpty,
            reason: 'No duplicate families after first repair');

        // Document counts should be same
        final recurrences2 = await fakeFirestore.collection('taskRecurrences').get();
        final tasks2 = await fakeFirestore.collection('tasks').get();

        expect(recurrences2.docs.length, equals(recurrences1.docs.length),
            reason: 'Recurrence count should be stable');
        expect(tasks2.docs.length, equals(tasks1.docs.length),
            reason: 'Task count should be stable');
      });
    });

    group('Edge Cases', () {
      test('handles recurrence with no tasks', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        await createTestRecurrence(
          fakeFirestore,
          name: 'No Tasks Recurrence',
          recurIteration: 5,
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Should not throw or detect issues
        expect(repairTool.outOfSyncRecurrences, isEmpty);
      });

      test('handles task with null recurIteration', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Null Iteration',
          recurIteration: 5,
        );

        await createTestTask(
          fakeFirestore,
          name: 'Null Iteration Task',
          recurrenceDocId: recId,
          recurIteration: null, // Null iteration
        );

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );

        // Should not throw
        await repairTool.run();
      });

      test('detects corrupted recurrence with empty name', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        // Manually create corrupted recurrence (bypassing helper validation)
        await fakeFirestore.collection('taskRecurrences').doc('corrupted').set({
          'name': '', // Empty name
          'personDocId': testPersonDocId,
          'recurIteration': 1,
          'dateAdded': DateTime.now().toUtc(),
        });

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: false,
        );
        await repairTool.run();

        expect(repairTool.corruptedRecurrences.length, equals(1),
            reason: 'Should detect corrupted recurrence with empty name');
      });

      test('off-cycle tasks are included in analysis', () async {
        await createTestPerson(fakeFirestore, docId: testPersonDocId, email: 'test@example.com');

        final recId = await createTestRecurrence(
          fakeFirestore,
          name: 'Off Cycle Test',
          recurIteration: 3,
        );

        // Off-cycle task at higher iteration
        await fakeFirestore.collection('tasks').doc('off-cycle-task').set({
          'name': 'Off Cycle Test',
          'personDocId': testPersonDocId,
          'recurrenceDocId': recId,
          'recurIteration': 10,
          'offCycle': true, // Off-cycle flag
          'dateAdded': DateTime.now().toUtc(),
        });

        final repairTool = RecurrenceRepairTool(
          firestore: fakeFirestore,
          personDocId: testPersonDocId,
          applyRepairs: true,
        );
        await repairTool.run();

        // Should sync to off-cycle task iteration
        final newIteration = await getRecurrenceIteration(fakeFirestore, recId);
        expect(newIteration, equals(10),
            reason: 'Off-cycle tasks should be included in iteration sync');
      });
    });
  });
}
