import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/models/context.dart' as ctx_model;
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart'
    show AreaStripe, EditableTaskItemWidget, PillView;
import 'package:taskmaestro/features/shared/presentation/widgets/plan_task_item.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/check_state.dart';
import 'package:taskmaestro/models/sprint_display_task.dart';
import 'package:taskmaestro/models/sprint_display_task_recurrence.dart';
import 'package:taskmaestro/models/task_date_holder.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_item_recur_preview.dart';

/// Tests for the redesigned `PlanTaskItemWidget` (TM-357 #3.8).
///
/// Verifies that the sprint-planning row now renders via the same chrome
/// helpers the main task card uses — `AreaStripe` and `PillView` — so the
/// two screens stay visually synchronized as the design evolves.

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      // Plan widget reads areaColorsProvider through its area-color
      // resolver; the real provider chains into auth + database which
      // spin up timers in a test env. Stub it so the widget falls
      // through to the hash-based AreaColorHelper.colorForArea.
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx_model.Context>[])),
    ],
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

TaskItem _makeTask({
  String docId = 'plan-1',
  String name = 'Plan task',
  String? area = 'Work',
  DateTime? targetDate,
  DateTime? dueDate,
  DateTime? completionDate,
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..name = name
    ..personDocId = 'p'
    ..area = area
    ..targetDate = targetDate
    ..dueDate = dueDate
    ..completionDate = completionDate
    ..retired = null
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false);
}

void main() {
  group('PlanTaskItemWidget (TM-357 #3.8 — shared chrome)', () {
    testWidgets('Renders the task name and the AreaStripe from shared chrome',
        (tester) async {
      final task = _makeTask(name: 'Sprint Candidate', area: 'Work');
      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: task,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: false,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));
      expect(find.text('Sprint Candidate'), findsOneWidget);
      // Shared chrome — same AreaStripe class as the main card.
      expect(find.byType(AreaStripe), findsOneWidget);
    });

    testWidgets('Renders a date pill via the shared PillView for dated tasks',
        (tester) async {
      final task = _makeTask(
        name: 'Due Soon',
        area: 'Work',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: task,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: false,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));
      // Pill widget is the shared PillView (not a custom local one).
      expect(find.byType(PillView), findsOneWidget);
      expect(find.text('DUE'), findsOneWidget);
    });

    testWidgets('Renders sprint icon when highlightSprint=true',
        (tester) async {
      final task = _makeTask(name: 'In Last Sprint', area: 'Work');
      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: task,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: true,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));
      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemCardSprintIcon('plan-1')),
        findsOneWidget,
      );
    });

    testWidgets('Hides sprint icon when highlightSprint=false', (tester) async {
      final task = _makeTask(name: 'Not Sprint', area: 'Work');
      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: task,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: false,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));
      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemCardSprintIcon('plan-1')),
        findsNothing,
      );
    });

    testWidgets('Tapping the row expands and reveals dates panel',
        (tester) async {
      // Use a `now()`-relative target so the test stays time-independent;
      // a hard-coded calendar date would silently start failing after
      // it slipped into the past (TaskDateType's display predicates
      // suppress the pill once the threshold is no longer in the
      // forward-looking window).
      final task = _makeTask(
        name: 'Expandable Plan Task',
        area: 'Work',
        targetDate: DateTime.now().add(const Duration(days: 7)),
      );
      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: task,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: false,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));
      // Before expand: only the summary-row date pill carries a TARGET
      // label — the expanded panel hasn't rendered yet.
      expect(find.text('TARGET'), findsOneWidget);

      // Tap the row body to toggle expansion via expandedTaskProvider.
      await tester.tap(find.text('Expandable Plan Task'));
      await tester.pumpAndSettle();

      // Now both the pill AND the expanded panel's date row render
      // a TARGET label, confirming the panel mounted on tap.
      expect(find.text('TARGET'), findsNWidgets(2));
    });

    testWidgets('Completed task → COMPLETED pill (shared completed semantics)',
        (tester) async {
      final task = _makeTask(
        name: 'Done already',
        area: 'Work',
        completionDate: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: task,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: false,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));
      expect(find.text('COMPLETED'), findsOneWidget);
    });
  });

  group('PlanTaskItemWidget (TM-365 — hardening)', () {
    testWidgets(
        'TaskItemRecurPreview render path returns a referentially-stable '
        'synthesised TaskItem across rebuilds', (tester) async {
      // The synthesis path uses `DateTime.now()` for the (display-unused)
      // dateAdded field, which would break built_value's content-equality
      // every frame without caching — forcing EditableTaskItemWidget to
      // rebuild unnecessarily. The State-side cache (TM-365) returns the
      // same TaskItem instance across rebuilds when the source key is
      // unchanged.
      final preview = TaskItemRecurPreview('Preview Task')
        ..personDocId = 'p';

      late StateSetter setOuterState;
      await tester.pumpWidget(_wrap(StatefulBuilder(
        builder: (context, setState) {
          setOuterState = setState;
          return PlanTaskItemWidget(
            sprintDisplayTask: preview,
            endDate: DateTime.now().add(const Duration(days: 14)),
            highlightSprint: false,
            initialCheckState: CheckState.inactive,
            onTaskAssignmentToggle: (_) => null,
          );
        },
      )));

      final taskAfterFirstBuild = tester
          .widget<EditableTaskItemWidget>(find.byType(EditableTaskItemWidget))
          .taskItem;

      // Force a parent rebuild — same source, no key change.
      setOuterState(() {});
      await tester.pumpAndSettle();

      final taskAfterSecondBuild = tester
          .widget<EditableTaskItemWidget>(find.byType(EditableTaskItemWidget))
          .taskItem;

      expect(identical(taskAfterFirstBuild, taskAfterSecondBuild), isTrue,
          reason:
              'Synthesised TaskItem must be referentially stable across '
              'rebuilds when the source SprintDisplayTask is unchanged.');
    });

    testWidgets('ValueKey preserves State.cache across reorder',
        (tester) async {
      // Without a stable ValueKey, ListView/Column matches Elements by
      // index — so a reorder shuffles States to the wrong sources, losing
      // each widget's cache (and any other per-Element state, e.g. the
      // DelayedCheckbox's animation state). With ValueKey tied to the
      // source's identifier, Flutter matches the State to the source's
      // new position.
      final previewA = TaskItemRecurPreview('Preview A')..personDocId = 'p';
      final previewB = TaskItemRecurPreview('Preview B')..personDocId = 'p';

      Widget buildList(List<TaskItemRecurPreview> order) => _wrap(Column(
            children: [
              for (final t in order)
                PlanTaskItemWidget(
                  key: ValueKey(t.getSprintDisplayTaskKey()),
                  sprintDisplayTask: t,
                  endDate: DateTime.now().add(const Duration(days: 14)),
                  highlightSprint: false,
                  initialCheckState: CheckState.inactive,
                  onTaskAssignmentToggle: (_) => null,
                ),
            ],
          ));

      await tester.pumpWidget(buildList([previewA, previewB]));

      // Capture A's synthesised TaskItem instance (the cached one).
      final aTaskBefore = tester
          .widget<EditableTaskItemWidget>(
            find.descendant(
              of: find.byKey(ValueKey(previewA.getSprintDisplayTaskKey())),
              matching: find.byType(EditableTaskItemWidget),
            ),
          )
          .taskItem;

      // Reorder: A and B swap positions.
      await tester.pumpWidget(buildList([previewB, previewA]));
      await tester.pumpAndSettle();

      // Find A's widget by its key — should still be the same Element
      // (state preserved), so the cached synthesised TaskItem must be
      // referentially identical to the pre-reorder one.
      final aTaskAfter = tester
          .widget<EditableTaskItemWidget>(
            find.descendant(
              of: find.byKey(ValueKey(previewA.getSprintDisplayTaskKey())),
              matching: find.byType(EditableTaskItemWidget),
            ),
          )
          .taskItem;

      expect(identical(aTaskBefore, aTaskAfter), isTrue,
          reason:
              'ValueKey based on SprintDisplayTask key must preserve the '
              'per-Element synthesis cache across list reorder.');
    });

    testWidgets('unknown SprintDisplayTask subtype falls back gracefully',
        (tester) async {
      // The pre-TM-365 widget threw StateError on any subtype other than
      // TaskItem / TaskItemRecurPreview — a future mixin implementor
      // would crash the plan screen. The TM-365 fallback synthesises a
      // minimal TaskItem from the common SprintDisplayTask surface so the
      // row renders with the available information.
      final fake = _FakeSprintDisplayTask(name: 'Fallback Row');

      await tester.pumpWidget(_wrap(PlanTaskItemWidget(
        sprintDisplayTask: fake,
        endDate: DateTime.now().add(const Duration(days: 14)),
        highlightSprint: false,
        initialCheckState: CheckState.inactive,
        onTaskAssignmentToggle: (_) => null,
      )));

      // Name visible from the fallback synthesis — no throw.
      expect(find.text('Fallback Row'), findsOneWidget);
      // Shared chrome still rendered.
      expect(find.byType(AreaStripe), findsOneWidget);

      // PR #31 review follow-up: the fallback must stamp `personDocId`
      // with the `_fallback_` marker — never empty or anything that
      // looks like a real Firestore docId. If a synthesised row ever
      // leaks into a write/filter path, the marker makes it obvious
      // in logs and prevents accidental matches against any real
      // user's data.
      final synthesised = tester
          .widget<EditableTaskItemWidget>(find.byType(EditableTaskItemWidget))
          .taskItem;
      expect(synthesised.personDocId, startsWith('_fallback_'));
      expect(synthesised.personDocId,
          contains(fake.getSprintDisplayTaskKey()));
    });
  });
}

