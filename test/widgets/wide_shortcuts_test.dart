import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/database/app_database.dart' hide Area, Context;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/core/services/task_completion_service.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/family/providers/family_task_filter_providers.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_shortcuts.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/features/tasks/providers/task_filter_providers.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/top_nav_item.dart';

import '../helpers/async_provider_helpers.dart';

/// TM-385 — WideShortcuts wraps the wide-shell row in `Shortcuts`
/// + `Actions`. These tests pin the binding → Intent → provider
/// effect for each shortcut, without spinning up the full shell.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpHarness(WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: WideShortcuts(
            child: Scaffold(
              // Focus target so key events reach the Shortcuts widget,
              // PLUS an offscreen Focus that adopts the sidebar
              // search FocusNode so its `requestFocus` actually
              // takes effect (FocusNodes need to be attached to a
              // widget to receive focus).
              body: Column(children: [
                _SearchFocusAttacher(),
                Expanded(child: Center(child: _AutoFocusedSink())),
              ]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('bare `n` invokes AddNewTaskIntent → flips pane to '
      '.addingNewTask + clears selection + collapses accordion '
      '(TM-385 — bare key, no modifier, because Cmd/Ctrl+N is '
      'intercepted by the browser)', (tester) async {
    final c = await pumpHarness(tester);
    // Pre-state: seed selection + expanded accordion so the post-key
    // assertions aren't trivially true.
    c.read(selectedTaskProvider.notifier).select('seed');
    c.read(expandedTaskProvider.notifier).toggle('seed');
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask);
    expect(c.read(selectedTaskProvider), isNull,
        reason: 'add-mode entry clears prior selection');
    expect(c.read(expandedTaskProvider), isNull,
        reason: 'add-mode entry collapses any expanded accordion');
  });

  testWidgets('Slash key focuses the sidebar search FocusNode '
      'EVEN WHEN NO TASK IS SELECTED (TM-385 — the autofocus Focus '
      'in WideShortcuts is what makes this work on first load)',
      (tester) async {
    final c = await pumpHarness(tester);
    // No selection, no prior focused row — only the autofocus Focus
    // is anchoring the Shortcuts widget. Without that anchor the
    // slash key would never reach FocusSearchIntent.
    expect(c.read(selectedTaskProvider), isNull);
    expect(c.read(sidebarSearchFocusNodeProvider).hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pump();

    expect(c.read(sidebarSearchFocusNodeProvider).hasFocus, isTrue,
        reason: 'FocusSearchIntent calls requestFocus() on the shared '
            'FocusNode that the sidebar TextField attaches to — and '
            'this must work on first load, before the user has '
            'clicked any row');
  });

  testWidgets('e key invokes EditSelectedIntent → flips pane to .editor '
      'WHEN selection exists (TM-385)', (tester) async {
    final c = await pumpHarness(tester);
    c.read(selectedTaskProvider.notifier).select('docA');
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.editor);
  });

  testWidgets('e key with no selection is a no-op (TM-385)', (tester) async {
    final c = await pumpHarness(tester);
    expect(c.read(selectedTaskProvider), isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty,
        reason: 'EditSelectedIntent with no selection should not flip '
            'the pane');
  });

  testWidgets('shortcuts still fire AFTER a TextField was focused and '
      'then unfocused (TM-385 — regression for "search broke `n`/`/` '
      'until app restart"). Pins HardwareKeyboard.addHandler '
      'focus-independence: the handler runs regardless of where '
      'primaryFocus lives (including the root scope after unfocus), '
      'so prior Shortcuts-tree behavior — where focus collapse to '
      'root silenced every binding — does not regress.',
      (tester) async {
    final c = await pumpHarness(tester);

    // Step 1: focus the sidebar search via the / shortcut.
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pump();
    expect(c.read(sidebarSearchFocusNodeProvider).hasFocus, isTrue,
        reason: 'sanity: slash focuses the search node');

    // Step 2: simulate the user clicking away. unfocus() drops focus
    // to the root scope — the exact bug scenario where the prior
    // Shortcuts-tree dispatch went silent.
    c.read(sidebarSearchFocusNodeProvider).unfocus();
    await tester.pump();

    // Step 3: `n` must STILL fire — the HardwareKeyboard handler runs
    // even when no widget currently holds primary focus.
    expect(c.read(rightPaneProvider), RightPaneMode.empty);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask,
        reason: 'HardwareKeyboard.addHandler dispatch is focus-tree '
            'independent — `n` should still flip the pane after the '
            'search field released focus');
  });

  testWidgets('shortcuts do NOT fire while a TextField has focus '
      '(TM-385 — TextField focus intercepts keystrokes before '
      'Shortcuts sees them)', (tester) async {
    final c = await pumpHarness(tester);
    c.read(selectedTaskProvider.notifier).select('docA');
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    // Re-pump with a TextField that grabs focus.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: WideShortcuts(
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue,
        reason: 'TextField should have focus after autofocus pump');
    // Pre-state: pane is empty. If EditSelectedIntent fired despite
    // TextField focus, mode would flip to .editor (selection exists).
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty,
        reason: 'TextField focus must intercept the keystroke before '
            'Shortcuts can fire EditSelectedIntent — otherwise typing '
            "into a text field would silently move the user's editor "
            'around');
  });

  // ─── j/k navigation + c completion (TM-385) ──────────────────────
  //
  // These tests pump the same WideShortcuts harness as above but with
  // a populated Tasks/Family surface (grouped tasks override) so the
  // `_moveSelection` / `_completeSelected` paths have a real list to
  // walk. Destination is overridden directly via
  // `activeNavDestinationProvider` rather than driving the tab index,
  // so the test stays decoupled from `riverpod_app.dart`'s tab layout.

  TaskItem _task(String docId, String name,
      {String personDocId = 'test-person', DateTime? completionDate}) {
    return TaskItem(
      (b) => b
        ..docId = docId
        ..name = name
        ..personDocId = personDocId
        ..completionDate = completionDate
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc(),
    );
  }

  Future<ProviderContainer> pumpHarnessWith(
    WidgetTester tester, {
    required NavDestination destination,
    List<TaskItem> tasksOnTasks = const [],
    List<TaskItem> tasksOnFamily = const [],
    _RecordingCompleteTask? completeRecorder,
  }) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    TaskGroupResult _wrap(List<TaskItem> ts) => TaskGroupResult(
          key: 'g',
          displayName: '',
          displayOrder: 1,
          tasks: ts,
        );

    final overrides = [
      databaseProvider.overrideWithValue(db),
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      activeNavDestinationProvider.overrideWith((ref) => destination),
      groupedTasksProvider.overrideWith((ref) async => [_wrap(tasksOnTasks)]),
      familyGroupedTasksProvider.overrideWith((ref) => [_wrap(tasksOnFamily)]),
      if (completeRecorder != null)
        completeTaskProvider.overrideWith(() => completeRecorder),
    ];

    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: WideShortcuts(
            child: Scaffold(
              body: Column(children: [
                _SearchFocusAttacher(),
                Expanded(child: Center(child: _AutoFocusedSink())),
              ]),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // Materialize the async grouped-tasks provider so
    // `_flatDocIdsForActiveSurface` sees `.value` populated rather
    // than the initial AsyncLoading state. `readAsyncValue` avoids the
    // `.future` hang documented in `async_provider_helpers.dart` /
    // memory `project_riverpod4_future_hang`.
    await readAsyncValue(container, groupedTasksProvider);
    await tester.pump();
    return container;
  }

  testWidgets('j with no selection selects the first row AND expands it '
      '(TM-385 — j/k co-fires accordion alongside selection so the '
      'focused card stays in sync)', (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A'), _task('b', 'B'), _task('c', 'C')],
    );
    expect(c.read(selectedTaskProvider), isNull);
    expect(c.read(expandedTaskProvider), isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pump();

    expect(c.read(selectedTaskProvider), 'a');
    expect(c.read(expandedTaskProvider), 'a',
        reason: 'j must co-fire expandedTaskProvider.toggle on the '
            'newly-selected docId so the accordion follows selection');
  });

  testWidgets('k with no selection selects the LAST row (TM-385)',
      (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A'), _task('b', 'B'), _task('c', 'C')],
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();

    expect(c.read(selectedTaskProvider), 'c');
    expect(c.read(expandedTaskProvider), 'c');
  });

  testWidgets('j past the end of the list is a no-op — selection AND '
      'accordion both stay (TM-385 — clamp guard)', (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A'), _task('b', 'B')],
    );
    c.read(selectedTaskProvider.notifier).select('b');
    c.read(expandedTaskProvider.notifier).toggle('b');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pump();

    expect(c.read(selectedTaskProvider), 'b');
    expect(c.read(expandedTaskProvider), 'b');
  });

  testWidgets('j mid-list advances selection AND accordion in lockstep '
      '(TM-385)', (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A'), _task('b', 'B'), _task('c', 'C')],
    );
    c.read(selectedTaskProvider.notifier).select('a');
    c.read(expandedTaskProvider.notifier).toggle('a');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pump();

    expect(c.read(selectedTaskProvider), 'b');
    expect(c.read(expandedTaskProvider), 'b');
  });

  testWidgets('c with no selection is a no-op (TM-385)', (tester) async {
    final recorder = _RecordingCompleteTask();
    await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A')],
      completeRecorder: recorder,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();

    expect(recorder.calls, isEmpty,
        reason: 'no selection → no completeTask dispatch');
  });

  testWidgets('c on Tasks fires completeTaskProvider with the selected '
      'task (TM-385)', (tester) async {
    final recorder = _RecordingCompleteTask();
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'Apple'), _task('b', 'Bear')],
      completeRecorder: recorder,
    );
    c.read(selectedTaskProvider.notifier).select('b');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();

    expect(recorder.calls.length, 1);
    expect(recorder.calls.single.task.docId, 'b');
    expect(recorder.calls.single.complete, isTrue,
        reason: 'task was incomplete → toggle should mark complete=true');
  });

  testWidgets('c on Stats is a no-op (no list surface) (TM-385)',
      (tester) async {
    final recorder = _RecordingCompleteTask();
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.stats,
      tasksOnTasks: [_task('a', 'A')],
      completeRecorder: recorder,
    );
    c.read(selectedTaskProvider.notifier).select('a');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();

    expect(recorder.calls, isEmpty,
        reason: 'Stats has no list surface → completeTask must not fire');
  });

  testWidgets('c on Family with a teammate-owned task is a no-op '
      '(TM-385 — ownership guard mirrors RightPaneSelectionSync)',
      (tester) async {
    final recorder = _RecordingCompleteTask();
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.family,
      tasksOnFamily: [
        _task('mine', 'Mine'),
        _task('theirs', 'Theirs', personDocId: 'other-person'),
      ],
      completeRecorder: recorder,
    );
    c.read(selectedTaskProvider.notifier).select('theirs');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();

    expect(recorder.calls, isEmpty,
        reason: 'teammate-owned task → guard bails before completeTask');
  });

  // ─── Modifier guard (TM-385) ──────────────────────────────────────
  //
  // Bare-character shortcuts must NOT fire when a modifier is held —
  // Cmd+J / Ctrl+N etc. belong to the OS / browser, and treating
  // capital Shift+N as a "new task" trigger would also surprise users.

  testWidgets('Ctrl+N does NOT fire AddNewTaskIntent (TM-385 modifier '
      'guard)', (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A')],
    );
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty,
        reason: 'modifier combos belong to the OS; bare-key shortcut '
            'handler must skip when Ctrl is held');
  });

  testWidgets('Shift+N does NOT fire AddNewTaskIntent (TM-385 modifier '
      'guard — capital N is a typed character, not a shortcut)',
      (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A')],
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
  });

  // ─── _resetPerTabState preserves .viewOptions (TM-385) ─────────────
  //
  // The TM-385 change to navigation_provider.dart's `_resetPerTabState`
  // gates the right-pane reset on `mode != .viewOptions`. Switching
  // tabs while the View Options panel is open must:
  //   (a) preserve the .viewOptions mode (panel re-renders for the new
  //       surface),
  //   (b) still clear the selection (a task selected on one surface
  //       may not exist on the new one).

  testWidgets('_resetPerTabState preserves .viewOptions across tab '
      'switch but clears selection (TM-385)', (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A')],
    );
    // Seed: in View Options mode + a selection.
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
    c.read(selectedTaskProvider.notifier).select('a');

    // Switch tab (which triggers the per-tab reset path).
    c.read(activeTabIndexProvider.notifier).setTab(1);
    // setTab defers state writes via scheduleMicrotask; drain the
    // microtask queue before asserting.
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.viewOptions,
        reason: '.viewOptions must survive tab switches so the panel '
            're-renders for the new surface');
    expect(c.read(selectedTaskProvider), isNull,
        reason: 'selection clears because a docId from one surface may '
            'not exist on the new one');
  });

  testWidgets('_resetPerTabState resets non-viewOptions modes back to '
      '.empty on tab switch (TM-385 control case for the preservation '
      'gate above)', (tester) async {
    final c = await pumpHarnessWith(
      tester,
      destination: NavDestination.tasks,
      tasksOnTasks: [_task('a', 'A')],
    );
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);

    c.read(activeTabIndexProvider.notifier).setTab(1);
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
  });
}

