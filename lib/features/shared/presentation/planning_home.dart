import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaster/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';

class PlanningHome extends ConsumerWidget {
  const PlanningHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        if (activeSprint == null) {
          return const NewSprintScreen();
        } else {
          return SprintTaskItemsScreen(sprint: activeSprint);
        }
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
