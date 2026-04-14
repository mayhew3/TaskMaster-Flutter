import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaster/features/shared/providers/navigation_provider.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/models/task_item.dart';

/// Tests for TM-323: Tasks tab - completed task should temporarily stay
///
/// Verifies that when a task is completed on the Tasks tab:
/// 1. It stays visible in its original category (not immediately hidden)
/// 2. It moves to "Completed" section only after navigating away and back
void main() {
  group('Tasks Tab Recently Completed Behavior (TM-323)', () {
    // Helper to create a task
    TaskItem createTask(
      String docId, {
      DateTime? completionDate,
      DateTime? urgentDate,
      DateTime? targetDate,
    }) {
      final now = DateTime.now().toUtc();
      return TaskItem((b) => b
        ..docId = docId
        ..name = 'Test Task $docId'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = completionDate
        ..urgentDate = urgentDate
        ..targetDate = targetDate
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);
    }

    test('recently completed task is included in filteredTasks even when showCompleted=false', () async {
      // Arrange: Create a completed task and add to recently completed
      final completedTask = createTask('task1', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          // Mock tasks to return our completed task
          tasksWithPendingStateProvider.overrideWith((ref) async => [completedTask]),
          // No active sprint
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Add to recently completed list
      container.read(recentlyCompletedTasksProvider.notifier).add(completedTask);

      // Ensure showCompleted is false (default)
      expect(container.read(showCompletedProvider), false);

      // Act: Get filtered tasks
      final filtered = await container.read(filteredTasksProvider.future);

      // Assert: Task should be included because it's recently completed
      expect(filtered.length, 1);
      expect(filtered.first.docId, 'task1');
    });

    test('completed task is excluded from filteredTasks when NOT recently completed and showCompleted=false', () async {
      // Arrange: Create a completed task but don't add to recently completed
      final completedTask = createTask('task1', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => [completedTask]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Don't add to recently completed
      expect(container.read(showCompletedProvider), false);

      // Act: Get filtered tasks
      final filtered = await container.read(filteredTasksProvider.future);

      // Assert: Task should be excluded
      expect(filtered.length, 0);
    });

    test('recently completed task stays in original group, not Completed section', () async {
      // Arrange: Create a task that was "Urgent" before completion
      final urgentDate = DateTime.now().subtract(const Duration(hours: 1));
      final completedTask = createTask(
        'task1',
        completionDate: DateTime.now(),
        urgentDate: urgentDate,
      );

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => [completedTask]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Add to recently completed
      container.read(recentlyCompletedTasksProvider.notifier).add(completedTask);

      // Act: Get grouped tasks
      final groups = await container.read(groupedTasksProvider.future);

      // Assert: Task should be in "Urgent" group (past urgent date), NOT in "Completed"
      final urgentGroup = groups.where((g) => g.name == 'Urgent').firstOrNull;
      final completedGroup = groups.where((g) => g.name == 'Completed').firstOrNull;

      expect(urgentGroup, isNotNull);
      expect(urgentGroup!.tasks.length, 1);
      expect(urgentGroup.tasks.first.docId, 'task1');

      // Completed group should not exist or be empty
      expect(completedGroup, isNull);
    });

    test('task moves to Completed section after tab navigation clears recentlyCompleted', () async {
      // Arrange: Create a completed task
      final completedTask = createTask('task1', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => [completedTask]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Add to recently completed and enable showCompleted to see the Completed section
      container.read(recentlyCompletedTasksProvider.notifier).add(completedTask);
      container.read(showCompletedProvider.notifier).set(true);

      // Verify task is NOT in Completed group yet
      var groups = await container.read(groupedTasksProvider.future);
      var completedGroup = groups.where((g) => g.name == 'Completed').firstOrNull;
      expect(completedGroup, isNull); // Not in Completed yet

      // Act: Simulate tab navigation (clears recently completed)
      container.read(activeTabIndexProvider.notifier).setTab(1);

      // Invalidate the provider to get fresh data
      container.invalidate(groupedTasksProvider);

      // Assert: Task should now be in Completed section
      groups = await container.read(groupedTasksProvider.future);
      completedGroup = groups.where((g) => g.name == 'Completed').firstOrNull;

      expect(completedGroup, isNotNull);
      expect(completedGroup!.tasks.length, 1);
      expect(completedGroup.tasks.first.docId, 'task1');
    });

    test('task disappears after tab navigation when showCompleted=false', () async {
      // Arrange: Create a completed task
      final completedTask = createTask('task1', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => [completedTask]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Add to recently completed, keep showCompleted=false
      container.read(recentlyCompletedTasksProvider.notifier).add(completedTask);
      expect(container.read(showCompletedProvider), false);

      // Verify task is visible initially (because recently completed)
      var filtered = await container.read(filteredTasksProvider.future);
      expect(filtered.length, 1);

      // Act: Simulate tab navigation
      container.read(activeTabIndexProvider.notifier).setTab(1);
      container.invalidate(filteredTasksProvider);

      // Assert: Task should now be hidden (showCompleted=false and not recently completed)
      filtered = await container.read(filteredTasksProvider.future);
      expect(filtered.length, 0);
    });

    test('multiple recently completed tasks all stay visible until tab change', () async {
      // Arrange: Create multiple completed tasks
      final task1 = createTask('task1', completionDate: DateTime.now());
      final task2 = createTask('task2', completionDate: DateTime.now());
      final task3 = createTask('task3', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => [task1, task2, task3]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Add all to recently completed
      container.read(recentlyCompletedTasksProvider.notifier)
        ..add(task1)
        ..add(task2)
        ..add(task3);

      // Verify all are visible
      var filtered = await container.read(filteredTasksProvider.future);
      expect(filtered.length, 3);

      // Act: Tab change
      container.read(activeTabIndexProvider.notifier).setTab(1);
      container.invalidate(filteredTasksProvider);

      // Assert: All should disappear
      filtered = await container.read(filteredTasksProvider.future);
      expect(filtered.length, 0);
    });

    test('uncompleting a recently completed task removes it from recentlyCompleted list', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final task = createTask('task1', completionDate: DateTime.now());
      container.read(recentlyCompletedTasksProvider.notifier).add(task);
      expect(container.read(recentlyCompletedTasksProvider).length, 1);

      // Act: Remove from recently completed (simulates uncomplete action)
      container.read(recentlyCompletedTasksProvider.notifier).remove(task);

      // Assert
      expect(container.read(recentlyCompletedTasksProvider).length, 0);
    });

    test(
        'recently completed task is re-inserted at its captured index, not appended',
        () async {
      // Position-preservation case (TM-339 Tasks tab follow-up): task at
      // index 1 in the base list is completed. After the Firestore write
      // it's removed from the base query; the merge in filteredTasksProvider
      // should re-insert it at index 1, not append at the end.
      final a = createTask('a', urgentDate: DateTime.now().subtract(const Duration(hours: 3)));
      final c = createTask('c', urgentDate: DateTime.now().subtract(const Duration(hours: 1)));

      final container = ProviderContainer(
        overrides: [
          // Base query has already dropped b (completion propagated)
          tasksWithPendingStateProvider.overrideWith((ref) async => [a, c]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // b was at index 1 when completed
      final bCompleted = createTask('b',
          urgentDate: DateTime.now().subtract(const Duration(hours: 2)),
          completionDate: DateTime.now());
      container.read(recentlyCompletedTasksProvider.notifier).add(bCompleted);
      container.read(recentlyCompletedIndicesProvider.notifier).set('b', 1);

      final filtered = await container.read(filteredTasksProvider.future);

      expect(filtered.map((t) => t.docId).toList(), ['a', 'b', 'c'],
          reason: 'b should be re-inserted at index 1, not appended');
    });

    test(
        'multiple recently-completed tasks are inserted in original-index order',
        () async {
      // Sanity: complete tasks at indices 0 and 2 in sequence — result
      // should still be [0, 1, 2] order.
      final b = createTask('b', urgentDate: DateTime.now().subtract(const Duration(hours: 2)));

      final container = ProviderContainer(
        overrides: [
          // Both a and c removed from base after completion
          tasksWithPendingStateProvider.overrideWith((ref) async => [b]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      final aCompleted = createTask('a',
          urgentDate: DateTime.now().subtract(const Duration(hours: 3)),
          completionDate: DateTime.now());
      final cCompleted = createTask('c',
          urgentDate: DateTime.now().subtract(const Duration(hours: 1)),
          completionDate: DateTime.now());
      container.read(recentlyCompletedTasksProvider.notifier)
        ..add(aCompleted)
        ..add(cCompleted);
      container.read(recentlyCompletedIndicesProvider.notifier)
        ..set('a', 0)
        ..set('c', 2);

      final filtered = await container.read(filteredTasksProvider.future);

      expect(filtered.map((t) => t.docId).toList(), ['a', 'b', 'c']);
    });

    test(
        'recently completed task without captured index falls back to append',
        () async {
      // If the index side table is empty (e.g. legacy path, or cleared),
      // behavior falls back to appending at the end (safe default).
      final a = createTask('a');
      final b = createTask('b', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => [a]),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      container.read(recentlyCompletedTasksProvider.notifier).add(b);
      // Deliberately don't set an index — simulate fallback.
      container.read(showCompletedProvider.notifier).set(true);

      final filtered = await container.read(filteredTasksProvider.future);

      expect(filtered.length, 2);
      expect(filtered.last.docId, 'b',
          reason: 'without captured index, b should be appended');
    });

    test('tab navigation clears captured indices alongside recentlyCompleted',
        () async {
      final a = createTask('a', completionDate: DateTime.now());

      final container = ProviderContainer(
        overrides: [
          tasksWithPendingStateProvider.overrideWith((ref) async => []),
          activeSprintProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      container.read(recentlyCompletedTasksProvider.notifier).add(a);
      container.read(recentlyCompletedIndicesProvider.notifier).set('a', 5);

      expect(container.read(recentlyCompletedIndicesProvider).length, 1);

      container.read(activeTabIndexProvider.notifier).setTab(1);

      expect(container.read(recentlyCompletedIndicesProvider).length, 0,
          reason: 'setTab should clear the index side table too');
    });
  });
}
