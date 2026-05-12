import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'task_recurrence_dao.g.dart';

@DriftAccessor(tables: [TaskRecurrences])
class TaskRecurrenceDao extends DatabaseAccessor<AppDatabase>
    with _$TaskRecurrenceDaoMixin {
  TaskRecurrenceDao(super.db);

  Stream<List<TaskRecurrence>> watchActive(String personDocId) {
    return (select(taskRecurrences)
          ..where((r) =>
              r.personDocId.equals(personDocId) &
              r.retired.isNull() &
              r.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  /// TM-361: also writes `lastSyncedRemoteVersion`. See TaskDao.upsertFromRemote.
  Future<void> upsertFromRemote(TaskRecurrencesCompanion row) async {
    final current = await (select(taskRecurrences)
          ..where((r) => r.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null &&
        current.syncState != SyncState.synced.name) {
      return;
    }
    await into(taskRecurrences).insertOnConflictUpdate(
      row.copyWith(
        syncState: Value(SyncState.synced.name),
        lastSyncedRemoteVersion: row.lastModified,
      ),
    );
  }

  /// Bulk upsert rows from a Firestore snapshot. See [TaskDao.bulkUpsertFromRemote].
  /// pendingConflict rows are also skipped (TM-342). TM-361: syncs
  /// `lastSyncedRemoteVersion` from each row's `lastModified`.
  ///
  /// TM-367: pending rows whose `lastSyncedRemoteVersion` is currently null
  /// (legacy / never-anchored) get a one-time back-fill from the listener's
  /// `lastModified` so the next push's conflict-check has a server-anchored
  /// reference. Pending rows whose anchor is already set are NOT touched
  /// here — see `TaskDao.bulkUpsertFromRemote` for the full rationale.
  Future<void> bulkUpsertFromRemote(List<TaskRecurrencesCompanion> rows) async {
    if (rows.isEmpty) return;

    // `selectOnly` reads only the two columns we actually use (mirrors
    // the same optimization in `TaskDao.bulkUpsertFromRemote`). Avoids
    // pulling every column — including potentially large
    // `conflictRemoteJson` blobs on pendingConflict rows — for a query
    // that only builds docId sets.
    final pendingQuery = selectOnly(taskRecurrences)
      ..addColumns(
          [taskRecurrences.docId, taskRecurrences.lastSyncedRemoteVersion])
      ..where(taskRecurrences.syncState.isIn([
        SyncState.pendingCreate.name,
        SyncState.pendingUpdate.name,
        SyncState.pendingDelete.name,
        SyncState.pendingConflict.name,
      ]));
    final pendingProjection = await pendingQuery.get();
    final pendingSet = <String>{};
    final pendingNeverAnchored = <String>{};
    for (final row in pendingProjection) {
      final docId = row.read(taskRecurrences.docId)!;
      pendingSet.add(docId);
      if (row.read(taskRecurrences.lastSyncedRemoteVersion) == null) {
        pendingNeverAnchored.add(docId);
      }
    }

    final toUpsert = rows
        .where((r) => !pendingSet.contains(r.docId.value))
        .map((r) => r.copyWith(
              syncState: Value(SyncState.synced.name),
              lastSyncedRemoteVersion: r.lastModified,
            ))
        .toList();

    // TM-367: one-time anchor back-fill for never-anchored pending rows.
    final toAnchor = rows
        .where((r) => pendingNeverAnchored.contains(r.docId.value))
        .where((r) => r.lastModified.present && r.lastModified.value != null)
        .toList();

    if (toUpsert.isNotEmpty) {
      await batch((b) => b.insertAllOnConflictUpdate(taskRecurrences, toUpsert));
    }
    // TM-367 + Copilot review: WHERE-clause guards `lastSyncedRemoteVersion
    // IS NULL` so a concurrent writer that anchored the row between the
    // pending-row snapshot above and this update can't be overwritten.
    if (toAnchor.isNotEmpty) {
      await transaction(() async {
        for (final r in toAnchor) {
          await (update(taskRecurrences)
                ..where((t) =>
                    t.docId.equals(r.docId.value) &
                    t.lastSyncedRemoteVersion.isNull()))
              .write(TaskRecurrencesCompanion(
                  lastSyncedRemoteVersion: r.lastModified));
        }
      });
    }
  }

  Future<void> deleteFromRemote(String docId) async {
    final current = await (select(taskRecurrences)
          ..where((r) => r.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(taskRecurrences)..where((r) => r.docId.equals(docId))).go();
  }

  Future<void> insertPending(TaskRecurrencesCompanion row, {DateTime? now}) {
    return into(taskRecurrences).insert(
      row.copyWith(
        syncState: Value(SyncState.pendingCreate.name),
        lastModified: Value(now ?? DateTime.now().toUtc()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// TM-361: stamp is `max(now, current.lastModified + 1ms)` so local clock
  /// skew can't produce a `lastModified` value behind the previously-synced
  /// server timestamp. See `TaskDao._monotonicStamp`.
  Future<void> markUpdatePending(
      String docId, TaskRecurrencesCompanion diff,
      {DateTime? now}) async {
    final current = await (select(taskRecurrences)
          ..where((r) => r.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    final nextSyncState =
        current.syncState == SyncState.pendingCreate.name
            ? SyncState.pendingCreate.name
            : SyncState.pendingUpdate.name;
    final stamp = _monotonicStamp(current.lastModified, now);
    await (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(diff.copyWith(
      syncState: Value(nextSyncState),
      lastModified: Value(stamp),
    ));
  }

  static DateTime _monotonicStamp(DateTime? previous, DateTime? now) {
    final wall = now ?? DateTime.now().toUtc();
    if (previous == null) return wall;
    final priorUtc = previous.isUtc ? previous : previous.toUtc();
    final beatsPrior = priorUtc.add(const Duration(milliseconds: 1));
    return wall.isAfter(beatsPrior) ? wall : beatsPrior;
  }

  Future<void> markSynced(String docId) {
    return (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(TaskRecurrencesCompanion(
            syncState: Value(SyncState.synced.name)));
  }

  /// TM-361: mark synced + anchor `lastSyncedRemoteVersion`. See
  /// `TaskDao.markSyncedWithVersion`.
  Future<void> markSyncedWithVersion(
      String docId, DateTime? serverVersion) {
    return (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(TaskRecurrencesCompanion(
      syncState: Value(SyncState.synced.name),
      lastModified: serverVersion == null
          ? const Value.absent()
          : Value(serverVersion),
      lastSyncedRemoteVersion: serverVersion == null
          ? const Value.absent()
          : Value(serverVersion),
    ));
  }

  /// TM-342: record a sync conflict on a recurrence. See
  /// [TaskDao.markPendingConflict].
  Future<void> markPendingConflict(String docId, String remoteEnvelopeJson) {
    return (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(TaskRecurrencesCompanion(
      syncState: Value(SyncState.pendingConflict.name),
      conflictRemoteJson: Value(remoteEnvelopeJson),
    ));
  }

  /// TM-342: resolve a conflict by accepting the remote version. TM-361:
  /// also anchors `lastSyncedRemoteVersion`. See TaskDao counterpart.
  Future<void> clearConflictAndAcceptRemote(
      String docId, TaskRecurrencesCompanion remoteRow) async {
    await into(taskRecurrences).insertOnConflictUpdate(
      remoteRow.copyWith(
        syncState: Value(SyncState.synced.name),
        conflictRemoteJson: const Value(null),
        lastSyncedRemoteVersion: remoteRow.lastModified,
      ),
    );
  }

  /// TM-342: resolve a conflict by keeping the local pending edit. TM-361:
  /// optionally bumps `lastSyncedRemoteVersion` so the next push doesn't
  /// re-detect the same conflict. See TaskDao counterpart.
  Future<void> clearConflictAndRestorePending(
      String docId, SyncState restoreTo,
      {DateTime? now, DateTime? acknowledgedRemoteVersion}) {
    return (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(TaskRecurrencesCompanion(
      syncState: Value(restoreTo.name),
      conflictRemoteJson: const Value(null),
      lastModified: Value(now ?? DateTime.now().toUtc()),
      lastSyncedRemoteVersion: acknowledgedRemoteVersion == null
          ? const Value.absent()
          : Value(acknowledgedRemoteVersion),
    ));
  }

  /// TM-342: stream of recurrences currently in conflict for [personDocId].
  Stream<List<TaskRecurrence>> watchRecurrencesWithConflicts(String personDocId) {
    return (select(taskRecurrences)
          ..where((r) =>
              r.personDocId.equals(personDocId) &
              r.syncState.equals(SyncState.pendingConflict.name)))
        .watch();
  }

  /// TM-342: see [TaskDao.forceClearStuckConflicts].
  Future<void> forceClearStuckConflicts(String personDocId,
      {DateTime? now}) {
    return (update(taskRecurrences)
          ..where((r) =>
              r.personDocId.equals(personDocId) &
              r.syncState.equals(SyncState.pendingConflict.name)))
        .write(TaskRecurrencesCompanion(
      syncState: Value(SyncState.pendingUpdate.name),
      conflictRemoteJson: const Value(null),
      lastModified: Value(now ?? DateTime.now().toUtc()),
    ));
  }

  Future<void> hardDelete(String docId) {
    return (delete(taskRecurrences)..where((r) => r.docId.equals(docId))).go();
  }

  /// Delete all `synced` rows whose docId is NOT in [remoteIds].
  /// See [TaskDao.deleteSyncedNotIn] for rationale.
  Future<void> deleteSyncedNotIn(Set<String> remoteIds) {
    return (delete(taskRecurrences)
          ..where((r) =>
              r.syncState.equals(SyncState.synced.name) &
              r.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  /// Delete all `synced` rows for [personDocId] whose docId is NOT in
  /// [remoteIds]. Scoped to [personDocId] so a sign-out/sign-in cycle with a
  /// different account never touches the new user's rows. Mirrors
  /// [TaskDao.deleteSyncedIncompleteNotIn].
  Future<void> deleteSyncedNotInForPerson(
      String personDocId, Set<String> remoteIds) {
    if (remoteIds.isEmpty) {
      return (delete(taskRecurrences)
            ..where((r) =>
                r.personDocId.equals(personDocId) &
                r.syncState.equals(SyncState.synced.name)))
          .go();
    }
    return (delete(taskRecurrences)
          ..where((r) =>
              r.personDocId.equals(personDocId) &
              r.syncState.equals(SyncState.synced.name) &
              r.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  Future<List<TaskRecurrence>> pendingWrites() {
    return (select(taskRecurrences)
          ..where((r) =>
              r.syncState.equals(SyncState.pendingCreate.name) |
              r.syncState.equals(SyncState.pendingUpdate.name) |
              r.syncState.equals(SyncState.pendingDelete.name)))
        .get();
  }
}
