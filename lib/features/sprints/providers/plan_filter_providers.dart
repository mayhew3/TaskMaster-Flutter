import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../helpers/task_selectors.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/task_list_view.dart';
import '../../shared/logic/task_grouping.dart' show applyTaskFilters;
import '../../shared/providers/task_list_view_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../logic/plan_preview_generation.dart';
import 'create_sprint_draft_provider.dart';
import 'sprint_providers.dart';

part 'plan_filter_providers.g.dart';

/// Pre-filter task pool for the create-sprint (plan) surface (TM-388).
///
/// Mirrors `tasksBasePool` / `sprintBasePool`: the candidate TaskItem set
/// BEFORE the user's TaskFilters, so the sidebar can compute faceted
/// Area/Context counts by re-running `applyTaskFilters` over this same
/// pool with one axis cleared.
///
/// Produces exactly what `PlanTaskList.getBaseList` produces — the same
/// `task_selectors` family-exclusion + completion filters, against the
/// same `tasksWithRecurrencesProvider` source and the same
/// `createSprintEndDate` formula — so the counts can't drift from the
/// rendered list. The synthesized recurrence-preview rows the picker
/// also shows are intentionally NOT counted (consistent with how the
/// other three surfaces count and how `applyTaskFilters` is designed —
/// previews aren't `TaskItem`s the filter set was built for).
@Riverpod(keepAlive: true)
Future<List<TaskItem>> planBasePool(Ref ref) async {
  final allTasks = await ref.watch(tasksWithRecurrencesProvider.future);
  final activeSprint = ref.watch(activeSprintProvider);
  final allBuilt = BuiltList<TaskItem>(allTasks);

  if (activeSprint == null) {
    final endDate = ref.watch(createSprintEndDateProvider);
    return taskItemsForPlacingOnNewSprint(allBuilt, endDate).toList();
  }
  return taskItemsForPlacingOnExistingSprint(allBuilt, activeSprint).toList();
}

/// Synthesized recurrence-preview rows for the create-sprint picker
/// (TM-388). Generated from the same source set as `planBasePool`'s
/// parents (eligible recurring tasks), with the picker's window
/// projection. Read by the sidebar facet-count helper so previews
/// contribute to Area/Context counts alongside base TaskItems; the
/// picker reads it too so the displayed previews and the tallied
/// previews stay in sync.
@Riverpod(keepAlive: true)
Future<List<TaskItemRecurPreview>> planRecurrencePreviews(Ref ref) async {
  final allTasks = await ref.watch(tasksWithRecurrencesProvider.future);
  final activeSprint = ref.watch(activeSprintProvider);
  final endDate = activeSprint != null
      ? activeSprint.endDate
      : ref.watch(createSprintEndDateProvider);
  // `taskRecurrencesProvider` is a Drift stream; awaiting its `.future`
  // is the same pattern `tasksBasePool` etc. use.
  final allRecurrences = await ref.watch(taskRecurrencesProvider.future);
  return generatePlanPreviews(
    allTasks: BuiltList(allTasks),
    activeSprint: activeSprint,
    endDate: endDate,
    allRecurrences: allRecurrences,
    now: DateTime.now(),
  );
}

/// Plan-surface tasks after the user's TaskFilters — the "normal" list
/// the sidebar reuses for the common case where the faceted axis isn't
/// narrowed (mirrors `filteredTasks` / `familyFilteredTasks`).
@riverpod
Future<List<TaskItem>> planFilteredTasks(Ref ref) async {
  final filters = ref.watch(
      taskListViewStateProvider(TaskListSurface.plan).select((v) => v.filters));
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final base = await ref.watch(planBasePoolProvider.future);
  return applyTaskFilters(
    base,
    filters,
    now: DateTime.now(),
    recentlyCompletedDocIds: recentlyCompleted.map((t) => t.docId).toSet(),
  ).toList();
}
