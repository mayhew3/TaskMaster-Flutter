import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/task_list_view.dart';

/// Reads / writes a [TaskListView] for each [TaskListSurface] via
/// `SharedPreferences`. The persistence-key version (`v1`) lives in the
/// key itself rather than inside the JSON, so a forward-incompatible
/// schema change can stage `v2.*` keys while leaving `v1.*` intact for
/// safe downgrades. JSON parse failures fall back to the surface default
/// silently (logged once per surface per process) so a corrupt entry
/// can't crash the app and doesn't spam logs on every read.
class TaskListViewStorage {
  TaskListViewStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Process-lifetime gate for the malformed-payload warning so the same
  /// corrupt entry doesn't log on every `loadSync` call (the keepAlive
  /// notifier calls `loadSync` once per build, but `_storage` can be
  /// reconstructed across hot reloads / test re-entrances).
  static final Set<TaskListSurface> _loggedMalformed = <TaskListSurface>{};

  static String keyFor(TaskListSurface surface) =>
      'taskmaestro.listview.v1.${surface.name}';

  /// Synchronous load. Safe to call from a Riverpod `build()` because
  /// `SharedPreferences` reads from an in-memory copy after
  /// `getInstance()` has resolved (which bootstrap awaits before
  /// `runApp`).
  TaskListView loadSync(TaskListSurface surface) {
    final defaultView = TaskListView.defaultForSurface(surface);
    final raw = _prefs.getString(keyFor(surface));
    if (raw == null) return defaultView;
    final parsed = TaskListView.fromJsonString(raw, defaultView: defaultView);
    if (identical(parsed, defaultView) &&
        raw.isNotEmpty &&
        _loggedMalformed.add(surface)) {
      developer.log(
        'TaskListViewStorage: malformed payload for $surface — using default',
        name: 'TaskListViewStorage',
      );
    }
    // TM-382: the search term is session-only. Drop any persisted query
    // (from a payload written before this rule, or a not-yet-stripped
    // write) so a search never survives an app restart.
    return parsed.rebuild((b) => b..filters.search = '');
  }

  /// Persist [view] for [surface]. Returns the SharedPreferences write
  /// Future so callers can `.ignore()` or `.await` as appropriate.
  Future<void> save(TaskListSurface surface, TaskListView view) {
    // TM-382: never persist the search term — it is session-only.
    final persisted = view.rebuild((b) => b..filters.search = '');
    return _prefs.setString(keyFor(surface), persisted.toJsonString());
  }

  /// Remove the persisted entry for [surface] (next load returns the
  /// surface default).
  Future<void> clear(TaskListSurface surface) {
    return _prefs.remove(keyFor(surface));
  }
}
