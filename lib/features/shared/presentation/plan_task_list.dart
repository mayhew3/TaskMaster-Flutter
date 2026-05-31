import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/features/sprints/logic/plan_preview_generation.dart';
import 'package:taskmaestro/models/sprint_blueprint.dart';
import 'package:taskmaestro/models/sprint_display_task.dart';
import 'package:taskmaestro/helpers/task_selectors.dart';

import '../../../date_util.dart';
import '../../../models/sprint.dart';
import '../../../models/task_colors.dart';
import '../../../models/task_display_grouping.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/task_list_view.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/crash_reporter.dart';
import '../../shared/logic/task_grouping.dart' show applyTaskFilters;
import '../../shared/presentation/view_options_sheet.dart';
import '../../shared/providers/task_list_view_providers.dart';
import '../../sprints/providers/create_sprint_draft_provider.dart';
import '../../sprints/providers/sprint_providers.dart';
import '../../sprints/services/sprint_service.dart';
import '../../tasks/providers/task_providers.dart';
import './widgets/plan_task_item.dart';
import './widgets/header_list_item.dart';
import '../../../models/check_state.dart';

/// Riverpod version of PlanTaskList
///
/// Displays tasks that can be selected for inclusion in a sprint
class PlanTaskList extends ConsumerStatefulWidget {
  final int? numUnits;
  final String? unitName;
  final DateTime? startDate;

  /// TM-388: true when rendered inside the wide shell content area
  /// (PlanningHome swaps it in) rather than as a pushed full-screen
  /// route. In-shell there is NO route to pop — submit/back drive
  /// `createSprintStepProvider` instead (popping would tear down the
  /// whole wide shell).
  final bool inShell;

  const PlanTaskList({
    super.key,
    this.numUnits,
    this.unitName,
    this.startDate,
    this.inShell = false,
  }) : assert(
            !inShell ||
                (numUnits == null && unitName == null && startDate == null),
            'PlanTaskList(inShell: true) must not be constructed with cadence '
            'params — in-shell resolves them from createSprintDraftProvider. '
            'The compact pushed path is the only caller that passes them.');

  @override
  ConsumerState<PlanTaskList> createState() => _PlanTaskListState();
}

class _PlanTaskListState extends ConsumerState<PlanTaskList> {
  bool initialized = false;
  bool submitting = false;

  late final Sprint? activeSprint;

  // three queues for the selected task items
  List<TaskItem> taskItemQueue = [];
  List<TaskItemRecurPreview> taskItemRecurPreviewQueue = [];
  List<SprintDisplayTask> sprintDisplayTaskQueue = [];

  // ALL preview items to be displayed (existing task item list is dynamically created)
  List<TaskItemRecurPreview> tempIterations = [];

  bool popped = false;

  late final DateTime endDate;

  // TM-388 (R0 follow-up): in wide in-shell new-sprint mode we snapshot
  // the draft cadence on first build alongside `endDate` so the picker
  // is fully frozen. A late `lastCompletedSprint` emission that re-seeds
  // `_cachedSeed` would otherwise leave the picker filtering by the old
  // window but submitting a `SprintBlueprint` with the new cadence —
  // user selects against one window, sprint is created against a
  // different one. Left null for compact (constructor params) and
  // existing-sprint paths; only read in `submit()` on the in-shell new
  // path.
  DateTime? _draftStartDateSnapshot;
  int? _draftNumUnitsSnapshot;
  String? _draftUnitNameSnapshot;

  void validateState() {
    if (activeSprint != null &&
        (widget.numUnits != null || widget.unitName != null || widget.startDate != null)) {
      throw Exception(
          'Expected all of numUnits, unitName, and startDate to be null if there is an active sprint.');
    }
  }

  void preSelectUrgentAndDueAndPreviousSprint(
      BuiltList<TaskItem> allTaskItems, Sprint? lastSprint) {
    BuiltList<TaskItem> baseList = getBaseList(allTaskItems);

    final Iterable<TaskItem> dueOrUrgentTasks = baseList.where((taskItem) =>
        taskItem.isDueBefore(endDate) ||
        taskItem.isUrgentBefore(endDate) ||
        taskItemIsInSprint(taskItem, lastSprint)
    );
    taskItemQueue.addAll(dueOrUrgentTasks);
    sprintDisplayTaskQueue.addAll(dueOrUrgentTasks);
  }

