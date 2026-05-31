import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/platform/form_factor.dart';
import '../../../core/services/task_completion_service.dart';
import '../../../models/check_state.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../shared/logic/task_grouping.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../../shared/presentation/editable_task_item.dart';
import '../../shared/presentation/plan_task_list.dart';
import '../providers/create_sprint_draft_provider.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/snooze_dialog.dart';
import '../../shared/presentation/task_action_error_helper.dart';
import '../../shared/presentation/view_options_sheet.dart';
import '../../shared/presentation/wide/aura_stack.dart';
import '../../shared/presentation/wide/selectable_task_item.dart';
import '../../shared/presentation/wide/view_options_summary_bar.dart';
import '../../shared/presentation/wide/wide_centered_column.dart';
import '../../shared/presentation/widgets/collapsible_group_header.dart';
import '../../shared/providers/task_list_view_providers.dart';
import '../../tasks/presentation/task_add_edit_screen.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/sprint_grouped_tasks_providers.dart';
import '../providers/sprint_providers.dart';

class SprintTaskItemsScreen extends ConsumerWidget {
  final Sprint sprint;

  const SprintTaskItemsScreen({
    super.key,
    required this.sprint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(sprintGroupedTasksProvider(sprint));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint Tasks'),
        actions: <Widget>[
          const ConnectionStatusIndicator(),
          const ViewOptionsButton(surface: TaskListSurface.sprint),
          const RefreshButton(),
        ],
        // TM-385: summary chip bar under the AppBar — only on the
        // two-pane wide layout (≥1200dp), where the docked View Options
        // pane its chips drive is actually mounted. On 840–1199dp the
        // bar would strand (no right pane); View Options stays reachable
        // via the AppBar button's bottom-sheet fallback there.
        bottom: isTwoPaneWideLayout(MediaQuery.sizeOf(context))
            ? const ViewOptionsSummaryBar(surface: TaskListSurface.sprint)
            : null,
      ),
      body: groupedAsync.when(
        data: (groups) => _SprintBody(sprint: sprint, groups: groups),
        loading: () {
          if (groupedAsync.hasValue) {
            return _SprintBody(sprint: sprint, groups: groupedAsync.value!);
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          print('❌ Error loading sprint tasks: $err\n$stack');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load sprint tasks. Please try again.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    // Invalidate upstream-to-downstream so a cached
                    // error in any pre-dependency actually recomputes.
                    // The error surfaced here may have originated in
                    // `sprintAllTasks` (Drift stream), the Firestore
                    // roster, or `sprintTaskItems` itself — invalidating
                    // only the leaf grouping provider wouldn't recover
                    // those.
                    ref.invalidate(sprintAllTasksProvider(sprint));
                    ref.invalidate(sprintRosterFirestoreProvider(sprint));
                    ref.invalidate(sprintTaskItemsProvider(sprint));
                    ref.invalidate(sprintGroupedTasksProvider(sprint));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      // TM-388: wide uses the sidebar profile footer to open the wide
      // shell's drawer; suppress this inner-screen drawer + auto-burger
      // on wide.
      drawer: isWideLayout(MediaQuery.sizeOf(context))
          ? null
          : const AppDrawer(),
    );
  }
}

class _SprintBody extends ConsumerWidget {
  final Sprint sprint;
  final List<TaskGroupResult> groups;

  const _SprintBody({required this.sprint, required this.groups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskListViewStateProvider(TaskListSurface.sprint));
    final viewNotifier = ref
        .read(taskListViewStateProvider(TaskListSurface.sprint).notifier);

    final tiles = <Widget>[];
    for (final group in groups) {
      final collapsed = view.collapsedGroups.contains(group.key);
      if (group.displayName.isNotEmpty) {
        tiles.add(CollapsibleGroupHeader(
          label: group.displayName,
          count: group.tasks.length,
          pointsTotal: group.pointsTotal,
          collapsed: collapsed,
          onTap: () => viewNotifier.toggleGroupCollapsed(group.key),
        ));
      }
      if (!collapsed) {
        for (final task in group.tasks) {
          tiles.add(_SprintTaskTile(task: task));
        }
      }
    }

    // Empty state: show the "No tasks found" card above the Add More
    // entry point. The empty case used to short-circuit into a separate
    // ListView that omitted Add More entirely, making it impossible to
    // add tasks from an empty sprint. Keeping `tiles` as the single
    // source of truth here means the empty-state card just slots in
    // ahead of the Add More button instead of replacing the whole view.
    if (groups.isEmpty || groups.every((g) => g.tasks.isEmpty)) {
      tiles.add(const _NoTasksFoundCard());
    }

    // "Add More..." entry point: opens the plan-mode picker so the user
    // can append more tasks to this sprint. Last in the list so it
    // always appears below any tiles / empty-state card.
    tiles.add(_AddMoreButton(sprint: sprint));

    return WideCenteredColumn(
      child: AuraStack(
        surface: TaskListSurface.sprint,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: 7.0,
            bottom: kFloatingActionButtonMargin + 54,
          ),
          itemCount: tiles.length,
          itemBuilder: (_, i) => tiles[i],
        ),
      ),
    );
  }
}

