import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/converters.dart';
import '../../../core/database/tables.dart' show SyncState;
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/serializers.dart';
import '../../../models/task_item.dart';
import '../../../models/task_recurrence.dart';

part 'sync_conflict_providers.g.dart';

/// TM-342: a sync conflict surfaces when [_pushPendingTasks] /
/// [_pushPendingRecurrences] detects that the remote was modified after the
/// local pending edit. The local row is preserved, the remote envelope is
/// stashed in `conflictRemoteJson`, and `syncState` becomes `pendingConflict`.
/// Sync is paused for that doc until the user resolves via the banner / dialog.

/// Common interface for [TaskConflict] and [RecurrenceConflict] so the banner
/// and list UI can show counts and route uniformly.
sealed class SyncConflict {
  String get docId;
  String get priorSyncState;
}

class TaskConflict implements SyncConflict {
  TaskConflict({
    required this.local,
    required this.remote,
    required this.priorSyncState,
  });

  final TaskItem local;
  final TaskItem remote;
  @override
  final String priorSyncState;

  @override
  String get docId => local.docId;
}

class RecurrenceConflict implements SyncConflict {
  RecurrenceConflict({
    required this.local,
    required this.remote,
    required this.priorSyncState,
  });

  final TaskRecurrence local;
  final TaskRecurrence remote;
  @override
  final String priorSyncState;

  @override
  String get docId => local.docId;
}

/// Decoded conflict envelope: the remote model plus the priorSyncState the
/// row had before it became `pendingConflict`. Used to be a record type
/// (`({TModel remote, String priorSyncState})?`), but riverpod_generator 4.x
/// can't introspect record types in the same compilation unit as `@riverpod`-
/// annotated providers — it bails with `InvalidTypeException`. Plain class
/// avoids that cliff and keeps the providers below buildable (TM-361).
class _DecodedEnvelope<TModel> {
  _DecodedEnvelope({required this.remote, required this.priorSyncState});
  final TModel remote;
  final String priorSyncState;
}

/// Decodes a conflict envelope JSON written by SyncService into the local +
/// remote pair plus the priorSyncState. Returns null on malformed envelopes
/// (logged) so a corrupt row doesn't crash the UI.
///
/// [normalize] is an optional pre-deserialization hook on the remote JSON
/// map. Used by the TaskItem decode path to map the legacy `project` key to
/// `area` for envelopes written by pre-TM-345 builds — without the remap,
/// "Use latest" would deserialize the remote with `area == null` and
/// silently drop the area tag.
_DecodedEnvelope<TModel>? _decodeEnvelope<TModel>({
  required String envelopeJson,
  required String docId,
  required Serializer<TModel> serializer,
  Map<String, dynamic> Function(Map<String, dynamic>)? normalize,
}) {
  try {
    final envelope = jsonDecode(envelopeJson) as Map<String, dynamic>;
    final priorSyncState = envelope['priorSyncState'] as String? ?? 'pendingUpdate';
    var remoteJson = Map<String, dynamic>.from(envelope['remote'] as Map);
    if (normalize != null) remoteJson = normalize(remoteJson);
    remoteJson['docId'] = docId;
    final remote = serializers.deserializeWith(serializer, remoteJson);
    if (remote == null) return null;
    return _DecodedEnvelope(remote: remote, priorSyncState: priorSyncState);
  } catch (e, s) {
    debugPrint('⚠️ [_decodeEnvelope] failed for $docId: $e\n$s');
    return null;
  }
}

/// TM-345 + TM-181 backwards compat for stored TaskItem conflict envelopes.
///
/// Conflict envelopes are written to Drift as opaque JSON text and survive
/// schema migrations on disk, so we have to translate field shapes in-flight
/// when the TaskItem schema changes:
/// - TM-345: pre-rename builds carried a `project` key — rename to `area`.
/// - TM-181: pre-rename builds carried a singular `context: "Phone"` —
///   rewrite as `contexts: [{name: "Phone"}]` via [TaskItem]'s helper.
///
/// Without these, "Use latest" would silently drop migrated fields when the
/// user resolves a stale conflict on a freshly-upgraded build.
Map<String, dynamic> _renameTaskFieldsForLegacyEnvelope(
    Map<String, dynamic> json) {
  if (json.containsKey('project') && !json.containsKey('area')) {
    json['area'] = json.remove('project');
  }
  TaskItem.applyLegacyContextFallback(json);
  return json;
}

