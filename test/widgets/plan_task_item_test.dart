import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart'
    show AreaStripe, PillView;
import 'package:taskmaestro/features/shared/presentation/widgets/plan_task_item.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/check_state.dart';
import 'package:taskmaestro/models/task_item.dart';

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
      final task = _makeTask(
        name: 'Expandable Plan Task',
        area: 'Work',
        targetDate: DateTime(2026, 5, 15),
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
}
