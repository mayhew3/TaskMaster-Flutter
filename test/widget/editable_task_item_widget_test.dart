import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_item.dart';

/// Widget tests for the V9-redesigned `EditableTaskItemWidget`.
///
/// Covers:
/// 1. Title and area name render
/// 2. Date pill labels the next upcoming milestone within its display
///    window (or the most recently crossed one if none are upcoming) —
///    not the recurrence-anchor date. See `_displayDateType` in
///    editable_task_item.dart.
/// 3. Sprint icon appears only when highlightSprint == true
/// 4. Completed/skipped tasks show the completed pill
/// 5. The card is wrapped in `Dismissible`
///
/// Expand-and-edit behavior is covered separately in
/// `editable_task_item_expanded_test.dart`.

Widget _wrap(Widget child) {
  return ProviderScope(
    // areaColorsProvider chains through personDocId + database providers,
    // which spin up timers in test env. Stubbing it here lets the widget
    // fall through to AreaColorHelper.colorForArea (hash-based).
    overrides: [
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
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

TaskItem _makeTask({
  String docId = 'test-task',
  String name = 'Test Task Name',
  String? area,
  DateTime? startDate,
  DateTime? targetDate,
  DateTime? urgentDate,
  DateTime? dueDate,
  DateTime? completionDate,
  bool skipped = false,
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..name = name
    ..personDocId = 'person-123'
    ..area = area
    ..startDate = startDate
    ..targetDate = targetDate
    ..urgentDate = urgentDate
    ..dueDate = dueDate
    ..completionDate = completionDate
    ..retired = null
    ..offCycle = false
    ..skipped = skipped
    ..pendingCompletion = false);
}

void main() {
  group('EditableTaskItemWidget — summary row', () {
    testWidgets('Displays the task name', (tester) async {
      final task = _makeTask(name: 'Test Task Name');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('Test Task Name'), findsOneWidget);
    });

    testWidgets('Renders the area name when present', (tester) async {
      final task = _makeTask(name: 'Task With Area', area: 'Work Project');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('Task With Area'), findsOneWidget);
      expect(find.text('Work Project'), findsOneWidget);
    });

    testWidgets('Omits the area row when area is null', (tester) async {
      final task = _makeTask(name: 'No Area Task', area: null);
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('No Area Task'), findsOneWidget);
      // The area key is only emitted when there's content to show.
      expect(
        find.byKey(TaskMaestroKeys.editableTaskItemCardAreaField('test-task')),
        findsNothing,
      );
    });

    testWidgets('Shows the sprint icon when highlightSprint is true',
        (tester) async {
      final task = _makeTask(name: 'Sprint Task');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: true,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });

    testWidgets('Hides the sprint icon when highlightSprint is false',
        (tester) async {
      final task = _makeTask(name: 'Non-Sprint Task');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.byIcon(Icons.assignment), findsNothing);
    });

    testWidgets('Card is wrapped in Dismissible (swipe-to-delete)',
        (tester) async {
      final task = _makeTask(name: 'Dismissible Task');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.byType(Dismissible), findsOneWidget);
    });
  });

  group('EditableTaskItemWidget — date pill (anchor selection)', () {
    testWidgets('Past due → DUE pill', (tester) async {
      final task = _makeTask(
        name: 'Past Due Task',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.byKey(TaskMaestroKeys.editableTaskItemDatePill('test-task')),
          findsOneWidget);
      expect(find.text('DUE'), findsOneWidget);
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('Past urgent (no due) → URGENT pill', (tester) async {
      final task = _makeTask(
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(const Duration(hours: 6)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('Past target (no due/urgent) → TARGET pill', (tester) async {
      final task = _makeTask(
        name: 'Target Task',
        targetDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets(
        'Future urgent wins over future due even when target has passed',
        (tester) async {
      // Mothers-Day-style task: target is in the past, urgent and due are
      // both upcoming. The pill should call out the next milestone the
      // user has to act on (urgent), not the highest-priority date type
      // that is set (due).
      final now = DateTime.now();
      final task = _makeTask(
        docId: 'mothers-day',
        name: "Mother's Day",
        targetDate: now.subtract(const Duration(days: 1)),
        urgentDate: now.add(const Duration(hours: 4)),
        dueDate: now.add(const Duration(days: 2)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('URGENT'), findsOneWidget,
          reason: 'Urgent is the next upcoming milestone — show it');
      expect(find.text('DUE'), findsNothing);
      expect(find.text('TARGET'), findsNothing);
    });

    testWidgets('Due wins over urgent and target', (tester) async {
      final now = DateTime.now();
      final task = _makeTask(
        name: 'Multi-date Task',
        targetDate: now.subtract(const Duration(days: 3)),
        urgentDate: now.subtract(const Duration(days: 2)),
        dueDate: now.subtract(const Duration(days: 1)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('DUE'), findsOneWidget);
      expect(find.text('URGENT'), findsNothing);
      expect(find.text('TARGET'), findsNothing);
    });

    testWidgets(
        'Pill bg = current state, fg = anchor type (due in future, urgent passed)',
        (tester) async {
      final now = DateTime.now();
      final task = _makeTask(
        docId: 'split-tone',
        name: 'Split-tone task',
        urgentDate: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 2)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));

      // Anchor = due (because dueDate is set and is the highest priority);
      // current state = urgent (because urgentDate has passed).
      // Therefore label says DUE, text uses dueText, bg uses urgentColor.
      final pill = tester.widget<Container>(
          find.byKey(TaskMaestroKeys.editableTaskItemDatePill('split-tone')));
      final decoration = pill.decoration! as BoxDecoration;
      expect(decoration.color, TaskColors.urgentColor,
          reason: 'Pill bg should reflect current state (urgent passed)');

      final labelTexts = tester.widgetList<Text>(find.descendant(
        of: find.byKey(TaskMaestroKeys.editableTaskItemDatePill('split-tone')),
        matching: find.byType(Text),
      ));
      // The value is the full dueText; the label is dueText with a small
      // alpha tweak. Either way, both reflect the anchor (DUE), not the
      // current-state (urgent).
      expect(labelTexts.last.style?.color, TaskColors.dueText,
          reason: 'Pill value text should use dueText (anchor) — not the bg state colour');
    });

    testWidgets('No dates → no date pill', (tester) async {
      final task = _makeTask(name: 'Simple Task');
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.byKey(TaskMaestroKeys.editableTaskItemDatePill('test-task')),
          findsNothing);
      expect(find.text('DUE'), findsNothing);
      expect(find.text('URGENT'), findsNothing);
      expect(find.text('TARGET'), findsNothing);
    });
  });

  group('EditableTaskItemWidget — scheduled state', () {
    testWidgets(
        'Scheduled tasks render with low-opacity fill + start-tone outline',
        (tester) async {
      final task = _makeTask(
        docId: 'scheduled',
        name: 'Scheduled Task',
        startDate: DateTime.now().add(const Duration(days: 3)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      final card = tester.widget<Card>(
          find.byKey(TaskMaestroKeys.editableTaskItemCard('scheduled')));
      // Surface is a translucent variant of the regular card colour.
      final surface = card.color!;
      expect(surface.a, lessThan(0.5),
          reason:
              'Scheduled cards should be hollow (low-alpha fill) to read as inactive');
      // Outline uses the start-tone scheduledOutline.
      final shape = card.shape! as RoundedRectangleBorder;
      expect(shape.side.color, TaskColors.scheduledOutline);
      expect(shape.side.width, greaterThan(0.5));
    });
  });

  group('EditableTaskItemWidget — completed/skipped state', () {
    testWidgets('Completed task shows the COMPLETED pill', (tester) async {
      final now = DateTime.now().toUtc();
      final task = _makeTask(name: 'Completed Task', completionDate: now);
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('Skipped task shows the SKIPPED pill', (tester) async {
      final now = DateTime.now().toUtc();
      final task = _makeTask(
        name: 'Skipped Task',
        completionDate: now,
        skipped: true,
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      expect(find.text('SKIPPED'), findsOneWidget);
    });
  });

  group('EditableTaskItemWidget — collapsed title row', () {
    testWidgets('Long title keeps single-row layout while collapsed',
        (tester) async {
      final longName =
          'An exceptionally long task name that would not fit on a single line';
      final task = _makeTask(
        docId: 'long-collapsed',
        name: longName,
        dueDate: DateTime.now().add(const Duration(days: 4)),
      );
      await tester.pumpWidget(_wrap(EditableTaskItemWidget(
        taskItem: task,
        highlightSprint: false,
        onTaskCompleteToggle: (_) => null,
      )));
      final titleRect = tester.getRect(find.text(longName));
      final pillRect = tester.getRect(
          find.byKey(TaskMaestroKeys.editableTaskItemDatePill('long-collapsed')));
      // Single row: pill is roughly horizontally aligned with the title.
      expect((pillRect.top - titleRect.top).abs(), lessThan(20),
          reason: 'Collapsed cards always keep the pill on the title row');
    });
  });

  group('EditableTaskItemWidget — multiple cards', () {
    testWidgets('Two cards render independently', (tester) async {
      final task1 = _makeTask(docId: 'task-1', name: 'First Task');
      final task2 = _makeTask(
        docId: 'task-2',
        name: 'Second Task',
        area: 'Project A',
      );
      await tester.pumpWidget(_wrap(ListView(
        children: [
          EditableTaskItemWidget(
            taskItem: task1,
            highlightSprint: false,
            onTaskCompleteToggle: (_) => null,
          ),
          EditableTaskItemWidget(
            taskItem: task2,
            highlightSprint: true,
            onTaskCompleteToggle: (_) => null,
          ),
        ],
      )));
      expect(find.text('First Task'), findsOneWidget);
      expect(find.text('Second Task'), findsOneWidget);
      expect(find.text('Project A'), findsOneWidget);
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });
  });
}
