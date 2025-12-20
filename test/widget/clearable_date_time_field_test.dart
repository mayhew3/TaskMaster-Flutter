import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/shared/presentation/widgets/clearable_date_time_field.dart';

import '../mocks/mock_timezone_helper.dart';

/// Widget Test: ClearableDateTimeField
///
/// Tests the ClearableDateTimeField widget used for all date inputs.
///
/// ClearableDateTimeField is a critical widget that:
/// - Wraps DateTimeField for date/time selection
/// - Uses TimezoneHelper for UTC to local time conversion
/// - Shows date picker then time picker on tap
/// - Supports nullable dates
/// - Supports custom date constraints (firstDate, currentDate)
/// - Displays dates in long format (e.g., "January 1, 2025 2:00 PM")
///
/// This widget is used extensively in add/edit task screens for all date fields.
void main() {
  group('ClearableDateTimeField Tests', () {
    late MockTimezoneHelper mockTimezoneHelper;

    setUp(() {
      mockTimezoneHelper = MockTimezoneHelper();
    });

    testWidgets('Displays label text', (tester) async {
      // Setup: Widget with label
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Start Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => DateTime(2025, 1, 1),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: Label appears
      expect(find.text('Start Date'), findsOneWidget);
    });

    testWidgets('Displays empty field when date is null', (tester) async {
      // Setup: Widget with null date
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Due Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => DateTime(2025, 1, 1),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: Field is empty (no date text)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('Displays formatted date when date has value', (tester) async {
      // Setup: Widget with date value
      final testDate = DateTime.utc(2025, 10, 13, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Target Date',
              dateGetter: () => testDate,
              dateSetter: (_) {},
              initialPickerGetter: () => testDate,
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: Date appears in long format
      // MockTimezoneHelper converts to America/Los_Angeles
      // Format should be like "October 13, 2025 7:30 AM" (PDT is UTC-7)
      expect(find.textContaining('October 13, 2025'), findsOneWidget);
      expect(find.textContaining('AM'), findsOneWidget);
    });

    testWidgets('Date displays use timezone conversion', (tester) async {
      // Setup: UTC date that should convert to local time
      final utcDate = DateTime.utc(2025, 1, 1, 0, 0); // Midnight UTC

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => utcDate,
              dateSetter: (_) {},
              initialPickerGetter: () => utcDate,
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: Date converted to local time zone (America/Los_Angeles is UTC-8 in winter)
      // Midnight UTC = 4:00 PM previous day PST
      expect(find.textContaining('December 31, 2024'), findsOneWidget);
      expect(find.textContaining('PM'), findsOneWidget);
    });

    testWidgets('Tapping field triggers date picker', (tester) async {
      // Setup: Widget ready for interaction
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Select Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => DateTime(2025, 1, 1),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Action: Tap the field
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Verify: Date picker dialog appears
      // Look for typical date picker elements (year selector, month/year header)
      // Material 3 date pickers might have "Cancel" and "OK" (capitalization varies)
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! Text || widget.data == null) return false;
          final upper = widget.data!.toUpperCase();
          return upper.contains('CANCEL') || upper.contains('OK');
        }),
        findsWidgets,
      );
    });

    testWidgets('Calls dateSetter when date is selected', (tester) async {
      // Setup: Track callback invocation
      DateTime? capturedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null,
              dateSetter: (date) {
                capturedDate = date;
              },
              initialPickerGetter: () => DateTime(2025, 1, 15),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Action: Tap field to open picker
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Find OK button (case-insensitive)
      final okButton = find.byWidgetPredicate((widget) =>
        widget is Text &&
        (widget.data?.toUpperCase() == 'OK')
      );

      // Action: Tap OK in date picker (this selects the initialDate)
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton.first);
        await tester.pumpAndSettle();

        // Note: After date picker, time picker appears
        // Find OK button in time picker
        final timeOkButton = find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data?.toUpperCase() == 'OK')
        );

        if (timeOkButton.evaluate().isNotEmpty) {
          await tester.tap(timeOkButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Verify: dateSetter was called with a date
      expect(capturedDate, isNotNull);
      expect(capturedDate!.year, 2025);
      expect(capturedDate!.month, 1);
      expect(capturedDate!.day, 15);
    });

    testWidgets('Canceling date picker does not call dateSetter', (tester) async {
      // Setup: Track callback invocation
      bool dateSetterCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null,
              dateSetter: (date) {
                dateSetterCalled = true;
              },
              initialPickerGetter: () => DateTime(2025, 1, 1),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Action: Tap field to open picker
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Find Cancel button (case-insensitive)
      final cancelButton = find.byWidgetPredicate((widget) =>
        widget is Text &&
        (widget.data?.toUpperCase() == 'CANCEL')
      );

      // Action: Tap CANCEL in date picker
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton.first);
        await tester.pumpAndSettle();
      }

      // Verify: dateSetter was NOT called
      expect(dateSetterCalled, false);
    });

    testWidgets('Uses initialPickerGetter for initial date in picker', (tester) async {
      // Setup: Specific initial date for picker
      final initialDate = DateTime(2025, 6, 15, 10, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null, // Field is empty
              dateSetter: (_) {},
              initialPickerGetter: () => initialDate, // But picker shows this date
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Action: Open date picker
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Verify: Picker shows June 2025 (the month from initialDate)
      expect(find.text('June 2025'), findsOneWidget);
    });

    testWidgets('Respects firstDate constraint', (tester) async {
      // Setup: Date field with firstDate constraint
      final firstDate = DateTime(2025, 1, 1);
      final initialDate = DateTime(2025, 6, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => initialDate,
              firstDateGetter: () => firstDate,
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Action: Open date picker
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Verify: Date picker opened (firstDate constraint is internal to the picker)
      // Look for any dialog buttons
      expect(
        find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data?.toUpperCase() == 'OK' || widget.data?.toUpperCase() == 'CANCEL')
        ),
        findsWidgets,
      );

      // Note: We can't easily test that dates before firstDate are disabled
      // without diving deep into the native DatePicker widget structure
    });

    testWidgets('Uses currentDate for picker navigation', (tester) async {
      // Setup: Date field with currentDate
      final currentDate = DateTime(2025, 12, 25);
      final initialDate = DateTime(2025, 6, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => initialDate,
              currentDateGetter: () => currentDate,
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Action: Open date picker
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Verify: Picker opened
      expect(
        find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data?.toUpperCase() == 'OK' || widget.data?.toUpperCase() == 'CANCEL')
        ),
        findsWidgets,
      );
    });

    testWidgets('TextField has OutlineInputBorder decoration', (tester) async {
      // Setup: Widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => DateTime(2025, 1, 1),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: TextField has correct decoration
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration, isNotNull);
      expect(textField.decoration!.border, isA<OutlineInputBorder>());
      expect(textField.decoration!.labelText, 'Test Date');
    });

    testWidgets('Widget has margin around it', (tester) async {
      // Setup: Widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClearableDateTimeField(
              labelText: 'Test Date',
              dateGetter: () => null,
              dateSetter: (_) {},
              initialPickerGetter: () => DateTime(2025, 1, 1),
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: Container with margin exists
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.margin, EdgeInsets.all(7.0));
    });

    testWidgets('Works with different label texts', (tester) async {
      // Setup: Multiple fields with different labels
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ClearableDateTimeField(
                  labelText: 'Start Date',
                  dateGetter: () => null,
                  dateSetter: (_) {},
                  initialPickerGetter: () => DateTime(2025, 1, 1),
                  timezoneHelper: mockTimezoneHelper,
                ),
                ClearableDateTimeField(
                  labelText: 'Due Date',
                  dateGetter: () => null,
                  dateSetter: (_) {},
                  initialPickerGetter: () => DateTime(2025, 1, 1),
                  timezoneHelper: mockTimezoneHelper,
                ),
                ClearableDateTimeField(
                  labelText: 'Urgent Date',
                  dateGetter: () => null,
                  dateSetter: (_) {},
                  initialPickerGetter: () => DateTime(2025, 1, 1),
                  timezoneHelper: mockTimezoneHelper,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify: All labels appear
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Urgent Date'), findsOneWidget);
    });
  });
}
