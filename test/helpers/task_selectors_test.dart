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
    DateTime? startDate,
  }) {
    return TaskItem((b) => b
      ..docId = docId
      ..name = name
      ..personDocId = personDocId
      ..familyDocId = familyDocId
      ..dateAdded = now
      ..completionDate = completionDate
      ..startDate = startDate
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
      final personal = makeTask(
        docId: 't-1',
        name: 'A',
        startDate: now.add(const Duration(days: 2)),
      );

      final result = taskItemsForPlacingOnNewSprint(
        BuiltList<TaskItem>([personal]),
        sprintEnd,
      );

      expect(result, hasLength(1));
      expect(result.first.docId, 't-1');
    });

    test('excludes tasks scheduled after the sprint end date (sanity)', () {
      // Boundary coverage for the isScheduledAfter predicate. The "in" task
      // starts during the sprint window; the "out" task starts after the
      // sprint ends and must be filtered.
      final inWindow = makeTask(
        docId: 't-in',
        name: 'In',
        startDate: now.add(const Duration(days: 2)),
      );
      final afterEnd = makeTask(
        docId: 't-out',
        name: 'Out',
        startDate: sprintEnd.add(const Duration(days: 1)),
      );

      final result = taskItemsForPlacingOnNewSprint(
        BuiltList<TaskItem>([inWindow, afterEnd]),
        sprintEnd,
      );

      expect(result.map((t) => t.docId), ['t-in']);
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

    test('excludes tasks scheduled after the sprint end date (sanity)', () {
      // Boundary coverage for the isScheduledAfter predicate on the
      // existing-sprint selector.
      final inWindow = makeTask(
        docId: 't-in',
        name: 'In',
        startDate: now.add(const Duration(days: 2)),
      );
      final afterEnd = makeTask(
        docId: 't-out',
        name: 'Out',
        startDate: sprintEnd.add(const Duration(days: 1)),
      );
      final sprint = makeSprint();

      final result = taskItemsForPlacingOnExistingSprint(
        BuiltList<TaskItem>([inWindow, afterEnd]),
        sprint,
      );

      expect(result.map((t) => t.docId), ['t-in']);
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

  group('eligibleItemsForPlanningPicker', () {
    // These tests pin the aggregator's contract for both branches (no active
    // sprint / active sprint). They protect the helper itself — a future
    // edit that drops the recurrencePreviewSeedTasksForSprint call inside
    // the aggregator would fail the active-sprint case here. They do NOT
    // catch a call-site regression that bypasses the aggregator entirely
    // (e.g., a UI file switching back to taskItemsForSprintSelector); that
    // class of regression needs widget-level coverage on the planning popup.

    test('no active sprint: excludes family tasks via the new-sprint selector',
        () {
      final personal = makeTask(docId: 't-personal', name: 'Personal');
      final family = makeTask(
          docId: 't-family', name: 'Family', familyDocId: 'fam-1');

      final result = eligibleItemsForPlanningPicker(
        allTaskItems: BuiltList<TaskItem>([personal, family]),
        activeSprint: null,
        endDate: sprintEnd,
      );

      expect(result.map((t) => t.docId), ['t-personal']);
    });

    test('active sprint: excludes family tasks from BOTH base and preview seeds',
        () {
      // Personal task NOT in the sprint → should appear via base selector.
      final personalNotIn = makeTask(docId: 't-p1', name: 'Personal Free');
      // Family task NOT in the sprint → should be excluded by base.
      final familyNotIn = makeTask(
          docId: 't-f1', name: 'Family Free', familyDocId: 'fam-1');
      // Family task IN the sprint → should be excluded by the recurrence-
      // preview seed step. Without the aggregator's
      // recurrencePreviewSeedTasksForSprint call, this would still leak.
      final familyInSprint = makeTask(
          docId: 't-f2', name: 'Family In Sprint', familyDocId: 'fam-1');
      // Personal task IN the sprint → should appear via preview-seed step.
      final personalInSprint = makeTask(docId: 't-p2', name: 'Personal In Sprint');

      final sprint = makeSprint(assignments: [
        SprintAssignment((b) => b
          ..docId = 'a-1'
          ..taskDocId = 't-f2'
          ..sprintDocId = 'sprint-1'),
        SprintAssignment((b) => b
          ..docId = 'a-2'
          ..taskDocId = 't-p2'
          ..sprintDocId = 'sprint-1'),
      ]);

      final result = eligibleItemsForPlanningPicker(
        allTaskItems: BuiltList<TaskItem>(
            [personalNotIn, familyNotIn, familyInSprint, personalInSprint]),
        activeSprint: sprint,
        endDate: sprintEnd,
      );

      // Should contain personalNotIn (base) and personalInSprint (preview seed).
      // Should NOT contain familyNotIn (filtered by base) or familyInSprint
      // (filtered by preview-seed step — the regression case).
      final ids = result.map((t) => t.docId).toSet();
      expect(ids.contains('t-p1'), isTrue);
      expect(ids.contains('t-p2'), isTrue);
      expect(ids.contains('t-f1'), isFalse);
      expect(ids.contains('t-f2'), isFalse,
          reason:
              'TM-348: family-shared task in active sprint must not appear in eligible items via the recurrence-preview seed path');
    });
  });

  // (No standalone test for TaskItem.createNextRecurPreview's familyDocId
  // propagation — exercising it cleanly requires a full TaskRecurrence
  // setup. The propagation is documented on
  // [recurrencePreviewSeedTasksForSprint], which is the chokepoint that
  // makes the leak unobservable in the picker.)
}
