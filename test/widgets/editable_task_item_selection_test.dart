import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/features/shared/presentation/wide/aura_stack.dart';
import 'package:taskmaestro/features/shared/presentation/wide/selectable_task_item.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/models/context.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-383 row-level selection tests:
///   (1) the magenta `SelectableTaskItem` ring overlay renders on wide
///       when selectedTaskProvider == this docId, and never on phone
///   (2) tapping an `EditableTaskItemWidget` summary row on wide writes
///       `selectedTaskProvider` in lockstep with the existing
///       `expandedTaskProvider.toggle()`; on phone, only the accordion
///       fires (selection stays null)
///
/// Uses the canonical `_wrap` shape from
/// `test/widget/editable_task_item_widget_test.dart` so Drift cleanup
/// timers don't leak past `finalizeTree` (MEMORY.md
/// `project_drift_flutter_test_interaction`).

/// Sets the test viewport size for one test. Passing `width >= 840` puts
/// `isWideLayout` true; `>= 1200` also flips `isTwoPaneWideLayout`. We
/// use `840` for the wide-but-not-two-pane band (still wide enough that
/// production wide-only behavior fires).
void _setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}


Widget _wrap(Widget child, {required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
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

ProviderContainer _container() {
  final container = ProviderContainer(overrides: [
    // Drift-touching providers EditableTaskItemWidget would otherwise
    // open — stub both as empty so the widget tree drains cleanly.
    areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
    contextsProvider.overrideWith((ref) => Stream.value(const <Context>[])),
    // SelectedTask / RightPane watch personDocIdProvider for the
    // cross-user reset (TM-384 pre-push review). Stub to a stable
    // value so the auth chain doesn't try to wire up Firebase Auth
    // in this widget-test environment.
    personDocIdProvider.overrideWith((ref) => 'test-person'),
  ]);
  addTearDown(container.dispose);
  return container;
}

TaskItem _task({
  String docId = 'docA',
  String name = 'Task A',
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..name = name
    ..personDocId = 'person-123'
    ..retired = null
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false);
}

void main() {
  group('SelectableTaskItem GlobalObjectKey attachment (TM-383)', () {
    // Aura visuals are now painted by the parent-level [AuraStack] (see
    // `aura_stack.dart`'s docstring for why). All [SelectableTaskItem]
    // does is attach a [GlobalObjectKey] to its child when wide AND
    // selected, so AuraStack's aura layer can find the row's RenderBox.
    // The actual aura rendering / positioning is covered by
    // `aura_stack_test.dart`.

    testWidgets(
        'on wide + selected, wraps child in KeyedSubtree with the '
        'shared GlobalObjectKey', (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      c.read(selectedTaskProvider.notifier).select('docA');

      await tester.pumpWidget(_wrap(
        const SelectableTaskItem(
          surface: TaskListSurface.tasks,
          taskDocId: 'docA',
          child: SizedBox(width: 200, height: 60),
        ),
        container: c,
      ));
      await tester.pump();

      // The selected row's child is reachable via the shared key.
      final key = SelectableTaskItemKey.of(TaskListSurface.tasks, 'docA');
      expect(key.currentContext, isNotNull,
          reason: 'selected row should be findable via the shared key');
    });

    testWidgets(
        'on wide but NOT selected, child is returned unchanged — no key',
        (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      // Some OTHER row is selected.
      c.read(selectedTaskProvider.notifier).select('docOther');

      await tester.pumpWidget(_wrap(
        const SelectableTaskItem(
          surface: TaskListSurface.tasks,
          taskDocId: 'docA',
          child: SizedBox(width: 200, height: 60),
        ),
        container: c,
      ));
      await tester.pump();

      expect(
          SelectableTaskItemKey.of(TaskListSurface.tasks, 'docA').currentContext,
          isNull,
          reason: 'unselected row must not carry the key');
    });

    testWidgets(
        'on compact, no key is attached even when selected — phone path '
        'never participates in the aura', (tester) async {
      _setSize(tester, const Size(800, 600));
      final c = _container();
      c.read(selectedTaskProvider.notifier).select('docA');

      await tester.pumpWidget(_wrap(
        const SelectableTaskItem(
          surface: TaskListSurface.tasks,
          taskDocId: 'docA',
          child: SizedBox(width: 200, height: 60),
        ),
        container: c,
      ));
      await tester.pump();

      expect(
          SelectableTaskItemKey.of(TaskListSurface.tasks, 'docA').currentContext,
          isNull,
          reason: 'compact path must not attach the aura key');
    });
  });

  group('EditableTaskItemWidget tap → selection (TM-383)', () {
    testWidgets(
        'on wide, tapping the summary row writes selectedTaskProvider',
        (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
          // hasExpandableContent gates the tap handler; supplying onEdit
          // is the cheapest way to make a no-dates card tappable.
          onEdit: () {},
        ),
        container: c,
      ));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), isNull);
      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), 'docA');
    });

    testWidgets(
        'on wide, tapping the same row again clears selection (toggle)',
        (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
          // hasExpandableContent gates the tap handler; supplying onEdit
          // is the cheapest way to make a no-dates card tappable.
          onEdit: () {},
        ),
        container: c,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();
      expect(c.read(selectedTaskProvider), 'docA');

      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();
      expect(c.read(selectedTaskProvider), isNull);
    });

    testWidgets(
        'on compact, tap does NOT touch selectedTaskProvider (accordion only)',
        (tester) async {
      _setSize(tester, const Size(800, 600));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
          // hasExpandableContent gates the tap handler; supplying onEdit
          // is the cheapest way to make a no-dates card tappable.
          onEdit: () {},
        ),
        container: c,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), isNull,
          reason: 'phone path must never write the selection provider');
      // The accordion DID toggle.
      expect(c.read(expandedTaskProvider), 'docA');
    });

    testWidgets(
        'on wide, the accordion ALSO toggles in sync with selection',
        (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
          // hasExpandableContent gates the tap handler; supplying onEdit
          // is the cheapest way to make a no-dates card tappable.
          onEdit: () {},
        ),
        container: c,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), 'docA');
      expect(c.read(expandedTaskProvider), 'docA',
          reason: 'D3: accordion + selection co-fire on wide');
    });
  });
}
