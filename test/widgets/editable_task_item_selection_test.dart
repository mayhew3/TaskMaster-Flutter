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

/// TM-383 / TM-385 row-level selection tests:
///   (1) the magenta `SelectableTaskItem` ring overlay renders on wide
///       when selectedTaskProvider == this docId, and never on phone
///   (2) tapping an `EditableTaskItemWidget` summary row that's wrapped
///       in `SelectableTaskItem` on wide writes `selectedTaskProvider`
///       (via the `SelectionTapPolicy` InheritedWidget the wrapper
///       installs — TM-385 refactor). On phone, the wrapper returns
///       child unchanged so no policy is installed; the leaf row's
///       `SelectionTapPolicy.maybeOf(context)` returns null and only
///       the accordion fires (selection stays null).
///   (3) `EditableTaskItemWidget` USED ALONE (no SelectableTaskItem
///       ancestor) NEVER writes selection regardless of viewport — the
///       leaf row is shell-state-decoupled after TM-385.
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
  String? description,
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..name = name
    ..description = description
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

  group('EditableTaskItemWidget tap → selection (TM-383 / TM-385)', () {
    // Helper that pumps the row wrapped in SelectableTaskItem — the
    // production composition. TM-385: SelectableTaskItem installs the
    // SelectionTapPolicy InheritedWidget so the leaf row's onTap can
    // drive selection without reading shell providers.
    Widget _wrappedRow(TaskItem task) => SelectableTaskItem(
          surface: TaskListSurface.tasks,
          taskDocId: task.docId,
          child: EditableTaskItemWidget(
            taskItem: task,
            highlightSprint: false,
            onTaskCompleteToggle: (_) => null,
            // Production lists pass onEdit. TM-385 gates `onEdit` to
            // null on wide (inline Edit button is hidden when the
            // docked editor is the editor), so on-wide tests that
            // assert accordion behavior must seed the task with
            // intrinsic expandable content (a description, dates,
            // recurrence, or contexts) — see `hasExpandableContent`.
            onEdit: () {},
          ),
        );

    testWidgets(
        'on wide + wrapped in SelectableTaskItem, tap writes '
        'selectedTaskProvider (TM-385 — policy-driven path)',
        (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(_wrappedRow(task), container: c));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), isNull);
      await tester.tap(find.text('Task A'));
      // 200ms > the 180ms Future.delayed scroll-into-view timer that
      // EditableTaskItemWidget's expand listener schedules; the
      // SelectableTaskItem KeyedSubtree wrap (on first-selection) re-
      // mounts the row, doubling the timers, and pumpAndSettle can
      // exit before the second one fires. Explicit advance flushes
      // both (`!timersPending` invariant — see MEMORY
      // `project_drift_flutter_test_interaction` lineage).
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), 'docA');
    });

    testWidgets(
        'on wide + wrapped, tapping the same row again clears selection '
        '(tap-same-to-clear policy)', (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(_wrappedRow(task), container: c));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      // 200ms > the 180ms Future.delayed scroll-into-view timer that
      // EditableTaskItemWidget's expand listener schedules; the
      // SelectableTaskItem KeyedSubtree wrap (on first-selection) re-
      // mounts the row, doubling the timers, and pumpAndSettle can
      // exit before the second one fires. Explicit advance flushes
      // both (`!timersPending` invariant — see MEMORY
      // `project_drift_flutter_test_interaction` lineage).
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(c.read(selectedTaskProvider), 'docA');

      await tester.tap(find.text('Task A'));
      // 200ms > the 180ms Future.delayed scroll-into-view timer that
      // EditableTaskItemWidget's expand listener schedules; the
      // SelectableTaskItem KeyedSubtree wrap (on first-selection) re-
      // mounts the row, doubling the timers, and pumpAndSettle can
      // exit before the second one fires. Explicit advance flushes
      // both (`!timersPending` invariant — see MEMORY
      // `project_drift_flutter_test_interaction` lineage).
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(c.read(selectedTaskProvider), isNull);
    });

    testWidgets(
        'on compact + wrapped, tap does NOT touch selectedTaskProvider — '
        'SelectableTaskItem returns child unchanged on compact, so no '
        'policy is installed (accordion only) (TM-385)', (tester) async {
      _setSize(tester, const Size(800, 600));
      final c = _container();
      final task = _task(docId: 'docA', name: 'Task A');

      await tester.pumpWidget(_wrap(_wrappedRow(task), container: c));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      // 200ms > the 180ms Future.delayed scroll-into-view timer that
      // EditableTaskItemWidget's expand listener schedules; the
      // SelectableTaskItem KeyedSubtree wrap (on first-selection) re-
      // mounts the row, doubling the timers, and pumpAndSettle can
      // exit before the second one fires. Explicit advance flushes
      // both (`!timersPending` invariant — see MEMORY
      // `project_drift_flutter_test_interaction` lineage).
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), isNull,
          reason: 'phone path must never write the selection provider — '
              'SelectableTaskItem returns child unchanged on compact so '
              'no SelectionTapPolicy is installed in the tree');
      // The accordion DID toggle.
      expect(c.read(expandedTaskProvider), 'docA');
    });

    testWidgets(
        'on wide + wrapped, the accordion ALSO toggles in lockstep with '
        'selection (D3 contract preserved across TM-385 refactor)',
        (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      // Description seeds intrinsic expandable content so the
      // accordion fires on wide (where TM-385's effectiveOnEdit gate
      // strips the Edit-button-only path).
      final task = _task(docId: 'docA', name: 'Task A', description: 'Notes');

      await tester.pumpWidget(_wrap(_wrappedRow(task), container: c));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      // 200ms > the 180ms Future.delayed scroll-into-view timer that
      // EditableTaskItemWidget's expand listener schedules; the
      // SelectableTaskItem KeyedSubtree wrap (on first-selection) re-
      // mounts the row, doubling the timers, and pumpAndSettle can
      // exit before the second one fires. Explicit advance flushes
      // both (`!timersPending` invariant — see MEMORY
      // `project_drift_flutter_test_interaction` lineage).
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), 'docA');
      expect(c.read(expandedTaskProvider), 'docA',
          reason: 'D3: accordion + selection co-fire on wide');
    });

    testWidgets(
        'EditableTaskItemWidget USED ALONE (no SelectableTaskItem '
        'ancestor) never writes selection, even on wide — the leaf row '
        'is shell-state-decoupled after TM-385', (tester) async {
      _setSize(tester, const Size(1280, 800));
      final c = _container();
      // Description gives the row intrinsic expandable content; on
      // wide, TM-385's effectiveOnEdit gate strips the onEdit path,
      // so the accordion would otherwise stay collapsed and the
      // assertion below couldn't distinguish "didn't fire selection"
      // from "didn't fire anything."
      final task = _task(docId: 'docA', name: 'Task A', description: 'Notes');

      // Bare EditableTaskItemWidget — no SelectableTaskItem wrap, so
      // no SelectionTapPolicy in the tree.
      await tester.pumpWidget(_wrap(
        EditableTaskItemWidget(
          taskItem: task,
          highlightSprint: false,
          onTaskCompleteToggle: (_) => null,
          onEdit: () {},
        ),
        container: c,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task A'));
      // 200ms > the 180ms Future.delayed scroll-into-view timer that
      // EditableTaskItemWidget's expand listener schedules; the
      // SelectableTaskItem KeyedSubtree wrap (on first-selection) re-
      // mounts the row, doubling the timers, and pumpAndSettle can
      // exit before the second one fires. Explicit advance flushes
      // both (`!timersPending` invariant — see MEMORY
      // `project_drift_flutter_test_interaction` lineage).
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(c.read(selectedTaskProvider), isNull,
          reason: 'leaf row must never read shell-level selection '
              'providers without the SelectionTapPolicy seam — proves '
              'the TM-385 decoupling holds');
      expect(c.read(expandedTaskProvider), 'docA',
          reason: 'accordion still fires — that\'s the row\'s own state');
    });
  });
}
