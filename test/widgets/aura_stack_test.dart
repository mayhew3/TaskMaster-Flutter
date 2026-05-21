import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/aura_stack.dart';
import 'package:taskmaestro/features/shared/presentation/wide/selectable_task_item.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';

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

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: AuraStack(
            child: ListView(
              children: const [
                SelectableTaskItem(
                  taskDocId: 'rowA',
                  child: SizedBox(height: 60, child: ColoredBox(color: Colors.blue)),
                ),
                SelectableTaskItem(
                  taskDocId: 'rowB',
                  child: SizedBox(height: 60, child: ColoredBox(color: Colors.blue)),
                ),
                SelectableTaskItem(
                  taskDocId: 'rowC',
                  child: SizedBox(height: 60, child: ColoredBox(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
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
      return shadows.any((s) =>
          // ignore: deprecated_member_use
          s.color.red == 0xD8 &&
          // ignore: deprecated_member_use
          s.color.green == 0x3A &&
          // ignore: deprecated_member_use
          s.color.blue == 0xFF);
    });
  }

  testWidgets('on wide, paints the aura when a row is selected (TM-383)',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800), selectDocId: 'rowB');
    expect(findAura(), findsOneWidget,
        reason: 'expected the magenta aura painted at the selected row');
  });

  testWidgets('on wide, no aura when nothing is selected (TM-383)',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(findAura(), findsNothing);
  });

  testWidgets(
      'on compact, AuraStack returns child unchanged — no aura painted '
      '(TM-383)', (tester) async {
    await pump(tester, logical: const Size(800, 600), selectDocId: 'rowB');
    expect(findAura(), findsNothing,
        reason: 'compact path bypasses AuraStack entirely');
  });

  testWidgets(
      'switching selection from rowA → rowB moves the aura (TM-383)',
      (tester) async {
    final c =
        await pump(tester, logical: const Size(1280, 800), selectDocId: 'rowA');
    expect(findAura(), findsOneWidget);

    c.read(selectedTaskProvider.notifier).select('rowB');
    await tester.pumpAndSettle();
    expect(findAura(), findsOneWidget,
        reason: 'still exactly one aura — just at the new row');
  });

  testWidgets(
      'clearing selection removes the aura (TM-383)', (tester) async {
    final c =
        await pump(tester, logical: const Size(1280, 800), selectDocId: 'rowA');
    expect(findAura(), findsOneWidget);

    c.read(selectedTaskProvider.notifier).clear();
    await tester.pumpAndSettle();
    expect(findAura(), findsNothing);
  });
}
