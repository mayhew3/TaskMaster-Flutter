import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/core/database/tables.dart';

void main() {
  late AppDatabase db;

  const personDocId = 'person-1';
  final now = DateTime.utc(2025, 6, 15);
  final end = now.add(const Duration(days: 7));

  SprintsCompanion _makeSprint({
    String docId = 'sprint-1',
    int sprintNumber = 1,
    String? syncState,
    String? retired,
  }) {
    return SprintsCompanion(
      docId: Value(docId),
      dateAdded: Value(now),
      startDate: Value(now),
      endDate: Value(end),
      numUnits: const Value(5),
      unitName: const Value('Points'),
      personDocId: const Value(personDocId),
      sprintNumber: Value(sprintNumber),
      syncState: Value(syncState ?? SyncState.synced.name),
      retired: Value(retired),
    );
  }

  SprintAssignmentsCompanion _makeAssignment({
    String docId = 'assign-1',
    String sprintDocId = 'sprint-1',
    String taskDocId = 'task-1',
    String? syncState,
    String? retired,
  }) {
    return SprintAssignmentsCompanion(
      docId: Value(docId),
      taskDocId: Value(taskDocId),
      sprintDocId: Value(sprintDocId),
      syncState: Value(syncState ?? SyncState.synced.name),
      retired: Value(retired),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('SprintDao.upsertSprintFromRemote', () {
    test('inserts synced sprint', () async {
      await db.sprintDao.upsertSprintFromRemote(_makeSprint());
      final pending = await db.sprintDao.pendingSprintWrites();
      expect(pending, isEmpty);
    });

    test('skips pending sprint on remote upsert', () async {
      await db.sprintDao.insertSprintPending(_makeSprint());
      await db.sprintDao
          .upsertSprintFromRemote(_makeSprint(sprintNumber: 99));
      final sprints = await (db.select(db.sprints)).get();
      // sprintNumber should not have been overwritten.
      expect(sprints.first.sprintNumber, 1);
    });
  });

  group('SprintDao.watchRecentSprints', () {
    test('returns sprints with their assignments', () async {
      await db.sprintDao.upsertSprintFromRemote(_makeSprint());
      await db.sprintDao.upsertAssignmentFromRemote(_makeAssignment());

      final rows = await db.sprintDao
          .watchRecentSprints(personDocId: personDocId, limit: 3)
          .first;
      expect(rows.length, 1);
      expect(rows.first.assignments.length, 1);
      expect(rows.first.assignments.first.taskDocId, 'task-1');
    });

    test('returns at most limit sprints, newest first', () async {
      for (var i = 1; i <= 5; i++) {
        await db.sprintDao.upsertSprintFromRemote(
          _makeSprint(docId: 'sprint-$i', sprintNumber: i),
        );
      }
      final rows = await db.sprintDao
          .watchRecentSprints(personDocId: personDocId, limit: 3)
          .first;
      expect(rows.length, 3);
      expect(rows.first.sprint.sprintNumber, 5);
      expect(rows.last.sprint.sprintNumber, 3);
    });

    test('excludes retired sprints', () async {
      await db.sprintDao.upsertSprintFromRemote(_makeSprint());
      await db.sprintDao.upsertSprintFromRemote(
        _makeSprint(docId: 'sprint-2', sprintNumber: 2, retired: 'sprint-2'),
      );
      final rows = await db.sprintDao
          .watchRecentSprints(personDocId: personDocId, limit: 3)
          .first;
      expect(rows.length, 1);
      expect(rows.first.sprint.docId, 'sprint-1');
    });

    test('excludes pendingDelete sprints', () async {
      await db.sprintDao.insertSprintPending(_makeSprint());
      await db.sprintDao.markSprintSynced('sprint-1');
      await (db.update(db.sprints)
            ..where((s) => s.docId.equals('sprint-1')))
          .write(SprintsCompanion(
              syncState: Value(SyncState.pendingDelete.name)));
      final rows = await db.sprintDao
          .watchRecentSprints(personDocId: personDocId, limit: 3)
          .first;
      expect(rows, isEmpty);
    });
  });

  group('SprintDao assignments', () {
    test('upsertAssignmentFromRemote inserts synced assignment', () async {
      await db.sprintDao.upsertSprintFromRemote(_makeSprint());
      await db.sprintDao.upsertAssignmentFromRemote(_makeAssignment());
      final pending = await db.sprintDao.pendingAssignmentWrites();
      expect(pending, isEmpty);
    });

    test('insertAssignmentPending marks as pendingCreate', () async {
      await db.sprintDao.insertAssignmentPending(_makeAssignment());
      final pending = await db.sprintDao.pendingAssignmentWrites();
      expect(pending.length, 1);
      expect(pending.first.syncState, SyncState.pendingCreate.name);
    });

    test('assignmentsForSprint excludes retired', () async {
      await db.sprintDao.upsertAssignmentFromRemote(_makeAssignment());
      await db.sprintDao.upsertAssignmentFromRemote(
        _makeAssignment(
            docId: 'assign-2', taskDocId: 'task-2', retired: 'assign-2'),
      );
      final assignments =
          await db.sprintDao.assignmentsForSprint('sprint-1');
      expect(assignments.length, 1);
      expect(assignments.first.taskDocId, 'task-1');
    });

    test('markAssignmentSynced flips pendingCreate to synced', () async {
      await db.sprintDao.insertAssignmentPending(_makeAssignment());
      await db.sprintDao.markAssignmentSynced('assign-1');
      final pending = await db.sprintDao.pendingAssignmentWrites();
      expect(pending, isEmpty);
    });
  });
}
