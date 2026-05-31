import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/models/bad_schema_task.dart';
import 'package:taskmaestro/models/task_item.dart';
import '../../../core/platform/form_factor.dart';
import '../../../core/services/task_completion_service.dart';
import '../../../models/task_list_view.dart' show TaskListSurface;
import '../providers/task_filter_providers.dart';
import '../providers/task_providers.dart';
import '../../sprints/providers/sprint_providers.dart';
import '../../../models/sprint.dart';
import '../../../models/check_state.dart';
import 'task_add_edit_screen.dart';
import '../../../models/task_colors.dart';
import '../../shared/presentation/editable_task_item.dart';
import '../../shared/presentation/view_options_sheet.dart';
import '../../shared/presentation/widgets/collapsible_group_header.dart';
import '../../shared/presentation/widgets/header_list_item.dart';
import '../../shared/presentation/snooze_dialog.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/task_action_error_helper.dart';
import '../../shared/presentation/wide/aura_stack.dart';
import '../../shared/presentation/wide/selectable_task_item.dart';
import '../../shared/presentation/wide/view_options_summary_bar.dart';
import '../../shared/presentation/wide/wide_centered_column.dart';
import '../../shared/providers/task_list_view_providers.dart';

/// Riverpod version of the Task List screen
/// Displays grouped tasks with filtering and completion functionality
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _searchController = TextEditingController();
  bool _searchBarVisible = false;

  /// TM-382: 250ms debounce so a fast typist doesn't re-run the
  /// filter/group/sort pipeline per keystroke.
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchBarVisible = !_searchBarVisible;
      if (_searchBarVisible) {
        // Seed from the current provider value — the search may have
        // been set externally (e.g. via the wide sidebar) while the
        // AppBar bar was hidden, in which case opening the bar with an
        // empty field would misrepresent the active filter.
        final current = ref.read(searchQueryProvider);
        _searchController.text = current;
        _searchController.selection =
            TextSelection.collapsed(offset: current.length);
      } else {
        _searchDebounce?.cancel();
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).clear();
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    // Timer.cancel() in dispose guarantees no callback after unmount.
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(searchQueryProvider.notifier).set(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksWithRecurrencesProvider);
    // Sync the controller when the search is cleared externally (e.g.
    // tab nav). `ref.listen` (vs a build-time read) so the 250ms
    // debounce window can't be mistaken for an external clear.
    ref.listen<String>(searchQueryProvider, (prev, next) {
      if (next.isEmpty &&
          _searchBarVisible &&
          _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: _searchBarVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              )
            : const Text('Tasks'),
        actions: [
          const ConnectionStatusIndicator(),
          // TM-382: the wide sidebar hosts its own search field, so the
          // redundant in-AppBar search toggle hides on wide — unless the
          // bar is already open (compact→wide resize), in which case
          // the close icon must stay reachable.
          if (!isWideLayout(MediaQuery.sizeOf(context)) || _searchBarVisible)
            IconButton(
              icon: Icon(_searchBarVisible ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          const ViewOptionsButton(surface: TaskListSurface.tasks),
          const RefreshButton(),
        ],
        // TM-385: summary chip bar under the AppBar — only on the
        // two-pane wide layout (≥1200dp). Its chips open the docked
        // View Options pane via `rightPaneProvider`, and that pane is
        // only mounted when `isTwoPaneWideLayout` (see
        // `_buildWideShell`). On the 840–1199dp band there's no right
        // pane, so the chips would strand; View Options stays reachable
        // there via the AppBar button's bottom-sheet fallback.
        bottom: isTwoPaneWideLayout(MediaQuery.sizeOf(context))
            ? const ViewOptionsSummaryBar(surface: TaskListSurface.tasks)
            : null,
      ),
      body: tasksAsync.when(
        data: (_) => const _TaskListBody(),
        loading: () {
          // Preserve previous data during loading to prevent list disappearing
          if (tasksAsync.hasValue) {
            return const _TaskListBody();
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          print('❌ Error loading tasks: $err\n$stack');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load tasks. Please try again.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(tasksWithRecurrencesProvider),
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
      // Hide the add-task FAB on wide layouts — the sidebar already
      // hosts an "+ Add task" affordance (which opens the docked
      // editor on two-pane wide, or pushes the route below that), so
      // keeping the FAB visible would just be a duplicate entry point
      // sitting next to it.
      floatingActionButton: isWideLayout(MediaQuery.sizeOf(context))
          ? null
          : FloatingActionButton(
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

    final groupedTasks = groupedTasksAsync.value ?? [];
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
      return WideCenteredColumn(
        child: AuraStack(
          surface: TaskListSurface.tasks,
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: 7.0,
              bottom: kFloatingActionButtonMargin + 54,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) => tiles[index],
          ),
        ),
      );
    }

    final showCompleted = ref.watch(showCompletedProvider);
    final view = ref.watch(taskListViewStateProvider(TaskListSurface.tasks));
    final viewNotifier =
        ref.read(taskListViewStateProvider(TaskListSurface.tasks).notifier);

    for (final group in groupedTasks) {
      final collapsed = view.collapsedGroups.contains(group.key);
      // Group axis = none renders a single bucket with empty displayName;
      // skip the header entirely in that case (matches plan §5).
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
          tiles.add(_TaskListItem(task: task));
        }
      }
    }

    // "Load More" button: appended once at end-of-list when there's
    // more completed history to fetch. Under group-by-dueStatus the
    // Completed bucket is the last group anyway, so this lands in
    // the same visual spot. Under any other group axis (Area /
    // Priority / Points / Estimated Time / none), completed tasks
    // are interleaved across buckets and there's no Completed group
    // to anchor the button to — so end-of-list is the only natural
    // home. Respect collapse state only when the Completed bucket
    // actually exists (i.e. dueStatus grouping); without it there's
    // nothing for the user to collapse.
    if (showCompleted) {
      final olderState = ref.watch(olderCompletedTasksBatchesProvider);
      if (olderState.hasMore) {
        final hasCompletedGroup =
            groupedTasks.any((g) => g.key == 'due:completed');
        final completedCollapsed =
            view.collapsedGroups.contains('due:completed');
        if (!hasCompletedGroup || !completedCollapsed) {
          tiles.add(_LoadMoreCompletedButton());
        }
      }
    }

    // Show bad-schema tasks at the bottom with warning styling
    final badSchemaTasks = ref.watch(badSchemaTasksProvider);
    if (badSchemaTasks.isNotEmpty) {
      tiles.add(HeadingItem('Schema Errors (${badSchemaTasks.length})'));
      for (final badTask in badSchemaTasks) {
        tiles.add(_BadSchemaTaskItem(badTask: badTask));
      }
    }

    return WideCenteredColumn(
      child: AuraStack(
        surface: TaskListSurface.tasks,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: 7.0,
            bottom: kFloatingActionButtonMargin + 54,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
        ),
      ),
    );
  }

  Widget _buildSprintBanner(Sprint sprint, List<TaskItem> sprintTasks) {
    final startDate = sprint.startDate;
    final endDate = sprint.endDate;
    final currentDay = DateTime.now().toUtc().difference(startDate).inDays + 1;
    final totalDays = endDate.difference(startDate).inDays;
    final sprintStr = 'Active Sprint - Day $currentDay of $totalDays';

    // TM-361 manual-test #18: pull true completion counts from the
    // DB-backed provider rather than the displayed merge — see
    // sprintCompletionCountsProvider for rationale.
    final counts = ref.watch(sprintCompletionCountsProvider(sprint)).value ??
        SprintCounts.empty;
    final taskStr = '${counts.completed}/${counts.total} Tasks Complete';

    // Active-sprint summary card: intentionally distinct (red tint, sprint-color outline).
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

class _BadSchemaTaskItem extends StatelessWidget {
  final BadSchemaTask badTask;

  const _BadSchemaTaskItem({required this.badTask});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      title: Text(
        badTask.displayName,
        style: const TextStyle(
          color: Colors.red,
          fontStyle: FontStyle.italic,
        ),
      ),
      subtitle: Text(
        badTask.errorMessage,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      dense: true,
      enabled: false,
    );
  }
}

class _LoadMoreCompletedButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final olderState = ref.watch(olderCompletedTasksBatchesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: olderState.isLoading
              ? null
              : () => ref.read(olderCompletedTasksBatchesProvider.notifier).loadNextBatch(),
          icon: olderState.isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.expand_more),
          label: Text(olderState.isLoading
              ? 'Loading...'
              : 'Load older completed tasks'),
        ),
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
    // Watch pending state directly for immediate UI feedback (TM-323)
    // This avoids waiting for the async provider chain to propagate
    final pendingTasks = ref.watch(pendingTasksProvider);
    final displayTask = pendingTasks[task.docId] ?? task;

    // TM-383: SelectableTaskItem wraps the row with the magenta selection
    // ring on the wide adaptive shell; on phone it returns its child
    // unchanged (no ring, no extra rebuild surface).
    return SelectableTaskItem(
      surface: TaskListSurface.tasks,
      taskDocId: task.docId,
      child: EditableTaskItemWidget(
        taskItem: displayTask,
        highlightSprint: highlightSprint,
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
            } catch (err) {
              return false;
            }
          }
          return false;
        },
      ),
    );
  }
}
