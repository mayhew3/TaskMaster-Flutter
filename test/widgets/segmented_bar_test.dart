import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('SegmentedBar', () {
    testWidgets('renders default 1..N labels', (tester) async {
      await _pump(
        tester,
        SegmentedBar(value: null, segments: 5, onChanged: (_) {}),
      );
      for (var i = 1; i <= 5; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders custom labels when provided', (tester) async {
      await _pump(
        tester,
        SegmentedBar(
          value: 2,
          segments: 4,
          labels: const ['Days', 'Weeks', 'Months', 'Years'],
          onChanged: (_) {},
        ),
      );
      expect(find.text('Days'), findsOneWidget);
      expect(find.text('Weeks'), findsOneWidget);
      expect(find.text('Months'), findsOneWidget);
      expect(find.text('Years'), findsOneWidget);
    });

    testWidgets('tap on inactive segment emits its 1-based index',
        (tester) async {
      int? captured;
      await _pump(
        tester,
        SegmentedBar(
          value: null,
          segments: 5,
          onChanged: (v) => captured = v,
        ),
      );
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(captured, 3);
    });

    testWidgets('tap on active segment with allowZero=true emits null',
        (tester) async {
      int? captured = -1; // sentinel: not yet called
      await _pump(
        tester,
        SegmentedBar(
          value: 2,
          segments: 5,
          allowZero: true,
          onChanged: (v) => captured = v,
        ),
      );
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(captured, isNull);
    });

    testWidgets('tap on active segment with allowZero=false is a no-op',
        (tester) async {
      var callCount = 0;
      await _pump(
        tester,
        SegmentedBar(
          value: 2,
          segments: 5,
          allowZero: false,
          onChanged: (_) => callCount++,
        ),
      );
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(callCount, 0);
    });

    testWidgets('asserts labels.length == segments', (tester) async {
      expect(
        () => SegmentedBar(
          value: null,
          segments: 3,
          labels: const ['a', 'b'],
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });
}
