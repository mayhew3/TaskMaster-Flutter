import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../family/providers/family_task_filter_providers.dart';
import '../../sprints/presentation/sprint_task_items_screen.dart';
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

  static const SidebarFacetCounts empty =
      SidebarFacetCounts(areas: {}, contexts: {});
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
/// [SidebarFacetCounts.empty]; a faithful plan count is a tracked
/// follow-up.
@Riverpod(keepAlive: true)
Future<SidebarFacetCounts> sidebarFacetCounts(
    Ref ref, TaskListSurface surface) async {
  final TaskListView view;
  // Only depend on / trigger the body's filtered list when a facet axis
  // is un-narrowed (its source == that list), and only the pre-filter
  // base pool when an axis IS narrowed.
  Future<List<TaskItem>>? normalF;
  Future<List<TaskItem>>? baseF;
  switch (surface) {
    case TaskListSurface.tasks:
      view = ref.watch(taskListViewStateProvider(TaskListSurface.tasks));
      final f = view.filters;
      normalF = (f.areas.isEmpty || f.contexts.isEmpty)
          ? ref.watch(filteredTasksProvider.future)
          : null;
      baseF = (f.areas.isNotEmpty || f.contexts.isNotEmpty)
          ? ref.watch(tasksBasePoolProvider.future)
          : null;
    case TaskListSurface.family:
      view = ref.watch(taskListViewStateProvider(TaskListSurface.family));
      final f = view.filters;
      normalF = (f.areas.isEmpty || f.contexts.isEmpty)
          ? Future.value(ref.watch(familyFilteredTasksProvider))
          : null;
      baseF = (f.areas.isNotEmpty || f.contexts.isNotEmpty)
          ? Future.value(ref.watch(familyBasePoolProvider))
          : null;
    case TaskListSurface.sprint:
      final sprint = ref.watch(activeSprintProvider);
      if (sprint == null) return SidebarFacetCounts.empty;
      view = ref.watch(taskListViewStateProvider(TaskListSurface.sprint));
      final f = view.filters;
      normalF = (f.areas.isEmpty || f.contexts.isEmpty)
          ? ref.watch(sprintTaskItemsProvider(sprint).future)
          : null;
      baseF = (f.areas.isNotEmpty || f.contexts.isNotEmpty)
          ? ref.watch(sprintBasePoolProvider(sprint).future)
          : null;
    case TaskListSurface.plan:
      return SidebarFacetCounts.empty;
  }

  final rc =
      ref.watch(recentlyCompletedTasksProvider).map((t) => t.docId).toSet();
  final now = DateTime.now();
  final nf = normalF;
  final bf = baseF;
  final normal = nf == null ? const <TaskItem>[] : await nf;
  final base = bf == null ? const <TaskItem>[] : await bf;

  // Areas count: every current filter EXCEPT the areas axis.
  final areaSource = view.filters.areas.isEmpty
      ? normal
      : applyTaskFilters(
          base,
          view.filters.rebuild((b) => b..areas.clear()),
          now: now,
          recentlyCompletedDocIds: rc,
        );
  final areaCounts = <String, int>{};
  for (final t in areaSource) {
    final key = (t.area ?? '').trim().toLowerCase();
    if (key.isEmpty) continue;
    areaCounts[key] = (areaCounts[key] ?? 0) + 1;
  }

  // Contexts count: every current filter EXCEPT the contexts axis.
  final contextSource = view.filters.contexts.isEmpty
      ? normal
      : applyTaskFilters(
          base,
          view.filters.rebuild((b) => b..contexts.clear()),
          now: now,
          recentlyCompletedDocIds: rc,
        );
  final contextCounts = <String, int>{};
  for (final t in contextSource) {
    for (final c in t.contexts) {
      final key = c.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      contextCounts[key] = (contextCounts[key] ?? 0) + 1;
    }
  }

  return SidebarFacetCounts(areas: areaCounts, contexts: contextCounts);
}
