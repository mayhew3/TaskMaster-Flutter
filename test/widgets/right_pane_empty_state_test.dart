import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_empty_state.dart';

/// TM-383: the right-pane "Select a task" empty state. Pins the
/// visible-text + presence-of-magenta-badge + the static keyboard hint
/// pills (`N`, `/`, `J`, `K`) — non-functional in Story 2 but visible
/// per prototype.
void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RightPaneEmptyState()),
    ));
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

  testWidgets(
      'renders all four keyboard hint pills (TM-383)',
      (tester) async {
    await pump(tester);
    expect(find.text('N'), findsOneWidget);
    expect(find.text('/'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);
    expect(find.text('new task'), findsOneWidget);
    expect(find.text('search'), findsOneWidget);
    expect(find.text('next/prev'), findsOneWidget);
  });

  testWidgets(
      'renders the magenta check-badge (#D83AFF) (TM-383)',
      (tester) async {
    await pump(tester);
    // Find the badge Container by its brand-magenta fill color.
    final badge = find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final dec = w.decoration;
      if (dec is! BoxDecoration) return false;
      return dec.color == const Color(0xFFD83AFF);
    });
    expect(badge, findsOneWidget,
        reason: 'expected the 22dp magenta check badge to be present');
    // And the check glyph inside it.
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets(
      'renders the faint task-card glyph (Icons.checklist_outlined)',
      (tester) async {
    await pump(tester);
    expect(find.byIcon(Icons.checklist_outlined), findsOneWidget);
  });
}