  PlanTaskItemWidget _createWidget({
    required SprintDisplayTask taskItem,
    required BuiltList<Sprint> allSprints,
    required Sprint? lastSprint,
  }) {
    return PlanTaskItemWidget(
      // TM-365: stable ValueKey tied to the source's identifier
      // (`docId` for real TaskItems, `key` for previews). Without it,
      // ListView.builder falls back to index-based Element matching, so
      // list reorder remounts each row — losing the inline `DelayedCheckbox`
      // state and the synthesised-TaskItem cache (PlanTaskItemWidget's
      // State is per-Element, not per-Widget).
      key: ValueKey(taskItem.getSprintDisplayTaskKey()),
      sprintDisplayTask: taskItem,
      endDate: endDate,
      highlightSprint: highlightSprint(taskItem, lastSprint),
      initialCheckState: sprintDisplayTaskQueue.contains(taskItem) ? CheckState.checked : CheckState.inactive,
      onTaskAssignmentToggle: (checkState) {
        var alreadyQueued = sprintDisplayTaskQueue.contains(taskItem);
        if (alreadyQueued) {
          setState(() {
            if (taskItem is TaskItem) {
              taskItemQueue.remove(taskItem);
            } else if (taskItem is TaskItemRecurPreview) {
              taskItemRecurPreviewQueue.remove(taskItem);
            }
            sprintDisplayTaskQueue.remove(taskItem);
          });
          return CheckState.inactive;
        } else {
          setState(() {
            if (taskItem is TaskItem) {
              taskItemQueue.add(taskItem);
            } else if (taskItem is TaskItemRecurPreview) {
              taskItemRecurPreviewQueue.add(taskItem);
            }
            sprintDisplayTaskQueue.add(taskItem);
          });
          return CheckState.checked;
        }
      },
    );
  }

  BuiltList<TaskItem> getBaseList(BuiltList<TaskItem> allTaskItems) {
    var sprint = activeSprint;
    if (sprint == null) {
      return taskItemsForPlacingOnNewSprint(allTaskItems, endDate);
    } else {
      return taskItemsForPlacingOnExistingSprint(allTaskItems, sprint);
    }
  }

  bool highlightSprint(SprintDisplayTask taskItem, Sprint? lastSprint) {
    return taskItemIsInSprint(taskItem, lastSprint);
  }

  bool wasInEarlierSprint(SprintDisplayTask taskItem, BuiltList<Sprint> allSprints, Sprint? lastSprint) {
    if (taskItem is TaskItem) {
      var sprints = sprintsForTaskItemSelector(allSprints, taskItem).where((sprint) => sprint != lastSprint);
      return sprints.isNotEmpty;
    } else {
      return false;
    }
  }

  void createTemporaryIterations(BuiltList<TaskItem> allTaskItems) {
    // TM-388: preview generation lifted into the pure
    // `generatePlanPreviews` helper so the sidebar facet-count provider
    // (`planRecurrencePreviewsProvider`) and the picker tally the exact
    // same set. Initial queue preselection (the original
    // `willBeUrgentOrDue` rule from `addNextIterations`) stays here —
    // it's user-selection state that belongs to the widget, not the
    // pure generator.
    final allRecurrences = ref.read(taskRecurrencesProvider).value ?? [];
    final previews = generatePlanPreviews(
      allTasks: allTaskItems,
      activeSprint: activeSprint,
      endDate: endDate,
      allRecurrences: allRecurrences,
      now: DateTime.now(),
    );
    for (final preview in previews) {
      tempIterations.add(preview);
      if (previewShouldPreselect(preview, endDate)) {
        taskItemRecurPreviewQueue.add(preview);
        sprintDisplayTaskQueue.add(preview);
      }
    }
  }

  void _addTaskTile({
    required List<Widget> tiles,
    required SprintDisplayTask task,
    required BuiltList<Sprint> allSprints,
    required Sprint? lastSprint,
  }) {
    tiles.add(_createWidget(
      taskItem: task,
      allSprints: allSprints,
      lastSprint: lastSprint,
    ));
  }

