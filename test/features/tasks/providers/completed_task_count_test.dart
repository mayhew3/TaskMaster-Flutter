import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/core/database/tables.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_filter_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testPersonDocId = 'test-person-123';

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<FakeFirebaseFirestore> seedFirestore({
    int incomplete = 0,
    int completed = 0,
    int retired = 0,
    int otherUserCompleted = 0,
  }) async {
    final firestore = FakeFirebaseFirestore();

    for (var i = 0; i < incomplete; i++) {
      await firestore.collection('tasks').doc('incomplete-$i').set({
        'name': 'Incomplete $i',
        'personDocId': testPersonDocId,
        'dateAdded': DateTime.now().toUtc(),
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    for (var i = 0; i < completed; i++) {
      await firestore.collection('tasks').doc('completed-$i').set({
        'name': 'Completed $i',
        'personDocId': testPersonDocId,
        'dateAdded': DateTime.now().toUtc(),
        'completionDate': DateTime.now().subtract(Duration(days: i)).toUtc(),
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    for (var i = 0; i < retired; i++) {
      await firestore.collection('tasks').doc('retired-$i').set({
        'name': 'Retired $i',
        'personDocId': testPersonDocId,
        'dateAdded': DateTime.now().toUtc(),
        'completionDate': DateTime.now().toUtc(),
        'retired': 'retired-$i',
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    for (var i = 0; i < otherUserCompleted; i++) {
      await firestore.collection('tasks').doc('other-$i').set({
        'name': 'Other $i',
        'personDocId': 'other-user',
        'dateAdded': DateTime.now().toUtc(),
        'completionDate': DateTime.now().toUtc(),
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    return firestore;
  }

  group('completedTaskCount provider', () {
    test('returns 0 when no completed tasks exist', () async {
      final firestore = await seedFirestore(incomplete: 5);
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 0);
    });

    test('returns count of completed tasks', () async {
      final firestore = await seedFirestore(incomplete: 3, completed: 7);
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 7);
    });

    test('excludes retired tasks', () async {
      final firestore = await seedFirestore(completed: 5, retired: 3);
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 5);
    });

    test('excludes tasks from other users', () async {
      final firestore = await seedFirestore(completed: 4, otherUserCompleted: 6);
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 4);
    });

    test('returns 0 when personDocId is null', () async {
      final firestore = await seedFirestore(completed: 5);
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => null),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 0);
    });

    test('subtracts synced skipped tasks from Firestore total', () async {
      // Firestore sees 7 completed (including the 2 that are skipped)
      final firestore = await seedFirestore(completed: 7);
      final now = DateTime.now().toUtc();
      // Seed 2 synced+skipped+completionDate rows so skippedTaskCount returns 2
      await db.taskDao.upsertFromRemote(TasksCompanion(
        docId: const Value('skip-1'),
        name: const Value('Skipped 1'),
        personDocId: const Value(testPersonDocId),
        dateAdded: Value(now),
        skipped: const Value(true),
        completionDate: Value(now),
        offCycle: const Value(false),
        syncState: Value(SyncState.synced.name),
      ));
      await db.taskDao.upsertFromRemote(TasksCompanion(
        docId: const Value('skip-2'),
        name: const Value('Skipped 2'),
        personDocId: const Value(testPersonDocId),
        dateAdded: Value(now),
        skipped: const Value(true),
        completionDate: Value(now),
        offCycle: const Value(false),
        syncState: Value(SyncState.synced.name),
      ));
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 5, reason: '7 Firestore completed − 2 synced skipped = 5');
    });

    test('pending skipped tasks are not subtracted (not yet in Firestore)', () async {
      final firestore = await seedFirestore(completed: 4);
      final now = DateTime.now().toUtc();
      // Pending skip — Firestore hasn't counted it yet
      await db.taskDao.insertPending(TasksCompanion(
        docId: const Value('skip-pending'),
        name: const Value('Pending Skip'),
        personDocId: const Value(testPersonDocId),
        dateAdded: Value(now),
        skipped: const Value(true),
        completionDate: Value(now),
        offCycle: const Value(false),
        syncState: Value(SyncState.pendingCreate.name),
      ));
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 4, reason: 'Pending skips are not yet in Firestore so the count is unchanged');
    });
  });
}
