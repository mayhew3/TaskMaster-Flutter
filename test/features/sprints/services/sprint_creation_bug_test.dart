import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/features/sprints/services/sprint_service.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';

/// TM-325: Tests for sprint creation bug fixes
///
/// Bug: Sprint creation is slow (10-15 seconds) and only shows 1-3 tasks until refresh.
///
/// Root Causes:
/// 1. Missing invalidation - CreateSprint notifier doesn't call ref.invalidate(sprintsProvider)
/// 2. Sequential writes - Sprint assignments are written one-by-one with await in a loop
///
/// Solution: Use Firestore WriteBatch for atomic commits - all documents (recurrences,
/// tasks, sprint, assignments) are created in a single batch.commit() call, triggering
/// only ONE snapshot update instead of N updates.

import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

void main() {
  group('TM-325: Sprint Creation Bug Fixes', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SprintService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = SprintService(fakeFirestore);
    });

    group('Parallel Assignment Writes', () {
      test('All tasks should have assignments created in createSprintWithTasks', () async {
        // Create test tasks
        final now = DateTime.now().toUtc();
        final tasks = List.generate(30, (i) {
          return TaskItem((b) => b
            ..docId = 'task$i'
            ..name = 'Task $i'
            ..personDocId = 'test-person'
            ..dateAdded = now
            ..offCycle = false
            ..pendingCompletion = false);
        });

        // Add tasks to Firestore
        for (var task in tasks) {
          await fakeFirestore.collection('tasks').doc(task.docId).set({
            'docId': task.docId,
            'name': task.name,
            'personDocId': task.personDocId,
            'dateAdded': task.dateAdded,
          });
        }

        final blueprint = SprintBlueprint(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        // Create sprint with 30 tasks
        final sprint = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: tasks,
          taskItemRecurPreviews: [],
        );

        // Verify all 30 assignments were created
        expect(sprint.sprintAssignments.length, equals(30),
            reason: 'All 30 task assignments should be created');

        // Verify each task has an assignment
        final assignedTaskIds =
            sprint.sprintAssignments.map((a) => a.taskDocId).toSet();
        for (var task in tasks) {
          expect(assignedTaskIds.contains(task.docId), isTrue,
              reason: 'Task ${task.docId} should have an assignment');
        }

        // Also verify directly in Firestore
        final assignmentsSnapshot = await fakeFirestore
            .collection('sprints')
            .doc(sprint.docId)
            .collection('sprintAssignments')
            .get();
        expect(assignmentsSnapshot.docs.length, equals(30),
            reason: 'Firestore should have 30 assignment documents');
      });

      test('addTasksToSprint should create all assignments', () async {
        // First create a sprint without tasks
        final blueprint = SprintBlueprint(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        final sprint = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: [],
          taskItemRecurPreviews: [],
        );

        expect(sprint.sprintAssignments.length, equals(0),
            reason: 'Sprint should start with 0 assignments');

        // Create test tasks
        final now = DateTime.now().toUtc();
        final tasks = List.generate(20, (i) {
          return TaskItem((b) => b
            ..docId = 'task$i'
            ..name = 'Task $i'
            ..personDocId = 'test-person'
            ..dateAdded = now
            ..offCycle = false
            ..pendingCompletion = false);
        });

        // Add tasks to sprint
        await service.addTasksToSprint(
          sprint: sprint,
          taskItems: tasks,
          taskItemRecurPreviews: [],
        );

        // Verify all 20 assignments were created in Firestore
        final assignmentsSnapshot = await fakeFirestore
            .collection('sprints')
            .doc(sprint.docId)
            .collection('sprintAssignments')
            .get();
        expect(assignmentsSnapshot.docs.length, equals(20),
            reason: 'Firestore should have 20 assignment documents after addTasksToSprint');
      });
    });

    group('Provider Invalidation', () {
      test('CreateSprint should invalidate sprintsProvider after creation', () async {
        // Track whether sprintsProvider was invalidated
        var invalidationCount = 0;

        final container = ProviderContainer(
          overrides: [
            firestoreProvider.overrideWithValue(fakeFirestore),
            // Override sprintsProvider with a custom provider that tracks invalidation
            sprintsProvider.overrideWith((ref) {
              ref.onDispose(() {
                invalidationCount++;
              });
              return Stream.value(<Sprint>[]);
            }),
          ],
        );

        addTearDown(container.dispose);

        // Read the sprintsProvider to establish it
        await container.read(sprintsProvider.future);
        final initialInvalidationCount = invalidationCount;

        // Create a sprint using the notifier
        final createSprint = container.read(createSprintProvider.notifier);
        await createSprint.call(
          sprintBlueprint: SprintBlueprint(
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 7)),
            numUnits: 1,
            unitName: 'Weeks',
            personDocId: 'test-person',
          ),
          taskItems: [],
          taskItemRecurPreviews: [],
        );

        // The sprintsProvider should have been invalidated
        // When a provider is invalidated, it gets disposed and recreated
        expect(invalidationCount, greaterThan(initialInvalidationCount),
            reason: 'sprintsProvider should be invalidated after sprint creation');
      });
    });

    group('WriteBatch Atomic Commits', () {
      test('createSprintWithTasks creates all documents atomically', () async {
        // Create existing tasks
        final now = DateTime.now().toUtc();
        final existingTasks = List.generate(5, (i) {
          return TaskItem((b) => b
            ..docId = 'existing-task-$i'
            ..name = 'Existing Task $i'
            ..personDocId = 'test-person'
            ..dateAdded = now
            ..offCycle = false
            ..pendingCompletion = false);
        });

        // Create recurrence previews (these will create new tasks + recurrences)
        final recurPreviews = List.generate(3, (i) {
          return TaskItemRecurPreview('Recurring Task $i')
            ..personDocId = 'test-person'
            ..gamePoints = 5
            ..recurNumber = 1
            ..recurUnit = 'Weeks'
            ..recurWait = false
            ..recurrence = TaskRecurrenceBlueprint();
        });

        final blueprint = SprintBlueprint(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        // Create sprint with both existing tasks and recurrence previews
        final sprint = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: existingTasks,
          taskItemRecurPreviews: recurPreviews,
        );

        // Verify sprint was created
        expect(sprint.docId, isNotEmpty);
        expect(sprint.sprintNumber, equals(1));

        // Verify all 8 assignments were created (5 existing + 3 from recurrences)
        expect(sprint.sprintAssignments.length, equals(8),
            reason: 'Should have 8 assignments (5 existing + 3 new from recurrences)');

        // Verify recurrence documents were created
        final recurrencesSnapshot =
            await fakeFirestore.collection('taskRecurrences').get();
        expect(recurrencesSnapshot.docs.length, equals(3),
            reason: 'Should have 3 recurrence documents');

        // Verify new task documents were created for recurrence previews
        final tasksSnapshot = await fakeFirestore.collection('tasks').get();
        expect(tasksSnapshot.docs.length, equals(3),
            reason: 'Should have 3 new task documents from recurrence previews');

        // Verify sprint document exists in Firestore
        final sprintDoc =
            await fakeFirestore.collection('sprints').doc(sprint.docId).get();
        expect(sprintDoc.exists, isTrue);

        // Verify assignments exist in Firestore subcollection
        final assignmentsSnapshot = await fakeFirestore
            .collection('sprints')
            .doc(sprint.docId)
            .collection('sprintAssignments')
            .get();
        expect(assignmentsSnapshot.docs.length, equals(8));
      });

      test('returned Sprint contains all data without read-back', () async {
        // This test verifies that the Sprint object returned from createSprintWithTasks
        // has all data populated locally without requiring additional Firestore reads

        final now = DateTime.now().toUtc();
        final tasks = List.generate(10, (i) {
          return TaskItem((b) => b
            ..docId = 'task-$i'
            ..name = 'Task $i'
            ..personDocId = 'test-person'
            ..dateAdded = now
            ..offCycle = false
            ..pendingCompletion = false);
        });

        final blueprint = SprintBlueprint(
          startDate: DateTime(2026, 1, 20, 9, 0),
          endDate: DateTime(2026, 1, 27, 17, 0),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        final sprint = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: tasks,
          taskItemRecurPreviews: [],
        );

        // Verify Sprint has valid docId (generated before batch commit)
        expect(sprint.docId, isNotEmpty);
        expect(sprint.docId, isNot(equals('null')));

        // Verify Sprint has correct data from blueprint
        expect(sprint.numUnits, equals(1));
        expect(sprint.unitName, equals('Weeks'));
        expect(sprint.personDocId, equals('test-person'));
        expect(sprint.sprintNumber, equals(1));

        // Verify each assignment has required fields populated
        expect(sprint.sprintAssignments.length, equals(10));
        for (var i = 0; i < sprint.sprintAssignments.length; i++) {
          final assignment = sprint.sprintAssignments[i];
          expect(assignment.docId, isNotEmpty,
              reason: 'Assignment $i should have docId');
          expect(assignment.taskDocId, isNotEmpty,
              reason: 'Assignment $i should have taskDocId');
          expect(assignment.sprintDocId, equals(sprint.docId),
              reason: 'Assignment $i should reference parent sprint');
        }
      });

      test('recurrence previews with recurrenceBlueprint create linked documents', () async {
        // Create a recurrence preview with a recurrence blueprint
        final recurPreview = TaskItemRecurPreview('Weekly Task')
          ..personDocId = 'test-person'
          ..gamePoints = 10
          ..recurNumber = 1
          ..recurUnit = 'Weeks'
          ..recurWait = false
          ..recurrence = TaskRecurrenceBlueprint();

        final blueprint = SprintBlueprint(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        final sprint = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: [],
          taskItemRecurPreviews: [recurPreview],
        );

        // Verify task was created
        final tasksSnapshot = await fakeFirestore.collection('tasks').get();
        expect(tasksSnapshot.docs.length, equals(1));

        final taskDoc = tasksSnapshot.docs.first;
        final taskData = taskDoc.data();

        // Verify task has recurrenceDocId linking to recurrence document
        expect(taskData['recurrenceDocId'], isNotNull,
            reason: 'Task should have recurrenceDocId');

        // Verify recurrence document exists
        final recurrenceDocId = taskData['recurrenceDocId'] as String;
        final recurrenceDoc = await fakeFirestore
            .collection('taskRecurrences')
            .doc(recurrenceDocId)
            .get();
        expect(recurrenceDoc.exists, isTrue,
            reason: 'Recurrence document should exist');

        // Verify assignment links to the new task
        expect(sprint.sprintAssignments.length, equals(1));
        expect(sprint.sprintAssignments.first.taskDocId, equals(taskDoc.id));
      });

      test('sprint number increments correctly', () async {
        final blueprint = SprintBlueprint(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        // Create first sprint
        final sprint1 = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: [],
          taskItemRecurPreviews: [],
        );
        expect(sprint1.sprintNumber, equals(1));

        // Create second sprint
        final sprint2 = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: [],
          taskItemRecurPreviews: [],
        );
        expect(sprint2.sprintNumber, equals(2));

        // Create third sprint
        final sprint3 = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: [],
          taskItemRecurPreviews: [],
        );
        expect(sprint3.sprintNumber, equals(3));
      });

      test('addTasksToSprint uses batch for all operations', () async {
        // Create initial sprint
        final blueprint = SprintBlueprint(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          numUnits: 1,
          unitName: 'Weeks',
          personDocId: 'test-person',
        );

        final sprint = await service.createSprintWithTasks(
          sprintBlueprint: blueprint,
          taskItems: [],
          taskItemRecurPreviews: [],
        );

        // Create existing tasks and recurrence previews to add
        final now = DateTime.now().toUtc();
        final existingTasks = List.generate(3, (i) {
          return TaskItem((b) => b
            ..docId = 'add-task-$i'
            ..name = 'Added Task $i'
            ..personDocId = 'test-person'
            ..dateAdded = now
            ..offCycle = false
            ..pendingCompletion = false);
        });

        final recurPreviews = List.generate(2, (i) {
          return TaskItemRecurPreview('Added Recurring $i')
            ..personDocId = 'test-person'
            ..gamePoints = 5
            ..recurNumber = 1
            ..recurUnit = 'Days'
            ..recurWait = false
            ..recurrence = TaskRecurrenceBlueprint();
        });

        // Add tasks to sprint
        await service.addTasksToSprint(
          sprint: sprint,
          taskItems: existingTasks,
          taskItemRecurPreviews: recurPreviews,
        );

        // Verify recurrence documents were created
        final recurrencesSnapshot =
            await fakeFirestore.collection('taskRecurrences').get();
        expect(recurrencesSnapshot.docs.length, equals(2),
            reason: 'Should have 2 recurrence documents');

        // Verify new task documents were created
        final tasksSnapshot = await fakeFirestore.collection('tasks').get();
        expect(tasksSnapshot.docs.length, equals(2),
            reason: 'Should have 2 task documents from recurrence previews');

        // Verify all 5 assignments exist (3 existing + 2 from recurrences)
        final assignmentsSnapshot = await fakeFirestore
            .collection('sprints')
            .doc(sprint.docId)
            .collection('sprintAssignments')
            .get();
        expect(assignmentsSnapshot.docs.length, equals(5),
            reason: 'Should have 5 assignments total');
      });
    });
  });
}
