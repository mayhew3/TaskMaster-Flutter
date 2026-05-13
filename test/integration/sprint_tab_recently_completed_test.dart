import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';

import '../helpers/async_provider_helpers.dart';

/// Tests for TM-339: Sprint screen - completed task behavior
///
/// Verifies:
///  - A just-completed task stays visible and in its original sprint
///    assignment position (does not jump to the end of its group).
///  - Older completed tasks flow through the provider so the TaskItemList
///    groups them into the "Completed" section at the bottom.
///  - Ordering is determined by sprint.sprintAssignments so completions
///    do not reshuffle the list.
/// TM-359 migration: the Sprint surface's "showCompleted" toggle moved
/// from the old `showCompletedInSprintProvider` to the new shared
/// `TaskFilters.showCompleted` axis (per-surface via
/// `taskListViewStateProvider`). This helper sets that flag on the
/// Sprint surface's TaskListView.
void _setShowCompleted(ProviderContainer container, bool value) {
  final notifier = container
      .read(taskListViewStateProvider(TaskListSurface.sprint).notifier);
  final current =
      container.read(taskListViewStateProvider(TaskListSurface.sprint));
  notifier.setFilters(
    current.filters.rebuild((b) => b..showCompleted = value),
  );
}

void main() {
  // Clear persisted TaskListView state between tests so an earlier
  // `showCompleted=false` doesn't leak across test boundaries.
  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  group('Sprint Screen Recently Completed Behavior (TM-339)', () {
    final now = DateTime.now().toUtc();

    TaskItem createTask(
      String docId, {
      DateTime? completionDate,
      DateTime? urgentDate,
    }) {
      return TaskItem((b) => b
        ..docId = docId
        ..name = 'Test Task $docId'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = completionDate
        ..urgentDate = urgentDate
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);
    }

    Sprint createSprintWithTasks(List<String> taskDocIds) {
      return Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now
        ..startDate = now.subtract(const Duration(days: 1))
        ..endDate = now.add(const Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder(
          taskDocIds.asMap().entries.map(
                (entry) => SprintAssignment((sa) => sa
                  ..docId = 'assign${entry.key}'
                  ..taskDocId = entry.value
                  ..sprintDocId = 'sprint1'),
              ),
        ));
    }

    test(
        'recently completed task stays visible when showCompletedInSprint=false',
        () async {
      // The TM-339 bug case: user toggles showCompleted off, then completes
      // a task — it should stay visible briefly, not disappear.
      final completedTask = createTask('task1', completionDate: now);
      final sprint = createSprintWithTasks(['task1']);

      final container = ProviderContainer(
        overrides: [
          // sprintAllTasks streams incomplete + completed; simulate a state
          // where the Drift stream hasn't yet included the just-completed
          // task (write still in flight).
          sprintAllTasksProvider(sprint).overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(recentlyCompletedTasksProvider.notifier)
          .add(completedTask);
      _setShowCompleted(container, false);

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.length, 1);
      expect(result.first.docId, 'task1');
    });

    test(
        'recently completed task stays visible when showCompletedInSprint=true',
        () async {
      final completedTask = createTask('task1', completionDate: now);
      final sprint = createSprintWithTasks(['task1']);

      final container = ProviderContainer(
        overrides: [
          sprintAllTasksProvider(sprint).overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(recentlyCompletedTasksProvider.notifier)
          .add(completedTask);
      // showCompletedInSprint defaults to true

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.length, 1);
      expect(result.first.docId, 'task1');
    });

    test(
        'older completed task flows through the provider when showCompleted=true',
        () async {
      // After navigation clears recentlyCompleted, an older completed task
      // must still appear so it can render in the "Completed" section.
      final completedTask = createTask('task1', completionDate: now);
      final sprint = createSprintWithTasks(['task1']);

      final container = ProviderContainer(
        overrides: [
          sprintAllTasksProvider(sprint)
              .overrideWith((ref) => Stream.value([completedTask])),
        ],
      );
      addTearDown(container.dispose);
      // showCompletedInSprint defaults to true; recentlyCompleted empty.

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.length, 1);
      expect(result.first.docId, 'task1');
    });

    test('older completed task is hidden when showCompletedInSprint=false',
        () async {
      final completedTask = createTask('task1', completionDate: now);
      final sprint = createSprintWithTasks(['task1']);

      final container = ProviderContainer(
        overrides: [
          sprintAllTasksProvider(sprint)
              .overrideWith((ref) => Stream.value([completedTask])),
        ],
      );
      addTearDown(container.dispose);

      _setShowCompleted(container, false);

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.length, 0);
    });

    test('order matches sprint.sprintAssignments regardless of completion',
        () async {
      // Stability check: assignment order is [a, b, c]. Completing b should
      // not move it to the end.
      final a = createTask('a');
      final b = createTask('b', completionDate: now); // just completed
      final c = createTask('c');
      final sprint = createSprintWithTasks(['a', 'b', 'c']);

      final container = ProviderContainer(
        overrides: [
          // Drift stream still includes b as completed
          sprintAllTasksProvider(sprint)
              .overrideWith((ref) => Stream.value([a, b, c])),
        ],
      );
      addTearDown(container.dispose);

      container.read(recentlyCompletedTasksProvider.notifier).add(b);

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.map((t) => t.docId).toList(), ['a', 'b', 'c']);
    });

    test(
        'position is preserved even when Drift has not yet emitted the completion',
        () async {
      // Race window: task was completed, Firestore write is in flight.
      // Drift stream still has b as incomplete; recentlyCompleted has the
      // completed copy of b. The provider should merge without reshuffling.
      final a = createTask('a');
      final bIncomplete = createTask('b'); // old state in Drift stream
      final bCompleted = createTask('b', completionDate: now); // in recentlyCompleted
      final c = createTask('c');
      final sprint = createSprintWithTasks(['a', 'b', 'c']);

      final container = ProviderContainer(
        overrides: [
          sprintAllTasksProvider(sprint)
              .overrideWith((ref) => Stream.value([a, bIncomplete, c])),
        ],
      );
      addTearDown(container.dispose);

      container.read(recentlyCompletedTasksProvider.notifier).add(bCompleted);

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.map((t) => t.docId).toList(), ['a', 'b', 'c']);
    });

    test('multiple recently completed tasks all stay visible', () async {
      final task1 = createTask('task1', completionDate: now);
      final task2 = createTask('task2', completionDate: now);
      final task3 = createTask('task3', completionDate: now);
      final sprint = createSprintWithTasks(['task1', 'task2', 'task3']);

      final container = ProviderContainer(
        overrides: [
          sprintAllTasksProvider(sprint).overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      container.read(recentlyCompletedTasksProvider.notifier)
        ..add(task1)
        ..add(task2)
        ..add(task3);
      _setShowCompleted(container, false);

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.length, 3);
    });

    test('recently completed tasks NOT in sprint are not included', () async {
      final sprintTask = createTask('task1', completionDate: now);
      final otherTask = createTask('task2', completionDate: now);
      final sprint = createSprintWithTasks(['task1']);

      final container = ProviderContainer(
        overrides: [
          sprintAllTasksProvider(sprint).overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      container.read(recentlyCompletedTasksProvider.notifier)
        ..add(sprintTask)
        ..add(otherTask);

      final result = await readAsyncValue(container, sprintTaskItemsProvider(sprint));

      expect(result.length, 1);
      expect(result.first.docId, 'task1');
    });
  });
}
