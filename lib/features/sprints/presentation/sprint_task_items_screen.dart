import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/feature_flags.dart';
import '../../../core/services/task_completion_service.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_colors.dart';
import '../../../models/task_display_grouping.dart';
import '../../../models/sprint_display_task.dart';
import '../../../redux/app_state.dart';
import '../../../redux/presentation/details_screen.dart';
import '../../../redux/presentation/delayed_checkbox.dart';
import '../../../redux/presentation/filter_button.dart';
import '../../../redux/presentation/header_list_item.dart';
import '../../../redux/presentation/plan_task_list.dart';
import '../../../redux/presentation/refresh_button.dart';
import '../../../redux/presentation/snooze_dialog.dart';
import '../../../redux/presentation/task_main_menu.dart';
import '../../../redux/containers/tab_selector.dart';
import '../providers/sprint_providers.dart';
import '../../tasks/presentation/task_details_screen.dart';
import '../../tasks/providers/task_providers.dart';
import '../../shared/presentation/task_item_list.dart';

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

  /// Check if Redux StoreProvider is available in the widget tree
  bool _hasReduxStore(BuildContext context) {
    try {
      StoreProvider.of<AppState>(context);
      return true;
    } catch (e) {
      return false;
    }
  }

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
        taskItems: BuiltList<TaskItem>(taskItems),
        sprintMode: true,
      ),
      // Only show drawer/bottomNav when Redux StoreProvider is available
      drawer: _hasReduxStore(context) ? const TaskMainMenu() : null,
      bottomNavigationBar: _hasReduxStore(context) ? const TabSelector() : null,
    );
  }
}
