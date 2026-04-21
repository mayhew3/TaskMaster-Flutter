import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/core/database/tables.dart';

void main() {
  late AppDatabase db;

  const personDocId = 'person-1';
  final now = DateTime.utc(2025, 6, 15);

  TasksCompanion _makeCompanion({
    String docId = 'task-1',
    String name = 'Test task',
    String? syncState,
    DateTime? completionDate,
    String? retired,
    bool skipped = false,
  }) {
    return TasksCompanion(
      docId: Value(docId),
      dateAdded: Value(now),
      name: Value(name),
      personDocId: const Value(personDocId),
      syncState: Value(syncState ?? SyncState.synced.name),
      completionDate: Value(completionDate),
      retired: Value(retired),
      offCycle: const Value(false),
      skipped: Value(skipped),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('TaskDao.upsertFromRemote', () {
    test('inserts a new synced row', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      final pending = await db.taskDao.pendingWrites();
      expect(pending, isEmpty);
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.length, 1);
      expect(all.first.syncState, SyncState.synced.name);
    });

    test('skips when existing row is pendingUpdate', () async {
      // Insert synced, then mark as pendingUpdate via update.
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao.markUpdatePending(
          'task-1', TasksCompanion(name: const Value('Local edit')));

      // Remote snapshot should NOT overwrite it.
      await db.taskDao.upsertFromRemote(_makeCompanion(name: 'Remote name'));

      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.name, 'Local edit');
      expect(all.first.syncState, SyncState.pendingUpdate.name);
    });

    test('overwrites when existing row is synced', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao
          .upsertFromRemote(_makeCompanion(name: 'Remote update'));
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.name, 'Remote update');
    });
  });

  group('TaskDao.insertPending', () {
    test('sets syncState to pendingCreate', () async {
      await db.taskDao.insertPending(_makeCompanion());
      final pending = await db.taskDao.pendingWrites();
      expect(pending.length, 1);
      expect(pending.first.syncState, SyncState.pendingCreate.name);
    });
  });

  group('TaskDao.markUpdatePending', () {
    test('synced → pendingUpdate', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao.markUpdatePending(
          'task-1', TasksCompanion(name: const Value('Changed')));
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.syncState, SyncState.pendingUpdate.name);
      expect(all.first.name, 'Changed');
    });

    test('pendingCreate stays pendingCreate after markUpdatePending', () async {
      await db.taskDao.insertPending(_makeCompanion());
      await db.taskDao.markUpdatePending(
          'task-1', TasksCompanion(name: const Value('Changed')));
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.syncState, SyncState.pendingCreate.name);
    });
  });

  group('TaskDao.markDeletePending', () {
    test('synced → pendingDelete', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao.markDeletePending('task-1');
      final pending = await db.taskDao.pendingWrites();
      expect(pending.first.syncState, SyncState.pendingDelete.name);
    });

    test('pendingCreate → hard delete (never pushed)', () async {
      await db.taskDao.insertPending(_makeCompanion());
      await db.taskDao.markDeletePending('task-1');
      final all = await db.taskDao.allForUser(personDocId);
      expect(all, isEmpty);
    });
  });

  group('TaskDao.deleteFromRemote', () {
    test('deletes a synced row', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao.deleteFromRemote('task-1');
      final all = await db.taskDao.allForUser(personDocId);
      expect(all, isEmpty);
    });

    test('does not delete a pending row', () async {
      await db.taskDao.insertPending(_makeCompanion());
      await db.taskDao.deleteFromRemote('task-1');
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.length, 1);
    });
  });

  group('TaskDao.watchIncompleteTasks', () {
    test('excludes completed tasks', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-active'));
      await db.taskDao.upsertFromRemote(
          _makeCompanion(docId: 'task-done', completionDate: now));
      final result =
          await db.taskDao.watchIncompleteTasks(personDocId).first;
      expect(result.length, 1);
      expect(result.first.docId, 'task-active');
    });

    test('excludes retired tasks', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-active'));
      await db.taskDao.upsertFromRemote(
          _makeCompanion(docId: 'task-retired', retired: 'task-retired'));
      final result =
          await db.taskDao.watchIncompleteTasks(personDocId).first;
      expect(result.length, 1);
    });

    test('excludes pendingDelete tasks', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-1'));
      await db.taskDao.markDeletePending('task-1');
      final result =
          await db.taskDao.watchIncompleteTasks(personDocId).first;
      expect(result, isEmpty);
    });

    test('includes skipped tasks (no completionDate set)', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-active'));
      await db.taskDao.upsertFromRemote(
          _makeCompanion(docId: 'task-skipped', skipped: true));
      final result =
          await db.taskDao.watchIncompleteTasks(personDocId).first;
      expect(result.length, 2,
          reason: 'Skipped tasks have no completionDate so they remain in active list');
      expect(result.map((t) => t.docId).toSet(),
          {'task-active', 'task-skipped'});
    });

    test('excludes skipped task that also has completionDate', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-active'));
      await db.taskDao.upsertFromRemote(
          _makeCompanion(docId: 'task-skipped-done', skipped: true, completionDate: now));
      final result =
          await db.taskDao.watchIncompleteTasks(personDocId).first;
      expect(result.length, 1);
      expect(result.first.docId, 'task-active');
    });
  });

  group('TaskDao.skipped field', () {
    test('defaults to false on insert', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.skipped, false);
    });

    test('round-trips skipped=true', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(skipped: true));
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.skipped, true);
    });

    test('markUpdatePending can set skipped=true', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao.markUpdatePending(
          'task-1', const TasksCompanion(skipped: Value(true)));
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.skipped, true);
    });

    test('markUpdatePending can clear skipped back to false', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(skipped: true));
      await db.taskDao.markUpdatePending(
          'task-1', const TasksCompanion(skipped: Value(false)));
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.skipped, false);
    });
  });

  group('TaskDao.deleteSyncedIncompleteNotIn', () {
    test('deletes synced incomplete row not in the remote set', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-active'));
      await db.taskDao.deleteSyncedIncompleteNotIn(personDocId, {'other-id'});
      final all = await db.taskDao.allForUser(personDocId);
      expect(all, isEmpty, reason: 'Synced incomplete row absent from remote set must be deleted');
    });

    test('does NOT delete synced completed row absent from remote set (TM-341)', () async {
      await db.taskDao.upsertFromRemote(
          _makeCompanion(docId: 'task-done', completionDate: now));
      await db.taskDao.deleteSyncedIncompleteNotIn(personDocId, {'other-id'});
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.length, 1, reason: 'Completed tasks must survive reconciliation');
      expect(all.first.docId, 'task-done');
    });

    test('keeps synced incomplete row that IS in the remote set', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'task-active'));
      await db.taskDao.deleteSyncedIncompleteNotIn(personDocId, {'task-active'});
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.length, 1);
    });

    test('does not affect pending rows', () async {
      await db.taskDao.insertPending(_makeCompanion(docId: 'task-pending'));
      await db.taskDao.deleteSyncedIncompleteNotIn(personDocId, {'other-id'});
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.length, 1, reason: 'Pending rows must not be affected');
    });

    test('mixed: deletes only incomplete+synced rows absent from set', () async {
      // Should be deleted (incomplete, synced, not in set)
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'incomplete-absent'));
      // Should be kept (completed, synced)
      await db.taskDao.upsertFromRemote(
          _makeCompanion(docId: 'completed', completionDate: now));
      // Should be kept (in set)
      await db.taskDao.upsertFromRemote(_makeCompanion(docId: 'in-set'));

      await db.taskDao.deleteSyncedIncompleteNotIn(personDocId, {'in-set'});

      final all = await db.taskDao.allForUser(personDocId);
      final remaining = all.map((t) => t.docId).toSet();
      expect(remaining, {'completed', 'in-set'});
    });
  });

  group('TaskDao.markSynced', () {
    test('flips pendingCreate to synced', () async {
      await db.taskDao.insertPending(_makeCompanion());
      await db.taskDao.markSynced('task-1');
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.syncState, SyncState.synced.name);
    });

    test('flips pendingUpdate to synced', () async {
      await db.taskDao.upsertFromRemote(_makeCompanion());
      await db.taskDao.markUpdatePending(
          'task-1', TasksCompanion(name: const Value('edit')));
      await db.taskDao.markSynced('task-1');
      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.syncState, SyncState.synced.name);
    });
  });

  group('TaskDao.cascadeRecurrenceFieldsToUpcoming', () {
    const recurrenceDocId = 'recur-1';

    TasksCompanion _makeRecurringCompanion({
      required String docId,
      required int recurIteration,
      String? syncState,
      bool? recurWait,
    }) {
      return TasksCompanion(
        docId: Value(docId),
        dateAdded: Value(now),
        name: Value('Recurring task $recurIteration'),
        personDocId: const Value(personDocId),
        syncState: Value(syncState ?? SyncState.synced.name),
        offCycle: const Value(false),
        recurrenceDocId: const Value(recurrenceDocId),
        recurIteration: Value(recurIteration),
        recurWait: Value(recurWait ?? false),
        recurNumber: const Value(7),
        recurUnit: const Value('Days'),
      );
    }

    final _cascadeDiff = const TasksCompanion(
      recurWait: Value(true),
      recurNumber: Value(14),
      recurUnit: Value('Weeks'),
    );

    test('updates recurWait/recurNumber/recurUnit on tasks with recurIteration > afterIteration', () async {
      await db.taskDao.upsertFromRemote(_makeRecurringCompanion(docId: 'task-1', recurIteration: 1));
      await db.taskDao.upsertFromRemote(_makeRecurringCompanion(docId: 'task-2', recurIteration: 2));
      await db.taskDao.upsertFromRemote(_makeRecurringCompanion(docId: 'task-3', recurIteration: 3));

      await db.taskDao.cascadeRecurrenceFieldsToUpcoming(
        personDocId: personDocId,
        recurrenceDocId: recurrenceDocId,
        afterIteration: 1,
        diff: _cascadeDiff,
      );

      final all = await db.taskDao.allForUser(personDocId);
      final byDocId = {for (final t in all) t.docId: t};

      // task-1 (the edited task) must NOT be updated
      expect(byDocId['task-1']!.recurWait, false);
      expect(byDocId['task-1']!.recurNumber, 7);
      expect(byDocId['task-1']!.recurUnit, 'Days');

      // task-2 and task-3 (upcoming) must be updated
      expect(byDocId['task-2']!.recurWait, true);
      expect(byDocId['task-2']!.recurNumber, 14);
      expect(byDocId['task-2']!.recurUnit, 'Weeks');
      expect(byDocId['task-3']!.recurWait, true);
      expect(byDocId['task-3']!.recurNumber, 14);
      expect(byDocId['task-3']!.recurUnit, 'Weeks');
    });

    test('does NOT update tasks with a different recurrenceDocId', () async {
      await db.taskDao.upsertFromRemote(_makeRecurringCompanion(docId: 'task-1', recurIteration: 1));
      // A task in a different recurrence chain
      await db.taskDao.upsertFromRemote(
        TasksCompanion(
          docId: const Value('task-other'),
          dateAdded: Value(now),
          name: const Value('Other chain'),
          personDocId: const Value(personDocId),
          syncState: Value(SyncState.synced.name),
          offCycle: const Value(false),
          recurrenceDocId: const Value('recur-2'),
          recurIteration: const Value(2),
          recurWait: const Value(false),
          recurNumber: const Value(7),
          recurUnit: const Value('Days'),
        ),
      );

      await db.taskDao.cascadeRecurrenceFieldsToUpcoming(
        personDocId: personDocId,
        recurrenceDocId: recurrenceDocId,
        afterIteration: 0,
        diff: _cascadeDiff,
      );

      final all = await db.taskDao.allForUser(personDocId);
      final other = all.firstWhere((t) => t.docId == 'task-other');
      expect(other.recurWait, false, reason: 'Different recurrence chain must not be affected');
      expect(other.recurNumber, 7);
    });

    test('preserves pendingCreate state on updated tasks', () async {
      await db.taskDao.insertPending(_makeRecurringCompanion(docId: 'task-2', recurIteration: 2));

      await db.taskDao.cascadeRecurrenceFieldsToUpcoming(
        personDocId: personDocId,
        recurrenceDocId: recurrenceDocId,
        afterIteration: 1,
        diff: _cascadeDiff,
      );

      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.syncState, SyncState.pendingCreate.name,
          reason: 'pendingCreate tasks must stay pendingCreate after cascade');
      expect(all.first.recurWait, true, reason: 'recurrence fields must still be updated');
    });

    test('transitions synced tasks to pendingUpdate', () async {
      await db.taskDao.upsertFromRemote(_makeRecurringCompanion(docId: 'task-2', recurIteration: 2));

      await db.taskDao.cascadeRecurrenceFieldsToUpcoming(
        personDocId: personDocId,
        recurrenceDocId: recurrenceDocId,
        afterIteration: 1,
        diff: _cascadeDiff,
      );

      final all = await db.taskDao.allForUser(personDocId);
      expect(all.first.syncState, SyncState.pendingUpdate.name,
          reason: 'synced tasks must be marked pendingUpdate after cascade');
    });

    test('does NOT update pendingDelete tasks', () async {
      await db.taskDao.upsertFromRemote(_makeRecurringCompanion(docId: 'task-2', recurIteration: 2));
      await db.taskDao.markDeletePending('task-2');

      await db.taskDao.cascadeRecurrenceFieldsToUpcoming(
        personDocId: personDocId,
        recurrenceDocId: recurrenceDocId,
        afterIteration: 1,
        diff: _cascadeDiff,
      );

      // pendingDelete row should still have original recurrence values
      final pending = await db.taskDao.pendingWrites();
      final task2 = pending.firstWhere((t) => t.docId == 'task-2');
      expect(task2.recurWait, false, reason: 'pendingDelete tasks must not be updated by cascade');
    });
  });
}
