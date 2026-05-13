import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/task_list_view.dart';

/// Reads / writes a [TaskListView] for each [TaskListSurface] via
/// `SharedPreferences`. The persistence-key version (`v1`) lives in the
/// key itself rather than inside the JSON, so a forward-incompatible
/// schema change can stage `v2.*` keys while leaving `v1.*` intact for
/// safe downgrades. JSON parse failures fall back to the surface default
/// silently (logged once) so a corrupt entry can't crash the app.
class TaskListViewStorage {
  TaskListViewStorage(this._prefs);

  final SharedPreferences _prefs;

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
    if (identical(parsed, defaultView) && raw.isNotEmpty) {
      // fromJsonString returned the fallback because parsing failed; log
      // once so a corrupt entry is visible in flight recordings without
      // spamming on every read.
      developer.log(
        'TaskListViewStorage: malformed payload for $surface — using default',
        name: 'TaskListViewStorage',
      );
    }
    return parsed;
  }

  /// Persist [view] for [surface]. Returns the SharedPreferences write
  /// Future so callers can `.ignore()` or `.await` as appropriate.
  Future<void> save(TaskListSurface surface, TaskListView view) {
    return _prefs.setString(keyFor(surface), view.toJsonString());
  }

  /// Remove the persisted entry for [surface] (next load returns the
  /// surface default).
  Future<void> clear(TaskListSurface surface) {
    return _prefs.remove(keyFor(surface));
  }
}