class _SprintTaskTile extends ConsumerWidget {
  final TaskItem task;
  const _SprintTaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTasks = ref.watch(pendingTasksProvider);
    final displayTask = pendingTasks[task.docId] ?? task;
    // TM-383: wrap with SelectableTaskItem so the magenta selection aura
    // renders on the wide adaptive shell. EditableTaskItemWidget's tap
    // handler already fires selectedTaskProvider on wide.
    return SelectableTaskItem(
      surface: TaskListSurface.sprint,
      taskDocId: task.docId,
      child: EditableTaskItemWidget(
        taskItem: displayTask,
        highlightSprint: false,
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskAddEditScreen(taskItemId: task.docId),
          ),
        ),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showDialog<void>(
            context: context,
            builder: (context) => SnoozeDialog(taskItem: task),
          );
        },
        onTaskCompleteToggle: (checkState) {
          if (checkState == CheckState.pending) return null;
          if (checkState == CheckState.skipped) {
            ref.read(skipTaskProvider.notifier).unskip(task).catchError(
                (Object e, StackTrace st) =>
                    showTaskActionError(context, e, st));
            return null;
          }
          ref
              .read(completeTaskProvider.notifier)
              .call(task, complete: checkState == CheckState.inactive)
              .catchError((Object e, StackTrace st) =>
                  showTaskActionError(context, e, st));
          return null;
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            try {
              await ref.read(deleteTaskProvider.notifier).call(task);
              return true;
            } catch (_) {
              return false;
            }
          }
          return false;
        },
      ),
    );
  }
}

class _AddMoreButton extends ConsumerWidget {
  final Sprint sprint;
  const _AddMoreButton({required this.sprint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TextButton (instead of the prior GestureDetector-on-Text): full
    // Material affordances — focus + hover ring, ≥48dp tap target,
    // screen-reader "button" role — without changing the bold-text
    // visual.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Center(
        child: TextButton(
          // TM-388: on wide, swap the add-to-existing picker in place
          // (sidebar stays visible) via the step provider; compact keeps
          // the full-screen route.
          onPressed: () {
            if (isWideLayout(MediaQuery.sizeOf(context))) {
              ref.read(createSprintStepProvider.notifier).toAddingToSprint();
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PlanTaskList()),
              );
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 12),
            minimumSize: const Size(120, 48),
          ),
          child: const Text(
            'Add More...',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}

class _NoTasksFoundCard extends StatelessWidget {
  const _NoTasksFoundCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Text(
        'No eligible tasks found.',
        style: TextStyle(fontSize: 17.0),
      ),
    );
  }
}
