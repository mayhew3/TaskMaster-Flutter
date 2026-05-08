import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/field_label.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  testWidgets('renders label uppercased', (tester) async {
    await _pump(tester, const FieldLabel('Priority'));
    expect(find.text('PRIORITY'), findsOneWidget);
  });

  testWidgets('renders hint when provided', (tester) async {
    await _pump(tester, const FieldLabel('Priority', hint: '3/5'));
    expect(find.text('PRIORITY'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('does not render hint when null', (tester) async {
    await _pump(tester, const FieldLabel('Priority'));
    expect(find.text('3/5'), findsNothing);
  });

  testWidgets('renders trailing action', (tester) async {
    await _pump(
      tester,
      const FieldLabel('Dates', action: Icon(Icons.add, key: Key('action'))),
    );
    expect(find.byKey(const Key('action')), findsOneWidget);
  });
}
