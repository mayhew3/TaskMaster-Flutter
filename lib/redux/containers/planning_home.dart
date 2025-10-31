import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/redux/containers/planning_home_viewmodel.dart';
import 'package:taskmaster/redux/containers/sprint_task_items.dart';
import 'package:taskmaster/redux/presentation/new_sprint.dart';
import 'package:taskmaster/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaster/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/core/feature_flags.dart';

import '../app_state.dart';

class PlanningHome extends ConsumerWidget {
  const PlanningHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Riverpod implementation if feature flag is enabled
    if (FeatureFlags.useRiverpodForSprints) {
      final activeSprint = ref.watch(activeSprintProvider);

      if (activeSprint == null) {
        return const NewSprintScreen();
      } else {
        return SprintTaskItemsScreen(sprint: activeSprint);
      }
    }

    // Default: use Redux implementation
    return StoreConnector<AppState, PlanningHomeViewModel>(
        builder: (context, PlanningHomeViewModel viewModel) {
          if (viewModel.activeSprint == null) {
            return const NewSprint();
          } else {
            return const SprintTaskItems();
          }
        },
        converter: PlanningHomeViewModel.fromStore
    );
  }
}
