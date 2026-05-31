import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sprints/providers/create_sprint_draft_provider.dart';
import 'package:taskmaestro/features/sprints/providers/plan_filter_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';
import 'package:taskmaestro/models/task_recurrence.dart';

import '../../../helpers/async_provider_helpers.dart';
import '../../../mocks/mock_data_builder.dart';
import '../../../mocks/mock_recurrence_builder.dart';

/// TM-388 — `planBasePool` is the create-sprint surface's pre-filter
/// task pool, mirroring `tasksBasePool` / `sprintBasePool`. It must
/// produce exactly what `PlanTaskList.getBaseList` produces (same
/// `task_selectors`, same `tasksWithRecurrences` source, same
/// `createSprintEndDate` formula). The selectors themselves are covered
/// in `task_selectors_test`; these tests pin the provider wiring.
void main() {
  TaskItem makeTask({
    required String docId,
    String area = 'Work',
    String? familyDocId,
    DateTime? startDate,
    DateTime? completionDate,
  }) =>
      TaskItem((b) => b
        ..docId = docId
        ..name = docId
        ..personDocId = 'p'
        ..area = area
        ..familyDocId = familyDocId
        ..startDate = startDate
        ..completionDate = completionDate
        ..dateAdded = DateTime.utc(2026, 1, 1)
        ..retired = null
        ..offCycle = false
        ..skipped = false
        ..pendingCompletion = false);

  Sprint makeSprint({required List<String> assignedDocIds}) {
    final now = DateTime.now();
    return Sprint((b) => b
      ..docId = 'sprint-1'
      ..dateAdded = now
      ..startDate = now.subtract(const Duration(days: 1))
      ..endDate = now.add(const Duration(days: 30))
      ..numUnits = 1
      ..unitName = 'Months'
      ..personDocId = 'p'
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder(assignedDocIds.map((id) =>
          SprintAssignment((a) => a
            ..docId = 'asg-$id'
            ..taskDocId = id
            ..sprintDocId = 'sprint-1'))));
  }

  test('new-sprint mode: excludes family-shared + completed; keeps personal '
      'incomplete tasks within the window (TM-388)', () async {
    final tasks = [
      makeTask(docId: 'keep'), // personal, incomplete, no start → in window
      makeTask(docId: 'family', familyDocId: 'fam'), // excluded (shared)
      makeTask(docId: 'done', completionDate: DateTime.utc(2026, 1, 2)), // excluded
    ];
    final c = ProviderContainer(overrides: [
      activeSprintProvider.overrideWith((ref) => null),
      lastCompletedSprintProvider.overrideWith((ref) => null),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
    ]);
    addTearDown(c.dispose);
    // Deterministic window: start far enough out that no task is
    // "scheduled after" the end.
    c.read(createSprintDraftProvider.notifier)
        .setStartDate(DateTime(2026, 6, 1));

    final pool = await readAsyncValue(c, planBasePoolProvider);
    expect(pool.map((t) => t.docId), ['keep']);
  });

  test('new-sprint mode: excludes tasks scheduled after the draft end date '
      '(TM-388)', () async {
    final tasks = [
      makeTask(docId: 'in', startDate: DateTime(2026, 6, 3)), // before end
      makeTask(docId: 'after', startDate: DateTime(2026, 7, 1)), // after end
    ];
    final c = ProviderContainer(overrides: [
      activeSprintProvider.overrideWith((ref) => null),
      lastCompletedSprintProvider.overrideWith((ref) => null),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
    ]);
    addTearDown(c.dispose);
    // start 2026-06-01 + default 1 Week → end 2026-06-08.
    c.read(createSprintDraftProvider.notifier)
        .setStartDate(DateTime(2026, 6, 1));

    final pool = await readAsyncValue(c, planBasePoolProvider);
    expect(pool.map((t) => t.docId), ['in']);
  });

  test('existing-sprint mode: uses the add-to-existing selector — excludes '
      'tasks already assigned to the active sprint (TM-388)', () async {
    final tasks = [
      makeTask(docId: 'free'), // not in sprint → included
      makeTask(docId: 'assigned'), // already in sprint → excluded
    ];
    final c = ProviderContainer(overrides: [
      activeSprintProvider
          .overrideWith((ref) => makeSprint(assignedDocIds: ['assigned'])),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
    ]);
    addTearDown(c.dispose);

    final pool = await readAsyncValue(c, planBasePoolProvider);
    expect(pool.map((t) => t.docId), ['free']);
  });

  test('planFilteredTasks applies the plan surface\'s TaskFilters '
      '(TM-388)', () async {
    final tasks = [
      makeTask(docId: 'work', area: 'Work'),
      makeTask(docId: 'home', area: 'Home'),
    ];
    final c = ProviderContainer(overrides: [
      activeSprintProvider.overrideWith((ref) => null),
      lastCompletedSprintProvider.overrideWith((ref) => null),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
    ]);
    addTearDown(c.dispose);
    c.read(createSprintDraftProvider.notifier)
        .setStartDate(DateTime(2026, 6, 1));
    // Narrow the plan surface to area=Work.
    c
        .read(taskListViewStateProvider(TaskListSurface.plan).notifier)
        .setFilters(TaskFilters((b) => b..areas.add('Work')));

    final filtered = await readAsyncValue(c, planFilteredTasksProvider);
    expect(filtered.map((t) => t.docId), ['work']);
  });

  group('planRecurrencePreviewsProvider (TM-388)', () {
    // Daily-recurring TaskItem with the recurrence populated inline so
    // generatePlanPreviews doesn't need to resolve via allRecurrences —
    // keeps these tests focused on the endDate-source wiring.
    TaskItem dailyRecurring() {
      final builder = MockTaskItemBuilder.withDates()
        ..withDueDateAnchor()
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..recurrenceDocId = MockTaskItemBuilder.me;
      builder.taskRecurrence = MockTaskRecurrenceBuilder()
        ..docId = MockTaskItemBuilder.me
        ..name = builder.name
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..anchorDate = builder.getAnchorDate()!;
      return builder.create();
    }

    test('new-sprint mode: endDate comes from createSprintEndDateProvider '
        '(draft) — wider draft window → more previews', () async {
      final source = dailyRecurring();
      // Narrow draft: 1 week.
      final cNarrow = ProviderContainer(overrides: [
        activeSprintProvider.overrideWith((ref) => null),
        lastCompletedSprintProvider.overrideWith((ref) => null),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([source])),
        taskRecurrencesProvider
            .overrideWith((ref) => Stream.value(const <TaskRecurrence>[])),
      ]);
      addTearDown(cNarrow.dispose);
      cNarrow
          .read(createSprintDraftProvider.notifier)
          .setNumUnits(1);
      cNarrow
          .read(createSprintDraftProvider.notifier)
          .setUnitName('Weeks');

      final narrow =
          await readAsyncValue(cNarrow, planRecurrencePreviewsProvider);

      // Wide draft: 4 weeks.
      final cWide = ProviderContainer(overrides: [
        activeSprintProvider.overrideWith((ref) => null),
        lastCompletedSprintProvider.overrideWith((ref) => null),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([source])),
        taskRecurrencesProvider
            .overrideWith((ref) => Stream.value(const <TaskRecurrence>[])),
      ]);
      addTearDown(cWide.dispose);
      cWide.read(createSprintDraftProvider.notifier).setNumUnits(4);
      cWide.read(createSprintDraftProvider.notifier).setUnitName('Weeks');

      final wide = await readAsyncValue(cWide, planRecurrencePreviewsProvider);

      // Bigger window → strictly more daily previews. Proves the
      // endDate is being read from the draft (not e.g. a hardcoded
      // fallback that would yield identical counts).
      expect(wide.length, greaterThan(narrow.length));
    });

    test('existing-sprint mode: endDate comes from activeSprint.endDate '
        '— wider sprint → more previews', () async {
      final source = dailyRecurring();
      final now = DateTime.now();

      Sprint sprintWithEnd(DateTime endDate) => Sprint((b) => b
        ..docId = 'sprint-end-${endDate.toIso8601String()}'
        ..dateAdded = now
        ..startDate = now.subtract(const Duration(days: 1))
        ..endDate = endDate
        ..numUnits = 1
        ..unitName = 'Months'
        ..personDocId = 'p'
        ..sprintNumber = 1
        ..sprintAssignments = ListBuilder<SprintAssignment>());

      final cNarrow = ProviderContainer(overrides: [
        activeSprintProvider.overrideWith(
            (ref) => sprintWithEnd(now.add(const Duration(days: 7)))),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([source])),
        taskRecurrencesProvider
            .overrideWith((ref) => Stream.value(const <TaskRecurrence>[])),
      ]);
      addTearDown(cNarrow.dispose);

      final cWide = ProviderContainer(overrides: [
        activeSprintProvider.overrideWith(
            (ref) => sprintWithEnd(now.add(const Duration(days: 28)))),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([source])),
        taskRecurrencesProvider
            .overrideWith((ref) => Stream.value(const <TaskRecurrence>[])),
      ]);
      addTearDown(cWide.dispose);

      final narrow =
          await readAsyncValue(cNarrow, planRecurrencePreviewsProvider);
      final wide =
          await readAsyncValue(cWide, planRecurrencePreviewsProvider);

      expect(wide.length, greaterThan(narrow.length));
    });
  });
}
