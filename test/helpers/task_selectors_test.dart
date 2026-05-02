import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/helpers/task_selectors.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item.dart';

void main() {
  const personDocId = 'person-1';
  final now = DateTime.utc(2026, 5, 1);
  final sprintEnd = now.add(const Duration(days: 7));

  TaskItem makeTask({
    required String docId,
    required String name,
    String? familyDocId,
    DateTime? completionDate,
  }) {
    return TaskItem((b) => b
      ..docId = docId
      ..name = name
      ..personDocId = personDocId
      ..familyDocId = familyDocId
      ..dateAdded = now
      ..completionDate = completionDate
      ..retired = null
      ..offCycle = false
      ..pendingCompletion = false);
  }

  Sprint makeSprint({
    String docId = 'sprint-1',
    List<SprintAssignment> assignments = const [],
  }) {
    return Sprint((b) => b
      ..docId = docId
      ..dateAdded = now
      ..startDate = now
      ..endDate = sprintEnd
      ..numUnits = 1
      ..unitName = 'Weeks'
      ..personDocId = personDocId
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder(assignments));
  }

  group('taskItemsForPlacingOnNewSprint', () {
    test('excludes family-shared tasks (TM-348)', () {
      // Bug: the planning popup must show only personal tasks. A task with
      // familyDocId set is shared via the Family tab and shouldn't appear
      // in the "Create Sprint" candidate list.
      final personal = makeTask(docId: 't-personal', name: 'Personal');
      final family =
          makeTask(docId: 't-family', name: 'Family', familyDocId: 'fam-1');

      final result = taskItemsForPlacingOnNewSprint(
        BuiltList<TaskItem>([personal, family]),
        sprintEnd,
      );

      expect(result.map((t) => t.docId), ['t-personal']);
    });

    test('keeps personal incomplete tasks scheduled within the sprint', () {
      final personal = makeTask(docId: 't-1', name: 'A');

      final result = taskItemsForPlacingOnNewSprint(
        BuiltList<TaskItem>([personal]),
        sprintEnd,
      );

      expect(result, hasLength(1));
      expect(result.first.docId, 't-1');
    });

    test('still excludes completed tasks (sanity)', () {
      final personal =
          makeTask(docId: 't-done', name: 'Done', completionDate: now);

      final result = taskItemsForPlacingOnNewSprint(
        BuiltList<TaskItem>([personal]),
        sprintEnd,
      );

      expect(result, isEmpty);
    });
  });

  group('taskItemsForPlacingOnExistingSprint', () {
    test('excludes family-shared tasks (TM-348)', () {
      final personal = makeTask(docId: 't-personal', name: 'Personal');
      final family =
          makeTask(docId: 't-family', name: 'Family', familyDocId: 'fam-1');
      final sprint = makeSprint();

      final result = taskItemsForPlacingOnExistingSprint(
        BuiltList<TaskItem>([personal, family]),
        sprint,
      );

      expect(result.map((t) => t.docId), ['t-personal']);
    });

    test('keeps personal tasks not yet assigned to the sprint', () {
      final personal = makeTask(docId: 't-1', name: 'A');
      final sprint = makeSprint();

      final result = taskItemsForPlacingOnExistingSprint(
        BuiltList<TaskItem>([personal]),
        sprint,
      );

      expect(result, hasLength(1));
      expect(result.first.docId, 't-1');
    });

    test('still excludes tasks already assigned to the sprint (sanity)', () {
      final assigned = makeTask(docId: 't-assigned', name: 'Already');
      final sprint = makeSprint(assignments: [
        SprintAssignment((b) => b
          ..docId = 'a-1'
          ..taskDocId = 't-assigned'
          ..sprintDocId = 'sprint-1'),
      ]);

      final result = taskItemsForPlacingOnExistingSprint(
        BuiltList<TaskItem>([assigned]),
        sprint,
      );

      expect(result, isEmpty);
    });
  });

  group('recurrencePreviewSeedTasksForSprint', () {
    test('excludes a family-shared task already in the sprint (TM-348)', () {
      // Regression test for the second flavor of the bug: a legacy
      // family-shared recurring task in a personal sprint would still
      // generate next-iteration previews via TaskItem.createNextRecurPreview
      // (which preserves familyDocId), and those previews leak into the
      // "Add Tasks to Sprint…" picker. Filter at the seed list so the
      // preview chain never starts for family tasks.
      final personal = makeTask(docId: 't-personal', name: 'Personal');
      final family = makeTask(
          docId: 't-family', name: 'Family', familyDocId: 'fam-1');
      final sprint = makeSprint(assignments: [
        SprintAssignment((b) => b
          ..docId = 'a-1'
          ..taskDocId = 't-personal'
          ..sprintDocId = 'sprint-1'),
        SprintAssignment((b) => b
          ..docId = 'a-2'
          ..taskDocId = 't-family'
          ..sprintDocId = 'sprint-1'),
      ]);

      final result = recurrencePreviewSeedTasksForSprint(
        BuiltList<TaskItem>([personal, family]),
        sprint,
      );

      expect(result.map((t) => t.docId), ['t-personal']);
    });

    test('keeps personal tasks already in the sprint (sanity)', () {
      final personal = makeTask(docId: 't-1', name: 'Personal');
      final sprint = makeSprint(assignments: [
        SprintAssignment((b) => b
          ..docId = 'a-1'
          ..taskDocId = 't-1'
          ..sprintDocId = 'sprint-1'),
      ]);

      final result = recurrencePreviewSeedTasksForSprint(
        BuiltList<TaskItem>([personal]),
        sprint,
      );

      expect(result.map((t) => t.docId), ['t-1']);
    });
  });

  // (No standalone test for TaskItem.createNextRecurPreview's familyDocId
  // propagation — exercising it cleanly requires a full TaskRecurrence
  // setup. The propagation is documented on
  // [recurrencePreviewSeedTasksForSprint], which is the chokepoint that
  // makes the leak unobservable in the picker.)
}
