import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/pill.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('Pill', () {
    testWidgets('renders label', (tester) async {
      await _pump(tester, const Pill(label: Text('Hello')));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('onTap fires when tapped', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        Pill(label: const Text('Tap me'), onTap: () => taps++),
      );
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('shows close icon when onRemove is set', (tester) async {
      await _pump(
        tester,
        Pill(label: const Text('X'), onRemove: () {}),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not show close icon when onRemove is null',
        (tester) async {
      await _pump(tester, const Pill(label: Text('X')));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('onRemove fires when close icon tapped', (tester) async {
      var removes = 0;
      await _pump(
        tester,
        Pill(label: const Text('X'), onRemove: () => removes++),
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(removes, 1);
    });
  });

  group('AddPill', () {
    testWidgets('renders label and add icon', (tester) async {
      await _pump(tester, AddPill(label: 'Add', onTap: () {}));
      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('onTap fires when tapped', (tester) async {
      var taps = 0;
      await _pump(tester, AddPill(label: 'Add', onTap: () => taps++));
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });
}
