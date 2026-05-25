import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_selection_sync.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';

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
  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer(overrides: [
      // SelectedTask / RightPane watch personDocIdProvider for the
      // cross-user reset (TM-384 pre-push review). Stub so the auth
      // chain doesn't try to wire up Firebase Auth in this widget-test
      // environment.
      personDocIdProvider.overrideWith((ref) => 'test-person'),
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
}
