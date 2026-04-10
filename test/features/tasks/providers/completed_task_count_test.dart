import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_filter_providers.dart';

void main() {
  const testPersonDocId = 'test-person-123';

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
        ],
      );
      addTearDown(container.dispose);

      final count = await container.read(completedTaskCountProvider.future);
      expect(count, 0);
    });
  });
}