/// Raw count of pendingConflict task rows for the user. Powers the banner
/// count and the "stuck-rows" calculation — used by `allConflictsCount`
/// and `stuckConflictsCount` below.
///
/// **Returns just the count rather than the full row list** because
/// riverpod_generator 4.x can't introspect Drift-generated row types
/// (`drift.Task`, `drift.TaskRecurrence`) in a provider's return signature
/// — it bails with `InvalidTypeException` (TM-361). The downstream
/// consumers in this file only need the row counts; surfacing them as
/// `int` avoids the cliff cleanly.
@Riverpod(keepAlive: true)
Stream<int> taskConflictRowCount(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);
  return db.taskDao
      .watchTasksWithConflicts(personDocId)
      .map((rows) => rows.length);
}

/// Same as [taskConflictRowCountProvider] but for recurrences.
@Riverpod(keepAlive: true)
Stream<int> recurrenceConflictRowCount(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);
  return db.taskRecurrenceDao
      .watchRecurrencesWithConflicts(personDocId)
      .map((rows) => rows.length);
}

/// Stream of task conflicts for the current user — only entries whose
/// `conflictRemoteJson` envelope decodes cleanly. Use
/// [taskConflictRowCountProvider] for the count (which includes rows that
/// fail to decode and would otherwise hide from the UI).
@Riverpod(keepAlive: true)
Stream<List<TaskConflict>> taskConflicts(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.taskDao.watchTasksWithConflicts(personDocId).map((rows) {
    final conflicts = <TaskConflict>[];
    for (final row in rows) {
      final envelope = row.conflictRemoteJson;
      if (envelope == null) continue;
      final decoded = _decodeEnvelope<TaskItem>(
        envelopeJson: envelope,
        docId: row.docId,
        serializer: TaskItem.serializer,
        normalize: _renameTaskFieldsForLegacyEnvelope,
      );
      if (decoded == null) continue;
      try {
        conflicts.add(TaskConflict(
          local: taskItemFromRow(row),
          remote: decoded.remote,
          priorSyncState: decoded.priorSyncState,
        ));
      } catch (e) {
        debugPrint('⚠️ [taskConflictsProvider] row conversion failed: $e');
      }
    }
    return conflicts;
  });
}

/// Stream of recurrence conflicts for the current user. Same caveat as
/// [taskConflictsProvider] re: rows with undecodable envelopes.
@Riverpod(keepAlive: true)
Stream<List<RecurrenceConflict>> recurrenceConflicts(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.taskRecurrenceDao
      .watchRecurrencesWithConflicts(personDocId)
      .map((rows) {
    final conflicts = <RecurrenceConflict>[];
    for (final row in rows) {
      final envelope = row.conflictRemoteJson;
      if (envelope == null) continue;
      final decoded = _decodeEnvelope<TaskRecurrence>(
        envelopeJson: envelope,
        docId: row.docId,
        serializer: TaskRecurrence.serializer,
      );
      if (decoded == null) continue;
      try {
        conflicts.add(RecurrenceConflict(
          local: taskRecurrenceFromRow(row),
          remote: decoded.remote,
          priorSyncState: decoded.priorSyncState,
        ));
      } catch (e) {
        debugPrint('⚠️ [recurrenceConflictsProvider] row conversion failed: $e');
      }
    }
    return conflicts;
  });
}

/// Combined count across task + recurrence conflicts for the banner. Returns
/// 0 unless BOTH underlying streams have emitted at least once.
///
/// **Drives the count from raw DAO row counts**, not from the decoded list
/// length, so a row whose envelope fails to decode still contributes to the
/// count. Otherwise the banner would silently disappear and the user would
/// have no way to clear the stuck row.
/// TM-368: pure-derived from two upstream count streams (both keepAlive).
/// Auto-dispose; rebuild is a trivial sum.
@riverpod
int allConflictsCount(Ref ref) {
  final tasksAsync = ref.watch(taskConflictRowCountProvider);
  final recurrencesAsync = ref.watch(recurrenceConflictRowCountProvider);
  if (!tasksAsync.hasValue || !recurrencesAsync.hasValue) return 0;
  return (tasksAsync.value ?? 0) + (recurrencesAsync.value ?? 0);
}

