import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/models/task_item.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/task_completion_service.dart';
import '../providers/task_filter_providers.dart';
import '../providers/task_providers.dart';
import '../../sprints/providers/sprint_providers.dart';
import '../../../models/sprint.dart';
import '../../../models/check_state.dart';
import 'task_add_edit_screen.dart';
import 'task_details_screen.dart';
import '../../../models/task_colors.dart';
import '../../shared/presentation/editable_task_item.dart';
import '../../../redux/presentation/header_list_item.dart';
import '../../shared/presentation/snooze_dialog.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/app_bottom_nav.dart';
import '../../shared/presentation/refresh_button.dart';

/// Riverpod version of the Task List screen
/// Displays grouped tasks with filtering and completion functionality
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('📋 TaskListScreen: Building...');
    final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

    print('📋 TaskListScreen: tasksAsync isLoading=${tasksAsync.isLoading}, hasValue=${tasksAsync.hasValue}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          _FilterPopupMenu(),
          const RefreshButton(),
        ],
      ),
      body: tasksAsync.when(
        data: (_) => const _TaskListBody(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading tasks: $err'),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TaskAddEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
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
  const _TaskListBody();

  @override
  ConsumerState<_TaskListBody> createState() => _TaskListBodyState();
}

class _TaskListBodyState extends ConsumerState<_TaskListBody> {
  bool showSprintTasks = false;

  @override
  Widget build(BuildContext context) {
    final groupedTasksAsync = ref.watch(groupedTasksProvider);
    final activeSprint = ref.watch(activeSprintProvider);

    // Handle loading/error states for grouped tasks
    if (groupedTasksAsync.isLoading && !groupedTasksAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groupedTasksAsync.hasError && !groupedTasksAsync.hasValue) {
      return Center(
        child: Text('Error loading tasks: ${groupedTasksAsync.error}'),
      );
    }

    final groupedTasks = groupedTasksAsync.valueOrNull ?? [];
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
          tiles.add(_TaskListItem(task: task, highlightSprint: true));
        }
      }
    }

    // If no task groups (all filtered out), show empty state after sprint banner
    if (groupedTasks.isEmpty) {
      if (tiles.isEmpty) {
        // No sprint banner either - show simple empty state
        return _buildEmptyState();
      }
      // Sprint banner exists but no other tasks - add empty message below banner
      tiles.add(_buildEmptyStateWidget());
      return ListView.builder(
        padding: const EdgeInsets.only(
          top: 7.0,
          bottom: kFloatingActionButtonMargin + 54,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, index) => tiles[index],
      );
    }

    for (final group in groupedTasks) {
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

  /// Widget version of empty state for use in a ListView
  Widget _buildEmptyStateWidget() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No eligible tasks found.',
            style: TextStyle(fontSize: 17.0),
          ),
        ],
      ),
    );
  }
}

class _TaskListItem extends ConsumerWidget {
  final TaskItem task;
  final bool highlightSprint;

  const _TaskListItem({required this.task, this.highlightSprint = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditableTaskItemWidget(
      taskItem: task,
      highlightSprint: highlightSprint,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailsScreen(taskItemId: task.docId),
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
            await ref.read(deleteTaskProvider.notifier).call(task);
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
