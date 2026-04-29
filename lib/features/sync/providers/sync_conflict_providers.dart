import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart' as drift;
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

/// Decodes a conflict envelope JSON written by SyncService into the local +
/// remote pair plus the priorSyncState. Returns null on malformed envelopes
/// (logged) so a corrupt row doesn't crash the UI.
({TModel remote, String priorSyncState})? _decodeEnvelope<TModel>({
  required String envelopeJson,
  required String docId,
  required Serializer<TModel> serializer,
}) {
  try {
    final envelope = jsonDecode(envelopeJson) as Map<String, dynamic>;
    final priorSyncState = envelope['priorSyncState'] as String? ?? 'pendingUpdate';
    final remoteJson = Map<String, dynamic>.from(envelope['remote'] as Map);
    remoteJson['docId'] = docId;
    final remote = serializers.deserializeWith(serializer, remoteJson);
    if (remote == null) return null;
    return (remote: remote, priorSyncState: priorSyncState);
  } catch (e, s) {
    debugPrint('⚠️ [_decodeEnvelope] failed for $docId: $e\n$s');
    return null;
  }
}

/// Raw stream of Drift rows currently in `pendingConflict` for the user.
/// Powers the banner count (so a row with an undecodable envelope still
/// contributes to the count and doesn't silently disappear from the UI).
@riverpod
Stream<List<drift.Task>> taskConflictRows(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.taskDao.watchTasksWithConflicts(personDocId);
}

/// Same as [taskConflictRowsProvider] but for recurrences.
@riverpod
Stream<List<drift.TaskRecurrence>> recurrenceConflictRows(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return Stream.value(const []);
  final db = ref.watch(databaseProvider);
  return db.taskRecurrenceDao.watchRecurrencesWithConflicts(personDocId);
}

/// Stream of task conflicts for the current user — only entries whose
/// `conflictRemoteJson` envelope decodes cleanly. Use [taskConflictRowsProvider]
/// for the count (which includes rows that fail to decode and would otherwise
/// hide from the UI).
@riverpod
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
@riverpod
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
@riverpod
int allConflictsCount(Ref ref) {
  final tasksAsync = ref.watch(taskConflictRowsProvider);
  final recurrencesAsync = ref.watch(recurrenceConflictRowsProvider);
  if (!tasksAsync.hasValue || !recurrencesAsync.hasValue) return 0;
  final tasks = tasksAsync.value ?? const <drift.Task>[];
  final recurrences =
      recurrencesAsync.value ?? const <drift.TaskRecurrence>[];
  return tasks.length + recurrences.length;
}

/// Count of pendingConflict rows whose envelope did NOT decode (so they
/// don't appear in the typed conflicts lists). When non-zero the screen
/// surfaces a "force clear stuck" recovery action.
@riverpod
int stuckConflictsCount(Ref ref) {
  final taskRowsAsync = ref.watch(taskConflictRowsProvider);
  final recurrenceRowsAsync = ref.watch(recurrenceConflictRowsProvider);
  final taskConflictsAsync = ref.watch(taskConflictsProvider);
  final recurrenceConflictsAsync = ref.watch(recurrenceConflictsProvider);
  if (!taskRowsAsync.hasValue ||
      !recurrenceRowsAsync.hasValue ||
      !taskConflictsAsync.hasValue ||
      !recurrenceConflictsAsync.hasValue) {
    return 0;
  }
  final taskStuck = (taskRowsAsync.value?.length ?? 0) -
      (taskConflictsAsync.value?.length ?? 0);
  final recurrenceStuck = (recurrenceRowsAsync.value?.length ?? 0) -
      (recurrenceConflictsAsync.value?.length ?? 0);
  return (taskStuck < 0 ? 0 : taskStuck) +
      (recurrenceStuck < 0 ? 0 : recurrenceStuck);
}

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which must win the next conflict-detection
/// comparison so the user's intent isn't bounced right back into a conflict).
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
