import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaestro/features/shared/presentation/widgets/hoverable.dart';

/// TM-385 — Hoverable wraps `MouseRegion` + state, exposing a
/// `(context, hovered)` builder. Touch interactions don't trigger
/// the hover state.
void main() {
  testWidgets('starts un-hovered; flips to hovered when mouse enters and '
      'back when it exits (TM-385)', (tester) async {
    bool? lastHovered;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Hoverable(
                builder: (context, hovered) {
                  lastHovered = hovered;
                  return Container(
                    color: hovered ? Colors.red : Colors.blue,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    expect(lastHovered, isFalse,
        reason: 'initial state — no mouse over the region');

    // Move a mouse pointer over the region.
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: const Offset(400, 300));
    await tester.pumpAndSettle();

    expect(lastHovered, isTrue, reason: 'mouse-over → hovered = true');

    // Move pointer off the region.
    await gesture.moveTo(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(lastHovered, isFalse, reason: 'mouse-off → hovered = false');
  });

  testWidgets('enabled: false reports hovered=false even when mouse enters '
      '(TM-385 — disabled rows shouldn\'t respond to mouse-over)',
      (tester) async {
    int hoveredCalls = 0;
    bool? lastHovered;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Hoverable(
                enabled: false,
                builder: (context, hovered) {
                  hoveredCalls++;
                  lastHovered = hovered;
                  return const ColoredBox(color: Colors.green);
                },
              ),
            ),
          ),
        ),
      ),
    );
    final initialCalls = hoveredCalls;

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: const Offset(400, 300));
    await tester.pumpAndSettle();

    expect(lastHovered, isFalse,
        reason: 'disabled Hoverable never flips to hovered=true');
    expect(hoveredCalls, initialCalls,
        reason: 'disabled Hoverable doesn\'t rebuild on mouse-over '
            '(no state change → no setState call)');
  });
}
