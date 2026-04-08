import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/models/task_item.dart';

void main() {
  const testPersonDocId = 'test-person-123';

  Future<FakeFirebaseFirestore> createFirestoreWithTasks({
    int incompleteTasks = 5,
    int recentCompletedTasks = 3,
    int olderCompletedTasks = 10,
  }) async {
    final firestore = FakeFirebaseFirestore();

    // Add incomplete tasks
    for (var i = 0; i < incompleteTasks; i++) {
      await firestore.collection('tasks').doc('incomplete-$i').set({
        'name': 'Incomplete Task $i',
        'personDocId': testPersonDocId,
        'dateAdded': DateTime.now().toUtc(),
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    // Add recently completed tasks (within 30 days)
    for (var i = 0; i < recentCompletedTasks; i++) {
      await firestore.collection('tasks').doc('recent-completed-$i').set({
        'name': 'Recent Completed $i',
        'personDocId': testPersonDocId,
        'dateAdded': DateTime.now().toUtc(),
        'completionDate': DateTime.now().subtract(Duration(days: 5 + i)).toUtc(),
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    // Add older completed tasks (31-90 days ago)
    for (var i = 0; i < olderCompletedTasks; i++) {
      await firestore.collection('tasks').doc('older-completed-$i').set({
        'name': 'Older Completed $i',
        'personDocId': testPersonDocId,
        'dateAdded': DateTime.now().toUtc(),
        'completionDate': DateTime.now().subtract(Duration(days: 35 + i * 3)).toUtc(),
        'offCycle': false,
        'pendingCompletion': false,
      });
    }

    return firestore;
  }

  group('OlderCompletedState', () {
    test('copyWith preserves unchanged fields', () {
      final state = OlderCompletedState(
        loadedTasks: [],
        oldestLoadedDate: DateTime(2026, 1, 1),
        isLoading: false,
        hasMore: true,
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.hasMore, true);
      expect(updated.loadedTasks, isEmpty);
      expect(updated.oldestLoadedDate, DateTime(2026, 1, 1));
    });

    test('copyWith updates multiple fields', () {
      final state = OlderCompletedState(
        loadedTasks: [],
        oldestLoadedDate: DateTime(2026, 1, 1),
        isLoading: false,
        hasMore: true,
      );

      final tasks = [
        TaskItem((b) => b
          ..docId = 'test'
          ..name = 'Test'
          ..personDocId = testPersonDocId
          ..offCycle = false
          ..dateAdded = DateTime.now().toUtc()),
      ];

      final updated = state.copyWith(
        loadedTasks: tasks,
        hasMore: false,
      );

      expect(updated.loadedTasks.length, 1);
      expect(updated.hasMore, false);
    });
  });

  group('OlderCompletedTasksBatches', () {
    test('initial state has empty tasks and hasMore=true', () {
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(olderCompletedTasksBatchesProvider);

      expect(state.loadedTasks, isEmpty);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
    });

    test('loadNextBatch fetches tasks and updates state', () async {
      final firestore = await createFirestoreWithTasks(
        olderCompletedTasks: 5,
      );

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(olderCompletedTasksBatchesProvider.notifier);
      await notifier.loadNextBatch();

      final state = container.read(olderCompletedTasksBatchesProvider);
      expect(state.isLoading, false);
      // Should have loaded some older completed tasks
      expect(state.loadedTasks.length, greaterThan(0));
    });

    test('loadNextBatch sets hasMore=false when batch is empty', () async {
      // Create Firestore with NO older completed tasks
      final firestore = await createFirestoreWithTasks(
        olderCompletedTasks: 0,
      );

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(olderCompletedTasksBatchesProvider.notifier);
      await notifier.loadNextBatch();

      final state = container.read(olderCompletedTasksBatchesProvider);
      expect(state.hasMore, false);
      expect(state.loadedTasks, isEmpty);
    });

    test('reset clears loaded tasks and resets state', () async {
      final firestore = await createFirestoreWithTasks(
        olderCompletedTasks: 5,
      );

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(olderCompletedTasksBatchesProvider.notifier);
      await notifier.loadNextBatch();

      // Verify tasks were loaded
      var state = container.read(olderCompletedTasksBatchesProvider);
      expect(state.loadedTasks.length, greaterThan(0));

      // Reset
      notifier.reset();

      state = container.read(olderCompletedTasksBatchesProvider);
      expect(state.loadedTasks, isEmpty);
      expect(state.hasMore, true);
      expect(state.isLoading, false);
    });

    test('loadNextBatch does nothing when already loading', () async {
      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
        ],
      );
      addTearDown(container.dispose);

      // This is a quick check - the guard against concurrent loads
      final notifier = container.read(olderCompletedTasksBatchesProvider.notifier);
      // Call twice quickly - second should be a no-op
      final future1 = notifier.loadNextBatch();
      final future2 = notifier.loadNextBatch();
      await Future.wait([future1, future2]);

      // Should complete without error
      final state = container.read(olderCompletedTasksBatchesProvider);
      expect(state.isLoading, false);
    });

    test('loadNextBatch does nothing when hasMore=false', () async {
      final firestore = await createFirestoreWithTasks(
        olderCompletedTasks: 0,
      );

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(olderCompletedTasksBatchesProvider.notifier);

      // First load sets hasMore=false
      await notifier.loadNextBatch();
      expect(container.read(olderCompletedTasksBatchesProvider).hasMore, false);

      // Second load should be a no-op
      await notifier.loadNextBatch();
      expect(container.read(olderCompletedTasksBatchesProvider).hasMore, false);
      expect(container.read(olderCompletedTasksBatchesProvider).loadedTasks, isEmpty);
    });
  });
}
