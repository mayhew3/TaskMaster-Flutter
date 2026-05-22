import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_container.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_empty_state.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/models/task_colors.dart';

/// The right-pane container switches on `rightPaneProvider`.
///
/// `.empty` and `.viewOptions` are exercised here with a lightweight
/// container. `.editor` now renders the real `DockedTaskEditorPane`
/// (TM-384), which needs the full Firestore/Drift provider graph — its
/// routing is covered by `docked_task_editor_pane_test.dart` instead.
/// `.viewOptions` remains a placeholder until TM-385.
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

  // `.editor` mode renders `DockedTaskEditorPane` (TM-384). That path
  // needs the live-Firestore harness, so its routing assertion lives in
  // `docked_task_editor_pane_test.dart` ("RightPaneContainer routing").

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

    // Switch to `.viewOptions` — the runtime-switch contract without
    // needing the editor's provider graph (see `.editor` note above).
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
    await tester.pumpAndSettle();

    expect(find.byType(RightPaneEmptyState), findsNothing);
    expect(find.textContaining('TM-385'), findsOneWidget);
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
