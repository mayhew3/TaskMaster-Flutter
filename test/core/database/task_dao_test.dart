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
}
