import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Riverpod Sprint Integration Tests', () {
    test('Tasks in active sprint are hidden from task list', () async {
      // Create test data
      final now = DateTime.now().toUtc();
      final task1 = TaskItem((b) => b
        ..docId = 'task1'
        ..name = 'Sprint Task'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task2 = TaskItem((b) => b
        ..docId = 'task2'
        ..name = 'Regular Task'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final sprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now
        ..startDate = now.subtract(Duration(days: 1))
        ..endDate = now.add(Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([
          SprintAssignment((b) => b
            ..docId = 'assign1'
            ..taskDocId = 'task1'
            ..sprintDocId = 'sprint1'),
        ]));

      // Create container with overrides
      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) {
            return Stream.value([task1, task2]);
          }),
          sprintsProvider.overrideWith((ref) {
            return Stream.value([sprint]);
          }),
        ],
      );

      // Wait for streams to emit
      addTearDown(container.dispose);

      // Wait for async providers to load
      await container.read(tasksProvider.future);
      await container.read(sprintsProvider.future);

      // Get filtered tasks
      final filteredTasks = container.read(filteredTasksProvider);

      // Verify: Only task2 should be visible (task1 is in active sprint)
      expect(filteredTasks.length, 1);
      expect(filteredTasks[0].docId, 'task2');
      expect(filteredTasks[0].name, 'Regular Task');
    });

    test('Completed tasks in active sprint are visible when showCompleted is true', () async {
      final now = DateTime.now().toUtc();
      final completedSprintTask = TaskItem((b) => b
        ..docId = 'task1'
        ..name = 'Completed Sprint Task'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = now
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final sprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now
        ..startDate = now.subtract(Duration(days: 1))
        ..endDate = now.add(Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([
          SprintAssignment((b) => b
            ..docId = 'assign1'
            ..taskDocId = 'task1'
            ..sprintDocId = 'sprint1'),
        ]));

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([completedSprintTask])),
          sprintsProvider.overrideWith((ref) => Stream.value([sprint])),
        ],
      );

      addTearDown(container.dispose);

      // Wait for async providers to load
      await container.read(tasksProvider.future);
      await container.read(sprintsProvider.future);

      // Enable show completed
      container.read(showCompletedProvider.notifier).set(true);

      // Get filtered tasks
      final filteredTasks = container.read(filteredTasksProvider);

      // Verify: Completed sprint task should be visible
      expect(filteredTasks.length, 1);
      expect(filteredTasks[0].docId, 'task1');
      expect(filteredTasks[0].name, 'Completed Sprint Task');
      expect(filteredTasks[0].completionDate, isNotNull);
    });

    test('Tasks not in sprint remain visible', () async {
      final now = DateTime.now().toUtc();
      final task1 = TaskItem((b) => b
        ..docId = 'task1'
        ..name = 'Task 1'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task2 = TaskItem((b) => b
        ..docId = 'task2'
        ..name = 'Task 2'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final sprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now
        ..startDate = now.subtract(Duration(days: 1))
        ..endDate = now.add(Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([])); // Empty sprint

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([task1, task2])),
          sprintsProvider.overrideWith((ref) => Stream.value([sprint])),
        ],
      );

      addTearDown(container.dispose);
      await container.read(tasksProvider.future);
      await container.read(sprintsProvider.future);

      final filteredTasks = container.read(filteredTasksProvider);

      // Verify: Both tasks should be visible
      expect(filteredTasks.length, 2);
      expect(filteredTasks.map((t) => t.docId), containsAll(['task1', 'task2']));

      // Disposed in tearDown
    });

    test('Active sprint is correctly identified', () async {
      final now = DateTime.now().toUtc();

      final pastSprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now.subtract(Duration(days: 14))
        ..startDate = now.subtract(Duration(days: 14))
        ..endDate = now.subtract(Duration(days: 7))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([]));

      final activeSprint = Sprint((b) => b
        ..docId = 'sprint2'
        ..dateAdded = now.subtract(Duration(days: 1))
        ..startDate = now.subtract(Duration(days: 1))
        ..endDate = now.add(Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 2
        ..sprintAssignments = ListBuilder([]));

      final futureSprint = Sprint((b) => b
        ..docId = 'sprint3'
        ..dateAdded = now
        ..startDate = now.add(Duration(days: 7))
        ..endDate = now.add(Duration(days: 14))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 3
        ..sprintAssignments = ListBuilder([]));

      final container = ProviderContainer(
        overrides: [
          sprintsProvider.overrideWith((ref) =>
            Stream.value([pastSprint, activeSprint, futureSprint])),
        ],
      );

      addTearDown(container.dispose);
      await container.read(sprintsProvider.future);

      final activeSprintResult = container.read(activeSprintProvider);

      // Verify: Only the current sprint should be active
      expect(activeSprintResult, isNotNull);
      expect(activeSprintResult!.docId, 'sprint2');
      expect(activeSprintResult.sprintNumber, 2);

      // Disposed in tearDown
    });

    test('No active sprint when all sprints are past or future', () async {
      final now = DateTime.now().toUtc();

      final pastSprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now.subtract(Duration(days: 14))
        ..startDate = now.subtract(Duration(days: 14))
        ..endDate = now.subtract(Duration(days: 7))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([]));

      final futureSprint = Sprint((b) => b
        ..docId = 'sprint2'
        ..dateAdded = now
        ..startDate = now.add(Duration(days: 7))
        ..endDate = now.add(Duration(days: 14))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 2
        ..sprintAssignments = ListBuilder([]));

      final container = ProviderContainer(
        overrides: [
          sprintsProvider.overrideWith((ref) =>
            Stream.value([pastSprint, futureSprint])),
        ],
      );

      addTearDown(container.dispose);
      await container.read(sprintsProvider.future);

      final activeSprintResult = container.read(activeSprintProvider);

      // Verify: No active sprint
      expect(activeSprintResult, isNull);

      // Disposed in tearDown
    });

    test('Multiple tasks in sprint are all hidden', () async {
      final now = DateTime.now().toUtc();
      final task1 = TaskItem((b) => b
        ..docId = 'task1'
        ..name = 'Sprint Task 1'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task2 = TaskItem((b) => b
        ..docId = 'task2'
        ..name = 'Sprint Task 2'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final task3 = TaskItem((b) => b
        ..docId = 'task3'
        ..name = 'Regular Task'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final sprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now
        ..startDate = now.subtract(Duration(days: 1))
        ..endDate = now.add(Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([
          SprintAssignment((b) => b
            ..docId = 'assign1'
            ..taskDocId = 'task1'
            ..sprintDocId = 'sprint1'),
          SprintAssignment((b) => b
            ..docId = 'assign2'
            ..taskDocId = 'task2'
            ..sprintDocId = 'sprint1'),
        ]));

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([task1, task2, task3])),
          sprintsProvider.overrideWith((ref) => Stream.value([sprint])),
        ],
      );

      addTearDown(container.dispose);
      await container.read(tasksProvider.future);
      await container.read(sprintsProvider.future);

      final filteredTasks = container.read(filteredTasksProvider);

      // Verify: Only task3 should be visible
      expect(filteredTasks.length, 1);
      expect(filteredTasks[0].docId, 'task3');
      expect(filteredTasks[0].name, 'Regular Task');

      // Disposed in tearDown
    });

    test('Closed sprint does not affect task visibility', () async {
      final now = DateTime.now().toUtc();
      final task1 = TaskItem((b) => b
        ..docId = 'task1'
        ..name = 'Task in closed sprint'
        ..personDocId = 'person1'
        ..dateAdded = now
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      final closedSprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = now.subtract(Duration(days: 7))
        ..startDate = now.subtract(Duration(days: 7))
        ..endDate = now.add(Duration(days: 1)) // Still technically active by date
        ..closeDate = now.subtract(Duration(days: 1)) // But manually closed
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder([
          SprintAssignment((b) => b
            ..docId = 'assign1'
            ..taskDocId = 'task1'
            ..sprintDocId = 'sprint1'),
        ]));

      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([task1])),
          sprintsProvider.overrideWith((ref) => Stream.value([closedSprint])),
        ],
      );

      addTearDown(container.dispose);
      await container.read(tasksProvider.future);
      await container.read(sprintsProvider.future);

      final activeSprintResult = container.read(activeSprintProvider);
      final filteredTasks = container.read(filteredTasksProvider);

      // Verify: No active sprint (closed sprint doesn't count)
      expect(activeSprintResult, isNull);

      // Verify: Task should be visible (not hidden by sprint)
      expect(filteredTasks.length, 1);
      expect(filteredTasks[0].docId, 'task1');

      // Disposed in tearDown
    });
  });
}
