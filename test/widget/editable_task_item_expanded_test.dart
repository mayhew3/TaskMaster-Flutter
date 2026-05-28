import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/context.dart' as ctx_model;
import 'package:taskmaestro/models/task_context.dart';
import 'package:taskmaestro/models/task_item.dart';

/// Tests for the inline expand-for-detail behavior introduced in TM-356.
///
/// Covers:
/// 1. Tap → expand → tap → collapse
/// 2. Accordion: tapping card B collapses card A
/// 3. Expanded panel content (date grid, recurrence, notes, context)
/// 4. Edit button invokes the parent onEdit callback

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
      // TM-181: see editable_task_item_widget_test for rationale.
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx_model.Context>[])),
    ],
    child: MaterialApp(
      theme: ThemeData(
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(Colors.blue),
        ),
      ),
      home: Scaffold(body: child),
    ),
  );
}

TaskItem _task({
  String docId = 'task-1',
  String name = 'Sample Task',
  String? description,
  String? context,
  DateTime? startDate,
  DateTime? targetDate,
  DateTime? urgentDate,
  DateTime? dueDate,
  int? recurNumber,
  String? recurUnit,
  bool? recurWait,
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..name = name
    ..description = description
    ..contexts = ListBuilder<TaskContext>(
        context == null ? <TaskContext>[] : [TaskContext.named(context)])
    ..personDocId = 'person-1'
    ..startDate = startDate
    ..targetDate = targetDate
    ..urgentDate = urgentDate
    ..dueDate = dueDate
    ..recurNumber = recurNumber
    ..recurUnit = recurUnit
    ..recurWait = recurWait
    ..completionDate = null
    ..retired = null
    ..offCycle = false
    ..pendingCompletion = false);
}

