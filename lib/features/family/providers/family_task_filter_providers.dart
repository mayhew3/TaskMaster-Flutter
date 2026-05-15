import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../models/task_item.dart';
import '../../../models/task_list_view.dart';
import '../../shared/logic/task_grouping.dart';
import '../../shared/providers/task_list_view_providers.dart';
import '../../tasks/providers/task_providers.dart';

part 'family_task_filter_providers.g.dart';

/// Family tab tasks after surface-specific gates + the user's `TaskFilters`.
///
/// Surface gates applied here (not part of the shared pipeline):
/// - drop retired rows.
/// - `ownedByMeOnly` filters to tasks created by the current user.
///
/// Everything else (search / showCompleted / showScheduled / recurrence /
/// age / priority / points / due-status / context / area) is delegated to
/// `applyTaskFilters` so the Family tab and the Tasks tab share a single
/// filtering code path.
///
/// TM-368: pure-derived. Cheap to recompute on consumer remount.
@riverpod
List<TaskItem> familyFilteredTasks(Ref ref) {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.family));
  final tasksAsync = ref.watch(familyTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final myPersonDocId = ref.watch(personDocIdProvider);

  final tasks = tasksAsync.value ?? const <TaskItem>[];

  final surfaceFiltered = tasks.where((task) {
    if (task.retired != null) return false;
    if (view.filters.ownedByMeOnly &&
        myPersonDocId != null &&
        task.personDocId != myPersonDocId) {
      return false;
    }
    return true;
  });

  return applyTaskFilters(
    surfaceFiltered,
    view.filters,
    now: DateTime.now(),
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  ).toList();
}

/// Grouped + sorted Family tab tasks, routed through `groupAndSortTasks`.
///
/// TM-368: pure-derived. `areasProvider` is read only when the active
/// group axis is `area` — otherwise this provider doesn't transitively
/// force a Drift open in tests that don't override the areas stream.
@riverpod
List<TaskGroupResult> familyGroupedTasks(Ref ref) {
  final view = ref.watch(taskListViewStateProvider(TaskListSurface.family));
  final filtered = ref.watch(familyFilteredTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);

  return groupAndSortTasks(
    tasks: filtered,
    view: view,
    now: DateTime.now(),
    recentlyCompletedDocIds:
        recentlyCompleted.map((t) => t.docId).toSet(),
  );
}
