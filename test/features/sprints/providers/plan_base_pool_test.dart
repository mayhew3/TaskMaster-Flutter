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

import '../../../helpers/async_provider_helpers.dart';

/// TM-388 — `planBasePool` is the create-sprint surface's pre-filter
/// task pool, mirroring `tasksBasePool` / `sprintBasePool`. It must
/// produce exactly what `PlanTaskList.getBaseList` produces (same
/// `task_selectors`, same `tasksWithRecurrences` source, same
/// `createSprintEndDate` formula). The selectors themselves are covered
/// in `task_selectors_test`; these tests pin the provider wiring.
void main() {
  TaskItem task({
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

  Sprint sprint({required List<String> assignedDocIds}) {
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
      task(docId: 'keep'), // personal, incomplete, no start → in window
      task(docId: 'family', familyDocId: 'fam'), // excluded (shared)
      task(docId: 'done', completionDate: DateTime.utc(2026, 1, 2)), // excluded
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
      task(docId: 'in', startDate: DateTime(2026, 6, 3)), // before end
      task(docId: 'after', startDate: DateTime(2026, 7, 1)), // after end
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
      task(docId: 'free'), // not in sprint → included
      task(docId: 'assigned'), // already in sprint → excluded
    ];
    final c = ProviderContainer(overrides: [
      activeSprintProvider
          .overrideWith((ref) => sprint(assignedDocIds: ['assigned'])),
      tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
    ]);
    addTearDown(c.dispose);

    final pool = await readAsyncValue(c, planBasePoolProvider);
    expect(pool.map((t) => t.docId), ['free']);
  });

  test('planFilteredTasks applies the plan surface\'s TaskFilters '
      '(TM-388)', () async {
    final tasks = [
      task(docId: 'work', area: 'Work'),
      task(docId: 'home', area: 'Home'),
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
}
