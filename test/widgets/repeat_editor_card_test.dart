import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/repeat_editor_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

RepeatEditorCard _card({
  bool enabled = false,
  int? number,
  String? unit,
  String? anchor,
  void Function(bool)? onEnabledChanged,
  void Function(int?)? onNumberChanged,
  void Function(String?)? onUnitChanged,
  void Function(String?)? onAnchorChanged,
  String? disabledReason,
  bool showValidationErrors = false,
}) {
  return RepeatEditorCard(
    enabled: enabled,
    number: number,
    unit: unit,
    anchor: anchor,
    onEnabledChanged: onEnabledChanged ?? (_) {},
    onNumberChanged: onNumberChanged ?? (_) {},
    onUnitChanged: onUnitChanged ?? (_) {},
    onAnchorChanged: onAnchorChanged ?? (_) {},
    disabledReason: disabledReason,
    showValidationErrors: showValidationErrors,
  );
}

void main() {
  group('RepeatEditorCard', () {
    testWidgets('disabled state hides the inner controls', (tester) async {
      await _pump(tester, _card(enabled: false));
      expect(find.text('Does not repeat'), findsOneWidget);
      // Inner labels should not be visible.
      expect(find.text('EVERY'), findsNothing);
      expect(find.text('UNIT'), findsNothing);
      expect(find.text('ANCHOR'), findsNothing);
    });

    testWidgets('enabled state shows Every/Unit/Anchor', (tester) async {
      await _pump(
        tester,
        _card(enabled: true, number: 3, unit: 'Weeks', anchor: 'Completed Date'),
      );
      expect(find.text('EVERY'), findsOneWidget);
      expect(find.text('UNIT'), findsOneWidget);
      expect(find.text('ANCHOR'), findsOneWidget);
      // Header sentence summarizes the rule.
      expect(find.textContaining('Repeats every 3 weeks'), findsOneWidget);
    });

    testWidgets('toggle calls onEnabledChanged', (tester) async {
      bool? captured;
      await _pump(
        tester,
        _card(
          enabled: false,
          onEnabledChanged: (v) => captured = v,
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(captured, true);
    });

    testWidgets('selecting a unit calls onUnitChanged', (tester) async {
      String? captured;
      await _pump(
        tester,
        _card(
          enabled: true,
          number: 3,
          unit: 'Weeks',
          anchor: 'Completed Date',
          onUnitChanged: (v) => captured = v,
        ),
      );
      await tester.tap(find.text('Months'));
      await tester.pumpAndSettle();
      expect(captured, 'Months');
    });

    testWidgets('selecting an anchor calls onAnchorChanged', (tester) async {
      String? captured;
      await _pump(
        tester,
        _card(
          enabled: true,
          number: 3,
          unit: 'Weeks',
          anchor: 'Completed Date',
          onAnchorChanged: (v) => captured = v,
        ),
      );
      await tester.tap(find.text('Schedule Dates'));
      await tester.pumpAndSettle();
      expect(captured, 'Schedule Dates');
    });

    testWidgets(
      'showValidationErrors=true with all fields missing renders Required '
      'captions and an inline TextField error',
      (tester) async {
        await _pump(
          tester,
          _card(
            enabled: true,
            number: null,
            unit: null,
            anchor: null,
            showValidationErrors: true,
          ),
        );
        // Two segmented bars (unit + anchor) get an inline "Required"
        // caption underneath; the every-N TextField shows its error via
        // InputDecoration.errorText (also "Required").
        expect(find.text('Required'), findsNWidgets(3));
      },
    );

    testWidgets(
      'showValidationErrors=true clears the unit caption once a unit is set',
      (tester) async {
        await _pump(
          tester,
          _card(
            enabled: true,
            number: 3,
            unit: 'Weeks',
            anchor: null,
            showValidationErrors: true,
          ),
        );
        // Only anchor still missing → exactly one Required caption.
        expect(find.text('Required'), findsOneWidget);
      },
    );

    testWidgets(
      'showValidationErrors=false hides all Required indicators',
      (tester) async {
        await _pump(
          tester,
          _card(enabled: true, number: null, unit: null, anchor: null),
        );
        // No validation triggered → no caption / errorText, even though
        // every required field is missing.
        expect(find.text('Required'), findsNothing);
      },
    );

    testWidgets('disabledReason renders message and hides toggle',
        (tester) async {
      await _pump(
        tester,
        _card(
          enabled: false,
          disabledReason: "Repeating tasks aren't supported in family view yet.",
        ),
      );
      expect(
        find.textContaining("Repeating tasks aren't supported"),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNothing);
    });
  });
}
