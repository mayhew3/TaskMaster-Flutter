
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';

void main() {

  String? fieldValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<MaterialApp> _createApp(WidgetTester tester, {bool? isRequired, FormFieldValidator<String>? validator}) async {

    Form form = Form(
          key: _formKey,
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

  Finder _findTextField() {
    return find.byType(TextFormField);
  }

  FormState? _getForm() {
    return _formKey.currentState;
  }

  testWidgets('has label', (WidgetTester tester) async {
    await _createApp(tester);

    var labelFinder = find.text('Type');

    expect(labelFinder, findsOneWidget);

  });

  testWidgets('change text', (WidgetTester tester) async {
    await _createApp(tester);

    var formField = _findTextField();

    var valueFinder = find.text('Fart');

    expect(formField, findsOneWidget);
    expect(valueFinder, findsOneWidget);

    await tester.enterText(formField, 'Lesser Gunk');

    expect(valueFinder, findsNothing);

    var newValueFinder = find.text('Lesser Gunk');

    expect(newValueFinder, findsOneWidget);

    final form = _getForm();
    form!.save();

    expect(fieldValue, 'Lesser Gunk');
  });

  testWidgets('validation passes null ok', (WidgetTester tester) async {
    await _createApp(tester, isRequired: false);

    var textField = _findTextField();
    await tester.enterText(textField, '');

    var form = _getForm();
    expect(form!.validate(), true);
  });

  testWidgets('validation fails null not ok', (WidgetTester tester) async {
    await _createApp(tester, isRequired: true);

    var textField = _findTextField();
    await tester.enterText(textField, '');

    var form = _getForm();
    expect(form!.validate(), false);
  });

  testWidgets('validation passes null not ok', (WidgetTester tester) async {
    await _createApp(tester, isRequired: true);

    var textField = _findTextField();
    await tester.enterText(textField, 'Real Text');

    var form = _getForm();
    expect(form!.validate(), true);
  });

  testWidgets('validation fails if validator fails', (WidgetTester tester) async {
    var validator = (value) => 'Required';
    await _createApp(tester, validator: validator);

    var textField = _findTextField();
    await tester.enterText(textField, '39');

    var form = _getForm();
    expect(form!.validate(), false);
  });

}