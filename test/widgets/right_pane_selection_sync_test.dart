import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_selection_sync.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/models/task_item.dart';

/// TM-384: the wide-shell listener that bridges `selectedTaskProvider`
/// → `rightPaneProvider`. Verifies both directions:
///   - non-null selection ⇒ `.editor` (only when current mode is
///     `.empty` or `.editor` — `.addingNewTask` / `.viewOptions` are
///     explicit modes that survive a coincident row tap)
///   - null selection ⇒ `.empty` (re-tap a row to deselect, or any
///     code path that clears the selection without explicitly setting
///     the right pane back to empty) — only when current is `.editor`
///
/// The downgrade is the fix for the "re-tap to collapse leaves a blank
/// right pane" bug — pre-fix the listener only upgraded on non-null and
/// the pane was left in `.editor` with no selection to render.
///
/// The MODE-PROTECTING gates are the fix for the `.addingNewTask`
/// clobber bug — pre-fix, a row tap while the user was mid-typing in
/// add-mode would silently switch the pane to `.editor` and discard
/// the in-progress new task. Same risk for `.viewOptions` (TM-385).
void main() {
  TaskItem _ownedTask(String docId) => TaskItem((b) => b
    ..docId = docId
    ..name = docId
    ..personDocId = 'test-person'
    ..dateAdded = DateTime.now().toUtc()
    ..priorityScaleVersion = 2
    ..offCycle = false);

  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer(overrides: [
      // SelectedTask / RightPane watch personDocIdProvider for the
      // cross-user reset (TM-384 pre-push review). Stub so the auth
      // chain doesn't try to wire up Firebase Auth in this widget-test
      // environment.
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      // The listener's ownership gate reads taskProvider(next) for
      // the selected docId; without these overrides it traverses
      // taskFromDbProvider → databaseProvider, which spins up the
      // Drift AppDatabase and leaks cleanup timers past finalizeTree
      // (MEMORY: project_drift_flutter_test_interaction). The mode-
      // gate tests don't care about task content, so stub the two
      // docIds they use as owned-by-test-person.
      taskProvider('task-1').overrideWith((ref) => _ownedTask('task-1')),
      taskProvider('task-2').overrideWith((ref) => _ownedTask('task-2')),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: RightPaneSelectionSync(child: SizedBox.shrink()),
          ),
        ),
      ),
    );
    return container;
  }

  testWidgets('non-null selection upgrades rightPaneProvider to .editor '
      '(TM-384)', (tester) async {
    final c = await pump(tester);
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.editor);
  });

  testWidgets('clearing the selection downgrades rightPaneProvider to '
      '.empty — the re-tap-to-collapse case (TM-384)', (tester) async {
    final c = await pump(tester);
    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.editor);

    // Simulate the row tap-again-to-deselect path. The listener must
    // drive the pane back to .empty so the user sees the empty-state
    // selection instructions, not a blank pane.
    c.read(selectedTaskProvider.notifier).clear();
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
  });

  testWidgets('switching selection from one task to another keeps the pane '
      'in .editor (TM-384)', (tester) async {
    final c = await pump(tester);
    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.editor);

    c.read(selectedTaskProvider.notifier).select('task-2');
    await tester.pump();

    // Still .editor — the listener fires with `next='task-2'` (non-null).
    expect(c.read(rightPaneProvider), RightPaneMode.editor);
  });

  testWidgets('null-selection listener does NOT downgrade .addingNewTask '
      'to .empty — the whole reason .addingNewTask is a distinct mode '
      '(TM-384)', (tester) async {
    final c = await pump(tester);
    // Simulate the sidebar "+ Add task" tap: clear selection, then
    // explicitly set .addingNewTask. The sidebar handler does these
    // in this order in production.
    c.read(selectedTaskProvider.notifier).clear();
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.addingNewTask);
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask);

    // Re-fire the selection-clear (e.g. a code path that defensively
    // clears selection while the user is mid-typing in add-mode). The
    // listener must leave .addingNewTask alone — pre-fix it downgraded
    // unconditionally and the user's in-progress new task evaporated.
    c.read(selectedTaskProvider.notifier).select('task-1');
    c.read(selectedTaskProvider.notifier).clear();
    await tester.pump();

    // Mode is still .addingNewTask. (Note: the .select('task-1') in
    // between is also gated by the upgrade test below — it must NOT
    // flip us into .editor while we're in .addingNewTask.)
    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask,
        reason: 'selection-clear must not clobber the explicit '
            '.addingNewTask mode set by the sidebar Add Task button');
  });

  testWidgets('non-null selection does NOT clobber .addingNewTask — a row '
      'tap while typing a new task must not silently discard it '
      '(TM-384)', (tester) async {
    final c = await pump(tester);
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.addingNewTask);
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask);

    // Simulate the user accidentally tapping a row in the list while
    // mid-typing a new task. The listener must NOT flip us to .editor
    // — the user has to Cancel out of add-mode first if they really
    // want to switch tasks.
    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask,
        reason: 'a row tap during add-mode must not clobber the '
            'explicit .addingNewTask mode');
  });

  testWidgets('non-null selection does NOT clobber .viewOptions either — '
      'same defensive gate (TM-384 / TM-385)', (tester) async {
    final c = await pump(tester);
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
    await tester.pump();

    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.viewOptions,
        reason: '.viewOptions is explicit user intent — a coincident '
            'row tap must not silently switch panes');
  });

  testWidgets('selecting a task NOT owned by the current user does NOT '
      'open the docked editor — preserves the Family tab\'s read-only '
      'contract on wide (TM-384 — Copilot R4 review feedback)',
      (tester) async {
    // A teammate's task: personDocId differs from the test-person
    // override below.
    final teammateTask = TaskItem((b) => b
      ..docId = 'teammate-task'
      ..name = 'Teammate task'
      ..personDocId = 'someone-else'
      ..dateAdded = DateTime.now().toUtc()
      ..priorityScaleVersion = 2
      ..offCycle = false);

    final container = ProviderContainer(overrides: [
      personDocIdProvider.overrideWith((ref) => 'me'),
      // taskProvider is a function provider keyed by docId; override
      // for the one docId we test to return the teammate-owned task.
      taskProvider('teammate-task').overrideWith((ref) => teammateTask),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: RightPaneSelectionSync(child: SizedBox.shrink()),
        ),
      ),
    ));

    expect(container.read(rightPaneProvider), RightPaneMode.empty);

    container.read(selectedTaskProvider.notifier).select('teammate-task');
    await tester.pump();

    expect(container.read(rightPaneProvider), RightPaneMode.empty,
        reason: 'tapping a teammate\'s task on wide must NOT open the '
            'docked editor — the compact path enforces this via '
            'onEdit: null in _FamilyTaskTile, and the docked surface '
            'must honor the same read-only contract (saving would '
            'either clobber personDocId via UpdateTask or be rejected '
            'by Firestore rules)');
  });

  testWidgets('selecting a task owned by the current user DOES open the '
      'docked editor — negative control for the ownership gate (TM-384)',
      (tester) async {
    final myTask = TaskItem((b) => b
      ..docId = 'my-task'
      ..name = 'My task'
      ..personDocId = 'me'
      ..dateAdded = DateTime.now().toUtc()
      ..priorityScaleVersion = 2
      ..offCycle = false);

    final container = ProviderContainer(overrides: [
      personDocIdProvider.overrideWith((ref) => 'me'),
      taskProvider('my-task').overrideWith((ref) => myTask),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: RightPaneSelectionSync(child: SizedBox.shrink()),
        ),
      ),
    ));

    container.read(selectedTaskProvider.notifier).select('my-task');
    await tester.pump();

    expect(container.read(rightPaneProvider), RightPaneMode.editor,
        reason: 'tapping a task the user owns must open the docked '
            'editor — confirms the ownership gate only blocks teammate '
            'tasks');
  });
}
