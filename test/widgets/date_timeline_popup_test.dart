import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_timeline_popup.dart';
import 'package:taskmaestro/models/task_date_type.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<TaskDateType, DateTime?> dates,
  void Function(TaskDateType, DateTime?) onChanged,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DateTimelinePopup(
          dates: dates,
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

void main() {
  group('DateTimelinePopup', () {
    testWidgets('renders empty-state hint when no dates set', (tester) async {
      final dates = {for (final t in TaskDateTypes.allTypes) t: null};
      await _pump(tester, dates, (_, __) {});
      expect(find.text('Tap a date type below to add it.'), findsOneWidget);
    });

    testWidgets('renders an Add pill for each unset date type',
        (tester) async {
      final dates = <TaskDateType, DateTime?>{
        TaskDateTypes.start: DateTime(2026, 5, 1),
        TaskDateTypes.target: null,
        TaskDateTypes.urgent: null,
        TaskDateTypes.due: null,
      };
      await _pump(tester, dates, (_, __) {});
      // Section header.
      expect(find.text('ADD A DATE'), findsOneWidget);
      // Three Add pills for unset types.
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
    });

    testWidgets('renders a marker label for each set date type',
        (tester) async {
      final dates = <TaskDateType, DateTime?>{
        TaskDateTypes.start: DateTime(2026, 5, 1),
        TaskDateTypes.target: DateTime(2026, 5, 6),
        TaskDateTypes.urgent: null,
        TaskDateTypes.due: DateTime(2026, 5, 25),
      };
      await _pump(tester, dates, (_, __) {});
      // Marker labels are uppercased.
      expect(find.text('START'), findsOneWidget);
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.text('DUE'), findsOneWidget);
      // No Urgent marker since unset; Urgent shows as an Add pill instead.
      expect(find.text('URGENT'), findsNothing);
      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets(
      'adding a date is committed via onChanged when Save is tapped',
      (tester) async {
        final dates = {for (final t in TaskDateTypes.allTypes) t: null};
        TaskDateType? capturedType;
        DateTime? capturedDate;
        await _pump(tester, dates, (t, d) {
          capturedType = t;
          capturedDate = d;
        });

        // Add Start; the popup updates internally but doesn't fire
        // onChanged yet — that only happens on Save.
        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();
        expect(capturedType, isNull,
            reason: 'Add should be deferred until the user taps Save.');

        // Tap Save in the header.
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(capturedType, TaskDateTypes.start);
        expect(capturedDate, isNotNull);
      },
    );

    testWidgets(
      'Cancel discards an add — onChanged is never called',
      (tester) async {
        final dates = {for (final t in TaskDateTypes.allTypes) t: null};
        var calls = 0;
        await _pump(tester, dates, (_, __) => calls++);

        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(calls, 0,
            reason: 'Cancel must drop pending edits, not commit them.');
      },
    );

    testWidgets(
      'Remove + Save commits a null for the removed type',
      (tester) async {
        final dates = <TaskDateType, DateTime?>{
          TaskDateTypes.start: DateTime(2026, 5, 1),
          TaskDateTypes.target: null,
          TaskDateTypes.urgent: null,
          TaskDateTypes.due: null,
        };
        DateTime? captured = DateTime(2099); // sentinel
        TaskDateType? capturedType;
        await _pump(tester, dates, (t, d) {
          capturedType = t;
          captured = d;
        });
        // Selected detail should already be visible for the only set date.
        expect(find.text('Start date'), findsOneWidget);
        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        // Save commits the removal.
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(capturedType, TaskDateTypes.start);
        expect(captured, isNull);
      },
    );

    testWidgets(
      'Save without changes does not call onChanged',
      (tester) async {
        final dates = <TaskDateType, DateTime?>{
          TaskDateTypes.start: DateTime(2026, 5, 1),
          TaskDateTypes.target: null,
          TaskDateTypes.urgent: null,
          TaskDateTypes.due: null,
        };
        var calls = 0;
        await _pump(tester, dates, (_, __) => calls++);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(calls, 0,
            reason: 'Save should diff against the initial dates and only '
                'emit for changed types.');
      },
    );
  });
}
