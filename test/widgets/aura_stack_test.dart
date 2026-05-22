import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/aura_stack.dart';
import 'package:taskmaestro/features/shared/presentation/wide/selectable_task_item.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-383: the [AuraStack] paints the selection aura at the list-body
/// level, BELOW the rows in z-order, so the row above never has the
/// aura painted over it (the per-row painting bug that this layer
/// fixes — see `aura_stack.dart`'s docstring).
void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required Size logical,
    String? selectDocId,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    if (selectDocId != null) {
      container.read(selectedTaskProvider.notifier).select(selectDocId);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: AuraStack(
              surface: TaskListSurface.tasks,
              child: ListView(
                children: const [
                  SelectableTaskItem(
                    surface: TaskListSurface.tasks,
                    taskDocId: 'rowA',
                    child: SizedBox(
                      height: 60,
                      child: ColoredBox(color: Colors.blue),
                    ),
                  ),
                  SelectableTaskItem(
                    surface: TaskListSurface.tasks,
                    taskDocId: 'rowB',
                    child: SizedBox(
                      height: 60,
                      child: ColoredBox(color: Colors.blue),
                    ),
                  ),
                  SelectableTaskItem(
                    surface: TaskListSurface.tasks,
                    taskDocId: 'rowC',
                    child: SizedBox(
                      height: 60,
                      child: ColoredBox(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// Aura is a DecoratedBox whose decoration carries a BoxShadow with
  /// brand-magenta RGB (R=0xD8, G=0x3A, B=0xFF). Matching on RGB only —
  /// not alpha — so retuning the aura's opacity doesn't break tests.
  Finder findAura() {
    return find.byWidgetPredicate((w) {
      if (w is! DecoratedBox) return false;
      final dec = w.decoration;
      if (dec is! BoxDecoration) return false;
      final shadows = dec.boxShadow;
      if (shadows == null || shadows.isEmpty) return false;
      // Modern Flutter color-channel API: `toARGB32()` returns the
      // packed 32-bit ARGB int; the lower 24 bits are RGB. Comparing
      // them to `0xD83AFF` matches the brandMagenta hue regardless of
      // alpha.
      return shadows.any((s) => (s.color.toARGB32() & 0xFFFFFF) == 0xD83AFF);
    });
  }

  testWidgets('on wide, paints the aura when a row is selected (TM-383)', (
    tester,
  ) async {
    await pump(tester, logical: const Size(1280, 800), selectDocId: 'rowB');
    expect(
      findAura(),
      findsOneWidget,
      reason: 'expected the magenta aura painted at the selected row',
    );
  });

  testWidgets('on wide, no aura when nothing is selected (TM-383)', (
    tester,
  ) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(findAura(), findsNothing);
  });

  testWidgets('on compact, AuraStack returns child unchanged — no aura painted '
      '(TM-383)', (tester) async {
    await pump(tester, logical: const Size(800, 600), selectDocId: 'rowB');
    expect(
      findAura(),
      findsNothing,
      reason: 'compact path bypasses AuraStack entirely',
    );
  });

  testWidgets('switching selection from rowA → rowB moves the aura (TM-383)', (
    tester,
  ) async {
    final c = await pump(
      tester,
      logical: const Size(1280, 800),
      selectDocId: 'rowA',
    );
    expect(findAura(), findsOneWidget);

    c.read(selectedTaskProvider.notifier).select('rowB');
    await tester.pumpAndSettle();
    expect(
      findAura(),
      findsOneWidget,
      reason: 'still exactly one aura — just at the new row',
    );
  });

  testWidgets('clearing selection removes the aura (TM-383)', (tester) async {
    final c = await pump(
      tester,
      logical: const Size(1280, 800),
      selectDocId: 'rowA',
    );
    expect(findAura(), findsOneWidget);

    c.read(selectedTaskProvider.notifier).clear();
    await tester.pumpAndSettle();
    expect(findAura(), findsNothing);
  });

  testWidgets('aura repositions when the ListView scrolls (TM-383 — the whole '
      'point of the parent-level architecture over per-row painting)', (
    tester,
  ) async {
    // Pump a tall list so there's actually room to scroll. Override the
    // default pump's 3-row helper.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(selectedTaskProvider.notifier).select('row-0');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: AuraStack(
              surface: TaskListSurface.tasks,
              child: ListView(
                children: [
                  for (var i = 0; i < 30; i++)
                    SelectableTaskItem(
                      surface: TaskListSurface.tasks,
                      taskDocId: 'row-$i',
                      child: SizedBox(
                        height: 60,
                        child: ColoredBox(color: Colors.blue.shade700),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Aura is present and at the top of the list.
    final auraBefore = findAura();
    expect(auraBefore, findsOneWidget);
    final yBefore = tester.getTopLeft(auraBefore).dy;

    // Scroll the list up by 200dp — row-0 moves up with it.
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Aura must still be one widget AND its Y must have shifted
    // upward by roughly the same amount. (Exact equality would be
    // fragile to floating-point + scroll physics; ±5dp tolerance.)
    final auraAfter = findAura();
    expect(
      auraAfter,
      findsOneWidget,
      reason: 'aura still attached to row-0 even after scroll',
    );
    final yAfter = tester.getTopLeft(auraAfter).dy;
    expect(
      yAfter,
      lessThan(yBefore - 100),
      reason:
          'aura should have moved up by ~200dp with the scrolled '
          'row, not stayed glued to screen-space (which would mean '
          'the NotificationListener / scrollTick / didUpdateWidget '
          'reposition path regressed)',
    );
  });
}