/// Count of pendingConflict rows whose envelope did NOT decode (so they
/// don't appear in the typed conflicts lists). When non-zero the screen
/// surfaces a "force clear stuck" recovery action.
/// TM-368: pure-derived. Auto-dispose; trivial diff between two counts.
@riverpod
int stuckConflictsCount(Ref ref) {
  final taskRowsAsync = ref.watch(taskConflictRowCountProvider);
  final recurrenceRowsAsync = ref.watch(recurrenceConflictRowCountProvider);
  final taskConflictsAsync = ref.watch(taskConflictsProvider);
  final recurrenceConflictsAsync = ref.watch(recurrenceConflictsProvider);
  if (!taskRowsAsync.hasValue ||
      !recurrenceRowsAsync.hasValue ||
      !taskConflictsAsync.hasValue ||
      !recurrenceConflictsAsync.hasValue) {
    return 0;
  }
  final taskStuck = (taskRowsAsync.value ?? 0) -
      (taskConflictsAsync.value?.length ?? 0);
  final recurrenceStuck = (recurrenceRowsAsync.value ?? 0) -
      (recurrenceConflictsAsync.value?.length ?? 0);
  return (taskStuck < 0 ? 0 : taskStuck) +
      (recurrenceStuck < 0 ? 0 : recurrenceStuck);
}

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which must win the next conflict-detection
/// comparison so the user's intent isn't bounced right back into a conflict).
/// TM-368: fire-and-forget mutation. Auto-dispose. Same for the two
/// resolution notifiers below.
@riverpod
class KeepLocalConflict extends _$KeepLocalConflict {
  @override
  FutureOr<void> build() {}

  Future<void> callTask(TaskConflict conflict) async {
    final db = ref.read(databaseProvider);
    final restoreTo = _parseSyncState(conflict.priorSyncState);
    await db.taskDao.clearConflictAndRestorePending(
      conflict.docId,
      restoreTo,
      now: _resolutionTimestamp(conflict.remote.lastModified),
      // TM-361: anchor lastSyncedRemoteVersion to the envelope's remote so
      // the next push's conflict check doesn't immediately re-fire on the
      // same baseline.
      acknowledgedRemoteVersion: conflict.remote.lastModified,
    );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'KeepLocalConflict.task')
        .ignore();
  }

  Future<void> callRecurrence(RecurrenceConflict conflict) async {
    final db = ref.read(databaseProvider);
    final restoreTo = _parseSyncState(conflict.priorSyncState);
    await db.taskRecurrenceDao.clearConflictAndRestorePending(
      conflict.docId,
      restoreTo,
      now: _resolutionTimestamp(conflict.remote.lastModified),
      acknowledgedRemoteVersion: conflict.remote.lastModified,
    );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'KeepLocalConflict.recurrence')
        .ignore();
  }
}

/// Pick a `lastModified` for "Keep mine" that is guaranteed to beat the
/// remote we conflicted against, even on a device with a slow clock. Falling
/// back to plain `DateTime.now()` could leave the new local timestamp behind
/// the server-stamped remote one and cause the next push to detect the same
/// conflict again — making "Keep mine" effectively impossible to complete
/// (Copilot round 7).
DateTime _resolutionTimestamp(DateTime? remoteLastModified) {
  final now = DateTime.now().toUtc();
  if (remoteLastModified == null) return now;
  final beatsRemote =
      remoteLastModified.toUtc().add(const Duration(milliseconds: 1));
  return now.isAfter(beatsRemote) ? now : beatsRemote;
}

/// Resolution: accept the remote version, overwriting the local pending edit.
@riverpod
class AcceptRemoteConflict extends _$AcceptRemoteConflict {
  @override
  FutureOr<void> build() {}

  Future<void> callTask(TaskConflict conflict) async {
    final db = ref.read(databaseProvider);
    await db.taskDao.clearConflictAndAcceptRemote(
      conflict.docId,
      taskItemToCompanion(conflict.remote),
    );
  }

  Future<void> callRecurrence(RecurrenceConflict conflict) async {
    final db = ref.read(databaseProvider);
    await db.taskRecurrenceDao.clearConflictAndAcceptRemote(
      conflict.docId,
      taskRecurrenceToCompanion(conflict.remote),
    );
  }
}

/// Force-clear pendingConflict rows whose envelope failed to decode (the
/// "stuck" set). Resets them to pendingUpdate with refreshed `lastModified`
/// and triggers a push so the next sync can resolve them.
@riverpod
class ForceClearStuckConflicts extends _$ForceClearStuckConflicts {
  @override
  FutureOr<void> build() {}

  Future<void> call() async {
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    final db = ref.read(databaseProvider);
    await db.taskDao.forceClearStuckConflicts(personDocId);
    await db.taskRecurrenceDao.forceClearStuckConflicts(personDocId);
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ForceClearStuckConflicts')
        .ignore();
  }
}

SyncState _parseSyncState(String name) {
  return SyncState.values.firstWhere(
    (s) => s.name == name,
    // Fallback: if the envelope has an unrecognized priorSyncState (e.g. due
    // to a future enum value), treat it as a pendingUpdate so "Keep mine"
    // still produces a push attempt.
    orElse: () => SyncState.pendingUpdate,
  );
}
