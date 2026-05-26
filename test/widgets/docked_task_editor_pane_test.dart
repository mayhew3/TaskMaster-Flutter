import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/docked_task_editor_pane.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_container.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_empty_state.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_selection_sync.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/tasks/presentation/task_add_edit_screen.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/models/anchor_date.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_recurrence.dart';

import '../integration/integration_test_helper.dart';

/// TM-384 — the wide-layout docked editor pane.
///
/// The editor is integration-shaped (Firestore streams + Drift writes +
/// auto-close), so these reuse `IntegrationTestHelper.pumpAppWithLiveFirestore`
/// — the same live-Firestore harness the full-screen editor tests use —
/// with `homeOverride` to render the docked pane (or `RightPaneContainer`)
/// instead of the tabbed test home.
void main() {
  TaskItem seedTask({
    String docId = 'task-1',
    String name = 'Existing Task',
    String? area,
    int? priority,
  }) {
    return TaskItem((b) => b
      ..docId = docId
      ..name = name
      ..personDocId = 'test-person-123'
      ..dateAdded = DateTime.now().toUtc()
      ..area = area
      ..priority = priority
      ..priorityScaleVersion = 2
      ..completionDate = null
      ..retired = null
      ..offCycle = false
      ..pendingCompletion = false);
  }

  /// A right-pane-sized host for the docked editor, wrapped in the
  /// same `RightPaneSelectionSync` the wide shell uses in production
  /// — so selection changes drive `rightPaneProvider` here just like
  /// they do live.
  Widget paneHost(Widget child) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 380,
          child: RightPaneSelectionSync(child: child),
        ),
      );

  group('DockedTaskEditorPane — edit mode', () {
    testWidgets('a selected task populates the editor in-pane (TM-384)',
        (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [seedTask(name: 'Buy groceries', area: 'Home')],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );

      // With no selection the pane renders nothing — the right pane
      // container shows RightPaneEmptyState instead (see the routing
      // group below). The editor docks only once a task is selected.
      expect(find.text('TASK DETAILS'), findsNothing);

      container.read(selectedTaskProvider.notifier).select('task-1');
      await tester.pumpAndSettle();

      // Edit-mode header + the task's fields populated in the pane.
      expect(find.text('TASK DETAILS'), findsOneWidget);
      // "Home" shows in BOTH the header strip and the Area picker field.
      expect(find.text('Home'), findsNWidgets(2),
          reason: 'area appears once in the header strip and once in '
              'the Area picker chevron-button');
      expect(find.text('Buy groceries'), findsOneWidget);
      // The docked editor never pushes the full-screen route.
      expect(find.byType(TaskAddEditScreen), findsNothing);
    });

    testWidgets('switching selection re-keys the editor to the new task '
        '(TM-384)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [
          seedTask(docId: 'task-1', name: 'First task'),
          seedTask(docId: 'task-2', name: 'Second task'),
        ],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );

      container.read(selectedTaskProvider.notifier).select('task-1');
      await tester.pumpAndSettle();
      expect(find.text('First task'), findsOneWidget);

      container.read(selectedTaskProvider.notifier).select('task-2');
      await tester.pumpAndSettle();
      expect(find.text('Second task'), findsOneWidget);
      expect(find.text('First task'), findsNothing);
    });

    testWidgets('header carries Delete + Close (X) affordances in edit-mode '
        '(TM-384)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [seedTask()],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(selectedTaskProvider.notifier).select('task-1');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Cancel discards unsaved edits but keeps the editor open on '
        'the same task — symmetric with Save (TM-384)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [seedTask(name: 'Original name')],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      // Simulate the wide row tap which opens BOTH accordion and editor.
      // RightPaneSelectionSync (in paneHost) flips mode → .editor.
      container.read(selectedTaskProvider.notifier).select('task-1');
      container.read(expandedTaskProvider.notifier).toggle('task-1');
      await tester.pumpAndSettle();

      // Type an edit into the name field.
      await tester.enterText(
        find.byKey(const Key('task_name_field')),
        'Unsaved edit',
      );
      await tester.pump();
      expect(find.text('Unsaved edit'), findsOneWidget);

      // Tap Cancel. The editor must STAY OPEN on the same task, the
      // selection / pane mode / accordion all stay set, and the name
      // field reverts to the persisted value.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(container.read(selectedTaskProvider), 'task-1');
      expect(container.read(rightPaneProvider), RightPaneMode.editor);
      expect(container.read(expandedTaskProvider), 'task-1');
      expect(find.text('Original name'), findsOneWidget);
      expect(find.text('Unsaved edit'), findsNothing);
    });

    testWidgets('Save changes persists the edit and the editor stays open '
        'showing the NEW value (TM-384 — D5)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [seedTask(name: 'Original')],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(selectedTaskProvider.notifier).select('task-1');
      await tester.pumpAndSettle();
      expect(find.text('Original'), findsOneWidget);

      // Edit and save.
      await tester.enterText(
        find.byKey(const Key('task_name_field')),
        'Saved value',
      );
      await tester.pump();
      expect(find.text('Saved value'), findsOneWidget);

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Editor must stay open on the same task (D5) AND show the new
      // value — pre-fix the body re-keyed before the saved value
      // propagated, so the freshly-initialised body read the stale
      // original and showed it.
      expect(container.read(selectedTaskProvider), 'task-1');
      expect(container.read(rightPaneProvider), RightPaneMode.editor);
      expect(find.text('Saved value'), findsOneWidget);
      expect(find.text('Original'), findsNothing);
    });

    testWidgets('Save changes on a PICKER field (priority) persists AND the '
        'editor pane shows the NEW picker value after re-key (TM-384)',
        (tester) async {
      // Repros the user-reported bug: pickers (Priority, Duration,
      // Recur unit) appeared to revert after Save Changes even though
      // the list reflected the new values.
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [seedTask(name: 'P-task', priority: 2)],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(selectedTaskProvider.notifier).select('task-1');
      await tester.pumpAndSettle();
      // Initial priority hint reads "2/5".
      expect(find.text('2/5'), findsOneWidget);

      // Tap the priority "4" segment. Filter to Segments whose label
      // is '4' — the priority bar's labels are '1'..'5'; none of the
      // other pickers visible in the docked editor body label a
      // Segment as the bare string '4'.
      final priority4 = find
          .byWidgetPredicate((w) => w is Segment && w.label == '4')
          .first;
      await tester.tap(priority4);
      await tester.pump();
      expect(find.text('4/5'), findsOneWidget,
          reason: 'tap should set priority to 4');

      // Save and let the Drift write + stream re-emit + re-key settle.
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Editor must stay open (D5) AND the priority bar must still
      // show 4/5 — re-init from the saved task should reflect the
      // persisted picker value.
      expect(container.read(selectedTaskProvider), 'task-1');
      expect(find.text('4/5'), findsOneWidget,
          reason: 'priority should remain 4 after save; pre-fix the '
              'picker reverted to its pre-edit value despite the '
              'underlying task being correctly persisted');
      expect(find.text('2/5'), findsNothing,
          reason: 'priority must NOT revert to 2');
    });

    testWidgets('multi-field save (recurrence + non-recurrence) end-to-end: '
        'editor pane shows the NEW values for both after save (TM-384)',
        (tester) async {
      // The user-reported intermittent (~50%) regression that motivated
      // the `_checkForAutoClose` gate change:
      // `UpdateTask.call` writes the recurrence row BEFORE the task
      // row, so in production the recurrence Drift/Firestore stream
      // emits first. The pre-fix listener fired on that recurrence
      // emit with `latestTask` still stale (task write hadn't happened
      // yet), captured the pre-edit task as `savedTask`, and the
      // re-keyed body initialised from the pre-edit values — visually
      // reverting all of the user's edits even though the list (read
      // from a separate watcher path) showed the persisted values.
      //
      // Only manifests when the user edits both a recurrence field
      // (recurUnit / recurNumber / recurWait / anchor) AND a non-
      // recurrence task field (priority / duration / name / etc.) in
      // the same save.
      //
      // HARNESS CAVEAT: this test does NOT deterministically reproduce
      // the recurrence-first-emit ordering — fakeFirestore's write
      // ordering doesn't match production's exactly, so the race may
      // or may not exercise the gate fix in any given run. What it
      // DOES verify end-to-end is that a multi-field save (recurrence
      // + non-recurrence) leaves both fields showing their new values
      // in the docked editor, which is the user-visible contract the
      // fix protects. A regression of the gate (back to
      // `hasTaskChanges || hasRecurrenceChanges`) should fail this
      // test in production-like conditions; if it stops failing in
      // the harness, the gate's contract is unit-tested via
      // `shouldSelectSavedDocId` etc. (the listener half) but the
      // race itself ultimately needs manual smoke verification.
      final anchorDate = AnchorDate((b) => b
        ..dateValue = DateTime.utc(2026, 5, 6)
        ..dateType = TaskDateTypes.start);
      final recurrence = TaskRecurrence((b) => b
        ..docId = 'rec-1'
        ..personDocId = 'test-person-123'
        ..name = 'Recurring task'
        ..recurNumber = 2
        ..recurUnit = 'Weeks'
        ..recurWait = false
        ..recurIteration = 1
        ..dateAdded = DateTime.now().toUtc()
        ..anchorDate = anchorDate.toBuilder());
      final task = seedTask(name: 'Recurring task', priority: 2).rebuild(
        (b) => b
          ..startDate = DateTime.utc(2026, 5, 6)
          ..recurrenceDocId = 'rec-1'
          ..recurNumber = 2
          ..recurUnit = 'Weeks'
          ..recurWait = false
          ..recurIteration = 1,
      );

      // Tall viewport: the editor body needs ~1500dp to show every
      // field including the Repeat card without scrolling, since the
      // test taps both a priority segment (near top) and the recur
      // unit segment (near bottom).
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1500);
      addTearDown(tester.view.reset);

      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [task],
        initialRecurrences: [recurrence],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(selectedTaskProvider.notifier).select('task-1');
      await tester.pumpAndSettle();

      // Sanity: opened with priority=2 and recurUnit=Weeks.
      expect(find.text('2/5'), findsOneWidget);

      // Change BOTH fields:
      //  (a) priority 2 → 4 (non-recurrence task field).
      //  (b) recur unit Weeks → Days (recurrence field — triggers the
      //      racy recurrence-first write path in UpdateTask.call).
      await tester.tap(
        find.byWidgetPredicate((w) => w is Segment && w.label == '4').first,
      );
      await tester.pump();
      expect(find.text('4/5'), findsOneWidget);

      await tester.tap(find.widgetWithText(Segment, 'Days'));
      await tester.pump();

      // Save and let the writes settle.
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Editor must stay open on the same task AND show the NEW
      // values for BOTH fields. Pre-fix, the priority bar reverted
      // to "2/5" and the Unit bar reverted to Weeks because the
      // re-key fired on the recurrence emit with a stale `latestTask`.
      expect(container.read(selectedTaskProvider), 'task-1');
      expect(find.text('4/5'), findsOneWidget,
          reason: 'priority must remain 4 after save (was reverting to 2 '
              'before the fix when the recurrence emit fired success '
              'with a stale `latestTask` snapshot)');
      expect(find.text('2/5'), findsNothing);
      // Unit SegmentedBar: 'Days' label maps to value=1; the Unit bar is
      // the one whose labels are exactly the four recur units.
      const unitLabels = ['Days', 'Weeks', 'Months', 'Years'];
      final unitBar = tester.widget<SegmentedBar>(
        find.byWidgetPredicate((w) {
          if (w is! SegmentedBar) return false;
          final l = w.labels;
          return l != null &&
              l.length == 4 &&
              l[0] == unitLabels[0] &&
              l[1] == unitLabels[1] &&
              l[2] == unitLabels[2] &&
              l[3] == unitLabels[3];
        }),
      );
      expect(unitBar.value, 1,
          reason: 'recur unit must be "Days" (value=1) after save (was '
              'reverting to "Weeks" before the fix)');
    });

    testWidgets('Close (X) icon tears down the editor — clears selection, '
        'pane mode, and the inline accordion (TM-384)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [seedTask()],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      // paneHost wraps in RightPaneSelectionSync, so setting selection
      // also flips mode → .editor.
      container.read(selectedTaskProvider.notifier).select('task-1');
      container.read(expandedTaskProvider.notifier).toggle('task-1');
      await tester.pumpAndSettle();
      expect(container.read(expandedTaskProvider), 'task-1');

      // The header's Close (X) is the explicit "done with this task"
      // affordance — unlike Cancel, it should fully tear down the
      // editor and its associated row-level state.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(container.read(selectedTaskProvider), isNull);
      expect(container.read(rightPaneProvider), RightPaneMode.empty);
      expect(container.read(expandedTaskProvider), isNull);
    });
  });

  group('DockedTaskEditorPane — add mode', () {
    testWidgets('rightPaneProvider == .addingNewTask renders the editor '
        'in add-mode (no selection, "NEW TASK" header, no Delete icon) '
        '(TM-384)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      // Simulate the sidebar "+ Add task" tap on two-pane wide.
      container.read(selectedTaskProvider.notifier).clear();
      container.read(rightPaneProvider.notifier).setMode(
            RightPaneMode.addingNewTask,
          );
      await tester.pumpAndSettle();

      expect(find.text('NEW TASK'), findsOneWidget);
      expect(find.text('TASK DETAILS'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing,
          reason: 'add-mode has no task to delete');
      expect(find.text('Add task'), findsOneWidget,
          reason: 'sticky action bar shows the add-mode label');
      expect(find.byType(TaskAddEditScreen), findsNothing,
          reason: 'docked add-mode must not push the full-screen route');
    });

    testWidgets('the add→edit transition: _handleSaved\'s mode+selection '
        'writes flip the pane out of .addingNewTask into .editor for the '
        'newly-created task (TM-384)', (tester) async {
      // This tests the production transition that `_handleSaved`
      // performs after a successful add-mode save. The Drift-write
      // → SyncService-push → fakeFirestore-emit chain that triggers
      // `_checkForAutoClose` is flaky under pumpAndSettle (the
      // `.ignore()`d push doesn't reliably complete), so this test
      // drives the EXIT side of `_handleSaved` directly:
      //   1. setMode(.editor) — explicit so the SelectionSync gate
      //      doesn't no-op us (the gate exists so that a row tap
      //      during add-mode doesn't clobber the user's typing; it
      //      would also no-op this post-save transition unless we
      //      set the mode explicitly).
      //   2. select(savedDocId) — re-keys the body from `__add__`
      //      to the saved docId.
      final task = seedTask(docId: 'new-task', name: 'Newly-added task');
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [task],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(rightPaneProvider.notifier).setMode(
            RightPaneMode.addingNewTask,
          );
      await tester.pumpAndSettle();
      expect(find.text('NEW TASK'), findsOneWidget);
      expect(container.read(rightPaneProvider), RightPaneMode.addingNewTask);

      // Simulate the production transition (matches `_handleSaved`).
      container.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
      container.read(selectedTaskProvider.notifier).select('new-task');
      await tester.pumpAndSettle();

      // Pane re-keys body to the new task's docId; header now shows
      // TASK DETAILS instead of NEW TASK.
      expect(container.read(rightPaneProvider), RightPaneMode.editor);
      expect(container.read(selectedTaskProvider), 'new-task');
      expect(find.text('TASK DETAILS'), findsOneWidget);
      expect(find.text('NEW TASK'), findsNothing);
      expect(find.text('Newly-added task'), findsOneWidget);
    });

    testWidgets('Cancel in add-mode discards the new task and closes the '
        'pane (no task to re-baseline to) (TM-384)', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1500);
      addTearDown(tester.view.reset);

      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(rightPaneProvider.notifier).setMode(
            RightPaneMode.addingNewTask,
          );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task_name_field')),
        'Discarded',
      );
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Pane closes — unlike edit-mode Cancel which stays open.
      expect(container.read(rightPaneProvider), RightPaneMode.empty);
      expect(container.read(selectedTaskProvider), isNull);
    });
  });

  group('DockedTaskEditorPane — loading / error chrome', () {
    testWidgets('renders the header chrome (with Close icon) for an '
        'edit-mode task that hasn\'t loaded yet — user must always have '
        'an exit affordance even while the provider graph hydrates '
        '(TM-384 — Copilot R5 feedback)', (tester) async {
      // No `initialTasks` for the requested docId → taskProvider
      // returns null on first build → TaskEditorBody hits the
      // loading branch. Pre-fix it returned a bare
      // CircularProgressIndicator that bypassed headerBuilder
      // entirely, stranding the user in the docked pane with no
      // Close (X) until the load completed.
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );
      container.read(selectedTaskProvider.notifier).select('not-yet-loaded');
      // Single pump — no pumpAndSettle, the load NEVER resolves in
      // this harness (the task isn't seeded) which is exactly the
      // condition we're testing.
      await tester.pump();

      // Header chrome present even though body is loading.
      expect(find.text('TASK DETAILS'), findsOneWidget,
          reason: 'edit-mode header label must render while task '
              'is loading so the docked pane has a Close affordance');
      expect(find.byIcon(Icons.close), findsOneWidget,
          reason: 'Close (X) icon must be reachable during the load');
      // Delete is hidden during loading — we don't have a confirmed
      // task to delete yet.
      expect(find.byIcon(Icons.delete_outline), findsNothing,
          reason: 'Delete must NOT render before the task materializes '
              '(would dereference null taskItem on tap)');
      // The body's CircularProgressIndicator is rendered.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('DockedTaskEditorPane — no selection', () {
    testWidgets('with no selection the pane renders nothing (defensive — '
        'the editor is edit-mode only; add-task uses the full-screen '
        'route) (TM-384)', (tester) async {
      await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [],
        initialSprints: [],
        homeOverride: paneHost(const DockedTaskEditorPane()),
      );

      // No header, no action bar, no editor — the right pane container
      // routes to RightPaneEmptyState for the no-selection state.
      expect(find.text('TASK DETAILS'), findsNothing);
      expect(find.text('NEW TASK'), findsNothing);
      expect(find.text('Add task'), findsNothing);
      expect(find.text('Save changes'), findsNothing);
      expect(find.byType(TaskAddEditScreen), findsNothing);
    });
  });

  group('DockedTaskEditorPane.shouldSelectSavedDocId — _handleSaved gate', () {
    test('bumps selection only when add-mode AND docId non-empty (TM-384)',
        () {
      // Add-mode + valid docId → bump.
      expect(
        DockedTaskEditorPane.shouldSelectSavedDocId(
            savedDocId: 'new-task', wasAddMode: true),
        isTrue,
      );
      // Edit-mode → never bump (the user is already on the right task).
      expect(
        DockedTaskEditorPane.shouldSelectSavedDocId(
            savedDocId: 'existing', wasAddMode: false),
        isFalse,
      );
      // Add-mode with EMPTY docId → never bump. Defends against an
      // AddTask.call failure where _pendingAddFuture resolved to '';
      // selecting an empty docId would route the next build to .editor
      // with a non-null but invalid selection, breaking the pane.
      expect(
        DockedTaskEditorPane.shouldSelectSavedDocId(
            savedDocId: '', wasAddMode: true),
        isFalse,
      );
      // Defence-in-depth: edit-mode + empty → still no-op.
      expect(
        DockedTaskEditorPane.shouldSelectSavedDocId(
            savedDocId: '', wasAddMode: false),
        isFalse,
      );
    });
  });

  group('RightPaneContainer routing', () {
    testWidgets('renders the docked editor for RightPaneMode.editor and the '
        'empty state for .empty (TM-384)', (tester) async {
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [],
        initialSprints: [],
        homeOverride: paneHost(const RightPaneContainer()),
      );

      // Defaults to the empty state.
      expect(find.byType(RightPaneEmptyState), findsOneWidget);
      expect(find.byType(DockedTaskEditorPane), findsNothing);

      container.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
      await tester.pumpAndSettle();

      expect(find.byType(DockedTaskEditorPane), findsOneWidget);
      expect(find.byType(RightPaneEmptyState), findsNothing);
    });

    testWidgets('routes RightPaneMode.addingNewTask to the docked editor in '
        'add-mode (TM-384)', (tester) async {
      // The container's switch arm for .addingNewTask was previously
      // not asserted — a regression that routed the new enum value to
      // the .viewOptions placeholder (or anywhere else) would not fail
      // any test even though the sidebar Add Task button's whole flow
      // depends on this arm.
      final container = await IntegrationTestHelper.pumpAppWithLiveFirestore(
        tester,
        initialTasks: [],
        initialSprints: [],
        homeOverride: paneHost(const RightPaneContainer()),
      );

      container.read(rightPaneProvider.notifier).setMode(
            RightPaneMode.addingNewTask,
          );
      await tester.pumpAndSettle();

      expect(find.byType(DockedTaskEditorPane), findsOneWidget);
      expect(find.byType(RightPaneEmptyState), findsNothing);
      expect(find.text('NEW TASK'), findsOneWidget,
          reason: 'editor body in add-mode renders the NEW TASK header');
    });
  });
}
