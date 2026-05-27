import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../family/providers/family_task_filter_providers.dart';
import '../../sprints/providers/sprint_grouped_tasks_providers.dart';
import '../../sprints/providers/sprint_providers.dart';
import '../../tasks/providers/task_filter_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../logic/task_grouping.dart';
import 'task_list_view_providers.dart';

part 'sidebar_facet_counts.g.dart';

/// Faceted Area/Context counts for the wide sidebar (TM-382), scoped to
/// the active destination's surface. Each map counts the tasks that would
/// be visible on that tab with every current filter applied EXCEPT the
/// facet's own axis (so the other facets stay meaningful), keyed by
/// `name.trim().toLowerCase()`.
class SidebarFacetCounts {
  const SidebarFacetCounts({required this.areas, required this.contexts});

  final Map<String, int> areas;
  final Map<String, int> contexts;

  static const SidebarFacetCounts empty = SidebarFacetCounts(
    areas: <String, int>{},
    contexts: <String, int>{},
  );
}

/// Active-surface faceted counts.
///
/// Perf (TM-382): clearing an axis that the user has NOT narrowed is a
/// no-op, so that facet's source list equals the body's already-computed
/// visible list — reuse it (`filteredTasks` / `familyFilteredTasks` /
/// `sprintTaskItems`, which the on-screen list already built) instead of
/// re-running `applyTaskFilters`, and only pay the extra pass over the
/// pre-filter base pool for an axis that IS narrowed. Common case (no
/// area/context filter selected): zero extra filter passes, no base-pool
/// recompute — just an O(n) tally. `keepAlive` so switching back to a
/// surface reuses the cached counts.
///
/// `plan` (the create-sprint flow) has no app-level base pool — it's
/// built from in-screen sprint-creation form state — so it yields
/// [SidebarFacetCounts.empty]. Faithful plan counts are tracked as
/// TM-388 (paired with restructuring the create-sprint flow to render
/// inside the wide shell).
@Riverpod(keepAlive: true)
Future<SidebarFacetCounts> sidebarFacetCounts(
    Ref ref, TaskListSurface surface) async {
  switch (surface) {
    case TaskListSurface.plan:
      return SidebarFacetCounts.empty;
    case TaskListSurface.tasks:
      return _computeForTasks(ref);
    case TaskListSurface.family:
      return _computeForFamily(ref);
    case TaskListSurface.sprint:
      return _computeForSprint(ref);
  }
}

Future<SidebarFacetCounts> _computeForTasks(Ref ref) async {
  // Narrow watch: facet counts depend only on filters; unrelated view
  // changes (group axis, sort axis, collapse state) must not invalidate.
  final filters = ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
      .select((v) => v.filters));
  final needNormal = filters.areas.isEmpty || filters.contexts.isEmpty;
  final needBase = filters.areas.isNotEmpty || filters.contexts.isNotEmpty;
  final normal = needNormal
      ? await ref.watch(filteredTasksProvider.future)
      : const <TaskItem>[];
  final base = needBase
      ? await ref.watch(tasksBasePoolProvider.future)
      : const <TaskItem>[];
  return _tally(ref, filters, normal: normal, base: base);
}

Future<SidebarFacetCounts> _computeForFamily(Ref ref) async {
  final filters = ref.watch(taskListViewStateProvider(TaskListSurface.family)
      .select((v) => v.filters));
  final needNormal = filters.areas.isEmpty || filters.contexts.isEmpty;
  final needBase = filters.areas.isNotEmpty || filters.contexts.isNotEmpty;
  final normal = needNormal
      ? ref.watch(familyFilteredTasksProvider)
      : const <TaskItem>[];
  final base = needBase
      ? ref.watch(familyBasePoolProvider)
      : const <TaskItem>[];
  return _tally(ref, filters, normal: normal, base: base);
}

Future<SidebarFacetCounts> _computeForSprint(Ref ref) async {
  final sprint = ref.watch(activeSprintProvider);
  if (sprint == null) return SidebarFacetCounts.empty;
  final filters = ref.watch(taskListViewStateProvider(TaskListSurface.sprint)
      .select((v) => v.filters));
  final needNormal = filters.areas.isEmpty || filters.contexts.isEmpty;
  final needBase = filters.areas.isNotEmpty || filters.contexts.isNotEmpty;
  final normal = needNormal
      ? await ref.watch(sprintTaskItemsProvider(sprint).future)
      : const <TaskItem>[];
  final base = needBase
      ? await ref.watch(sprintBasePoolProvider(sprint).future)
      : const <TaskItem>[];
  return _tally(ref, filters, normal: normal, base: base);
}

/// Run the facet passes and tally. Re-uses [normal] (the body's already-
/// computed visible list) when an axis is un-narrowed; uses [base] to
/// re-filter with the narrowed axis cleared otherwise.
SidebarFacetCounts _tally(
  Ref ref,
  TaskFilters filters, {
  required List<TaskItem> normal,
  required List<TaskItem> base,
}) {
  final recentlyCompletedIds =
      ref.watch(recentlyCompletedTasksProvider).map((t) => t.docId).toSet();
  final now = DateTime.now();

  // Areas count: every current filter EXCEPT the areas axis.
  final areaSource = filters.areas.isEmpty
      ? normal
      : applyTaskFilters(
          base,
          filters.rebuild((b) => b..areas.clear()),
          now: now,
          recentlyCompletedDocIds: recentlyCompletedIds,
        );
  final areaCounts = <String, int>{};
  for (final task in areaSource) {
    final key = (task.area ?? '').trim().toLowerCase();
    if (key.isEmpty) continue;
    areaCounts[key] = (areaCounts[key] ?? 0) + 1;
  }

  // Contexts count: every current filter EXCEPT the contexts axis.
  final contextSource = filters.contexts.isEmpty
      ? normal
      : applyTaskFilters(
          base,
          filters.rebuild((b) => b..contexts.clear()),
          now: now,
          recentlyCompletedDocIds: recentlyCompletedIds,
        );
  final contextCounts = <String, int>{};
  for (final task in contextSource) {
    for (final context in task.contexts) {
      final key = context.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      contextCounts[key] = (contextCounts[key] ?? 0) + 1;
    }
  }

  return SidebarFacetCounts(areas: areaCounts, contexts: contextCounts);
}
