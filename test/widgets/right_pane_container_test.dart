import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_container.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_empty_state.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// TM-383: the right-pane container switches on `rightPaneProvider`.
/// Story 2 only ever lands `.empty`, but the `.editor` / `.viewOptions`
/// branches are scaffolded for TM-384 / TM-385 — pin both placeholders
/// so the next implementer sees the contract.
void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    required RightPaneMode initialMode,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Seed the provider before pumping so the build sees the override.
    container.read(rightPaneProvider.notifier).setMode(initialMode);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: RightPaneContainer())),
      ),
    );
    return container;
  }

  testWidgets('renders RightPaneEmptyState when mode is .empty (TM-383)', (
    tester,
  ) async {
    await pump(tester, initialMode: RightPaneMode.empty);
    expect(find.byType(RightPaneEmptyState), findsOneWidget);
    expect(find.text('Select a task'), findsOneWidget);
  });

  testWidgets('renders editor placeholder when mode is .editor (TM-384 stub)', (
    tester,
  ) async {
    await pump(tester, initialMode: RightPaneMode.editor);
    expect(find.byType(RightPaneEmptyState), findsNothing);
    expect(find.textContaining('TM-384'), findsOneWidget);
  });

  testWidgets('renders view-options placeholder when mode is .viewOptions '
      '(TM-385 stub)', (tester) async {
    await pump(tester, initialMode: RightPaneMode.viewOptions);
    expect(find.byType(RightPaneEmptyState), findsNothing);
    expect(find.textContaining('TM-385'), findsOneWidget);
  });

  testWidgets('switching mode at runtime updates the pane (TM-383)', (
    tester,
  ) async {
    final c = await pump(tester, initialMode: RightPaneMode.empty);
    expect(find.byType(RightPaneEmptyState), findsOneWidget);

    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
    await tester.pumpAndSettle();

    expect(find.byType(RightPaneEmptyState), findsNothing);
    expect(find.textContaining('TM-384'), findsOneWidget);
  });

  testWidgets('paints TaskColors.bgDeep as the pane background — distinct from '
      'the sidebar (brand blue) and the center column (background) '
      '(TM-383)', (tester) async {
    await pump(tester, initialMode: RightPaneMode.empty);

    // The RightPaneContainer wraps its child in a Material whose color
    // is the deliberate `bgDeep` token. The predicate matches exactly
    // `Material(color: bgDeep)`; an alternate background-painting
    // widget (`ColoredBox(color: bgDeep)`, `DecoratedBox(...)`, …)
    // would NOT pass. If the production implementation switches off of
    // Material, broaden the predicate accordingly.
    final material = find.byWidgetPredicate(
      (w) => w is Material && w.color == TaskColors.bgDeep,
    );
    expect(
      material,
      findsOneWidget,
      reason: 'expected the deeper background for visual distinction',
    );
  });
}
