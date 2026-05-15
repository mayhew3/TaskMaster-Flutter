import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/task_completion_service.dart';
import '../../../models/check_state.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../../models/task_recurrence.dart';
import '../../shared/logic/task_grouping.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../../shared/presentation/editable_task_item.dart';
import '../../shared/presentation/plan_task_list.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/snooze_dialog.dart';
import '../../shared/presentation/task_action_error_helper.dart';
import '../../shared/presentation/view_options_sheet.dart';
import '../../shared/presentation/widgets/collapsible_group_header.dart';
import '../../shared/providers/task_list_view_providers.dart';
import '../../tasks/presentation/task_add_edit_screen.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/sprint_providers.dart';

part 'sprint_task_items_screen.g.dart';

/// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
/// with recurrences populated. Used by [sprintTaskItems] so that completed
/// tasks appear in the "Completed" section at the bottom of the list
/// (not just recently-completed ones).
///
/// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
/// loading), which broke the sprint screen's Completed section. This provider
/// bypasses that restriction via a direct Drift query scoped to the sprint's
/// task docIds, so the result set is bounded and cheap.
///
/// TM-368: family provider keyed by Sprint. keepAlive would pin every
/// sprint a user has ever opened in this session into memory. Auto-dispose
/// releases the watch when the sprint screen unmounts.
@riverpod
Stream<List<TaskItem>> sprintAllTasks(Ref ref, Sprint sprint) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value(const []);

  final docIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toList(growable: false);
  if (docIds.isEmpty) return Stream.value(const []);

  final tasksStream =
      db.taskDao.watchTasksByDocIds(personDocId, docIds).map((rows) {
    final result = <TaskItem>[];
    for (final row in rows) {
      try {
        result.add(taskItemFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [sprintAllTasks] Failed to convert task ${row.docId}: $e');
      }
    }
    return result;
  });

  final recurrencesStream =
      db.taskRecurrenceDao.watchActive(personDocId).map((rows) {
    final result = <TaskRecurrence>[];
    for (final row in rows) {
      try {
        result.add(taskRecurrenceFromRow(row));
      } catch (e) {
        debugPrint(
            '⚠️ [sprintAllTasks] Failed to convert recurrence ${row.docId}: $e');
      }
    }
    return result;
  });

  return Rx.combineLatest2<List<TaskItem>, List<TaskRecurrence>,
      List<TaskItem>>(
    tasksStream,
    recurrencesStream,
    (tasks, recurrences) {
      final recurrenceMap = {for (final r in recurrences) r.docId: r};
      return tasks.map((task) {
        if (task.recurrenceDocId != null) {
          final recurrence = recurrenceMap[task.recurrenceDocId];
          if (recurrence != null) {
            return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
          }
        }
        return task;
      }).toList();
    },
  );
}

/// Sprint task list in sprint-assignment order (TM-339), with the user's
/// TaskFilters applied via the shared pipeline.
///
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks`.
@riverpod
Future<List<TaskItem>> sprintTaskItems(Ref ref, Sprint sprint) async {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.sprint));
  final allSprintTasks =
      await ref.watch(sprintAllTasksProvider(sprint).future);
  final pendingTasks = ref.watch(pendingTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);
  final firestoreRoster =
      await ref.watch(sprintRosterFirestoreProvider(sprint).future);

  final sprintDocIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toSet();

  final taskMap = <String, TaskItem>{};
  for (final task in allSprintTasks) {
    taskMap[task.docId] = pendingTasks[task.docId] ?? task;
  }
  for (final task in recentlyCompleted) {
    if (sprintDocIds.contains(task.docId)) {
      if (task.completionDate != null) {
        taskMap[task.docId] = task;
      } else {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
  }
  final sprintCompletedVisible = view.filters.dueStatus.isEmpty ||
      view.filters.dueStatus.contains(DueStatusBucket.completed);
  if (sprintCompletedVisible) {
    for (final task in olderState.loadedTasks) {
      if (sprintDocIds.contains(task.docId)) {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
    for (final task in firestoreRoster) {
      if (sprintDocIds.contains(task.docId)) {
        taskMap.putIfAbsent(task.docId, () => task);
      }
    }
  }

  // Iterate sprint assignments IN ORDER (TM-339) — completion doesn't
  // reshuffle the displayed list.
  final ordered = <TaskItem>[];
  for (final sa in sprint.sprintAssignments) {
    if (sa.retired != null) continue;
    final task = taskMap[sa.taskDocId];
    if (task != null) ordered.add(task);
  }

  return applyTaskFilters(
    ordered.where((t) => t.retired == null),
    view.filters,
    now: DateTime.now(),
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  ).toList();
}

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
/// result is the bucketed view with most-pressing tasks first within
/// each bucket. The user can pick any other group/sort axis via the
/// View Options sheet.
@riverpod
Future<List<TaskGroupResult>> sprintGroupedTasks(Ref ref, Sprint sprint) async {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.sprint));
  final tasks = await ref.watch(sprintTaskItemsProvider(sprint).future);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);

  return groupAndSortTasks(
    tasks: tasks,
    view: view,
    now: DateTime.now(),
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  );
}

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
                  onPressed: () =>
                      ref.invalidate(sprintGroupedTasksProvider(sprint)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      drawer: const AppDrawer(),
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

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 7.0,
        bottom: kFloatingActionButtonMargin + 54,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) => tiles[i],
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
    return EditableTaskItemWidget(
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
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  final Sprint sprint;
  const _AddMoreButton({required this.sprint});

  @override
  Widget build(BuildContext context) {
    // TextButton (instead of the prior GestureDetector-on-Text): full
    // Material affordances — focus + hover ring, ≥48dp tap target,
    // screen-reader "button" role — without changing the bold-text
    // visual.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlanTaskList()),
          ),
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
