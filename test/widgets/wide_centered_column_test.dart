import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_centered_column.dart';

/// TM-383: `WideCenteredColumn` is the single shared helper that Tasks,
/// Family, and Sprint screens use to constrain their list bodies to a
/// centered ~720dp column on the wide adaptive shell. Pin the contract
/// here so changing the max-width or the breakpoint gating is a one-file
/// edit caught by one test, not three.
///
/// Per-screen wrap-presence is exercised end-to-end by
/// `task_list_screen_selection_test.dart` (Tasks); Family and Sprint
/// rely on static evidence (each screen imports + wraps with
/// `WideCenteredColumn`) plus this helper-level contract test.
void main() {
  Future<void> pump(WidgetTester tester, Size logical, Widget child) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: WideCenteredColumn(child: child)),
    ));
  }

  testWidgets(
      'on wide (1280×800) wraps child in Center + ConstrainedBox(720)',
      (tester) async {
    const marker = Text('content');
    await pump(tester, const Size(1280, 800), marker);

    expect(find.text('content'), findsOneWidget);

    final wrap = find.byWidgetPredicate((w) =>
        w is ConstrainedBox &&
        w.constraints.maxWidth == WideCenteredColumn.maxWidth);
    expect(wrap, findsOneWidget,
        reason: 'expected ConstrainedBox(maxWidth: 720) on wide');
    expect(find.byType(Center), findsAtLeastNWidgets(1));
  });

  testWidgets(
      'on compact (800×600) returns child unchanged — no max-width wrap',
      (tester) async {
    const marker = Text('content');
    await pump(tester, const Size(800, 600), marker);

    expect(find.text('content'), findsOneWidget);

    final wrap = find.byWidgetPredicate((w) =>
        w is ConstrainedBox &&
        w.constraints.maxWidth == WideCenteredColumn.maxWidth);
    expect(wrap, findsNothing,
        reason: 'phone path must NOT add the max-width wrap');
  });

  testWidgets(
      'at the exact wide breakpoint (840×800) the wrap appears',
      (tester) async {
    const marker = Text('content');
    await pump(tester, const Size(840, 800), marker);

    final wrap = find.byWidgetPredicate((w) =>
        w is ConstrainedBox &&
        w.constraints.maxWidth == WideCenteredColumn.maxWidth);
    expect(wrap, findsOneWidget);
  });

  testWidgets(
      'on a wide-but-short landscape phone (844×390) no wrap (phone form)',
      (tester) async {
    const marker = Text('content');
    await pump(tester, const Size(844, 390), marker);

    final wrap = find.byWidgetPredicate((w) =>
        w is ConstrainedBox &&
        w.constraints.maxWidth == WideCenteredColumn.maxWidth);
    expect(wrap, findsNothing,
        reason: 'landscape phone is still phone (shortest-side rule)');
  });
}
