import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/task_item_list.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/context.dart' as ctx_model;
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';
import 'package:taskmaestro/models/task_item.dart';

/// Regression test for TM-366.
///
/// The active-sprint banner on the Tasks tab used to read its completed
/// count off `widget.taskItems`, which is the incomplete-only base set
/// — so the numerator was always zero, even when sprint tasks had been
/// completed mid-session. The fix is to read the merged sprint task list
/// from `tasksForSprintProvider`, which includes incomplete + recently-
/// completed (+ older-completed when toggled on).
///
/// These tests pump `TaskItemList` with a stubbed sprint and stubbed
/// merged-task source, then assert on the banner text.

TaskItem _task({
  required String docId,
  String? completionDate,
  String name = 'Task',
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.utc(2026, 1, 1)
    ..personDocId = 'me'
    ..name = name
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false
    ..completionDate = completionDate == null
        ? null
        : DateTime.parse(completionDate));
}

Sprint _sprintWith(List<String> taskDocIds) {
  return Sprint((b) => b
    ..docId = 'sprint-1'
    ..dateAdded = DateTime.utc(2026, 1, 1)
    ..startDate = DateTime.now().subtract(const Duration(days: 2)).toUtc()
    ..endDate = DateTime.now().add(const Duration(days: 5)).toUtc()
    ..numUnits = 1
    ..unitName = 'week'
    ..personDocId = 'me'
    ..sprintNumber = 1
    ..sprintAssignments = ListBuilder<SprintAssignment>(
      taskDocIds.asMap().entries.map(
            (e) => SprintAssignment((sb) => sb
              ..docId = 'assign-${e.key}'
              ..taskDocId = e.value
              ..sprintDocId = 'sprint-1'),
          ),
    ));
}

class _StubRecentlyCompleted extends RecentlyCompletedTasks {
  _StubRecentlyCompleted(this._initial);
  final List<TaskItem> _initial;

  @override
  List<TaskItem> build() => _initial;
}

Widget _wrap({
  required List<TaskItem> incompleteTasks,
  required List<TaskItem> recentlyCompleted,
  required Sprint sprint,
  required SprintCounts counts,
}) {
  return ProviderScope(
    overrides: [
      // tasksForSprintProvider transitively watches olderCompletedTasksBatchesProvider,
      // whose build() reads personDocIdProvider. Without this override the
      // real auth chain runs (GoogleSignIn.initialize → UnimplementedError).
      personDocIdProvider.overrideWith((ref) => 'me'),
      // Stub the catalog providers that EditableTaskItemWidget pulls so we
      // don't subscribe to real Drift streams (would leak cleanup timers
      // past finalizeTree per MEMORY.md).
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx_model.Context>[])),
      // Sprint setup.
      sprintsProvider.overrideWith((ref) => Stream.value([sprint])),
      // TM-361 manual-test #18: the banner now reads its M/N from this
      // dedicated DB-backed provider (sprintCompletionCountsProvider)
      // rather than off the merged in-memory list. Override it so the
      // banner can render without spinning up Firestore + Drift roster.
      sprintCompletionCountsProvider(sprint)
          .overrideWith((ref) => Stream.value(counts)),
      // Inputs to `tasksForSprintProvider`. The merged provider reads
      // these (plus the show-completed and older-completed batches, which
      // default to empty / off) and merges them into the sprint's full
      // task list.
      tasksWithRecurrencesProvider
          .overrideWith((ref) => Stream.value(incompleteTasks)),
      recentlyCompletedTasksProvider
          .overrideWith(() => _StubRecentlyCompleted(recentlyCompleted)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: TaskItemList(
          // Same shape the production parent passes — incomplete-only.
          taskItems: BuiltList<TaskItem>(incompleteTasks),
          sprintMode: false,
        ),
      ),
    ),
  );
}

void main() {
  group('Sprint banner count (TM-366)', () {
    testWidgets(
        'banner shows correct M/(M+N) when M sprint tasks are completed',
        (tester) async {
      final incomplete = [
        for (var i = 0; i < 4; i++) _task(docId: 'inc-$i', name: 'Inc $i'),
      ];
      final completed = [
        for (var i = 0; i < 3; i++)
          _task(
            docId: 'comp-$i',
            name: 'Comp $i',
            completionDate: '2026-05-09T12:00:00Z',
          ),
      ];
      final sprint = _sprintWith(
          [...incomplete.map((t) => t.docId), ...completed.map((t) => t.docId)]);

      await tester.pumpWidget(_wrap(
        incompleteTasks: incomplete,
        recentlyCompleted: completed,
        sprint: sprint,
        counts: const SprintCounts(completed: 3, total: 7),
      ));
      await tester.pumpAndSettle();

      // Pre-fix the banner read `0/4 Tasks Complete` because the count
      // was computed off the incomplete-only `widget.taskItems`. Fix
      // moves the source to sprintCompletionCountsProvider (DB-backed),
      // which the test stubs with 3/7.
      expect(find.text('3/7 Tasks Complete'), findsOneWidget);
    });

    testWidgets(
        'banner shows 0/N when no tasks are completed (no regression)',
        (tester) async {
      final incomplete = [
        for (var i = 0; i < 5; i++) _task(docId: 'inc-$i', name: 'Inc $i'),
      ];
      final sprint = _sprintWith(incomplete.map((t) => t.docId).toList());

      await tester.pumpWidget(_wrap(
        incompleteTasks: incomplete,
        recentlyCompleted: const [],
        sprint: sprint,
        counts: const SprintCounts(completed: 0, total: 5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('0/5 Tasks Complete'), findsOneWidget);
    });
  });
}
