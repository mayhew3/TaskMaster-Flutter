import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/providers/sidebar_facet_counts.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
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

  test('Tasks surface: a non-facet filter (search) is still applied',
      () async {
    final base = [
      _task(docId: 'a', name: 'alpha', area: 'Work', contexts: ['Phone']),
      _task(docId: 'b', name: 'beta', area: 'Home', contexts: ['Phone']),
    ];
    final container = ProviderContainer(overrides: [
      tasksBasePoolProvider.overrideWith((ref) => base),
    ]);
    addTearDown(container.dispose);

    container
        .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
        .setFilters(TaskFilters((b) => b
          ..areas.add('Work')
          ..search = 'alpha'));

    final counts = await readAsyncValue(
      container,
      sidebarFacetCountsProvider(TaskListSurface.tasks),
    );

    // Area axis cleared, but search='alpha' still excludes 'beta' (Home).
    expect(counts.areas, {'work': 1});
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
}
