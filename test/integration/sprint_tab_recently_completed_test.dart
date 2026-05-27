import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_grouped_tasks_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';

import '../helpers/async_provider_helpers.dart';

/// Tests for TM-339: Sprint screen - completed task behavior
///
/// Verifies:
///  - A just-completed task stays visible (does not disappear) while it
///    is still in the recently-completed set.
///  - Older completed tasks flow through the provider so the TaskItemList
///    groups them into the "Completed" section at the bottom.
///
/// NOTE: the original TM-339 sprint-assignment-order stability contract
/// was retired in TM-359. `sprintGroupedTasks` re-buckets + sorts by the
/// surface's group/sort axes before rendering, so `sprintTaskItems` no
/// longer guarantees any particular order — these tests only assert
/// membership / visibility, never sequence.
/// TM-359 migration: the Sprint surface's "showCompleted" toggle moved
/// from the old `showCompletedInSprintProvider` into membership of the
/// `TaskFilters.dueStatus` whitelist. `value = true` means "include the
/// Completed bucket in the visible set"; `value = false` means "exclude
/// it." Empty whitelist = no filter applied = everything visible.
/// Mirrors the production `_toggleBucket` normalization: a full
/// 6-of-6 whitelist collapses back to the empty "show all" sentinel so
/// the helper produces the same canonical state production code would.
void _setShowCompleted(ProviderContainer container, bool value) {
  final notifier = container
      .read(taskListViewStateProvider(TaskListSurface.sprint).notifier);
  final current =
      container.read(taskListViewStateProvider(TaskListSurface.sprint));
  final set = current.filters.dueStatus;
  Set<DueStatusBucket> next;
  if (value) {
    if (set.isEmpty || set.contains(DueStatusBucket.completed)) return;
    next = {...set, DueStatusBucket.completed};
  } else {
    if (set.isEmpty) {
      next = DueStatusBucket.values
          .where((b) => b != DueStatusBucket.completed)
          .toSet();
    } else if (set.contains(DueStatusBucket.completed)) {
      next = {...set}..remove(DueStatusBucket.completed);
    } else {
      return;
    }
  }
  if (next.length == DueStatusBucket.values.length) {
    next = <DueStatusBucket>{};
  }
  notifier.setFilters(
    current.filters.rebuild((b) => b..dueStatus.replace(next)),
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
