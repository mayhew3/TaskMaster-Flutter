import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../redux/presentation/task_item_list.dart';
import '../../../redux/presentation/filter_button.dart';
import '../../../redux/presentation/refresh_button.dart';
import '../../../redux/presentation/task_main_menu.dart';
import '../../../redux/containers/tab_selector.dart';
import '../providers/sprint_providers.dart';
import '../../tasks/providers/task_providers.dart';

part 'sprint_task_items_screen.g.dart';

/// Provider for sprint filter settings
/// Using keepAlive to persist state across tab switches
@Riverpod(keepAlive: true)
class ShowCompletedInSprint extends _$ShowCompletedInSprint {
  @override
  bool build() => true; // Default to true for sprint tab

  void toggle() => state = !state;
}

@Riverpod(keepAlive: true)
class ShowScheduledInSprint extends _$ShowScheduledInSprint {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

/// Provider for filtered tasks in the active sprint
@riverpod
List<TaskItem> sprintTaskItems(SprintTaskItemsRef ref, Sprint sprint) {
  final allTasks = ref.watch(tasksProvider).value ?? [];
  final showCompleted = ref.watch(showCompletedInSprintProvider);
  final showScheduled = ref.watch(showScheduledInSprintProvider);

  // Get tasks assigned to this sprint
  final sprintTasks = allTasks.where((task) {
    return sprint.sprintAssignments.any((sa) => sa.taskDocId == task.docId);
  });

  // Apply filters
  return sprintTasks.where((task) {
    if (task.retired != null) return false;

    final completedPredicate = task.completionDate == null || showCompleted;
    final scheduledPredicate = task.startDate == null ||
        task.startDate!.isBefore(DateTime.now()) ||
        showScheduled;

    return completedPredicate && scheduledPredicate;
  }).toList();
}

class SprintTaskItemsScreen extends ConsumerWidget {
  final Sprint sprint;

  const SprintTaskItemsScreen({
    super.key,
    required this.sprint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskItems = ref.watch(sprintTaskItemsProvider(sprint));
    final showCompleted = ref.watch(showCompletedInSprintProvider);
    final showScheduled = ref.watch(showScheduledInSprintProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint Tasks'),
        actions: <Widget>[
          FilterButton(
            scheduledGetter: () => showScheduled,
            completedGetter: () => showCompleted,
            toggleScheduled: () =>
                ref.read(showScheduledInSprintProvider.notifier).toggle(),
            toggleCompleted: () =>
                ref.read(showCompletedInSprintProvider.notifier).toggle(),
          ),
          const RefreshButton(),
        ],
      ),
      body: TaskItemList(
        taskItems: taskItems.toBuiltList(),
        sprintMode: true,
      ),
      drawer: const TaskMainMenu(),
      bottomNavigationBar: const TabSelector(),
    );
  }
}
