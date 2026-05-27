import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/database/app_database.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
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
    // `.viewOptions` mode renders `DockedViewOptionsPane`, which
    // chains through `activeNavDestinationProvider` → `currentFamily
    // DocIdProvider` → `currentPersonProvider` → Drift. Override the
    // database with an in-memory instance + stub family-doc-id so
    // the test doesn't open the real (file-backed) database and
    // leak cleanup timers past `finalizeTree` (MEMORY:
    // project_drift_flutter_test_interaction).
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      // RightPane watches personDocIdProvider for the cross-user reset
      // (TM-384 pre-push review). Stub so the auth chain doesn't try
      // to wire up Firebase Auth in this widget-test environment.
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
    ]);
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
  // needs the live-Firestore harness, so its routing assertion lives
  // in `docked_task_editor_pane_test.dart` ("RightPaneContainer
  // routing"). Likewise `.viewOptions` mode renders the real
  // `DockedViewOptionsPane` (TM-385); deep routing assertions live in
  // `docked_view_options_pane_test.dart`. The runtime-switch test
  // below verifies the mode change drives a structural rebuild (the
  // empty state disappears) without depending on either pane's
  // provider graph.

  testWidgets('switching mode at runtime away from .empty rebuilds the pane '
      '(TM-383)', (tester) async {
    final c = await pump(tester, initialMode: RightPaneMode.empty);
    expect(find.byType(RightPaneEmptyState), findsOneWidget);

    // Flip mode → the empty state is no longer rendered. Don't assert
    // on the View Options pane's internals here (those need the
    // pane's own provider stubs); just verify the structural change.
    c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
    await tester.pump();

    expect(find.byType(RightPaneEmptyState), findsNothing);
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
