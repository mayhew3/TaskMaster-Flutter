import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/shared/presentation/widgets/editable_task_field.dart';

void main() {

  String? fieldValue;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Modified createApp to include more parameters for flexibility
  Future<MaterialApp> createApp(WidgetTester tester, {
    String initialText = 'Fart', // Defaulted for existing tests
    String labelText = 'Type',   // Defaulted for existing tests
    bool? isRequired,
    FormFieldValidator<String>? validator,
    TextInputType inputType = TextInputType.text, // Defaulted
    bool wordCaps = true, // Defaulted, can be overridden
    ValueChanged<String?>? fieldSetterOverride, // Added for flexibility
  }) async {
    Form form = Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EditableTaskField(
        initialText: initialText,
        labelText: labelText,
        fieldSetter: fieldSetterOverride ?? (value) => fieldValue = value,
        inputType: inputType,
        isRequired: isRequired ?? false,
        validator: validator,
        wordCaps: wordCaps, // Use the parameter
      ),
    );
    var app = MaterialApp(
      home: Scaffold(
        body: form,
      ),
    );
    await tester.pumpWidget(app);
    return app;
  }

  Finder findTextField() {
    return find.byType(TextFormField);
  }

  FormState? getForm() {
    return formKey.currentState;
  }

  testWidgets('has label', (WidgetTester tester) async {
    await createApp(tester);

    var labelFinder = find.text('Type');

    expect(labelFinder, findsOneWidget);

  });

  testWidgets('change text', (WidgetTester tester) async {
    await createApp(tester);

    var formField = findTextField();

    var valueFinder = find.text('Fart');

    expect(formField, findsOneWidget);
    expect(valueFinder, findsOneWidget);

    await tester.enterText(formField, 'Lesser Gunk');

    expect(valueFinder, findsNothing);

    var newValueFinder = find.text('Lesser Gunk');

    expect(newValueFinder, findsOneWidget);

    final form = getForm();
    form!.save();

    expect(fieldValue, 'Lesser Gunk');
  });

  testWidgets('validation passes null ok', (WidgetTester tester) async {
    await createApp(tester, isRequired: false);

    var textField = findTextField();
    await tester.enterText(textField, '');

    var form = getForm();
    expect(form!.validate(), true);
  });

  testWidgets('validation fails null not ok', (WidgetTester tester) async {
    await createApp(tester, isRequired: true);

    var textField = findTextField();
    await tester.enterText(textField, '');

    var form = getForm();
    expect(form!.validate(), false);
  });

  testWidgets('validation passes null not ok', (WidgetTester tester) async {
    await createApp(tester, isRequired: true);

    var textField = findTextField();
    await tester.enterText(textField, 'Real Text');

    var form = getForm();
    expect(form!.validate(), true);
  });

  testWidgets('validation fails if validator fails', (WidgetTester tester) async {
    validator(value) => 'Required';
    await createApp(tester, validator: validator);

    var textField = findTextField();
    await tester.enterText(textField, '39');

    var form = getForm();
    expect(form!.validate(), false);
  });

  // New tests:

  testWidgets('displays initialText', (WidgetTester tester) async {
    await createApp(tester, initialText: 'Specific Initial Text');
    expect(find.text('Specific Initial Text'), findsOneWidget);
  });

  testWidgets('applies wordCaps: true', (WidgetTester tester) async {
    await createApp(tester, wordCaps: true);
    final textFormFieldFinder = findTextField();
    expect(textFormFieldFinder, findsOneWidget);

    final textFieldDescendantFinder = find.descendant(
      of: textFormFieldFinder,
      matching: find.byType(TextField),
    );
    expect(textFieldDescendantFinder, findsOneWidget);

    final textFieldWidget = tester.widget<TextField>(textFieldDescendantFinder);
    expect(textFieldWidget.textCapitalization, TextCapitalization.words);
  });

  testWidgets('applies wordCaps: false', (WidgetTester tester) async {
    await createApp(tester, wordCaps: false);
    final textFormFieldFinder = findTextField();
    expect(textFormFieldFinder, findsOneWidget);

    final textFieldDescendantFinder = find.descendant(
      of: textFormFieldFinder,
      matching: find.byType(TextField),
    );
    expect(textFieldDescendantFinder, findsOneWidget);

    final textFieldWidget = tester.widget<TextField>(textFieldDescendantFinder);
    expect(textFieldWidget.textCapitalization, TextCapitalization.sentences);
  });

  testWidgets('propagates inputType to TextFormField', (WidgetTester tester) async {
    await createApp(tester, inputType: TextInputType.number);
    final textFormFieldFinder = findTextField();
    expect(textFormFieldFinder, findsOneWidget);

    final textFieldDescendantFinder = find.descendant(
      of: textFormFieldFinder,
      matching: find.byType(TextField),
    );
    expect(textFieldDescendantFinder, findsOneWidget);

    final textFieldWidget = tester.widget<TextField>(textFieldDescendantFinder);
    expect(textFieldWidget.keyboardType, TextInputType.number);
  });

  testWidgets('validation passes with custom validator and no error text', (WidgetTester tester) async {
    String? validationResult;
    await createApp(
      tester,
      validator: (value) {
        if (value == 'invalid') {
          validationResult = 'Error!';
          return validationResult;
        }
        validationResult = null;
        return null;
      },
      isRequired: false, // Explicitly false for this test
    );

    var textField = findTextField();
    await tester.enterText(textField, 'valid');
    await tester.pump(); // Allow for validation to run

    var form = getForm();
    expect(form!.validate(), true);
    expect(validationResult, isNull);
    expect(find.text('Error!'), findsNothing); // Ensure no error text is shown
  });


  testWidgets('displays default error message when isRequired fails', (WidgetTester tester) async {
    await createApp(tester, isRequired: true, labelText: 'Task Name'); // Use a specific label for clarity

    var textField = findTextField();
    await tester.enterText(textField, '');
    await tester.pump(); // Allow for validation to run and error text to appear

    var form = getForm();
    expect(form!.validate(), false);
    expect(find.text('Task Name is required'), findsOneWidget);
  });

  testWidgets('displays custom error message when custom validator fails', (WidgetTester tester) async {
    await createApp(
      tester,
      validator: (value) => 'Custom error here',
    );

    var textField = findTextField();
    await tester.enterText(textField, 'any text'); // Text to trigger validation
    await tester.pump(); // Allow for validation to run

    var form = getForm();
    expect(form!.validate(), false);
    expect(find.text('Custom error here'), findsOneWidget);
  });

}