  ListView _buildListView(BuildContext context, BuiltList<TaskItem> allTaskItems, BuiltList<Sprint> allSprints,
      Sprint? lastSprint, BuiltList<TaskItem> recentlyCompleted) {
    final List<SprintDisplayTask> otherTasks = [];
    // TM-359: apply the user's TaskFilters to the TaskItem subset before
    // bucketing. The plan-mode 8-bucket grouping below is sprint-history-
    // aware and intentionally stays hardcoded for v1 — only the *filter*
    // axes (search, recurrence, areas, etc.) take effect here. TaskItem-
    // RecurPreview rows always flow through (they're forward-looking
    // synthesized rows that the filter set wasn't designed to cover).
    //
    // `ref.watch` (not `read`): the View Options sheet mutates this provider
    // and the plan-mode body must rebuild when the user applies a new
    // filter, otherwise the sheet visually opens but the list does nothing.
    final view = ref.watch(taskListViewStateProvider(TaskListSurface.plan));
    final baseTasks = getBaseList(allTaskItems);
    final recentlyCompletedDocIds =
        recentlyCompleted.map((t) => t.docId).toSet();
    final filteredBase = applyTaskFilters(
      baseTasks,
      view.filters,
      now: DateTime.now(),
      recentlyCompletedDocIds: recentlyCompletedDocIds,
    );
    // TM-388 follow-up: the synthesized recurrence-preview rows
    // (`tempIterations`) inherit `area` / `contexts` from their source
    // task, so apply the user's area + context narrowing here too —
    // otherwise on wide the sidebar visibly narrows by area, the user
    // sees preview rows from non-selected areas in this list, and
    // wonders why the picker ignored their filter. Mirrors
    // `applyTaskFilters`'s exact-match + any-of context semantics.
    // (Other filter axes — search, priority, points, duration, due
    // status, age — remain pre-existing TM-359 behavior on previews.)
    final filteredPreviews = tempIterations.where((p) {
      if (view.filters.areas.isNotEmpty &&
          !view.filters.areas.contains(p.area ?? '')) {
        return false;
      }
      if (view.filters.contexts.isNotEmpty &&
          !p.contexts.any((c) => view.filters.contexts.contains(c.name))) {
        return false;
      }
      return true;
    });
    otherTasks.addAll(filteredBase);
    otherTasks.addAll(filteredPreviews);

    startDateSort(SprintDisplayTask a, SprintDisplayTask b) => a.startDate!.compareTo(b.startDate!);
    completionDateSort(SprintDisplayTask a, SprintDisplayTask b) => a.completionDate!.compareTo(b.completionDate!);

    final List<TaskDisplayGrouping> groupings = [
      TaskDisplayGrouping(displayName: 'Last Sprint', displayOrder: 1, filter: (taskItem) => (taskItem is TaskItem) && taskItemIsInSprint(taskItem, lastSprint)),
      TaskDisplayGrouping(displayName: 'Older Sprints', displayOrder: 2, filter: (taskItem) => wasInEarlierSprint(taskItem, allSprints, lastSprint)),
      TaskDisplayGrouping(displayName: 'Due Soon', displayOrder: 3, filter: (taskItem) => taskItem.isDueBefore(endDate)),
      TaskDisplayGrouping(displayName: 'Urgent Soon', displayOrder: 4, filter: (taskItem) => taskItem.isUrgentBefore(endDate)),
      TaskDisplayGrouping(displayName: 'Target Soon', displayOrder: 5, filter: (taskItem) => taskItem.isTargetBefore(endDate)),
      TaskDisplayGrouping(displayName: 'Starting Later', displayOrder: 7, filter: (taskItem) => taskItem.isScheduledAfter(endDate), ordering: startDateSort),
      TaskDisplayGrouping(displayName: 'Completed', displayOrder: 8, filter: (taskItem) => taskItem.isCompleted() &&
              !recentlyCompleted.any((t) => t.docId == taskItem.getSprintDisplayTaskKey()), ordering: completionDateSort),
      // must come last to take all the other tasks
      TaskDisplayGrouping(displayName: 'Tasks', displayOrder: 6, filter: (_) => true),
    ];

    List<Widget> tiles = [];

    for (var g in groupings) {
      g.stealItemsThatMatch(otherTasks);
    }
    groupings.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    for (var grouping in groupings) {
      if (grouping.taskItems.isNotEmpty) {
        tiles.add(HeadingItem(grouping.displayName));
        for (var task in grouping.taskItems) {
          _addTaskTile(
            tiles: tiles,
            task: task,
            allSprints: allSprints,
            lastSprint: lastSprint,
          );
        }
      }
    }

    if (tiles.isEmpty) {
      tiles.add(_createNoTasksFoundCard());
    }

    return ListView.builder(
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 54),
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        });
  }

  Card _createNoTasksFoundCard() {
    // Borderless empty-state card: blends with the screen background.
    // elevation: 0 + surfaceTintColor: transparent suppress M3's tonal overlay
    // so the card surface matches the screen bg exactly.
    return Card(
      elevation: 0,
      shadowColor: TaskColors.invisible,
      surfaceTintColor: Colors.transparent,
      color: TaskColors.backgroundColor,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            )
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'No eligible tasks found.',
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TM-388: wide in-shell NEW-sprint path — rendered in-shell, no active
  /// sprint. Its cadence comes from `createSprintDraftProvider`.
  bool get _isInShellNewSprint => widget.inShell && activeSprint == null;

  DateTime getEndDate() {
    if (activeSprint != null) return activeSprint!.endDate;
    // New-sprint mode: draft formula on the wide in-shell path, else the
    // constructor params from the compact full-screen push.
    if (_isInShellNewSprint) return ref.read(createSprintEndDateProvider);
    return DateUtil.adjustToDate(
        widget.startDate!, widget.numUnits!, widget.unitName!);
  }

  bool addMode() {
    return activeSprint == null;
  }

  void submit(BuildContext context, String personDocId) async {
    if (submitting) {
      print('[TM-306] Submit already in progress, ignoring duplicate call');
      return;
    }

    submitting = true;

    try {
      if (addMode()) {
        // TM-388: in the wide in-shell path the cadence comes from the
        // `_draft*Snapshot` fields captured on first build (NOT a live
        // `ref.read(createSprintDraftProvider)` here), so the picker's
        // filtering window (`endDate`) and the submitted blueprint
        // (start/numUnits/unitName) stay consistent even if the draft
        // re-seeds while the picker is open. Compact passes its values
        // through constructor params directly. `??` resolves to whichever
        // channel is populated.
        final startDate = widget.startDate ?? _draftStartDateSnapshot!;
        final numUnits = widget.numUnits ?? _draftNumUnitsSnapshot!;
        final unitName = widget.unitName ?? _draftUnitNameSnapshot!;
        final sprint = SprintBlueprint(
            startDate: startDate,
            endDate: endDate,
            numUnits: numUnits,
            unitName: unitName,
            personDocId: personDocId);
        print('[TM-306] Submitting new sprint');
        await ref.read(createSprintProvider.notifier).call(
          sprintBlueprint: sprint,
          taskItems: taskItemQueue,
          taskItemRecurPreviews: taskItemRecurPreviewQueue,
        );
        // TM-388: guard ref/context use after the await — the user can
        // navigate away or sign out during the in-flight call, which
        // disposes the ConsumerState; touching `ref` post-dispose
        // throws.
        if (!mounted) return;
      } else {
        print('[TM-306] Adding ${taskItemQueue.length} tasks to sprint ${activeSprint!.docId}');
        await ref.read(addTasksToSprintProvider.notifier).call(
          sprint: activeSprint!,
          taskItems: taskItemQueue,
          taskItemRecurPreviews: taskItemRecurPreviewQueue,
        );
        if (!mounted) return;
        // Unlike CreateSprint (which lets failures propagate),
        // AddTasksToSprint.call() wraps its work in AsyncValue.guard, so a
        // failure is captured in the provider's error state instead of
        // thrown. Re-surface it so the shared catch below keeps the screen
        // open on failure rather than popping as if it succeeded
        // (TM-375; Copilot PR #34 round 1).
        final addResult = ref.read(addTasksToSprintProvider);
        if (addResult.hasError) {
          Error.throwWithStackTrace(
              addResult.error!, addResult.stackTrace ?? StackTrace.current);
        }
      }

      // TM-375: leave the screen deterministically on success for both
      // modes.
      print('[TM-306] Submit complete, leaving picker');
      if (mounted && !popped) {
        popped = true;
        if (widget.inShell) {
          // TM-388: no pushed route to pop. Show a transient spinner
          // (`creating`) covering the gap between submit-success and
          // the Drift sprints stream emitting the change — for BOTH
          // new-sprint AND add-to-existing. Without it, add-to-existing
          // would flash the OLD sprint list (cached
          // sprintGroupedTasks(oldSprint)) before the new sprint
          // instance arrives. `PlanningHome` clears the spinner on the
          // next sprints emission and renders the (now-updated)
          // SprintTaskItemsScreen / cadence form / new sprint view.
          ref.read(createSprintStepProvider.notifier).toCreating();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e, stack) {
      // Don't pop on failure — leave the screen up so the user can
      // retry. submitting is reset in `finally` so a retry isn't
      // blocked by the duplicate-call guard.
      // Redacted breadcrumb only — the print-capturing zone persists to
      // a user-exportable log file, so don't echo $e/$stack (they can
      // carry task/sprint field values + personDocId). Full detail goes
      // to the crash reporter: Crashlytics in release; in debug it only
      // debugPrints to the dev console (NOT the persisted print zone),
      // and debug builds don't produce user-exportable logs anyway.
      // Fire-and-forget via .ignore() so a throwing reporter can't
      // surface as a secondary unhandled async error after we've handled
      // the failure.
      print('[TM-375] Submit failed: ${e.runtimeType}');
      // Guard ref.read against post-dispose throw (the widget may have
      // unmounted during the awaited call).
      if (mounted) {
        ref.read(crashReporterProvider).logError(e, stack,
            context: 'Create Sprint / Add to Sprint submit').ignore();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    } finally {
      submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final allTasksAsync = ref.watch(tasksWithRecurrencesProvider);
    final allSprintsAsync = ref.watch(sprintsProvider);
    final recentlyCompletedList = ref.watch(recentlyCompletedTasksProvider);
    final personDocId = ref.watch(personDocIdProvider);

    // Handle loading/error states
    if (allTasksAsync.isLoading || allSprintsAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Select Tasks')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (allTasksAsync.hasError || allSprintsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text('Select Tasks')),
        body: Center(child: Text('Error loading data')),
      );
    }

    final allTasks = allTasksAsync.value ?? [];
    final allSprints = allSprintsAsync.value ?? [];
    final allTasksBuilt = BuiltList<TaskItem>(allTasks);
    final allSprintsBuilt = BuiltList<Sprint>(allSprints);
    final recentlyCompleted = BuiltList<TaskItem>(recentlyCompletedList);

    // Initialize on first build
    if (!initialized) {
      activeSprint = activeSprintSelector(allSprintsBuilt);
      validateState();
      endDate = getEndDate();
      if (_isInShellNewSprint) {
        final draft = ref.read(createSprintDraftProvider);
        _draftStartDateSnapshot = draft.sprintStart;
        _draftNumUnitsSnapshot = draft.numUnits;
        _draftUnitNameSnapshot = draft.unitName;
      }
      final lastSprint = lastCompletedSprintSelector(allSprintsBuilt);
      preSelectUrgentAndDueAndPreviousSprint(allTasksBuilt, lastSprint);
      createTemporaryIterations(allTasksBuilt);
      initialized = true;

      // Set up listeners after initialization (so activeSprint is set).
      // TM-375: the create-mode auto-pop listener was removed — it raced
      // the awaited submit on the sprintsProvider Drift stream and often
      // never fired, leaving the screen open. `submit()` now pops
      // deterministically for both modes (guarded by `popped`).

      // Auto-pop when tasks are added to existing sprint (pushed route
      // only). TM-388: the in-shell path has no route to pop — submit()
      // returns to the sprint list via `createSprintStepProvider`, so
      // this listener must NOT run there (it would pop the wide shell).
      if (activeSprint != null && !widget.inShell) {
        print('[TM-306] Setting up listener for sprint ${activeSprint!.docId}');
        ref.listen(sprintsProvider, (previous, next) {
          print('[TM-306] Sprints provider changed!');
          if (!popped) {
            // Find the current sprint in the updated list
            final prevSprints = previous?.value ?? [];
            final nextSprints = next.value ?? [];

            final prevSprint = prevSprints.firstWhereOrNull((s) => s.docId == activeSprint!.docId);
            final nextSprint = nextSprints.firstWhereOrNull((s) => s.docId == activeSprint!.docId);

            final prevCount = prevSprint?.sprintAssignments.length ?? 0;
            final nextCount = nextSprint?.sprintAssignments.length ?? 0;

            print('[TM-306] Sprint assignment count changed: $prevCount -> $nextCount');

            if (nextCount > prevCount) {
              print('[TM-306] Popping navigation!');
              popped = true;
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          }
        });
      }
    }

    final lastSprint = lastCompletedSprintSelector(allSprintsBuilt);

    return Scaffold(
      appBar: AppBar(
        // TM-388: in-shell wide path has no pushed route, so it gets no
        // automatic back button — supply one that returns to the prior
        // in-shell view (cadence form for new-sprint, sprint list for
        // add-to-existing; both are the default `form` step). Compact
        // (pushed) keeps the framework's default leading.
        leading: widget.inShell
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip:
                    activeSprint == null ? 'Back to cadence' : 'Back to sprint',
                onPressed: () =>
                    ref.read(createSprintStepProvider.notifier).toForm(),
              )
            : null,
        title: const Text('Select Tasks'),
        actions: [
          const ViewOptionsButton(surface: TaskListSurface.plan),
        ],
      ),
      body: _buildListView(context, allTasksBuilt, allSprintsBuilt, lastSprint, recentlyCompleted),
      floatingActionButton: Visibility(
        visible: sprintDisplayTaskQueue.isNotEmpty,
        child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => submit(context, personDocId ?? ''),
            label: Text('Submit')
        ),
      ),
    );
  }
}