class _CompleteCall {
  final TaskItem task;
  final bool complete;
  _CompleteCall(this.task, {required this.complete});
}

/// Records every `call()` invocation so tests can assert what the
/// shortcut handler dispatched without spinning up Drift + Firestore.
class _RecordingCompleteTask extends CompleteTask {
  final calls = <_CompleteCall>[];

  @override
  FutureOr<void> build() {}

  @override
  Future<void> call(TaskItem task, {required bool complete}) async {
    calls.add(_CompleteCall(task, complete: complete));
  }
}

/// Pumps a hidden Focus widget that adopts the sidebar search
/// FocusNode from `sidebarSearchFocusNodeProvider`, so
/// `requestFocus()` calls during the test actually take effect.
/// (A bare FocusNode that isn't installed on any widget can't
/// claim focus — there's no widget context for the focus manager
/// to walk.)
class _SearchFocusAttacher extends ConsumerWidget {
  const _SearchFocusAttacher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      focusNode: ref.watch(sidebarSearchFocusNodeProvider),
      child: const SizedBox.shrink(),
    );
  }
}

/// Invisible widget that grabs focus on first build so key events
/// have somewhere to land (otherwise they're routed to the platform
/// nowhere and Shortcuts never fires).
class _AutoFocusedSink extends StatefulWidget {
  const _AutoFocusedSink();

  @override
  State<_AutoFocusedSink> createState() => _AutoFocusedSinkState();
}

class _AutoFocusedSinkState extends State<_AutoFocusedSink> {
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _node.requestFocus());
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(focusNode: _node, child: const SizedBox.shrink());
  }
}
