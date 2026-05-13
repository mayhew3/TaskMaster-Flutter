import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/task_list_view.dart';
import '../persistence/task_list_view_storage.dart';
import 'shared_preferences_provider.dart';

part 'task_list_view_providers.g.dart';

/// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
/// so Tasks / Family / Sprint / Plan each remember independent
/// selections. State is hydrated synchronously from
/// `TaskListViewStorage` (which reads from an already-loaded
/// `SharedPreferences`) and every mutator writes through.
///
/// `keepAlive: true` because the selections are stateful user data that
/// must survive consumer remounts (TM-368 policy). The notifier
/// shouldn't be auto-disposed.
@Riverpod(keepAlive: true)
class TaskListViewState extends _$TaskListViewState {
  late final TaskListSurface _surface;
  late final TaskListViewStorage _storage;

  @override
  TaskListView build(TaskListSurface surface) {
    _surface = surface;
    final prefs = ref.watch(sharedPreferencesProvider);
    _storage = TaskListViewStorage(prefs);
    return _storage.loadSync(surface);
  }

  void setGroupAxis(TaskGroupAxis axis) {
    if (state.groupAxis == axis) return;
    _emit(state.rebuild((b) => b..groupAxis = axis));
  }

  void setSortAxis(TaskSortAxis axis) {
    if (state.sortAxis == axis) return;
    _emit(state.rebuild((b) => b..sortAxis = axis));
  }

  void setSortDirection(SortDirection direction) {
    if (state.sortDirection == direction) return;
    _emit(state.rebuild((b) => b..sortDirection = direction));
  }

  void toggleSortDirection() {
    final next = state.sortDirection == SortDirection.ascending
        ? SortDirection.descending
        : SortDirection.ascending;
    _emit(state.rebuild((b) => b..sortDirection = next));
  }

  void setFilters(TaskFilters filters) {
    if (state.filters == filters) return;
    _emit(state.rebuild((b) => b..filters.replace(filters)));
  }

  void setSearch(String search) {
    if (state.filters.search == search) return;
    _emit(state.rebuild((b) => b..filters.search = search));
  }

  void toggleGroupCollapsed(String groupKey) {
    final next = state.rebuild((b) {
      if (state.collapsedGroups.contains(groupKey)) {
        b.collapsedGroups.remove(groupKey);
      } else {
        b.collapsedGroups.add(groupKey);
      }
    });
    _emit(next);
  }

  void collapseAll(Iterable<String> groupKeys) {
    _emit(state.rebuild((b) => b..collapsedGroups.replace(groupKeys)));
  }

  void expandAll() {
    if (state.collapsedGroups.isEmpty) return;
    _emit(state.rebuild((b) => b..collapsedGroups.clear()));
  }

  /// Restore the surface's factory default (clears the persisted entry).
  void reset() {
    final fresh = TaskListView.defaultForSurface(_surface);
    state = fresh;
    // Fire-and-forget; SharedPreferences errors are non-fatal and would
    // log internally — the in-memory state is already correct for the
    // current session.
    _storage.clear(_surface).ignore();
  }

  void _emit(TaskListView next) {
    state = next;
    _storage.save(_surface, next).ignore();
  }
}
