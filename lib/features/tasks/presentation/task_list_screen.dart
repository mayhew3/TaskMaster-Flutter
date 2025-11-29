import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/core/feature_flags.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/presentation/add_edit_screen.dart';
import 'package:taskmaster/redux/presentation/details_screen.dart';
import 'package:taskmaster/redux/presentation/editable_task_item.dart';
import 'package:taskmaster/redux/presentation/header_list_item.dart';
import 'package:taskmaster/redux/presentation/snooze_dialog.dart';
import 'package:taskmaster/redux/presentation/task_main_menu.dart';
import 'package:taskmaster/redux/presentation/refresh_button.dart';
import 'package:taskmaster/redux/containers/tab_selector.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/delayed_checkbox.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/task_completion_service.dart';
import '../providers/task_filter_providers.dart';
import '../providers/task_providers.dart';
import '../../sprints/providers/sprint_providers.dart';
import '../../../models/sprint.dart';
import 'task_add_edit_screen.dart';
import 'task_details_screen.dart';
import '../../../models/task_colors.dart';

/// Riverpod version of the Task List screen
/// Displays grouped tasks with filtering and completion functionality
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTasks = ref.watch(groupedTasksProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          const RefreshButton(),
          _FilterPopupMenu(),
        ],
      ),
      body: tasksAsync.when(
        data: (_) => _TaskListBody(groups: groupedTasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading tasks: $err'),
        ),
      ),
      drawer: TaskMainMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeatureFlags.useRiverpodForTasks
                  ? const TaskAddEditScreen()
                  : AddEditScreen(
                      timezoneHelper: StoreProvider.of<AppState>(context).state.timezoneHelper,
                    ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: TabSelector(),
    );
  }

}

/// Filter popup menu for showing/hiding completed and scheduled tasks
class _FilterPopupMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCompleted = ref.watch(showCompletedProvider);
    final showScheduled = ref.watch(showScheduledProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) {
        if (value == 'completed') {
          ref.read(showCompletedProvider.notifier).toggle();
        } else if (value == 'scheduled') {
          ref.read(showScheduledProvider.notifier).toggle();
        }
      },
      itemBuilder: (context) => [
        CheckedPopupMenuItem<String>(
          checked: showScheduled,
          value: 'scheduled',
          child: const Text('Show Scheduled'),
        ),
        CheckedPopupMenuItem<String>(
          checked: showCompleted,
          value: 'completed',
          child: const Text('Show Completed'),
        ),
      ],
    );
  }
}

class _TaskListBody extends ConsumerStatefulWidget {
  final List<TaskGroup> groups;

  const _TaskListBody({required this.groups});

  @override
  ConsumerState<_TaskListBody> createState() => _TaskListBodyState();
}

class _TaskListBodyState extends ConsumerState<_TaskListBody> {
  bool showSprintTasks = false;

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return _buildEmptyState();
    }

    final activeSprint = ref.watch(activeSprintProvider);
    final sprintTasks = activeSprint != null
        ? ref.watch(tasksForSprintProvider(activeSprint))
        : <TaskItem>[];

    final tiles = <Widget>[];

    // Add sprint banner if there's an active sprint
    if (activeSprint != null) {
      tiles.add(_buildSprintBanner(activeSprint, sprintTasks));
    }

    // Add sprint tasks if toggled on
    if (activeSprint != null && showSprintTasks) {
      if (sprintTasks.isNotEmpty) {
        tiles.add(HeadingItem('Sprint Tasks'));
        for (final task in sprintTasks) {
          tiles.add(_TaskListItem(task: task));
        }
      }
    }

    for (final group in widget.groups) {
      tiles.add(HeadingItem(group.name));
      for (final task in group.tasks) {
        tiles.add(_TaskListItem(task: task));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 7.0,
        bottom: kFloatingActionButtonMargin + 54,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) => tiles[index],
    );
  }

  Widget _buildSprintBanner(Sprint sprint, List<TaskItem> sprintTasks) {
    final startDate = sprint.startDate;
    final endDate = sprint.endDate;
    final currentDay = DateTime.now().toUtc().difference(startDate).inDays + 1;
    final totalDays = endDate.difference(startDate).inDays;
    final sprintStr = 'Active Sprint - Day $currentDay of $totalDays';

    final completed = sprintTasks.where((task) => task.completionDate != null).length;
    final taskStr = '$completed/${sprintTasks.length} Tasks Complete';

    return Card(
      color: const Color.fromARGB(100, 100, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
        side: BorderSide(
          color: TaskColors.sprintColor,
          width: 1.0,
        ),
      ),
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(13.5),
          child: Row(
            children: <Widget>[
              Icon(Icons.assignment, color: TaskColors.sprintColor),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sprintStr,
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      taskStr,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: TaskColors.sprintColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => showSprintTasks = !showSprintTasks),
                child: Text(
                  showSprintTasks ? 'Hide Tasks' : 'Show Tasks',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No eligible tasks found.',
              style: TextStyle(fontSize: 17.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskListItem extends ConsumerWidget {
  final TaskItem task;

  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditableTaskItemWidget(
      taskItem: task,
      highlightSprint: false, // TODO: Add sprint highlighting logic
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FeatureFlags.useRiverpodForTasks
                ? TaskDetailsScreen(taskItemId: task.docId)
                : DetailsScreen(taskItemId: task.docId),
          ),
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showDialog<void>(
          context: context,
          builder: (context) => SnoozeDialog(taskItem: task),
        );
      },
      onTaskCompleteToggle: (checkState) {
        if (checkState != CheckState.pending) {
          final shouldComplete = checkState == CheckState.inactive;
          ref.read(completeTaskProvider.notifier).call(
                task,
                complete: shouldComplete,
              );
        }
        return null;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          try {
            // Use Redux dispatch for now to maintain compatibility
            StoreProvider.of<AppState>(context).dispatch(
              DeleteTaskItemAction(task),
            );
            return true;
          } catch (err) {
            return false;
          }
        }
        return false;
      },
    );
  }
}
