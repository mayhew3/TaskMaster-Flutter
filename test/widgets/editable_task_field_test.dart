
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/redux/presentation/editable_task_field.dart';

void main() {

  String? fieldValue;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<MaterialApp> createApp(WidgetTester tester, {bool? isRequired, FormFieldValidator<String>? validator}) async {

    Form form = Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: EditableTaskField(
            initialText: 'Fart',
            labelText: 'Type',
            fieldSetter: (value) => fieldValue = value,
            inputType: TextInputType.text,
            isRequired: isRequired ?? false,
            validator: validator,
            wordCaps: true,
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

}