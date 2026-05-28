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
  late TaskListSurface _surface;
  TaskListViewStorage? _storage;

  /// True once *any* mutator (including `reset()`) has run while
  /// `_storage` was still null. Tracks intent rather than state value:
  /// a `state == defaultView` after `reset()` is conceptually different
  /// from a `state == defaultView` that has never been touched, and
  /// the async init needs to distinguish them so it doesn't overwrite
  /// the user's intent with a stale persisted entry.
  bool _touchedBeforeStorageReady = false;

  @override
  TaskListView build(TaskListSurface surface) {
    _surface = surface;
    // Sync path: if SharedPreferences is already resolved (production
    // main.dart pre-warms it before runApp; many tests have already
    // awaited a microtask before reading this provider), initialize
    // synchronously and load from storage.
    final prefsAsync = ref.read(sharedPreferencesProvider);
    if (prefsAsync.hasValue) {
      _storage = TaskListViewStorage(prefsAsync.requireValue);
      return _storage!.loadSync(surface);
    }
    // Async path: prefs not yet resolved. Return the surface default and
    // schedule a one-time init that either loads from storage (user
    // has not touched state → safe to overwrite) or persists the
    // current state (user mutated before init → preserve their change).
    // Crucially we do NOT `ref.watch` the prefs provider — re-entering
    // build() on prefs resolution would stomp any mutations made in
    // the interim.
    _storage = null;
    _touchedBeforeStorageReady = false;
    ref.read(sharedPreferencesProvider.future).then((prefs) {
      if (!ref.mounted) return;
      _storage = TaskListViewStorage(prefs);
      if (_touchedBeforeStorageReady) {
        // User mutated before storage was ready; flush the divergence
        // so the next session sees it. `reset()` lands in this branch
        // too — current state happens to match the surface default,
        // so clearing the persisted entry produces the same future
        // load result as saving the default verbatim.
        if (state == TaskListView.defaultForSurface(_surface)) {
          _storage!.clear(_surface).ignore();
        } else {
          _storage!.save(_surface, state).ignore();
        }
      } else {
        // No user mutation since build — load persisted (if any).
        state = _storage!.loadSync(_surface);
      }
    }).ignore();
    return TaskListView.defaultForSurface(surface);
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

  /// Wide-layout (TM-385): toggle the View Options panel's
  /// collapsed-vs-expanded state for this surface.
  void toggleViewOptionsCollapsed() {
    _emit(state.rebuild((b) =>
        b..viewOptionsCollapsed = !state.viewOptionsCollapsed));
  }

  /// Wide-layout (TM-385): explicitly set the collapsed flag (used by
  /// the sidebar's View Options button to force-expand on open even
  /// if the user previously collapsed the panel for this surface).
  void setViewOptionsCollapsed(bool collapsed) {
    if (state.viewOptionsCollapsed == collapsed) return;
    _emit(state.rebuild((b) => b..viewOptionsCollapsed = collapsed));
  }

  /// Wide-layout (TM-385): update the View Options panel's expanded
  /// width ratio for this surface. Clamped to `[0.0, 1.0]`; the
  /// width-computing provider lerps between `kViewOptionsExpandedMin`
  /// and `kViewOptionsExpandedMax`.
  void setViewOptionsExpandedRatio(double ratio) {
    final clamped = ratio.clamp(0.0, 1.0);
    if (state.viewOptionsExpandedRatio == clamped) return;
    _emit(state.rebuild((b) => b..viewOptionsExpandedRatio = clamped));
  }

  /// Restore the surface's factory default (clears the persisted entry).
  void reset() {
    final fresh = TaskListView.defaultForSurface(_surface);
    state = fresh;
    // Storage may be null during the brief window before
    // sharedPreferencesProvider resolves. Record the touch so the
    // async init's "no user mutation since build" branch doesn't
    // overwrite the reset with a stale persisted entry; otherwise
    // persist immediately.
    if (_storage == null) {
      _touchedBeforeStorageReady = true;
    } else {
      _storage!.clear(_surface).ignore();
    }
  }

  void _emit(TaskListView next) {
    state = next;
    if (_storage == null) {
      _touchedBeforeStorageReady = true;
    } else {
      _storage!.save(_surface, next).ignore();
    }
  }
}