void main() {
  group('Expand/collapse', () {
    testWidgets('Tap card body expands the panel; tap again collapses',
        (tester) async {
      final task = _task(
        docId: 'task-1',
        name: 'Expandable Task',
        description: 'Some notes',
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      final panelKey = TaskMaestroKeys.editableTaskItemExpandedPanel('task-1');

      // Collapsed initially.
      expect(find.byKey(panelKey), findsNothing);

      await tester.tap(find.text('Expandable Task'));
      await tester.pumpAndSettle();
      expect(find.byKey(panelKey), findsOneWidget);

      await tester.tap(find.text('Expandable Task'));
      await tester.pumpAndSettle();
      expect(find.byKey(panelKey), findsNothing);
    });

    testWidgets(
        'Accordion: tapping a second card collapses the first',
        (tester) async {
      final taskA = _task(docId: 'a', name: 'Task A', description: 'A notes');
      final taskB = _task(docId: 'b', name: 'Task B', description: 'B notes');

      await tester.pumpWidget(_wrap(ListView(
        children: [
          EditableTaskItemWidget(
            taskItem: taskA,
            highlightSprint: false,
            onTaskCompleteToggle: (_) => null,
          ),
          EditableTaskItemWidget(
            taskItem: taskB,
            highlightSprint: false,
            onTaskCompleteToggle: (_) => null,
          ),
        ],
      )));

      final panelA = TaskMaestroKeys.editableTaskItemExpandedPanel('a');
      final panelB = TaskMaestroKeys.editableTaskItemExpandedPanel('b');

      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();
      expect(find.byKey(panelA), findsOneWidget);
      expect(find.byKey(panelB), findsNothing);

      await tester.tap(find.text('Task B'));
      await tester.pumpAndSettle();
      expect(find.byKey(panelA), findsNothing);
      expect(find.byKey(panelB), findsOneWidget);
    });
  });

  group('Expanded panel content', () {
    testWidgets('Renders all four date rows when each date is set',
        (tester) async {
      final now = DateTime.now();
      final task = _task(
        docId: 'task-dates',
        name: 'Multi-date Task',
        startDate: now.subtract(const Duration(days: 5)),
        targetDate: now.subtract(const Duration(days: 1)),
        urgentDate: now.add(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 5)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text('Multi-date Task'));
      await tester.pumpAndSettle();

      // Each date label appears at least once in the grid; the date
      // labelled by the pill (the next upcoming milestone — URGENT here,
      // since target has passed and urgent is the next future date)
      // appears twice (pill + grid).
      expect(find.text('START'), findsOneWidget);
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.text('URGENT'), findsAtLeast(1));
      expect(find.text('DUE'), findsOneWidget);
    });

    testWidgets('Renders only the dates that are set', (tester) async {
      final task = _task(
        docId: 'task-partial',
        name: 'Partial Task',
        targetDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text('Partial Task'));
      await tester.pumpAndSettle();

      expect(find.text('START'), findsNothing);
      expect(find.text('TARGET'), findsAtLeast(1));
      expect(find.text('URGENT'), findsNothing);
      expect(find.text('DUE'), findsNothing);
    });

    testWidgets('Recurrence, notes, and context rows render when set',
        (tester) async {
      final task = _task(
        docId: 'task-meta',
        name: 'Metadata Task',
        description: 'Bring the keys',
        context: 'Phone',
        recurNumber: 2,
        recurUnit: 'Weeks',
        recurWait: true,
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text('Metadata Task'));
      await tester.pumpAndSettle();

      expect(find.text('CONTEXTS'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('REPEAT'), findsOneWidget);
      expect(find.text('Every 2 weeks (after completion)'), findsOneWidget);
      expect(find.text('NOTES'), findsOneWidget);
      expect(find.text('Bring the keys'), findsOneWidget);
    });

    testWidgets('Card with no expandable content renders no panel on tap',
        (tester) async {
      final task = _task(docId: 'task-bare', name: 'Bare Task');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text('Bare Task'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemExpandedPanel('task-bare')),
        findsNothing,
      );
    });
  });

  group('Title row when expanded', () {
    // Pill drops below the title in expanded mode regardless of title
    // length. Earlier versions tried to keep the pill inline with
    // short titles via TextPainter-based measurement, but the
    // measurement diverged from actual rendered widths across
    // platforms (Roboto vs SF), leaving titles of borderline length
    // ellipsised on iOS while wrapping on Android. The unconditional
    // drop sidesteps that platform-dependent bias.

    testWidgets(
        'Short title also drops the pill below in expanded mode (no measurement bias)',
        (tester) async {
      final task = _task(
        docId: 'short-x',
        name: 'Short Task',
        description: 'has notes so panel renders',
        dueDate: DateTime.now().add(const Duration(days: 4)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text('Short Task'));
      await tester.pumpAndSettle();

      final titleRect = tester.getRect(find.text('Short Task'));
      final pillRect = tester
          .getRect(find.byKey(TaskMaestroKeys.editableTaskItemDatePill('short-x')));
      expect(pillRect.top, greaterThan(titleRect.bottom - 1),
          reason:
              'Pill should sit on its own row below the title in expanded mode regardless of title length');
    });

    testWidgets(
        'Long title drops pill below and right-aligns it when expanded',
        (tester) async {
      final longName =
          'An exceptionally long task name that will not fit on a single line and forces the pill to wrap to a second row';
      final task = _task(
        docId: 'long-x',
        name: longName,
        description: 'has notes so panel renders',
        dueDate: DateTime.now().add(const Duration(days: 4)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text(longName));
      await tester.pumpAndSettle();

      final titleRect = tester.getRect(find.text(longName));
      final pillRect = tester
          .getRect(find.byKey(TaskMaestroKeys.editableTaskItemDatePill('long-x')));
      // Pill drops below the title.
      expect(pillRect.top, greaterThan(titleRect.bottom - 1),
          reason: 'Long title should push the pill onto a row below it');
      // And the pill is right-aligned — its right edge is close to the title's right edge.
      expect((pillRect.right - titleRect.right).abs(), lessThan(4),
          reason: 'Pill should be right-aligned in the wrapped layout');
    });
  });

  group('Edit button', () {
    testWidgets('Tapping the edit button invokes onEdit', (tester) async {
      var pressed = 0;
      final task = _task(
        docId: 'task-edit',
        name: 'Editable Task',
        description: 'Has notes so panel renders',
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
        onEdit: () => pressed++,
      )));

      await tester.tap(find.text('Editable Task'));
      await tester.pumpAndSettle();

      final editKey =
          TaskMaestroKeys.editableTaskItemEditButton('task-edit');
      expect(find.byKey(editKey), findsOneWidget);

      await tester.tap(find.byKey(editKey));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });

    testWidgets('Edit button is hidden when onEdit is not provided',
        (tester) async {
      final task = _task(
        docId: 'task-no-edit',
        name: 'No-edit Task',
        description: 'Notes',
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      await tester.tap(find.text('No-edit Task'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemEditButton('task-no-edit')),
        findsNothing,
      );
    });

    testWidgets(
        'Edit button is hidden on TWO-PANE WIDE (≥1200dp) even when '
        'onEdit IS provided (TM-385 — docked editor pane replaces the '
        'inline Edit affordance; rendering both would push a '
        'full-screen route on top of the docked editor)',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);
      final task = _task(
        docId: 'task-wide',
        name: 'Wide-mode Task',
        description: 'Has notes so panel renders',
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
        // Provide a non-null onEdit — on phone this would render the
        // Edit button. Two-pane wide must suppress it via the
        // `effectiveOnEdit` gate in `EditableTaskItemWidget.build`.
        onEdit: () {},
      )));

      await tester.tap(find.text('Wide-mode Task'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemEditButton('task-wide')),
        findsNothing,
        reason: 'two-pane wide layout must hide the inline Edit '
            'button even when onEdit is provided',
      );
    });

    testWidgets(
        'Edit button IS shown on the wide-but-NOT-two-pane band '
        '(840–1199dp) even though `isWideLayout` is true — there is '
        'no docked editor pane in that band, so nulling onEdit would '
        'leave the task with no edit affordance at all (TM-385 R3 '
        'regression: the gate must be `isTwoPaneWideLayout`, not '
        '`isWideLayout`)', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      // 1000dp: comfortably inside the wide band (≥840) but BELOW
      // the two-pane threshold (1200).
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);
      final task = _task(
        docId: 'task-mid-wide',
        name: 'Mid-Wide Task',
        description: 'Has notes so panel renders',
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
        onEdit: () {},
      )));

      await tester.tap(find.text('Mid-Wide Task'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemEditButton('task-mid-wide')),
        findsOneWidget,
        reason: '840–1199dp has no right pane; the inline Edit '
            'button must remain so users can still edit the task',
      );
    });

    testWidgets(
        'Empty task (no dates / recurrence / notes / contexts) on '
        'TWO-PANE WIDE does NOT expand to an empty panel even though '
        'onEdit is provided (TM-385 — `effectiveOnEdit` is gated to '
        'null on two-pane wide so `hasExpandableContent` returns '
        'false, and the shell-tap path fires selection only without '
        'toggling the accordion)', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);
      final task = _task(
        docId: 'task-empty-wide',
        name: 'Empty Wide Task',
        // No description / dates / recurrence / contexts.
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
        onEdit: () {},
      )));

      await tester.tap(find.text('Empty Wide Task'));
      await tester.pumpAndSettle();

      // Panel must not render: no expandable content, and on two-pane
      // wide the Edit button doesn't count toward "expandable
      // content" anymore.
      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemExpandedPanel(
            'task-empty-wide')),
        findsNothing,
        reason: 'empty task on two-pane wide must not expand into an '
            'empty panel',
      );
    });
  });
}
