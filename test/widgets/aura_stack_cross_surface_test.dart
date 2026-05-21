import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/wide/aura_stack.dart';
import 'package:taskmaestro/features/shared/presentation/wide/selectable_task_item.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-383 regression: cross-surface duplicate-GlobalKey throw.
///
/// **The actually-reachable repro** the surface-scoping was added for:
///
/// The Tasks-tab banner has a "Show Tasks" toggle
/// (`task_list_screen.dart:212` → `_TaskListBody.showSprintTasks`)
/// which, when on, also renders the active sprint's tasks INSIDE the
/// Tasks tab (with `highlightSprint: true`). Those SAME docIds also
/// render on the Plan tab's sprint view
/// (`sprint_task_items_screen.dart:360-361`). The wide shell mounts
/// every tab body in an `IndexedStack` so both tabs stay attached even
/// when the user is looking at one of them — meaning the same docId is
/// simultaneously attached to a `SelectableTaskItem(surface: .tasks)`
/// AND a `SelectableTaskItem(surface: .sprint)`.
///
/// Before surface-scoping, both would attach
/// `GlobalObjectKey(_AuraRowKey('docX'))` — Flutter's "Duplicate
/// GlobalKey" assertion fires the instant either selection lands.
///
/// With surface-scoping (the production fix), the keys are
/// `GlobalObjectKey(_AuraRowKey(.tasks, 'docX'))` vs
/// `GlobalObjectKey(_AuraRowKey(.sprint, 'docX'))` — distinct, no
/// throw.
///
/// This test stages the same multi-surface mount the IndexedStack
/// produces (without standing up the full TaskListScreen +
/// SprintTaskItemsScreen widget tree, which would require a wall of
/// provider stubs unrelated to the contract under test). It is the
/// minimum sufficient case for the bug class.
void main() {
  testWidgets(
      'same docId mounted simultaneously on .tasks and .sprint surfaces — '
      'selecting it does NOT throw "Duplicate GlobalKey" (TM-383)',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Stage the cross-surface mount: same docId on two surfaces, both
    // alive at once (mirrors what IndexedStack keeps mounted across
    // Tasks tab with `showSprintTasks=true` AND Plan tab's sprint
    // view).
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // "Tasks tab" surface — sprint-assigned task rendered
                // here because Show Tasks is on.
                Expanded(
                  child: AuraStack(
                    surface: TaskListSurface.tasks,
                    child: ListView(
                      children: const [
                        SelectableTaskItem(
                          surface: TaskListSurface.tasks,
                          taskDocId: 'docX',
                          child: SizedBox(
                            height: 60,
                            child:
                                ColoredBox(color: Color(0xFF1976D2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // "Plan tab" surface — same docX rendered here as the
                // canonical sprint location.
                Expanded(
                  child: AuraStack(
                    surface: TaskListSurface.sprint,
                    child: ListView(
                      children: const [
                        SelectableTaskItem(
                          surface: TaskListSurface.sprint,
                          taskDocId: 'docX',
                          child: SizedBox(
                            height: 60,
                            child:
                                ColoredBox(color: Color(0xFF1976D2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sanity: both rows alive simultaneously.
    expect(find.byType(SelectableTaskItem), findsNWidgets(2));

    // The bug fires on selection — the GlobalKey gets attached then.
    // Without surface scoping, this is where Flutter would throw
    // "Duplicate GlobalKey detected in widget tree".
    container.read(selectedTaskProvider.notifier).select('docX');
    await tester.pumpAndSettle();

    // The fact that pumpAndSettle returned without throwing IS the
    // assertion. Adding an explicit takeException check makes the
    // failure mode discoverable in CI logs if the regression reopens.
    expect(
      tester.takeException(),
      isNull,
      reason: 'cross-surface mount with surface-scoped keys must NOT '
          'throw "Duplicate GlobalKey" — that throw is exactly what the '
          'TM-383 Round 2 fix prevents',
    );

    // And both surfaces' shared keys resolve independently — each row
    // is findable via its own (surface, docId) lookup.
    expect(
      SelectableTaskItemKey.of(TaskListSurface.tasks, 'docX').currentContext,
      isNotNull,
      reason: 'tasks-surface row should be findable via its own key',
    );
    expect(
      SelectableTaskItemKey.of(TaskListSurface.sprint, 'docX').currentContext,
      isNotNull,
      reason: 'sprint-surface row should be findable via its own key',
    );
  });
}
