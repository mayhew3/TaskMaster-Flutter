
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';

void main() {

  String fieldValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<MaterialApp> _createApp(WidgetTester tester) async {
    Form form = Form(
          key: _formKey,
          autovalidate: false,
          child: EditableTaskField(
            initialText: 'Fart',
            labelText: 'Type',
            fieldSetter: (value) => fieldValue = value,
            inputType: TextInputType.text,
            isRequired: true,
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

  testWidgets('has label', (WidgetTester tester) async {
    await _createApp(tester);

    var labelFinder = find.text('Type');

    expect(labelFinder, findsOneWidget);

  });

  testWidgets('change text', (WidgetTester tester) async {
    await _createApp(tester);

    var formField = find.byType(TextFormField);

    var valueFinder = find.text('Fart');

    expect(formField, findsOneWidget);
    expect(valueFinder, findsOneWidget);

    await tester.enterText(formField, 'Lesser Gunk');

    expect(valueFinder, findsNothing);

    var newValueFinder = find.text('Lesser Gunk');

    expect(newValueFinder, findsOneWidget);

    final form = _formKey.currentState;

    form.save();

    expect(fieldValue, 'Lesser Gunk');
  });
}