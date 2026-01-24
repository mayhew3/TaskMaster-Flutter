import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/shared/presentation/widgets/nullable_dropdown.dart';

/// Widget Test: NullableDropdown
///
/// Tests the NullableDropdown widget (StatefulWidget with dropdown and null handling).
///
/// NullableDropdown is a complex widget that:
/// - Manages internal state (StatefulWidget)
/// - Wraps/unwraps null values as "(none)"
/// - Provides dropdown with multiple options
/// - Triggers callbacks on value change
/// - Supports form validation
/// - Styles menu items differently based on selection
///
/// This tests StatefulWidget patterns, state management, and form integration.
void main() {
  group('NullableDropdown Tests', () {
    testWidgets('Displays dropdown with label', (tester) async {
      // Setup: Create dropdown with options
      final options = BuiltList<String>(['Option 1', 'Option 2', 'Option 3']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'Option 1',
              labelText: 'Choose Option',
              possibleValues: options,
              valueSetter: (value) {},
            ),
          ),
        ),
      );

      // Verify: Label appears
      expect(find.text('Choose Option'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('Displays "(none)" when initialValue is null', (tester) async {
      // Setup: Dropdown with null initial value (must include "(none)" in options)
      final options = BuiltList<String>(['(none)', 'Option 1', 'Option 2']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: null,
              labelText: 'Select',
              possibleValues: options,
              valueSetter: (value) {},
            ),
          ),
        ),
      );

      // Verify: "(none)" is displayed as current value
      expect(find.text('(none)'), findsOneWidget);
    });

    testWidgets('Displays initialValue when provided', (tester) async {
      // Setup: Dropdown with initial value
      final options = BuiltList<String>(['Low', 'Medium', 'High']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'Medium',
              labelText: 'Priority',
              possibleValues: options,
              valueSetter: (value) {},
            ),
          ),
        ),
      );

      // Verify: Initial value is displayed
      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('Shows all options when dropdown is tapped', (tester) async {
      // Setup: Dropdown with multiple options
      final options = BuiltList<String>(['Red', 'Green', 'Blue']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'Red',
              labelText: 'Color',
              possibleValues: options,
              valueSetter: (value) {},
            ),
          ),
        ),
      );

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Verify: All options appear (Red is visible, Green and Blue in dropdown menu)
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('Selecting option triggers valueSetter callback', (tester) async {
      // Setup: Track callback
      String? capturedValue;
      final options = BuiltList<String>(['Alpha', 'Beta', 'Gamma']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'Alpha',
              labelText: 'Greek',
              possibleValues: options,
              valueSetter: (value) {
                capturedValue = value;
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select 'Beta'
      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();

      // Verify: Callback received the value
      expect(capturedValue, 'Beta');

      // Verify: Display updated
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('Unwraps "(none)" to null in valueSetter', (tester) async {
      // Setup: Track callback with null value
      String? capturedValue = 'not-null-yet';
      final options = BuiltList<String>(['Option A', '(none)']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'Option A',
              labelText: 'Test',
              possibleValues: options,
              valueSetter: (value) {
                capturedValue = value;
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select "(none)"
      await tester.tap(find.text('(none)').last);
      await tester.pumpAndSettle();

      // Verify: Callback received null (unwrapped)
      expect(capturedValue, null);
    });

    testWidgets('Optional onChanged callback is triggered', (tester) async {
      // Setup: Track both callbacks
      String? valueSetterCalled;
      String? onChangedCalled;
      final options = BuiltList<String>(['One', 'Two']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'One',
              labelText: 'Number',
              possibleValues: options,
              valueSetter: (value) {
                valueSetterCalled = value;
              },
              onChanged: (value) {
                onChangedCalled = value;
              },
            ),
          ),
        ),
      );

      // Open dropdown and select
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Two').last);
      await tester.pumpAndSettle();

      // Verify: Both callbacks triggered
      expect(valueSetterCalled, 'Two');
      expect(onChangedCalled, 'Two');
    });

    testWidgets('Works without onChanged callback', (tester) async {
      // Setup: No onChanged callback
      String? valueSetterCalled;
      final options = BuiltList<String>(['X', 'Y', 'Z']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'X',
              labelText: 'Axis',
              possibleValues: options,
              valueSetter: (value) {
                valueSetterCalled = value;
              },
              // onChanged: null (not provided)
            ),
          ),
        ),
      );

      // Open dropdown and select
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Y').last);
      await tester.pumpAndSettle();

      // Verify: Works without error
      expect(valueSetterCalled, 'Y');
      expect(find.text('Y'), findsOneWidget);
    });

    testWidgets('Validator is called and displays error', (tester) async {
      // Setup: Dropdown with validation
      final options = BuiltList<String>(['Valid', 'Invalid']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              autovalidateMode: AutovalidateMode.always,
              child: NullableDropdown(
                initialValue: 'Invalid',
                labelText: 'Status',
                possibleValues: options,
                valueSetter: (value) {},
                validator: (value) {
                  if (value == 'Invalid') {
                    return 'This option is not allowed';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Wait for validation
      await tester.pumpAndSettle();

      // Verify: Error message appears
      expect(find.text('This option is not allowed'), findsOneWidget);
    });

    testWidgets('State updates when selecting different values', (tester) async {
      // Setup: Track state changes
      final selectedValues = <String>[];
      final options = BuiltList<String>(['First', 'Second', 'Third']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'First',
              labelText: 'Choice',
              possibleValues: options,
              valueSetter: (value) {
                selectedValues.add(value ?? '(null)');
              },
            ),
          ),
        ),
      );

      // Select Second
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Second').last);
      await tester.pumpAndSettle();

      // Select Third
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Third').last);
      await tester.pumpAndSettle();

      // Verify: All selections recorded
      expect(selectedValues, ['Second', 'Third']);

      // Verify: Current display shows Third
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('Handles empty string as valid option', (tester) async {
      // Setup: Empty string as option
      final options = BuiltList<String>(['', 'Option']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NullableDropdown(
              initialValue: 'Option',
              labelText: 'Test',
              possibleValues: options,
              valueSetter: (_) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select empty string (appears as blank in menu)
      final dropdownItems = tester.widgetList<DropdownMenuItem<String>>(
        find.byType(DropdownMenuItem<String>),
      );

      // Verify: Empty string option exists
      expect(dropdownItems.any((item) => item.value == ''), true);
    });

    testWidgets('Multiple dropdowns work independently', (tester) async {
      // Setup: Two separate dropdowns
      String? value1;
      String? value2;
      final options1 = BuiltList<String>(['A', 'B']);
      final options2 = BuiltList<String>(['X', 'Y']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NullableDropdown(
                  key: Key('dropdown1'),
                  initialValue: 'A',
                  labelText: 'Dropdown 1',
                  possibleValues: options1,
                  valueSetter: (value) {
                    value1 = value;
                  },
                ),
                NullableDropdown(
                  key: Key('dropdown2'),
                  initialValue: 'X',
                  labelText: 'Dropdown 2',
                  possibleValues: options2,
                  valueSetter: (value) {
                    value2 = value;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Change first dropdown
      await tester.tap(find.descendant(
        of: find.byKey(Key('dropdown1')),
        matching: find.byType(DropdownButtonFormField<String>),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B').last);
      await tester.pumpAndSettle();

      // Verify: Only first dropdown changed
      expect(value1, 'B');
      expect(value2, null); // Not changed yet

      // Change second dropdown
      await tester.tap(find.descendant(
        of: find.byKey(Key('dropdown2')),
        matching: find.byType(DropdownButtonFormField<String>),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Y').last);
      await tester.pumpAndSettle();

      // Verify: Second dropdown changed
      expect(value2, 'Y');
    });

    testWidgets('Dropdown can be recreated with new initial value', (tester) async {
      // Setup: Widget that recreates dropdown with different initialValue
      String currentInitial = 'First';
      final options = BuiltList<String>(['First', 'Second', 'Third']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    NullableDropdown(
                      key: ValueKey(currentInitial), // Force recreation
                      initialValue: currentInitial,
                      labelText: 'Dynamic',
                      possibleValues: options,
                      valueSetter: (value) {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentInitial = 'Third';
                        });
                      },
                      child: Text('Change'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify: Initial value displayed
      expect(find.text('First'), findsOneWidget);

      // Trigger state change to recreate with new initial value
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // Verify: New initial value displayed
      expect(find.text('Third'), findsOneWidget);
    });
  });
}
