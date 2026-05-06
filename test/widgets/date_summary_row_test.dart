import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_summary_row.dart';
import 'package:taskmaestro/models/task_date_type.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('DateSummaryRow', () {
    testWidgets('shows "No dates set" when all dates are null',
        (tester) async {
      final dates = {for (final t in TaskDateTypes.allTypes) t: null};
      await _pump(
        tester,
        DateSummaryRow(dates: dates, onTap: () {}),
      );
      expect(find.text('No dates set'), findsOneWidget);
    });

    testWidgets('renders pills only for set dates with x/4 counter',
        (tester) async {
      final dates = <TaskDateType, DateTime?>{
        TaskDateTypes.start: DateTime(2026, 5, 1),
        TaskDateTypes.target: null,
        TaskDateTypes.urgent: DateTime(2026, 5, 14),
        TaskDateTypes.due: DateTime(2026, 5, 25),
      };
      await _pump(
        tester,
        DateSummaryRow(dates: dates, onTap: () {}),
      );
      expect(find.text('START'), findsOneWidget);
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('DUE'), findsOneWidget);
      expect(find.text('TARGET'), findsNothing);
      expect(find.text('3/4'), findsOneWidget);
    });

    testWidgets('formats dates as "Mon D"', (tester) async {
      final dates = <TaskDateType, DateTime?>{
        for (final t in TaskDateTypes.allTypes) t: null,
      };
      dates[TaskDateTypes.due] = DateTime(2026, 5, 25);
      await _pump(
        tester,
        DateSummaryRow(dates: dates, onTap: () {}),
      );
      expect(find.text('May 25'), findsOneWidget);
    });

    testWidgets('onTap fires when row is tapped', (tester) async {
      var taps = 0;
      final dates = {for (final t in TaskDateTypes.allTypes) t: null};
      await _pump(
        tester,
        DateSummaryRow(dates: dates, onTap: () => taps++),
      );
      await tester.tap(find.text('No dates set'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });
}
