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
  });
}
