
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';

void main() {

  Future<MaterialApp> _createApp(WidgetTester tester, {bool isRequired, FormFieldValidator<String> validator}) async {

    var app = MaterialApp(
      home: Scaffold(
      ),
    );
    await tester.pumpWidget(app);
    return app;
  }

  testWidgets('has label', (WidgetTester tester) async {
    await _createApp(tester);
/*

    var labelFinder = find.text('Type');

    expect(labelFinder, findsOneWidget);
*/

  });

}