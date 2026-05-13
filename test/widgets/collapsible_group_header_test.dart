import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/collapsible_group_header.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
    theme: ThemeData.dark(),
  );
}

void main() {
  testWidgets('renders uppercase label + count', (tester) async {
    await tester.pumpWidget(_wrap(const CollapsibleGroupHeader(
      label: 'Urgent',
      count: 3,
      collapsed: false,
    )));
    expect(find.text('URGENT'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tap toggles via onTap callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(CollapsibleGroupHeader(
      label: 'Urgent',
      count: 3,
      collapsed: false,
      onTap: () => taps++,
    )));
    await tester.tap(find.text('URGENT'));
    expect(taps, 1);
  });

  testWidgets('without onTap the widget is not interactive', (tester) async {
    await tester.pumpWidget(_wrap(const CollapsibleGroupHeader(
      label: 'Done',
      count: 0,
      collapsed: true,
    )));
    // Tapping with no onTap is a no-op; verify the widget renders (no
    // InkWell ancestor required) and didn't throw.
    expect(find.text('DONE'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('the chevron rotation is driven by `collapsed`', (tester) async {
    await tester.pumpWidget(_wrap(const CollapsibleGroupHeader(
      label: 'Open group',
      count: 1,
      collapsed: false,
    )));
    var rotate = tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
    expect(rotate.turns, 0.0);

    await tester.pumpWidget(_wrap(const CollapsibleGroupHeader(
      label: 'Open group',
      count: 1,
      collapsed: true,
    )));
    rotate = tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
    expect(rotate.turns, -0.25);
  });
}
