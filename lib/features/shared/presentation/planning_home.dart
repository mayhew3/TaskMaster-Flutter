import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/features/shared/presentation/plan_task_list.dart';
import 'package:taskmaestro/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaestro/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaestro/features/sprints/providers/create_sprint_draft_provider.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';

import '../../../core/platform/form_factor.dart';

class PlanningHome extends ConsumerWidget {
  const PlanningHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TM-388: once the sprints store ACTUALLY changes after a submit,
    // drop the transient wide-flow `creating` spinner. Drift can re-emit
    // sprintsProvider on watched-table touches that don't actually
    // change the sprints list (a "no-op" emission); clearing `creating`
    // on those would briefly render SprintTaskItemsScreen with the OLD
    // sprint instance (cached groupedTasks → stale-list flash) before
    // the real update arrives. Deep-compare prev vs next to gate the
    // reset on a real change (length grew → new sprint added;
    // assignments changed → add-to-existing).
    ref.listen(sprintsProvider, (prev, next) {
      if (!next.hasValue) return;
      if (ref.read(createSprintStepProvider) !=
          CreateSprintStepValue.creating) return;
      if (prev != null &&
          prev.hasValue &&
          const ListEquality().equals(prev.value!, next.value!)) {
        return;
      }
      ref.read(createSprintStepProvider.notifier).toForm();
    });

    final sprintsAsync = ref.watch(sprintsProvider);

    return sprintsAsync.when(
      data: (sprints) {
        // Find active sprint from the loaded sprints
        final now = DateTime.now().toUtc();
        final activeSprint = sprints
            .where((sprint) =>
                sprint.startDate.isBefore(now) &&
                sprint.endDate.isAfter(now) &&
                sprint.closeDate == null)
            .lastOrNull;

        final wide = isWideLayout(MediaQuery.sizeOf(context));

        if (activeSprint != null) {
          if (wide) {
            // TM-388: the "Add More..." picker renders IN PLACE on
            // wide (sidebar stays visible) instead of a full-screen
            // route; the transient `creating` spinner covers the gap
            // between submit-success and the sprints stream emitting
            // the updated sprint (without it,
            // SprintTaskItemsScreen would briefly render the OLD
            // sprint's cached grouped-tasks before the new sprint
            // instance arrives, causing a stale-list flash).
            final step = ref.watch(createSprintStepProvider);
            if (step == CreateSprintStepValue.addingToSprint) {
              return const PlanTaskList(inShell: true);
            }
            if (step == CreateSprintStepValue.creating) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          }
          return SprintTaskItemsScreen(sprint: activeSprint);
        }

        // No active sprint → create-sprint flow.
        //
        // TM-388: on the wide layout, swap the cadence form and the task
        // picker IN PLACE inside the shell content area (sidebar stays
        // visible) instead of pushing the picker as a full-screen route.
        // Compact keeps the form, which pushes the picker full-screen.
        if (wide) {
          final step = ref.watch(createSprintStepProvider);
          switch (step) {
            case CreateSprintStepValue.picking:
              // resolves cadence from the draft
              return const PlanTaskList(inShell: true);
            case CreateSprintStepValue.creating:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case CreateSprintStepValue.form:
            case CreateSprintStepValue.addingToSprint:
              // `addingToSprint` is meaningless with no active sprint
              // (stale after the sprint closed) — fall back to the form.
              return const NewSprintScreen();
          }
        }
        return const NewSprintScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error loading sprints: $err'),
        ),
      ),
    );
  }
}
