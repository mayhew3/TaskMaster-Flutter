
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  Future<MaterialApp> createApp(WidgetTester tester) async {

    var app = MaterialApp(
      home: Scaffold(
      ),
    );
    await tester.pumpWidget(app);
    return app;
  }

  testWidgets('has label', (WidgetTester tester) async {
    await createApp(tester);
/*

    var labelFinder = find.text('Type');

    expect(labelFinder, findsOneWidget);
*/

  });

}