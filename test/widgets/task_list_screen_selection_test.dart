import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_centered_column.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/context.dart' as ctx;
import 'package:taskmaestro/models/task_item.dart';

/// TM-383: the wide-only centered max-width column wrap in `_TaskListBody`.
///
/// Tap-driven selection contract (which-tap-writes-which-provider, ring
/// rendering) is covered separately in `editable_task_item_selection_test
/// .dart` — testing tap on a full-screen pump leaks Drift cleanup timers
/// (`!timersPending` invariant, MEMORY.md `project_drift_flutter_test_
/// interaction`), so the tap-level tests live in a row-level harness
/// (see `editable_task_item_widget_test.dart`'s `_wrap` pattern).
late StreamController<List<TaskItem>> _tasksController;

TaskItem _task(String docId, String name) {
  return TaskItem((b) => b
    ..docId = docId
    ..name = name
    ..personDocId = 'test-person'
    ..offCycle = false
    ..dateAdded = DateTime.now().toUtc());
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required Size logical,
    required List<TaskItem> tasks,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    _tasksController = StreamController<List<TaskItem>>();
    addTearDown(_tasksController.close);
    _tasksController.add(tasks);

    final group = TaskGroupResult(
      key: 'g',
      displayName: '',
      displayOrder: 1,
      tasks: tasks,
    );

    final container = ProviderContainer(overrides: [
      tasksWithRecurrencesProvider
          .overrideWith((ref) => _tasksController.stream),
      groupedTasksProvider.overrideWith((ref) async => [group]),
      activeSprintProvider.overrideWith((ref) => null),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
      authProvider.overrideWith(_FakeAuth.new),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      // Drift-touching providers EditableTaskItemWidget reads — stub so
      // rendering doesn't open Drift in this test (TM-181 / memory
      // `project_drift_flutter_test_interaction`).
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx.Context>[])),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: TaskListScreen()),
    ));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
      'on wide, the list is wrapped in Center + ConstrainedBox at '
      'WideCenteredColumn.maxWidth (TM-383)', (tester) async {
    final taskA = _task('docA', 'Task A');
    await pump(tester, logical: const Size(1280, 800), tasks: [taskA]);

    final wrap = find.byWidgetPredicate((w) {
      if (w is! ConstrainedBox) return false;
      return w.constraints.maxWidth == WideCenteredColumn.maxWidth;
    });
    expect(wrap, findsAtLeastNWidgets(1),
        reason: 'expected the wide-only ConstrainedBox(maxWidth: '
            'WideCenteredColumn.maxWidth) wrap');
  });

  testWidgets(
      'on compact, NO WideCenteredColumn.maxWidth wrap (TM-383)',
      (tester) async {
    final taskA = _task('docA', 'Task A');
    await pump(tester, logical: const Size(800, 600), tasks: [taskA]);

    final wrap = find.byWidgetPredicate((w) {
      if (w is! ConstrainedBox) return false;
      return w.constraints.maxWidth == WideCenteredColumn.maxWidth;
    });
    expect(wrap, findsNothing,
        reason: 'phone path must not wrap the list in a max-width column');
  });

  testWidgets('on wide, the Tasks tab add-task FAB is hidden — the sidebar '
      '"+ Add task" is the canonical add affordance there (TM-384)',
      (tester) async {
    final taskA = _task('docA', 'Task A');
    await pump(tester, logical: const Size(1280, 800), tasks: [taskA]);
    expect(find.byType(FloatingActionButton), findsNothing,
        reason: 'wide layouts must not show a duplicate add-task FAB '
            'next to the sidebar\'s "+ Add task" button');
  });

  testWidgets('on compact, the Tasks tab add-task FAB is present — '
      '(TM-384 / behavior-preserving for phone)', (tester) async {
    final taskA = _task('docA', 'Task A');
    await pump(tester, logical: const Size(800, 600), tasks: [taskA]);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

class _FakeAuth extends Auth {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

class _FakeSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;
}
