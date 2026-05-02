import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart' hide Area;
import 'package:taskmaster/core/database/tables.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/services/sync_service.dart';
import 'package:taskmaster/features/areas/services/area_service.dart';

/// SyncService stub that no-ops `pushPendingWrites` so tests don't try to
/// run the real push loop (which depends on connectivity, notification
/// providers, and other plumbing irrelevant to AreaService logic).
class _FakeSyncService extends SyncService {
  _FakeSyncService({
    required super.db,
    required super.firestore,
    required super.ref,
  });

  @override
  Future<void> pushPendingWrites({String caller = 'unknown'}) async {}
}

void main() {
  late AppDatabase db;
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      firestoreProvider.overrideWithValue(firestore),
      syncServiceProvider.overrideWith((ref) => _FakeSyncService(
            db: ref.watch(databaseProvider),
            firestore: ref.watch(firestoreProvider),
            ref: ref,
          )),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  AreaService getService() => container.read(areaServiceProvider);

  group('AreaService.createArea', () {
    test('first area gets sortOrder 0', () async {
      final area = await getService()
          .createArea(name: 'Home', personDocId: 'me');
      expect(area.name, 'Home');
      expect(area.sortOrder, 0);
      expect(area.personDocId, 'me');
    });

    test('subsequent areas get sortOrder = max(existing) + 1', () async {
      final svc = getService();
      final first = await svc.createArea(name: 'Home', personDocId: 'me');
      final second = await svc.createArea(name: 'Work', personDocId: 'me');
      final third = await svc.createArea(name: 'Health', personDocId: 'me');
      expect(first.sortOrder, 0);
      expect(second.sortOrder, 1);
      expect(third.sortOrder, 2);
    });

    test('inserted as pendingCreate in Drift', () async {
      await getService().createArea(name: 'Home', personDocId: 'me');
      final pending = await db.areaDao.pendingAreaWrites();
      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pendingCreate.name);
    });

    test('isolates per-user sortOrder counters', () async {
      final svc = getService();
      await svc.createArea(name: 'A', personDocId: 'alice');
      await svc.createArea(name: 'B', personDocId: 'alice');
      final bobFirst = await svc.createArea(name: 'A', personDocId: 'bob');
      // Bob's max is 0 because Alice's areas are scoped out of his query.
      expect(bobFirst.sortOrder, 0);
    });
  });

  group('AreaService.createArea duplicate rejection', () {
    test('throws DuplicateAreaNameException on case-insensitive collision',
        () async {
      final svc = getService();
      await svc.createArea(name: 'Home', personDocId: 'me');
      await expectLater(
        svc.createArea(name: 'home', personDocId: 'me'),
        throwsA(isA<DuplicateAreaNameException>()),
      );
    });

    test('still allows the same name for a DIFFERENT user', () async {
      final svc = getService();
      await svc.createArea(name: 'Home', personDocId: 'alice');
      // Bob isn't blocked by Alice's "Home".
      final bobHome = await svc.createArea(name: 'Home', personDocId: 'bob');
      expect(bobHome.name, 'Home');
    });
  });

  group('AreaService.renameArea duplicate rejection', () {
    test('throws when renaming to an existing name', () async {
      final svc = getService();
      await svc.createArea(name: 'Home', personDocId: 'me');
      final work = await svc.createArea(name: 'Work', personDocId: 'me');

      await expectLater(
        svc.renameArea(work, 'home'),
        throwsA(isA<DuplicateAreaNameException>()),
      );
    });

    test('allows renaming to its own current name (no self-collision)',
        () async {
      final svc = getService();
      final home = await svc.createArea(name: 'Home', personDocId: 'me');
      // Renaming Home → Home is a no-op but must not throw.
      await svc.renameArea(home, 'Home');
    });
  });

  group('AreaService reserved name rejection', () {
    test('createArea throws on the (none) sentinel', () async {
      await expectLater(
        getService().createArea(name: '(none)', personDocId: 'me'),
        throwsA(isA<ReservedAreaNameException>()),
      );
    });

    test('createArea throws on the + Add new area… sentinel', () async {
      await expectLater(
        getService().createArea(name: '+ Add new area…', personDocId: 'me'),
        throwsA(isA<ReservedAreaNameException>()),
      );
    });

    test('renameArea throws when renaming to a sentinel', () async {
      final svc = getService();
      final area = await svc.createArea(name: 'Home', personDocId: 'me');
      await expectLater(
        svc.renameArea(area, '(none)'),
        throwsA(isA<ReservedAreaNameException>()),
      );
    });
  });

  group('AreaService.deleteArea', () {
    test('marks the area pendingDelete and stamps retired', () async {
      final area =
          await getService().createArea(name: 'Home', personDocId: 'me');

      // First simulate that the create has flushed to "synced" — otherwise
      // markDeletePending applies on top of pendingCreate.
      await db.areaDao.markAreaSynced(area.docId);

      await getService().deleteArea(area);

      final row = await (db.select(db.areas)
            ..where((a) => a.docId.equals(area.docId)))
          .getSingle();
      expect(row.syncState, SyncState.pendingDelete.name);
      expect(row.retired, area.docId);
    });
  });

  group('AreaService.reorderAreas', () {
    test('rewrites sortOrder to 0..N-1 in the new order', () async {
      final svc = getService();
      final a = await svc.createArea(name: 'A', personDocId: 'me');
      final b = await svc.createArea(name: 'B', personDocId: 'me');
      final c = await svc.createArea(name: 'C', personDocId: 'me');

      // Mark all synced so reorderAreas writes pendingUpdate (not still-pending).
      for (final id in [a.docId, b.docId, c.docId]) {
        await db.areaDao.markAreaSynced(id);
      }

      // Move C to the front: [C, A, B]
      // We need fresh Area instances with current sortOrders to compare against.
      final reordered = [
        // The reorderAreas implementation only reads sortOrder for the no-op
        // optimization; it doesn't matter what we pass beyond identity here.
        c, a, b,
      ];
      await svc.reorderAreas(reordered);

      final rows = await (db.select(db.areas)
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();
      expect(rows.map((r) => r.name), ['C', 'A', 'B']);
      expect(rows.first.syncState, SyncState.pendingUpdate.name);
    });

    test('skips the write when the order is already correct', () async {
      final svc = getService();
      final a = await svc.createArea(name: 'A', personDocId: 'me');
      final b = await svc.createArea(name: 'B', personDocId: 'me');
      for (final id in [a.docId, b.docId]) {
        await db.areaDao.markAreaSynced(id);
      }

      // Pass them in the same order they're already in. Nothing should flip
      // back to pendingUpdate.
      await svc.reorderAreas([a, b]);

      final rows = await (db.select(db.areas)).get();
      expect(rows.every((r) => r.syncState == SyncState.synced.name), isTrue);
    });
  });
}