/// Test-only `SprintDisplayTask` implementor that's neither `TaskItem` nor
/// `TaskItemRecurPreview`. Exercises the TM-365 unknown-subtype fallback
/// without dragging in any of the real implementations. Mixes in both
/// `DateHolder` (for the default isScheduled/isUrgent/etc. implementations)
/// and `SprintDisplayTask` — same pattern as `TaskItemRecurPreview`.
class _FakeSprintDisplayTask with DateHolder, SprintDisplayTask {
  _FakeSprintDisplayTask({required this.name});

  @override
  final String name;

  @override
  String? get area => null;

  @override
  DateTime? get startDate => null;
  @override
  DateTime? get targetDate => null;
  @override
  DateTime? get urgentDate => null;
  @override
  DateTime? get dueDate => null;
  @override
  DateTime? get completionDate => null;

  @override
  SprintDisplayTaskRecurrence? get recurrence => null;
  @override
  int? get recurIteration => null;

  @override
  int? get recurNumber => null;
  @override
  String? get recurUnit => null;
  @override
  bool? get recurWait => null;

  @override
  bool get offCycle => false;

  @override
  bool isPreview() => true;

  @override
  TaskItemRecurPreview createNextRecurPreview({
    required Map<TaskDateType, DateTime> dates,
  }) =>
      throw UnimplementedError(
          '_FakeSprintDisplayTask is for plan-row fallback rendering only.');

  @override
  String getSprintDisplayTaskKey() => 'fake-${name.hashCode}';
}
