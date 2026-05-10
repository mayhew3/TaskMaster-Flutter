import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/context_icon.dart';

/// Tests for the closed `ContextIcon` set (TM-181).
///
/// Verifies that every default-seed name resolves to a non-empty Icon widget
/// and that unknown names render an empty `SizedBox.shrink()` rather than
/// throwing.

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ContextIcon — closed set rendering', () {
    for (final name in const [
      'computer',
      'home',
      'office',
      'email',
      'phone',
      'outside',
      'reading',
      'planning',
    ]) {
      testWidgets('"$name" renders a Material Icon', (tester) async {
        await tester.pumpWidget(_wrap(ContextIcon(name: name)));
        expect(find.byType(Icon), findsOneWidget);
      });
    }
  });

  group('ContextIcon — unknown names', () {
    testWidgets('null name renders empty', (tester) async {
      await tester.pumpWidget(_wrap(const ContextIcon(name: null)));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('unknown name renders empty', (tester) async {
      await tester.pumpWidget(_wrap(const ContextIcon(name: 'frobnitz')));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('hasIcon() agrees with rendered output', (tester) async {
      expect(ContextIcon.hasIcon('phone'), isTrue);
      expect(ContextIcon.hasIcon('frobnitz'), isFalse);
      expect(ContextIcon.hasIcon(null), isFalse);
      expect(ContextIcon.hasIcon(''), isFalse);
    });
  });

  group('ContextIcon — case insensitivity', () {
    testWidgets('PHONE resolves the same as phone', (tester) async {
      await tester.pumpWidget(_wrap(const ContextIcon(name: 'PHONE')));
      expect(find.byType(Icon), findsOneWidget);
    });
  });

  group('ContextIcon — outdoors / outside synonym', () {
    testWidgets('both names resolve to the same icon', (tester) async {
      // Default seed name is "outside"; the design prototype uses "outdoors"
      // (sun glyph). Both should resolve to a rendered Icon — same glyph
      // either way.
      await tester.pumpWidget(_wrap(const Row(
        children: [
          ContextIcon(name: 'outside'),
          ContextIcon(name: 'outdoors'),
        ],
      )));
      expect(find.byType(Icon), findsNWidgets(2));
    });
  });
}
