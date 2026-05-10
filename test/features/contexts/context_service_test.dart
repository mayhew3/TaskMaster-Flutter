import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/database/app_database.dart';
import 'package:taskmaestro/core/database/converters.dart';
import 'package:taskmaestro/core/database/tables.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/core/providers/firebase_providers.dart';
import 'package:taskmaestro/core/services/sync_service.dart';
import 'package:taskmaestro/features/contexts/services/context_service.dart';
import 'package:taskmaestro/models/task_context.dart' as m;

/// Tests for `ContextService` (TM-181). Mirrors the AreaService test layout —
/// see `test/features/areas/area_service_test.dart` for the source pattern.

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

  ContextService getService() => container.read(contextServiceProvider);

  group('createContext', () {
    test('first context gets sortOrder 0', () async {
      final ctx = await getService()
          .createContext(name: 'Phone', personDocId: 'me');
      expect(ctx.name, 'Phone');
      expect(ctx.sortOrder, 0);
      expect(ctx.personDocId, 'me');
    });

    test('subsequent contexts get sortOrder = max(existing) + 1', () async {
      final svc = getService();
      final first = await svc.createContext(name: 'Phone', personDocId: 'me');
      final second =
          await svc.createContext(name: 'Computer', personDocId: 'me');
      final third = await svc.createContext(name: 'Home', personDocId: 'me');
      expect(first.sortOrder, 0);
      expect(second.sortOrder, 1);
      expect(third.sortOrder, 2);
    });

    test('inserted as pendingCreate in Drift', () async {
      await getService().createContext(name: 'Phone', personDocId: 'me');
      final pending = await db.contextDao.pendingContextWrites();
      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pendingCreate.name);
    });

    test('isolates per-user sortOrder counters', () async {
      final svc = getService();
      await svc.createContext(name: 'Phone', personDocId: 'alice');
      await svc.createContext(name: 'Computer', personDocId: 'alice');
      final bobFirst =
          await svc.createContext(name: 'Phone', personDocId: 'bob');
      expect(bobFirst.sortOrder, 0);
    });

    test('persists iconName when supplied', () async {
      final ctx = await getService().createContext(
        name: 'Phone',
        personDocId: 'me',
        iconName: 'phone',
      );
      expect(ctx.iconName, 'phone');
      final stored = await db.contextDao.getContextsForUser('me');
      expect(stored.first.iconName, 'phone');
    });
  });

  group('createContext duplicate / reserved', () {
    test('throws DuplicateContextNameException on case-insensitive collision',
        () async {
      final svc = getService();
      await svc.createContext(name: 'Phone', personDocId: 'me');
      await expectLater(
        svc.createContext(name: 'phone', personDocId: 'me'),
        throwsA(isA<DuplicateContextNameException>()),
      );
    });

    test('still allows the same name for a different user', () async {
      final svc = getService();
      await svc.createContext(name: 'Phone', personDocId: 'alice');
      final bobPhone =
          await svc.createContext(name: 'Phone', personDocId: 'bob');
      expect(bobPhone.name, 'Phone');
    });

    test('rejects reserved sentinel names', () async {
      await expectLater(
        getService().createContext(
            name: kNoneContextSentinelName, personDocId: 'me'),
        throwsA(isA<ReservedContextNameException>()),
      );
      await expectLater(
        getService().createContext(
            name: kAddNewContextSentinelName, personDocId: 'me'),
        throwsA(isA<ReservedContextNameException>()),
      );
    });
  });

  group('renameContext', () {
    test('updates the name and marks pendingUpdate', () async {
      final svc = getService();
      final phone = await svc.createContext(name: 'Phone', personDocId: 'me');
      // Mark synced so the rename moves it from pendingCreate → pendingUpdate.
      await db.contextDao.markContextSynced(phone.docId);
      await svc.renameContext(phone, 'Telephone');
      final pending = await db.contextDao.pendingContextWrites();
      expect(pending, hasLength(1));
      expect(pending.first.name, 'Telephone');
      expect(pending.first.syncState, SyncState.pendingUpdate.name);
    });

    test('rejects rename to an existing name (case-insensitive)', () async {
      final svc = getService();
      await svc.createContext(name: 'Phone', personDocId: 'me');
      final computer =
          await svc.createContext(name: 'Computer', personDocId: 'me');
      await expectLater(
        svc.renameContext(computer, 'phone'),
        throwsA(isA<DuplicateContextNameException>()),
      );
    });

    test('allows renaming to its own current name (no self-collision)',
        () async {
      final svc = getService();
      final phone = await svc.createContext(name: 'Phone', personDocId: 'me');
      await svc.renameContext(phone, 'Phone'); // no-op, must not throw
    });
  });

  group('deleteContext', () {
    test('marks pendingDelete and stops appearing in watch stream', () async {
      final svc = getService();
      final phone = await svc.createContext(name: 'Phone', personDocId: 'me');
      await db.contextDao.markContextSynced(phone.docId);
      await svc.deleteContext(phone);
      final pending = await db.contextDao.pendingContextWrites();
      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pendingDelete.name);
      // Watcher excludes pendingDelete rows immediately.
      final visible =
          await db.contextDao.watchContextsForUser('me').first;
      expect(visible, isEmpty);
    });
  });

  group('reorderContexts', () {
    test('rewrites sortOrder 0..N-1 in a single transaction', () async {
      final svc = getService();
      final a = await svc.createContext(name: 'A', personDocId: 'me');
      final b = await svc.createContext(name: 'B', personDocId: 'me');
      final c = await svc.createContext(name: 'C', personDocId: 'me');
      // Mark synced so reorder yields pendingUpdate rows we can inspect.
      for (final ctx in [a, b, c]) {
        await db.contextDao.markContextSynced(ctx.docId);
      }
      await svc.reorderContexts([c, a, b]);
      final stored = await db.contextDao.getContextsForUser('me');
      stored.sort((x, y) => x.sortOrder.compareTo(y.sortOrder));
      expect(stored.map((x) => x.name).toList(), ['C', 'A', 'B']);
      expect(stored.map((x) => x.sortOrder).toList(), [0, 1, 2]);
    });
  });

  group('setIconName / setColor (Tier-2 hooks)', () {
    test('setIconName updates the column and marks pendingUpdate', () async {
      final svc = getService();
      final phone = await svc.createContext(name: 'Phone', personDocId: 'me');
      await db.contextDao.markContextSynced(phone.docId);
      await svc.setIconName(phone, 'phone');
      final stored = await db.contextDao.getContextsForUser('me');
      expect(stored.first.iconName, 'phone');
      expect(stored.first.syncState, SyncState.pendingUpdate.name);
    });

    test('setColor updates the column', () async {
      final svc = getService();
      final phone = await svc.createContext(name: 'Phone', personDocId: 'me');
      await db.contextDao.markContextSynced(phone.docId);
      await svc.setColor(phone, '#3B82F6');
      final stored = await db.contextDao.getContextsForUser('me');
      expect(stored.first.color, '#3B82F6');
    });
  });

  group('cascade — countTasksUsingContext / removeContextFromAllTasks', () {
    Future<void> insertTask({
      required String docId,
      required List<m.TaskContext> contexts,
      String personDocId = 'me',
    }) async {
      await db.into(db.tasks).insert(TasksCompanion(
            docId: Value(docId),
            dateAdded: Value(DateTime.now().toUtc()),
            personDocId: Value(personDocId),
            name: Value('Task $docId'),
            taskContexts: Value(serializeTaskContexts(contexts)),
            syncState: const Value('synced'),
          ));
    }

    test('countTasksUsingContext only counts the user\'s own non-retired rows',
        () async {
      await insertTask(
          docId: 't1', contexts: [m.TaskContext.named('Phone')]);
      await insertTask(
          docId: 't2', contexts: [m.TaskContext.named('phone')]);
      await insertTask(
          docId: 't3', contexts: [m.TaskContext.named('Computer')]);
      // Different user — should not count.
      await insertTask(
          docId: 't4',
          personDocId: 'someone-else',
          contexts: [m.TaskContext.named('Phone')]);

      final n = await getService().countTasksUsingContext(
        contextName: 'Phone',
        personDocId: 'me',
      );
      // Case-insensitive match → t1 + t2; t3 has a different name; t4 is
      // a different user.
      expect(n, 2);
    });

    test(
        'removeContextFromAllTasks strips matching entries and marks pendingUpdate',
        () async {
      await insertTask(docId: 't1', contexts: [
        m.TaskContext.named('Phone'),
        m.TaskContext.named('Computer'),
      ]);
      await insertTask(docId: 't2', contexts: [m.TaskContext.named('Phone')]);
      await insertTask(docId: 't3', contexts: [m.TaskContext.named('Home')]);

      final updated = await getService().removeContextFromAllTasks(
        contextName: 'Phone',
        personDocId: 'me',
      );
      expect(updated, 2);

      final t1 = await db.taskDao.getByDocId('t1');
      expect(parseTaskContexts(t1!.taskContexts).map((c) => c.name).toList(),
          ['Computer']);
      expect(t1.syncState, SyncState.pendingUpdate.name);

      final t2 = await db.taskDao.getByDocId('t2');
      expect(parseTaskContexts(t2!.taskContexts), isEmpty);
      expect(t2.syncState, SyncState.pendingUpdate.name);

      // Untagged task should not have been touched.
      final t3 = await db.taskDao.getByDocId('t3');
      expect(t3!.syncState, SyncState.synced.name);
    });
  });

  group('cascade — renameContextOnAllTasks', () {
    Future<void> insertTask({
      required String docId,
      required List<m.TaskContext> contexts,
    }) async {
      await db.into(db.tasks).insert(TasksCompanion(
            docId: Value(docId),
            dateAdded: Value(DateTime.now().toUtc()),
            personDocId: const Value('me'),
            name: Value('Task $docId'),
            taskContexts: Value(serializeTaskContexts(contexts)),
            syncState: const Value('synced'),
          ));
    }

    test('rewrites matching context names while preserving value', () async {
      await insertTask(docId: 't1', contexts: [
        m.TaskContext((b) => b
          ..name = 'Phone'
          ..value = 5),
        m.TaskContext.named('Computer'),
      ]);

      final updated = await getService().renameContextOnAllTasks(
        oldName: 'Phone',
        newName: 'Telephone',
        personDocId: 'me',
      );
      expect(updated, 1);

      final t1 = await db.taskDao.getByDocId('t1');
      final ctxs = parseTaskContexts(t1!.taskContexts);
      expect(ctxs.map((c) => c.name).toList(), ['Telephone', 'Computer']);
      // value field is preserved on the renamed entry.
      final renamed = ctxs.firstWhere((c) => c.name == 'Telephone');
      expect(renamed.value, 5);
      expect(t1.syncState, SyncState.pendingUpdate.name);
    });

    test('case-insensitive match', () async {
      await insertTask(
          docId: 't1', contexts: [m.TaskContext.named('PHONE')]);

      final updated = await getService().renameContextOnAllTasks(
        oldName: 'phone',
        newName: 'Telephone',
        personDocId: 'me',
      );
      expect(updated, 1);

      final t1 = await db.taskDao.getByDocId('t1');
      expect(parseTaskContexts(t1!.taskContexts).single.name, 'Telephone');
    });
  });
}
