import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaestro/features/shared/presentation/wide/sidebar_row.dart';

/// TM-385 R6 — the sidebar row's hover overlay must be ADDITIVE:
/// composited over the base (selected pill or transparent) rather than
/// swallowed by the selected branch. These tests pin that a selected
/// row's background changes on mouse-hover (it didn't before R6).
void main() {
  Future<Material> pumpAndFindMaterial(
    WidgetTester tester, {
    required bool selected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SidebarRow(
            icon: Icons.list,
            label: 'Tasks',
            selected: selected,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    // The row's background Material is the InkWell's parent — the first
    // Material descendant of SidebarRow.
    return tester.widget<Material>(
      find
          .descendant(
            of: find.byType(SidebarRow),
            matching: find.byType(Material),
          )
          .first,
    );
  }

  Future<Color?> hoverAndReadColor(
    WidgetTester tester, {
    required bool selected,
  }) async {
    await pumpAndFindMaterial(tester, selected: selected);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byType(SidebarRow)));
    await tester.pump();

    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(SidebarRow),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.color;
  }

  testWidgets('selected row changes background on hover (additive overlay) '
      '(TM-385 R6)', (tester) async {
    final restingColor = (await pumpAndFindMaterial(tester, selected: true)).color;
    final hoveredColor = await hoverAndReadColor(tester, selected: true);

    expect(hoveredColor, isNotNull);
    expect(hoveredColor, isNot(equals(restingColor)),
        reason: 'a selected row must still show hover feedback — the '
            'overlay is composited OVER the selected pill, not '
            'swallowed by the selected branch');
  });

  testWidgets('unselected row changes background on hover (TM-385)',
      (tester) async {
    final restingColor =
        (await pumpAndFindMaterial(tester, selected: false)).color;
    final hoveredColor = await hoverAndReadColor(tester, selected: false);

    expect(hoveredColor, isNotNull);
    expect(hoveredColor, isNot(equals(restingColor)),
        reason: 'an unselected row gets the hover tint over its '
            'transparent base');
  });
}
