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
import 'package:taskmaster/redux/containers/tab_selector.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/delayed_checkbox.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/task_completion_service.dart';
import '../providers/task_filter_providers.dart';
import '../providers/task_providers.dart';
import 'task_add_edit_screen.dart';
import 'task_details_screen.dart';

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

class _TaskListBody extends StatelessWidget {
  final List<TaskGroup> groups;

  const _TaskListBody({required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _buildEmptyState();
    }

    final tiles = <Widget>[];
    for (final group in groups) {
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
