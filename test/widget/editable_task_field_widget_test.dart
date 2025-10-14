import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/redux/presentation/editable_task_field.dart';

/// Widget Test: EditableTaskField
///
/// Tests the EditableTaskField widget (StatefulWidget with TextFormField and validation).
///
/// EditableTaskField is a complex widget that:
/// - Manages internal state (StatefulWidget)
/// - Provides text input with various keyboard types
/// - Supports single-line and multiline input
/// - Has built-in validation (required fields)
/// - Supports custom validators
/// - Handles text capitalization (words vs sentences)
/// - Integrates with Form (onSaved, validator)
///
/// This tests StatefulWidget with form integration and validation logic.
void main() {
  group('EditableTaskField Tests', () {
    testWidgets('Displays text field with label', (tester) async {
      // Setup: Create field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: '',
              labelText: 'Task Name',
              fieldSetter: (value) {},
              inputType: TextInputType.text,
            ),
          ),
        ),
      );

      // Verify: Label appears
      expect(find.text('Task Name'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Displays initial text when provided', (tester) async {
      // Setup: Field with initial text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: 'My Initial Task',
              labelText: 'Name',
              fieldSetter: (value) {},
              inputType: TextInputType.text,
            ),
          ),
        ),
      );

      // Verify: Initial text appears in field
      expect(find.text('My Initial Task'), findsOneWidget);
    });

    testWidgets('Accepts user text input', (tester) async {
      // Setup: Empty field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: '',
              labelText: 'Description',
              fieldSetter: (value) {},
              inputType: TextInputType.text,
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'New task description');
      await tester.pump();

      // Verify: Text appears
      expect(find.text('New task description'), findsOneWidget);
    });

    testWidgets('Triggers onChanged callback when text changes', (tester) async {
      // Setup: Track onChanged
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: '',
              labelText: 'Notes',
              fieldSetter: (value) {},
              inputType: TextInputType.text,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Test note');
      await tester.pump();

      // Verify: Callback triggered
      expect(changedValue, 'Test note');
    });

    testWidgets('Triggers fieldSetter when form is saved', (tester) async {
      // Setup: Form with field
      String? savedValue;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  EditableTaskField(
                    initialText: 'Initial',
                    labelText: 'Field',
                    fieldSetter: (value) {
                      savedValue = value;
                    },
                    inputType: TextInputType.text,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.save();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Change text
      await tester.enterText(find.byType(TextFormField), 'Modified text');
      await tester.pump();

      // Save form
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Verify: fieldSetter called with current value
      expect(savedValue, 'Modified text');
    });

    testWidgets('Shows error when required field is empty', (tester) async {
      // Setup: Required field
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  EditableTaskField(
                    initialText: '',
                    labelText: 'Required Field',
                    fieldSetter: (value) {},
                    inputType: TextInputType.text,
                    isRequired: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.validate();
                    },
                    child: Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();

      // Verify: Error message appears
      expect(find.text('Required Field is required'), findsOneWidget);
    });

    testWidgets('No error when required field has text', (tester) async {
      // Setup: Required field with text
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: EditableTaskField(
                initialText: 'Some text',
                labelText: 'Required Field',
                fieldSetter: (value) {},
                inputType: TextInputType.text,
                isRequired: true,
              ),
            ),
          ),
        ),
      );

      // Validate
      final isValid = formKey.currentState!.validate();

      // Verify: Validation passes
      expect(isValid, true);
    });

    testWidgets('Custom validator is used when provided', (tester) async {
      // Setup: Field with custom validator
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: EditableTaskField(
                initialText: 'bad',
                labelText: 'Custom Validation',
                fieldSetter: (value) {},
                inputType: TextInputType.text,
                validator: (value) {
                  if (value == 'bad') {
                    return 'This value is not allowed';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Validate
      final isValid = formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // Verify: Custom error appears
      expect(isValid, false);
      expect(find.text('This value is not allowed'), findsOneWidget);
    });

    testWidgets('Custom validator overrides required check', (tester) async {
      // Setup: Required field with custom validator
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: EditableTaskField(
                initialText: '',
                labelText: 'Field',
                fieldSetter: (value) {},
                inputType: TextInputType.text,
                isRequired: true,
                validator: (value) {
                  // Custom validator that allows empty
                  if (value != null && value.contains('invalid')) {
                    return 'Contains invalid word';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Validate empty field
      final isValid = formKey.currentState!.validate();

      // Verify: Custom validator takes precedence (allows empty)
      expect(isValid, true);
    });

    testWidgets('Multiline input type allows multiple lines', (tester) async {
      // Setup: Multiline field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: 'Line 1\nLine 2\nLine 3',
              labelText: 'Multiline',
              fieldSetter: (value) {},
              inputType: TextInputType.multiline,
            ),
          ),
        ),
      );

      // Verify: Field shows multiline text
      expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
      // Note: Cannot directly test maxLines property on TextFormField
    });

    testWidgets('Different input types are accepted', (tester) async {
      // Setup: Number input type
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: '42',
              labelText: 'Number',
              fieldSetter: (value) {},
              inputType: TextInputType.number,
            ),
          ),
        ),
      );

      // Verify: Field renders with number input
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Number'), findsOneWidget);
      // Note: Cannot directly test keyboardType property on TextFormField
    });

    testWidgets('Multiple fields work independently', (tester) async {
      // Setup: Two separate fields
      String? value1;
      String? value2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EditableTaskField(
                  initialText: 'Field 1',
                  labelText: 'First',
                  fieldSetter: (value) {
                    value1 = value;
                  },
                  inputType: TextInputType.text,
                ),
                EditableTaskField(
                  initialText: 'Field 2',
                  labelText: 'Second',
                  fieldSetter: (value) {
                    value2 = value;
                  },
                  inputType: TextInputType.text,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify: Both fields display independently
      expect(find.text('Field 1'), findsOneWidget);
      expect(find.text('Field 2'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('Field can be cleared by user', (tester) async {
      // Setup: Field with initial text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: 'Clear me',
              labelText: 'Clearable',
              fieldSetter: (value) {},
              inputType: TextInputType.text,
            ),
          ),
        ),
      );

      // Clear the text
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // Verify: Field is empty
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.initialValue, 'Clear me'); // initialValue doesn't change
      // But the controller shows empty
      expect(find.text('Clear me'), findsNothing);
    });

    testWidgets('Field has margin around it', (tester) async {
      // Setup: Check container margin
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableTaskField(
              initialText: '',
              labelText: 'Margined',
              fieldSetter: (value) {},
              inputType: TextInputType.text,
            ),
          ),
        ),
      );

      // Verify: Container with margin exists
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(TextFormField),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.margin, EdgeInsets.all(7.0));
    });
  });
}
