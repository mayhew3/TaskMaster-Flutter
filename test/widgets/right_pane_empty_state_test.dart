import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_empty_state.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// TM-383: the right-pane "Select a task" empty state. Pins the
/// visible-text + presence-of-magenta-badge + the static keyboard hint
/// pills (`N`, `/`, `J`, `K`) — non-functional in Story 2 but visible
/// per prototype.
void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RightPaneEmptyState())),
    );
  }

  testWidgets('renders the title text (TM-383)', (tester) async {
    await pump(tester);
    expect(find.text('Select a task'), findsOneWidget);
  });

  testWidgets('renders the subtitle copy (TM-383)', (tester) async {
    await pump(tester);
    expect(
      find.textContaining('Click any row to edit it here'),
      findsOneWidget,
    );
  });

  testWidgets('renders all four keyboard hint pills (TM-383)', (tester) async {
    await pump(tester);
    expect(find.text('N'), findsOneWidget);
    expect(find.text('/'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);
    expect(find.text('new task'), findsOneWidget);
    expect(find.text('search'), findsOneWidget);
    expect(find.text('next/prev'), findsOneWidget);
  });

  testWidgets('renders the magenta check-badge (TM-383)', (
    tester,
  ) async {
    await pump(tester);
    // Find the badge Container by its brand-magenta fill color.
    // Match against the canonical design token, not a hex literal, so
    // the test follows the brand color if it's ever retuned.
    final badge = find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final dec = w.decoration;
      if (dec is! BoxDecoration) return false;
      return dec.color == TaskColors.brandMagenta;
    });
    expect(
      badge,
      findsOneWidget,
      reason: 'expected the 22dp magenta check badge to be present',
    );
    // And the check glyph inside it.
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('renders the faint task-card glyph (Icons.checklist_outlined)', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byIcon(Icons.checklist_outlined), findsOneWidget);
  });

  testWidgets('at the minimum two-pane interior width (~320dp), the keyboard '
      'hint pills wrap cleanly without RenderFlex overflow (TM-383 '
      'regression — defends the Row→Wrap fix)', (tester) async {
    // 320dp ≈ the right-pane interior width at the minimum two-pane
    // viewport (1200 sidebar/380right and the empty-state's 30dp
    // padding on each side leaves ~320dp for the hint row).
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 400,
              child: RightPaneEmptyState(),
            ),
          ),
        ),
      ),
    );
    // If `_KeyboardHintRow` regressed back to a single `Row` (instead
    // of `Wrap`), this pump would emit a "RenderFlex overflowed by N
    // pixels" FlutterError captured by tester.takeException().
    expect(
      tester.takeException(),
      isNull,
      reason:
          'expected Wrap to absorb the narrow width without '
          'RenderFlex overflow',
    );
    // And the hint row should still render every keycap.
    expect(find.text('N'), findsOneWidget);
    expect(find.text('/'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);
  });
}
