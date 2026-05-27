import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/database/app_database.dart' hide Area, Context;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_shortcuts.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';

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
      'then unfocused — FocusManager listener re-grabs focus from '
      'the root scope (TM-385 — regression for "search broke `n`/`/` '
      'until app restart")', (tester) async {
    final c = await pumpHarness(tester);

    // Step 1: focus the sidebar search via the / shortcut.
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pump();
    expect(c.read(sidebarSearchFocusNodeProvider).hasFocus, isTrue,
        reason: 'sanity: slash focuses the search node');

    // Step 2: simulate the user clicking away. unfocus() drops focus
    // to the root scope — the exact bug scenario where Shortcuts
    // stops dispatching.
    c.read(sidebarSearchFocusNodeProvider).unfocus();
    await tester.pump();
    // The FocusManager listener defers via microtask; drain it.
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNotNull,
        reason: 'shell focus listener should have re-grabbed focus '
            'rather than leaving primary focus null');

    // Step 3: `n` must STILL fire after the focus round-trip.
    expect(c.read(rightPaneProvider), RightPaneMode.empty);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.addingNewTask,
        reason: 'after the search field releases focus, the shell '
            'should re-grab it so subsequent shortcuts dispatch');
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
