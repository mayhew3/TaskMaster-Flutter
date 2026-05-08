import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
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
