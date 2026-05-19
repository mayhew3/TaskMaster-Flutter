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

/// Active-surface faceted counts. `plan` (the create-sprint flow) has no
/// app-level base pool — it's built from in-screen sprint-creation form
/// state — so it yields [SidebarFacetCounts.empty] (the sidebar then
/// shows no count there); a faithful plan count is a tracked follow-up.
@riverpod
Future<SidebarFacetCounts> sidebarFacetCounts(
    Ref ref, TaskListSurface surface) async {
  final List<TaskItem> base;
  switch (surface) {
    case TaskListSurface.tasks:
      base = await ref.watch(tasksBasePoolProvider.future);
    case TaskListSurface.family:
      base = ref.watch(familyBasePoolProvider);
    case TaskListSurface.sprint:
      final sprint = ref.watch(activeSprintProvider);
      if (sprint == null) return SidebarFacetCounts.empty;
      base = await ref.watch(sprintBasePoolProvider(sprint).future);
    case TaskListSurface.plan:
      return SidebarFacetCounts.empty;
  }

  final view = ref.watch(taskListViewStateProvider(surface));
  final rc =
      ref.watch(recentlyCompletedTasksProvider).map((t) => t.docId).toSet();
  final now = DateTime.now();

  // Areas count: every current filter EXCEPT the areas axis.
  final areaCounts = <String, int>{};
  for (final t in applyTaskFilters(
    base,
    view.filters.rebuild((b) => b..areas.clear()),
    now: now,
    recentlyCompletedDocIds: rc,
  )) {
    final key = (t.area ?? '').trim().toLowerCase();
    if (key.isEmpty) continue;
    areaCounts[key] = (areaCounts[key] ?? 0) + 1;
  }

  // Contexts count: every current filter EXCEPT the contexts axis.
  final contextCounts = <String, int>{};
  for (final t in applyTaskFilters(
    base,
    view.filters.rebuild((b) => b..contexts.clear()),
    now: now,
    recentlyCompletedDocIds: rc,
  )) {
    for (final c in t.contexts) {
      final key = c.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      contextCounts[key] = (contextCounts[key] ?? 0) + 1;
    }
  }

  return SidebarFacetCounts(areas: areaCounts, contexts: contextCounts);
}
