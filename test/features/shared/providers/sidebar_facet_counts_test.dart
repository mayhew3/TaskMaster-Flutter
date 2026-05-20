import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/family/providers/family_task_filter_providers.dart';
import 'package:taskmaestro/features/shared/providers/sidebar_facet_counts.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/task_context.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';

import '../../../helpers/async_provider_helpers.dart';

TaskContext _ctx(String name) => TaskContext((b) => b..name = name);

TaskItem _task({
  required String docId,
  required String name,
  required String area,
  required List<String> contexts,
}) =>
    TaskItem((b) => b
      ..docId = docId
      ..name = name
      ..personDocId = 'p'
      ..area = area
      ..priority = 3
      ..priorityScaleVersion = 2
      ..dateAdded = DateTime.utc(2026, 1, 1)
      ..contexts =
          ListBuilder<TaskContext>(contexts.map(_ctx))
      ..retired = null
      ..offCycle = false
      ..skipped = false
      ..pendingCompletion = false);

Sprint _sprint() {
  final now = DateTime.utc(2026, 1, 1);
  return Sprint((b) => b
    ..docId = 'sprint-1'
    ..dateAdded = now
    ..startDate = now
    ..endDate = now.add(const Duration(days: 14))
    ..numUnits = 2
    ..unitName = 'Weeks'
    ..personDocId = 'p'
    ..sprintNumber = 1
    ..sprintAssignments = ListBuilder([]));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
      'Tasks surface: each facet ignores its own axis but respects the '
      'other (TM-382)', () async {
    final base = [
      _task(docId: 'a', name: 'alpha', area: 'Work', contexts: ['Phone']),
      _task(docId: 'b', name: 'beta', area: 'Home', contexts: ['Phone']),
      _task(docId: 'c', name: 'gamma', area: 'Work', contexts: ['Email']),
      _task(docId: 'd', name: 'delta', area: 'Home', contexts: ['Email']),
    ];

    final container = ProviderContainer(overrides: [
      tasksBasePoolProvider.overrideWith((ref) => base),
    ]);
    addTearDown(container.dispose);

    // User has BOTH facets narrowed: area=Work, context=Phone.
    container
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setFilters(TaskFilters((b) => b
          ..areas.add('Work')
          ..contexts.add('Phone')));

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.tasks),
    );

    // Areas count clears the AREA axis but keeps context=Phone:
    // Phone tasks are a (Work) + b (Home).
    expect(counts.areas, {'work': 1, 'home': 1});

    // Contexts count clears the CONTEXT axis but keeps area=Work:
    // Work tasks are a (Phone) + c (Email).
    expect(counts.contexts, {'phone': 1, 'email': 1});
  });

  test(
      'Tasks surface: a non-facet filter (search) is still applied while '
      'faceting (TM-382)', () async {
    final base = [
      _task(docId: 'a', name: 'alpha', area: 'Work', contexts: ['Phone']),
      _task(docId: 'b', name: 'beta', area: 'Work', contexts: ['Phone']),
    ];
    final container = ProviderContainer(overrides: [
      tasksBasePoolProvider.overrideWith((ref) => base),
    ]);
    addTearDown(container.dispose);

    // Both facets narrowed (base-only path) + a search term.
    container
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setFilters(TaskFilters((b) => b
          ..areas.add('Work')
          ..contexts.add('Phone')
          ..search = 'alpha'));

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.tasks),
    );

    // Area axis cleared, but search='alpha' still excludes 'beta'.
    expect(counts.areas, {'work': 1});
  });

  test(
      'Tasks surface: with no facet filter, counts reuse the body list — '
      'no base-pool recompute (TM-382)', () async {
    final visible = [
      _task(docId: 'x', name: 'x', area: 'Work', contexts: ['Phone']),
      _task(docId: 'y', name: 'y', area: 'Home', contexts: ['Email']),
    ];
    // tasksBasePool intentionally NOT overridden — the reuse path must
    // not touch it; only the body's filtered list is consulted.
    final container = ProviderContainer(overrides: [
      filteredTasksProvider.overrideWith((ref) async => visible),
    ]);
    addTearDown(container.dispose);

    // Default tasks filters have no area/context narrowed → reuse path.
    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.tasks),
    );

    expect(counts.areas, {'work': 1, 'home': 1});
    expect(counts.contexts, {'phone': 1, 'email': 1});
  });

  test('plan surface yields empty counts (no app-level base pool)',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.plan),
    );
    expect(counts.areas, isEmpty);
    expect(counts.contexts, isEmpty);
  });

  test(
      'Family surface: each facet ignores its own axis but respects the '
      'other (TM-382)', () async {
    final base = [
      _task(docId: 'a', name: 'alpha', area: 'Work', contexts: ['Phone']),
      _task(docId: 'b', name: 'beta', area: 'Home', contexts: ['Phone']),
      _task(docId: 'c', name: 'gamma', area: 'Work', contexts: ['Email']),
      _task(docId: 'd', name: 'delta', area: 'Home', contexts: ['Email']),
    ];
    final container = ProviderContainer(overrides: [
      familyBasePoolProvider.overrideWith((ref) => base),
    ]);
    addTearDown(container.dispose);

    container
        .read(taskListViewStateProvider(TaskListSurface.family).notifier)
        .setFilters(TaskFilters((b) => b
          ..areas.add('Work')
          ..contexts.add('Phone')));

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.family),
    );
    expect(counts.areas, {'work': 1, 'home': 1});
    expect(counts.contexts, {'phone': 1, 'email': 1});
  });

  test(
      'Sprint surface (with active sprint): each facet ignores its own '
      'axis but respects the other (TM-382)', () async {
    final base = [
      _task(docId: 'a', name: 'alpha', area: 'Work', contexts: ['Phone']),
      _task(docId: 'b', name: 'beta', area: 'Home', contexts: ['Phone']),
      _task(docId: 'c', name: 'gamma', area: 'Work', contexts: ['Email']),
    ];
    final sprint = _sprint();
    final container = ProviderContainer(overrides: [
      activeSprintProvider.overrideWith((ref) => sprint),
      sprintBasePoolProvider.overrideWith((ref, _) async => base),
    ]);
    addTearDown(container.dispose);

    container
        .read(taskListViewStateProvider(TaskListSurface.sprint).notifier)
        .setFilters(TaskFilters((b) => b
          ..areas.add('Work')
          ..contexts.add('Phone')));

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.sprint),
    );
    // Areas: contexts=Phone keeps a,b → {work:1, home:1}.
    expect(counts.areas, {'work': 1, 'home': 1});
    // Contexts: areas=Work keeps a,c → {phone:1, email:1}.
    expect(counts.contexts, {'phone': 1, 'email': 1});
  });

  test('Sprint surface with no active sprint yields empty counts (TM-382)',
      () async {
    final container = ProviderContainer(overrides: [
      activeSprintProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.sprint),
    );
    expect(counts.areas, isEmpty);
    expect(counts.contexts, isEmpty);
  });

  test(
      'Tasks surface, asymmetric narrowing: one axis uses the base path, '
      'the other reuses the body list (TM-382)', () async {
    // areas narrowed → area counts come from applyTaskFilters(base, ...).
    // contexts un-narrowed → context counts come from the reused
    // `filteredTasksProvider` list (sentinel). Distinct override values
    // prove which source each facet consulted.
    final base = [
      _task(docId: 'a', name: 'a', area: 'Work', contexts: ['Phone']),
      _task(docId: 'b', name: 'b', area: 'Work', contexts: ['Email']),
    ];
    final visible = [
      _task(docId: 'x', name: 'x', area: 'Home', contexts: ['Other']),
    ];
    final container = ProviderContainer(overrides: [
      tasksBasePoolProvider.overrideWith((ref) => base),
      filteredTasksProvider.overrideWith((ref) async => visible),
    ]);
    addTearDown(container.dispose);

    container
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setFilters(TaskFilters((b) => b..areas.add('Work')));

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.tasks),
    );
    // Areas (areas axis cleared, base path): both base tasks pass → {work:2}.
    expect(counts.areas, {'work': 2});
    // Contexts (contexts axis empty → reuse visible): single sentinel task
    // → {other:1}. If the provider had wrongly recomputed from base, this
    // would be {phone:1, email:1}.
    expect(counts.contexts, {'other': 1});
  });
}
