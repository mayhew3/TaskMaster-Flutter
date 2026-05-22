import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_selection_sync.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';

/// TM-384: the wide-shell listener that bridges `selectedTaskProvider`
/// → `rightPaneProvider`. Verifies both directions:
///   - non-null selection ⇒ `.editor`
///   - null selection ⇒ `.empty` (re-tap a row to deselect, or any
///     code path that clears the selection without explicitly setting
///     the right pane back to empty)
///
/// The downgrade is the fix for the "re-tap to collapse leaves a blank
/// right pane" bug — pre-fix the listener only upgraded on non-null and
/// the pane was left in `.editor` with no selection to render.
void main() {
  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RightPaneSelectionSync(child: SizedBox.shrink()),
      ),
    );
    return container;
  }

  testWidgets('non-null selection upgrades rightPaneProvider to .editor '
      '(TM-384)', (tester) async {
    final c = await pump(tester);
    expect(c.read(rightPaneProvider), RightPaneMode.empty);

    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.editor);
  });

  testWidgets('clearing the selection downgrades rightPaneProvider to '
      '.empty — the re-tap-to-collapse case (TM-384)', (tester) async {
    final c = await pump(tester);
    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.editor);

    // Simulate the row tap-again-to-deselect path. The listener must
    // drive the pane back to .empty so the user sees the empty-state
    // selection instructions, not a blank pane.
    c.read(selectedTaskProvider.notifier).clear();
    await tester.pump();

    expect(c.read(rightPaneProvider), RightPaneMode.empty);
  });

  testWidgets('switching selection from one task to another keeps the pane '
      'in .editor (TM-384)', (tester) async {
    final c = await pump(tester);
    c.read(selectedTaskProvider.notifier).select('task-1');
    await tester.pump();
    expect(c.read(rightPaneProvider), RightPaneMode.editor);

    c.read(selectedTaskProvider.notifier).select('task-2');
    await tester.pump();

    // Still .editor — the listener fires with `next='task-2'` (non-null).
    expect(c.read(rightPaneProvider), RightPaneMode.editor);
  });
}
