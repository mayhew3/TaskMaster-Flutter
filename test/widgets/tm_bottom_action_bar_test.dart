import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/tm_bottom_action_bar.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('TmBottomActionBar', () {
    testWidgets('renders save label', (tester) async {
      await _pump(
        tester,
        TmBottomActionBar(saveLabel: 'Save changes', onSave: () {}),
      );
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('does not render cancel when cancelLabel is null',
        (tester) async {
      await _pump(
        tester,
        TmBottomActionBar(saveLabel: 'Save', onSave: () {}),
      );
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('renders cancel when cancelLabel is set', (tester) async {
      await _pump(
        tester,
        TmBottomActionBar(
          saveLabel: 'Save',
          cancelLabel: 'Cancel',
          onSave: () {},
          onCancel: () {},
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('save callback fires on tap', (tester) async {
      var saved = 0;
      await _pump(
        tester,
        TmBottomActionBar(saveLabel: 'Save', onSave: () => saved++),
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, 1);
    });

    testWidgets('cancel callback fires on tap', (tester) async {
      var cancelled = 0;
      await _pump(
        tester,
        TmBottomActionBar(
          saveLabel: 'Save',
          cancelLabel: 'Cancel',
          onSave: () {},
          onCancel: () => cancelled++,
        ),
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cancelled, 1);
    });

    testWidgets('save is disabled when saveEnabled is false', (tester) async {
      var saved = 0;
      await _pump(
        tester,
        TmBottomActionBar(
          saveLabel: 'Save',
          onSave: () => saved++,
          saveEnabled: false,
        ),
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, 0);
    });
  });
}
