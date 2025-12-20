import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/shared/providers/navigation_provider.dart';
import 'package:taskmaster/models/task_item.dart';

/// Tests for TM-312: Task not moving to Completed section in Sprint
///
/// Verifies that recently completed tasks are cleared when navigating
/// between tabs, allowing them to move to the "Completed" section.
void main() {
  group('Recently Completed Task Behavior', () {
    // Helper to create a completed task
    TaskItem createCompletedTask(String docId) {
      final now = DateTime.now().toUtc();
      return TaskItem((b) => b
        ..docId = docId
        ..name = 'Test Task'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = now
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);
    }

    test('recentlyCompleted list is cleared on tab change', () {
      // Arrange: Create container and add a recently completed task
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final task = createCompletedTask('task1');
      container.read(recentlyCompletedTasksProvider.notifier).add(task);

      // Verify task was added
      expect(container.read(recentlyCompletedTasksProvider).length, 1);

      // Act: Simulate tab change
      container.read(activeTabIndexProvider.notifier).setTab(1);

      // Assert: recentlyCompleted should be cleared
      expect(container.read(recentlyCompletedTasksProvider).length, 0);
    });

    test('task stays in recentlyCompleted until tab change', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final task = createCompletedTask('task1');
      container.read(recentlyCompletedTasksProvider.notifier).add(task);

      // Assert: Task should remain until navigation
      expect(container.read(recentlyCompletedTasksProvider).length, 1);
      expect(container.read(recentlyCompletedTasksProvider).first.docId, 'task1');
    });

    test('multiple completed tasks are all cleared on tab change', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Add multiple completed tasks
      container.read(recentlyCompletedTasksProvider.notifier)
        ..add(createCompletedTask('task1'))
        ..add(createCompletedTask('task2'))
        ..add(createCompletedTask('task3'));

      expect(container.read(recentlyCompletedTasksProvider).length, 3);

      // Act: Tab change
      container.read(activeTabIndexProvider.notifier).setTab(2);

      // Assert: All cleared
      expect(container.read(recentlyCompletedTasksProvider).length, 0);
    });

    test('recentlyCompleted is cleared even when switching to same tab', () {
      // Edge case: switching to the same tab should also clear
      // This handles scenarios like refreshing the current view
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final task = createCompletedTask('task1');
      container.read(recentlyCompletedTasksProvider.notifier).add(task);

      // Verify initial state
      expect(container.read(activeTabIndexProvider), 0);
      expect(container.read(recentlyCompletedTasksProvider).length, 1);

      // Act: Switch to tab 0 (same as current)
      container.read(activeTabIndexProvider.notifier).setTab(0);

      // Assert: Should still clear (allows "refresh" behavior)
      expect(container.read(recentlyCompletedTasksProvider).length, 0);
    });
  });
}
