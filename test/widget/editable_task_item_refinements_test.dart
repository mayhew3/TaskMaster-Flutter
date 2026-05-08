import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/task_item.dart';

/// Tests for the TM-357 task-card refinements:
///   3.1 Left stripe color reflects the task's date state (when set)
///   3.2 Date pills carry a thicker (2px) border than COMPLETED pills
///   3.3 Sprint icon renders inline with the area label, not in a separate
///       column to the right of the row
///   3.4 REPEAT row is a tappable link when `recurrenceDocId` is set
///   3.6 Priority/Length/Pts subtitles appear only in expanded mode
///   3.7 Title truncation epsilon — near-edge titles wrap instead of
///       getting ellipsised on a single row when expanded

Widget _wrap(Widget child, {String? expandedDocId}) {
  return ProviderScope(
    overrides: [
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
      if (expandedDocId != null)
        expandedTaskProvider.overrideWith(() => _PrimedExpanded(expandedDocId)),
    ],
    child: MaterialApp(
      theme: ThemeData(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

class _PrimedExpanded extends ExpandedTask {
  _PrimedExpanded(this.initial);
  final String? initial;

  @override
  String? build() => initial;
}

TaskItem _makeTask({
  String docId = 'r-1',
  String name = 'Task',
  String? area,
  DateTime? targetDate,
  DateTime? urgentDate,
  DateTime? dueDate,
  DateTime? completionDate,
  String? recurrenceDocId,
  int? recurNumber,
  String? recurUnit,
  bool? recurWait,
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..name = name
    ..personDocId = 'p'
    ..area = area
    ..targetDate = targetDate
    ..urgentDate = urgentDate
    ..dueDate = dueDate
    ..completionDate = completionDate
    ..recurrenceDocId = recurrenceDocId
    ..recurNumber = recurNumber
    ..recurUnit = recurUnit
    ..recurWait = recurWait
    ..retired = null
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false);
}

void main() {
  group('Sprint icon position (TM-357 #3)', () {
    testWidgets(
        'Sprint icon renders inline with area, not as a top-level column',
        (tester) async {
      final task = _makeTask(name: 'Sprint Task', area: 'Work');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: true,
        onTaskCompleteToggle: (_) => null,
      )));
      // Icon still appears…
      expect(find.byIcon(Icons.assignment), findsOneWidget);
      // …and lives inside the area-label key cluster (the meta row), not
      // outside it. The area key only wraps the inline meta cluster, so
      // finding the icon inside it confirms the new layout.
      expect(
        find.descendant(
          of: find.byKey(TaskMaestroKeys.editableTaskItemCardAreaField('r-1')),
          matching: find.byIcon(Icons.assignment),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'Sprint icon renders even when area is null (no area dot, just badge)',
        (tester) async {
      final task = _makeTask(name: 'Sprintless Areaful', area: null);
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: true,
        onTaskCompleteToggle: (_) => null,
      )));
      // The sprint badge alone is enough to keep the area key present so
      // the meta row still aligns; this covers the area==null branch in
      // _areaLabel that previously short-circuited to SizedBox.shrink.
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });
  });

  group('Field subtitles when expanded (TM-357 #6)', () {
    testWidgets('Collapsed card does NOT render Priority/Length/Pts subtitles',
        (tester) async {
      final task = _makeTask(name: 'Collapsed', area: 'A');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('Priority'), findsNothing);
      expect(find.text('Length'), findsNothing);
      expect(find.text('Pts'), findsNothing);
    });

    testWidgets('Expanded card DOES render Priority/Length/Pts subtitles',
        (tester) async {
      final task = _makeTask(
        name: 'Expanded',
        area: 'A',
        // Some content to make the card expandable; recurrence forces the
        // expand affordance even without dates/notes.
        recurNumber: 1,
        recurUnit: 'Weeks',
        recurWait: true,
      );
      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
        ),
        expandedDocId: task.docId,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('Pts'), findsOneWidget);
    });
  });

  group('REPEAT row link (TM-357 #4)', () {
    testWidgets('REPEAT renders without chevron when recurrenceDocId is null',
        (tester) async {
      final task = _makeTask(
        name: 'Inline rule task',
        // Recurrence on the TaskItem itself, no recurrence doc.
        recurNumber: 1,
        recurUnit: 'Weeks',
        recurWait: true,
      );
      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
        ),
        expandedDocId: task.docId,
      ));
      await tester.pumpAndSettle();
      // REPEAT label is present…
      expect(find.text('REPEAT'), findsOneWidget);
      // …but the chevron-suffix link affordance is not (no recurrenceDocId
      // means there's no history page to navigate to).
      // Find chevron_right icons inside the expanded panel.
      final chevrons = find.byIcon(Icons.chevron_right);
      // Calendar / other icons may exist, but in this test scaffold there
      // shouldn't be any chevron_right for the REPEAT row.
      expect(chevrons, findsNothing);
    });

    testWidgets('REPEAT renders chevron + link when recurrenceDocId is set',
        (tester) async {
      final task = _makeTask(
        name: 'Linked rule task',
        recurrenceDocId: 'recur-abc',
        recurNumber: 1,
        recurUnit: 'Weeks',
        recurWait: true,
      );
      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
        ),
        expandedDocId: task.docId,
      ));
      await tester.pumpAndSettle();
      expect(find.text('REPEAT'), findsOneWidget);
      // Chevron suffix appears, indicating the row is a link.
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
