import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/firebase_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/task_item.dart';

import '../../../helpers/async_provider_helpers.dart';

void main() {
  // Reset persisted TaskListView state between tests so an earlier test's
  // `searchQueryProvider.notifier.set('hello')` doesn't leak its 'hello'
  // into the next test's "empty search" assertion.
  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  const testPersonDocId = 'test-person-123';

  TaskItem createTask(String docId, String name) {
    return TaskItem((b) => b
      ..docId = docId
      ..name = name
      ..personDocId = testPersonDocId
      ..offCycle = false
      ..dateAdded = DateTime.now().toUtc());
  }

  group('SearchQuery provider', () {
    test('defaults to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), '');
    });

    test('set updates the value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('hello');
      expect(container.read(searchQueryProvider), 'hello');
    });

    test('clear resets to empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('hello');
      container.read(searchQueryProvider.notifier).clear();
      expect(container.read(searchQueryProvider), '');
    });
  });

  group('Search filtering in filteredTasksProvider', () {
    test('empty search returns all eligible tasks', () async {
      final tasks = [
        createTask('1', 'Buy groceries'),
        createTask('2', 'Fix the car'),
        createTask('3', 'Call dentist'),
      ];

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
          tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
          sprintsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      final filtered = await readAsyncValue(container, filteredTasksProvider);
      expect(filtered.length, 3);
    });

    test('search filters by name case-insensitively', () async {
      final tasks = [
        createTask('1', 'Buy groceries'),
        createTask('2', 'Fix the car'),
        createTask('3', 'Call dentist'),
      ];

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
          tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
          sprintsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      // Set search query
      container.read(searchQueryProvider.notifier).set('buy');

      final filtered = await readAsyncValue(container, filteredTasksProvider);
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Buy groceries');
    });

    test('search is case-insensitive', () async {
      final tasks = [
        createTask('1', 'Buy Groceries'),
        createTask('2', 'Fix the car'),
      ];

      final container = ProviderContainer(
        overrides: [
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
          tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
          sprintsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).set('GROCERIES');

      final filtered = await readAsyncValue(container, filteredTasksProvider);
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Buy Groceries');
    });
  });
}
