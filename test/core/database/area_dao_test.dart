import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/core/database/tables.dart';

void main() {
  late AppDatabase db;

  const personDocId = 'person-1';
  final now = DateTime.utc(2026, 5, 1);

  AreasCompanion makeArea({
    String docId = 'area-1',
    String name = 'Home',
    int sortOrder = 0,
    String person = personDocId,
    String? syncState,
    String? retired,
  }) {
    return AreasCompanion(
      docId: Value(docId),
      dateAdded: Value(now),
      name: Value(name),
      sortOrder: Value(sortOrder),
      personDocId: Value(person),
      syncState: Value(syncState ?? SyncState.synced.name),
      retired: Value(retired),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('AreaDao.upsertAreaFromRemote', () {
    test('inserts a synced area', () async {
      await db.areaDao.upsertAreaFromRemote(makeArea());
      final pending = await db.areaDao.pendingAreaWrites();
      expect(pending, isEmpty);
      final all = await (db.select(db.areas)).get();
      expect(all, hasLength(1));
      expect(all.first.name, 'Home');
    });

    test('does not overwrite a row that is pending locally', () async {
      await db.areaDao.insertAreaPending(makeArea(name: 'Local'));
      await db.areaDao.upsertAreaFromRemote(makeArea(name: 'Remote'));
      final all = await (db.select(db.areas)).get();
      expect(all.first.name, 'Local',
          reason: 'pending-local-wins should preserve local edits');
    });
  });

  group('AreaDao.watchAreasForUser', () {
    test('returns areas sorted by sortOrder ascending', () async {
      await db.areaDao
          .upsertAreaFromRemote(makeArea(docId: 'a-2', name: 'B', sortOrder: 2));
      await db.areaDao
          .upsertAreaFromRemote(makeArea(docId: 'a-1', name: 'A', sortOrder: 0));
      await db.areaDao
          .upsertAreaFromRemote(makeArea(docId: 'a-3', name: 'C', sortOrder: 1));

      final emitted = await db.areaDao.watchAreasForUser(personDocId).first;
      expect(emitted.map((a) => a.name), ['A', 'C', 'B']);
    });

    test('excludes retired areas', () async {
      await db.areaDao.upsertAreaFromRemote(makeArea(docId: 'a-1', name: 'A'));
      await db.areaDao.upsertAreaFromRemote(
        makeArea(docId: 'a-2', name: 'B', retired: 'a-2'),
      );

      final emitted = await db.areaDao.watchAreasForUser(personDocId).first;
      expect(emitted.map((a) => a.name), ['A']);
    });

    test('excludes areas pending delete', () async {
      await db.areaDao.upsertAreaFromRemote(makeArea(docId: 'a-1', name: 'A'));
      await db.areaDao.insertAreaPending(
        makeArea(docId: 'a-2', name: 'B'),
      );
      await db.areaDao.markAreaDeletePending('a-2');

      final emitted = await db.areaDao.watchAreasForUser(personDocId).first;
      expect(emitted.map((a) => a.name), ['A']);
    });

    test('scopes by personDocId', () async {
      await db.areaDao
          .upsertAreaFromRemote(makeArea(docId: 'a-1', person: 'me'));
      await db.areaDao
          .upsertAreaFromRemote(makeArea(docId: 'a-2', person: 'someone-else'));

      final emitted = await db.areaDao.watchAreasForUser('me').first;
      expect(emitted, hasLength(1));
      expect(emitted.first.docId, 'a-1');
    });
  });

  group('AreaDao.markAreaDeletePending', () {
    test('flips syncState to pendingDelete and stamps retired', () async {
      await db.areaDao.upsertAreaFromRemote(makeArea());
      await db.areaDao.markAreaDeletePending('area-1');

      final row = await (db.select(db.areas)
            ..where((a) => a.docId.equals('area-1')))
          .getSingle();
      expect(row.syncState, SyncState.pendingDelete.name);
      expect(row.retired, 'area-1');
      expect(row.retiredDate, isNot(null));
    });
  });

  group('AreaDao.deleteSyncedAreasNotIn', () {
    test('removes synced rows absent from the snapshot, keeps pending', () async {
      await db.areaDao.upsertAreaFromRemote(makeArea(docId: 'a-1'));
      await db.areaDao.upsertAreaFromRemote(makeArea(docId: 'a-2'));
      await db.areaDao.insertAreaPending(makeArea(docId: 'a-3'));

      await db.areaDao.deleteSyncedAreasNotIn({'a-1'});

      final all = await (db.select(db.areas)).get();
      final ids = all.map((a) => a.docId).toSet();
      // a-1 stays (in remote set), a-2 deleted (synced + absent), a-3 stays
      // (pendingCreate, never touched).
      expect(ids, {'a-1', 'a-3'});
    });
  });
}
