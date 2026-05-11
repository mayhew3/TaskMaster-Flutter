import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import '../app_database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Stream of incomplete, non-retired, non-pending-delete tasks for a user.
  /// Mirrors the current Firestore query used by `tasksProvider`.
  Stream<List<Task>> watchIncompleteTasks(String personDocId) {
    return (select(tasks)
          ..where((t) =>
              t.personDocId.equals(personDocId) &
              t.retired.isNull() &
              t.completionDate.isNull() &
              t.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  /// Stream of non-retired, non-pending-delete tasks for a family (union of
  /// every member's tasks). Includes completed rows so the Family tab's
  /// "Show Completed" toggle can surface them after the user navigates away
  /// and back; the filter provider hides them when the toggle is off.
  Stream<List<Task>> watchFamilyActiveTasks(String familyDocId) {
    return (select(tasks)
          ..where((t) =>
              t.familyDocId.equals(familyDocId) &
              t.retired.isNull() &
              t.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  /// Stream of a single task by docId (or null if not present).
  Stream<Task?> watchTaskById(String docId) {
    return (select(tasks)..where((t) => t.docId.equals(docId)))
        .watchSingleOrNull();
  }

  /// One-shot fetch of a single task by docId.
  Future<Task?> getByDocId(String docId) {
    return (select(tasks)..where((t) => t.docId.equals(docId)))
        .getSingleOrNull();
  }

  /// Stream of tasks (both incomplete and completed) whose docId is in [docIds].
  /// Used by the sprint screen to load all tasks assigned to a sprint —
  /// completed ones must be included so they can render in the "Completed"
  /// section below the sprint's active tasks (TM-339).
  Stream<List<Task>> watchTasksByDocIds(String personDocId, List<String> docIds) {
    if (docIds.isEmpty) return Stream.value(const []);
    return (select(tasks)
          ..where((t) =>
              t.personDocId.equals(personDocId) &
              t.retired.isNull() &
              t.docId.isIn(docIds) &
              t.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  /// All rows for a user (including completed), used by history views.
  Future<List<Task>> allForUser(String personDocId) {
    return (select(tasks)
          ..where((t) => t.personDocId.equals(personDocId))
          ..where((t) => t.syncState.equals(SyncState.pendingDelete.name).not()))
        .get();
  }

  /// Stream of every non-retired, non-pending-delete row for a user
  /// (including completed). Powers the per-area / per-context task-count
  /// badges on the Manage screens (TM-345 / TM-181) — the badges need to
  /// reflect every task that references the catalog name regardless of
  /// completion status, since the count is what informs the user's
  /// "Remove from tasks?" decision when they delete the catalog entry.
  Stream<List<Task>> watchAllNonRetiredForUser(String personDocId) {
    return (select(tasks)
          ..where((t) =>
              t.personDocId.equals(personDocId) &
              t.retired.isNull() &
              t.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  /// Upsert a row coming from Firestore. Skips rows whose current sync_state
  /// is anything other than `synced` — that catches pendingCreate /
  /// pendingUpdate / pendingDelete (pending-local-wins) and pendingConflict
  /// (TM-342: don't overwrite a row the user is actively resolving).
  ///
  /// TM-361: also writes `lastSyncedRemoteVersion = row.lastModified` so the
  /// conflict detector has the server timestamp this row was last observed
  /// at. Without this, an offline edit later compares against its own
  /// local-clock `lastModified` and can't tell that the remote moved.
  Future<void> upsertFromRemote(TasksCompanion row) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null &&
        current.syncState != SyncState.synced.name) {
      return;
    }
    await into(tasks).insertOnConflictUpdate(
      row.copyWith(
        syncState: Value(SyncState.synced.name),
        lastSyncedRemoteVersion: row.lastModified,
      ),
    );
  }

  /// Bulk upsert rows from a Firestore snapshot. Fetches all pending docIds in
  /// one query (pending-local-wins) then batch-inserts the rest in one shot —
  /// far fewer SQL round-trips than calling [upsertFromRemote] per row.
  /// pendingConflict rows are also skipped (TM-342).
  Future<void> bulkUpsertFromRemote(List<TasksCompanion> rows) async {
    if (rows.isEmpty) return;

    final pendingIds = await (select(tasks)
          ..where((t) => t.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
                SyncState.pendingConflict.name,
              ])))
        .map((t) => t.docId)
        .get();
    final pendingSet = pendingIds.toSet();

    // TM-361: sync the lastSyncedRemoteVersion column at the same time —
    // see upsertFromRemote for rationale.
    final toUpsert = rows
        .where((r) => !pendingSet.contains(r.docId.value))
        .map((r) => r.copyWith(
              syncState: Value(SyncState.synced.name),
              lastSyncedRemoteVersion: r.lastModified,
            ))
        .toList();

    if (kDebugMode) {
      final skipped = rows
          .where((r) => pendingSet.contains(r.docId.value))
          .map((r) => r.docId.value)
          .toList();
      if (skipped.isNotEmpty) {
        debugPrint(
            '[TaskDao.bulkUpsertFromRemote] skipped ${skipped.length} pending rows: $skipped');
      }
      for (final r in toUpsert) {
        debugPrint(
            '[TaskDao.bulkUpsertFromRemote] anchoring ${r.docId.value}: lastSyncedRemoteVersion=${r.lastModified}');
      }
    }
    if (toUpsert.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(tasks, toUpsert));
  }

  /// Delete a row that no longer exists in Firestore. Skips if local row is
  /// pending.
  Future<void> deleteFromRemote(String docId) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(tasks)..where((t) => t.docId.equals(docId))).go();
  }

  /// Insert a brand-new locally-created row as pendingCreate. Stamps
  /// `lastModified` with [now] (or the current UTC time) for TM-342 conflict
  /// detection.
  Future<void> insertPending(TasksCompanion row, {DateTime? now}) {
    return into(tasks).insert(
      row.copyWith(
        syncState: Value(SyncState.pendingCreate.name),
        lastModified: Value(now ?? DateTime.now().toUtc()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Update an existing row, marking it pendingUpdate unless it is already
  /// pendingCreate (in which case it stays pendingCreate). Stamps
  /// `lastModified` with [now] (or the current UTC time) for TM-342 conflict
  /// detection.
  ///
  /// TM-361: the stamp is clamped to `max(now, current.lastModified + 1ms)`
  /// so it never goes backwards from the previously-synced server timestamp.
  /// Without the clamp, a device with a local clock that runs behind the
  /// server clock (common on Android emulators and phones whose time hasn't
  /// re-synced after sleep) would write `lastModified < remote.lastModified`,
  /// and the push-time conflict check would false-positive against this same
  /// device's own prior push — surfacing as "conflict between my change and
  /// the baseline" and refusing to clear through Use Mine.
  Future<void> markUpdatePending(String docId, TasksCompanion diff,
      {DateTime? now}) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    final nextSyncState =
        current.syncState == SyncState.pendingCreate.name
            ? SyncState.pendingCreate.name
            : SyncState.pendingUpdate.name;
    final stamp = _monotonicStamp(current.lastModified, now);
    if (kDebugMode) {
      debugPrint(
          '[TaskDao.markUpdatePending] $docId: prior state=${current.syncState} lastModified=${current.lastModified} lastSynced=${current.lastSyncedRemoteVersion} → stamp=$stamp');
    }
    await (update(tasks)..where((t) => t.docId.equals(docId))).write(
      diff.copyWith(
        syncState: Value(nextSyncState),
        lastModified: Value(stamp),
      ),
    );
  }

  /// Mark a row for delete. If it was pendingCreate (never pushed), delete
  /// outright. Stamps `lastModified` for TM-342 conflict detection so the
  /// push-time comparison can decide local-delete vs newer-remote-update.
  /// TM-361: monotonic stamp; see [markUpdatePending] for rationale.
  Future<void> markDeletePending(String docId, {DateTime? now}) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState == SyncState.pendingCreate.name) {
      await (delete(tasks)..where((t) => t.docId.equals(docId))).go();
      return;
    }
    final stamp = _monotonicStamp(current.lastModified, now);
    await (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(
        syncState: Value(SyncState.pendingDelete.name),
        lastModified: Value(stamp),
      ),
    );
  }

  /// Returns a `lastModified` value that is strictly greater than [previous]
  /// while still preferring the wall-clock "now" when the wall clock is
  /// already ahead. Ensures the local row's timestamp marches forward
  /// monotonically across edits, so a slow local clock can't conflict with a
  /// server timestamp this device itself just stamped (TM-361).
  static DateTime _monotonicStamp(DateTime? previous, DateTime? now) {
    final wall = now ?? DateTime.now().toUtc();
    if (previous == null) return wall;
    final priorUtc = previous.isUtc ? previous : previous.toUtc();
    final beatsPrior = priorUtc.add(const Duration(milliseconds: 1));
    return wall.isAfter(beatsPrior) ? wall : beatsPrior;
  }

  /// Mark a row as synced (called after successful push).
  Future<void> markSynced(String docId) {
    return (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(syncState: Value(SyncState.synced.name)),
    );
  }

  /// TM-361: mark synced and anchor `lastSyncedRemoteVersion` to the
  /// server-stamped timestamp we read back after the push. Without this
  /// anchor, a rapid edit-then-push in the window before the snapshot
  /// listener delivers the server-confirmed update would compare a stale
  /// `lastSyncedRemoteVersion` against the freshly-stamped remote and
  /// false-positive a conflict.
  Future<void> markSyncedWithVersion(
      String docId, DateTime? serverVersion) {
    if (kDebugMode) {
      debugPrint(
          '[TaskDao.markSyncedWithVersion] $docId: serverVersion=$serverVersion ${serverVersion == null ? "(no anchor update — will rely on listener)" : "(anchoring lastSynced & lastModified)"}');
    }
    return (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(
        syncState: Value(SyncState.synced.name),
        lastModified: serverVersion == null
            ? const Value.absent()
            : Value(serverVersion),
        lastSyncedRemoteVersion: serverVersion == null
            ? const Value.absent()
            : Value(serverVersion),
      ),
    );
  }

  /// TM-342: record a sync conflict. Sets syncState to pendingConflict and
  /// stashes the remote envelope JSON for later resolution. The local row's
  /// data fields are intentionally left intact so the conflict UI can render
  /// the user's pending edit alongside the remote version.
  Future<void> markPendingConflict(String docId, String remoteEnvelopeJson) {
    return (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(
        syncState: Value(SyncState.pendingConflict.name),
        conflictRemoteJson: Value(remoteEnvelopeJson),
      ),
    );
  }

  /// TM-342: resolve a conflict by accepting the remote version. Replaces the
  /// local row with [remoteRow], clears the conflict envelope, and marks the
  /// row synced. TM-361: also anchors `lastSyncedRemoteVersion` to the
  /// remote's `lastModified` so we don't re-conflict on the next push.
  Future<void> clearConflictAndAcceptRemote(
      String docId, TasksCompanion remoteRow) async {
    await into(tasks).insertOnConflictUpdate(
      remoteRow.copyWith(
        syncState: Value(SyncState.synced.name),
        conflictRemoteJson: const Value(null),
        lastSyncedRemoteVersion: remoteRow.lastModified,
      ),
    );
  }

  /// TM-342: resolve a conflict by keeping the local pending edit. Restores
  /// the row to [restoreTo] (pendingUpdate or pendingDelete) and refreshes
  /// `lastModified` so the next push wins against the remote that beat us.
  /// Clears the conflict envelope.
  ///
  /// TM-361: also bumps `lastSyncedRemoteVersion` to [acknowledgedRemoteVersion]
  /// (the timestamp from the conflict envelope's remote). The user has now
  /// explicitly said "I saw that remote version and I'm overriding it"; if we
  /// left `lastSyncedRemoteVersion` at the old value, the very next push's
  /// conflict check would compare against the same stale baseline and
  /// re-detect the same conflict in a loop.
  Future<void> clearConflictAndRestorePending(
      String docId, SyncState restoreTo,
      {DateTime? now, DateTime? acknowledgedRemoteVersion}) {
    return (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(
        syncState: Value(restoreTo.name),
        conflictRemoteJson: const Value(null),
        lastModified: Value(now ?? DateTime.now().toUtc()),
        lastSyncedRemoteVersion: acknowledgedRemoteVersion == null
            ? const Value.absent()
            : Value(acknowledgedRemoteVersion),
      ),
    );
  }

  /// TM-342: stream of rows currently in conflict for [personDocId].
  Stream<List<Task>> watchTasksWithConflicts(String personDocId) {
    return (select(tasks)
          ..where((t) =>
              t.personDocId.equals(personDocId) &
              t.syncState.equals(SyncState.pendingConflict.name)))
        .watch();
  }

  /// TM-342: force-resolve every pendingConflict row for [personDocId] by
  /// keeping the local edit. Used as a recovery when a row's
  /// `conflictRemoteJson` envelope can't be decoded (schema drift, corrupt
  /// data) — without this, those rows would be permanently stuck with no
  /// way to exit pendingConflict via the normal Keep mine / Use latest UI.
  /// Refreshes `lastModified` so the next push wins; the row's prior
  /// pending state is unknowable here so we conservatively restore to
  /// pendingUpdate (a stuck pendingDelete becomes a normal update — the
  /// user can re-issue the delete from the UI if that was their intent).
  Future<void> forceClearStuckConflicts(String personDocId,
      {DateTime? now}) {
    return (update(tasks)
          ..where((t) =>
              t.personDocId.equals(personDocId) &
              t.syncState.equals(SyncState.pendingConflict.name)))
        .write(TasksCompanion(
      syncState: Value(SyncState.pendingUpdate.name),
      conflictRemoteJson: const Value(null),
      lastModified: Value(now ?? DateTime.now().toUtc()),
    ));
  }

  /// Remove a row outright (used to finalize a pending-delete after Firestore
  /// confirms the delete).
  Future<void> hardDelete(String docId) {
    return (delete(tasks)..where((t) => t.docId.equals(docId))).go();
  }

  /// Delete all `synced` rows whose docId is NOT in [remoteIds].
  /// Used during the initial snapshot to purge stale local rows that no longer
  /// exist in Firestore (e.g. after an emulator reset or server-side bulk delete).
  /// Pending rows are intentionally left untouched.
  Future<void> deleteSyncedNotIn(Set<String> remoteIds) {
    return (delete(tasks)
          ..where((t) =>
              t.syncState.equals(SyncState.synced.name) &
              t.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  /// Delete all `synced`, incomplete (completionDate IS NULL) rows for
  /// [personDocId] whose docId is NOT in [remoteIds]. Scoped to [personDocId]
  /// so a sign-out/sign-in cycle with a different account never touches the
  /// new user's rows. The Firestore tasks listener only listens to incomplete
  /// tasks, so only incomplete rows should be reconciled here. Completed rows
  /// must NOT be deleted — they are not part of the listener query and would
  /// be incorrectly purged otherwise (TM-341).
  Future<void> deleteSyncedIncompleteNotIn(
      String personDocId, Set<String> remoteIds) {
    // When remoteIds is empty every synced incomplete row for this user is
    // stale — delete them all without an IN-list predicate to avoid SQL
    // edge-cases with `NOT IN ()`.
    if (remoteIds.isEmpty) {
      return (delete(tasks)
            ..where((t) =>
                t.personDocId.equals(personDocId) &
                t.syncState.equals(SyncState.synced.name) &
                t.completionDate.isNull()))
          .go();
    }
    return (delete(tasks)
          ..where((t) =>
              t.personDocId.equals(personDocId) &
              t.syncState.equals(SyncState.synced.name) &
              t.completionDate.isNull() &
              t.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  /// Delete all `synced`, non-retired rows for [familyDocId] whose docId is
  /// NOT in [remoteIds]. Used by the family-tasks listener (TM-335) on
  /// initial snapshot reconciliation. Scoped to [familyDocId] so leaving and
  /// rejoining a different family doesn't purge stale rows that belong to
  /// the old family. Includes both completed and incomplete rows because the
  /// listener pulls both (so "Show Completed" survives tab navigation).
  Future<void> deleteSyncedFamilyTasksNotIn(
      String familyDocId, Set<String> remoteIds) {
    if (remoteIds.isEmpty) {
      return (delete(tasks)
            ..where((t) =>
                t.familyDocId.equals(familyDocId) &
                t.syncState.equals(SyncState.synced.name) &
                t.retired.isNull()))
          .go();
    }
    return (delete(tasks)
          ..where((t) =>
              t.familyDocId.equals(familyDocId) &
              t.syncState.equals(SyncState.synced.name) &
              t.retired.isNull() &
              t.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  /// Cascade recurrence field changes to all tasks in the same chain whose
  /// recurIteration is greater than [afterIteration]. Used by UpdateTask when
  /// editing task N so that upcoming tasks N+1, N+2, ... stay in sync with the
  /// updated shared TaskRecurrence (TM-243). Skips pendingDelete rows;
  /// preserves pendingCreate state; transitions synced/pendingUpdate rows to
  /// pendingUpdate so they get pushed to Firestore on the next sync.
  /// Scoped to [personDocId] to prevent cross-user updates after sign-out/sign-in.
  /// No-ops if [diff] contains no frequency fields (recurWait/recurNumber/recurUnit).
  Future<void> cascadeRecurrenceFieldsToUpcoming({
    required String personDocId,
    required String recurrenceDocId,
    required int afterIteration,
    required TasksCompanion diff,
  }) async {
    final hasFrequencyFields = diff.recurWait.present ||
        diff.recurNumber.present ||
        diff.recurUnit.present;
    if (!hasFrequencyFields) return;

    // Two set-based UPDATEs instead of a per-row loop to avoid N+1 SQL:
    // one to preserve pendingCreate state, one to promote the rest to pendingUpdate.
    upcomingFilter(Tasks t) =>
        t.personDocId.equals(personDocId) &
        t.recurrenceDocId.equals(recurrenceDocId) &
        t.recurIteration.isBiggerThan(Variable<int>(afterIteration)) &
        t.syncState.equals(SyncState.pendingDelete.name).not();

    await (update(tasks)
          ..where((t) =>
              upcomingFilter(t) &
              t.syncState.equals(SyncState.pendingCreate.name)))
        .write(diff.copyWith(syncState: Value(SyncState.pendingCreate.name)));

    await (update(tasks)
          ..where((t) =>
              upcomingFilter(t) &
              t.syncState.equals(SyncState.pendingCreate.name).not()))
        .write(diff.copyWith(syncState: Value(SyncState.pendingUpdate.name)));
  }

  /// Update [familyDocId] on every active (non-retired, non-pending-delete)
  /// task owned by [personDocId]. Currently only used for self-leave cleanup
  /// (called with `null` to clear the user's own family-shared tasks back to
  /// personal). MVP intentionally does NOT backfill on join — tasks created
  /// before joining stay personal; only AddTask stamps `familyDocId` on
  /// newly-added tasks while in a family. Synced rows are promoted to
  /// pendingUpdate; pendingCreate rows stay pendingCreate; rows already at
  /// the target value are skipped to avoid pointless writes.
  Future<void> setFamilyDocIdForAllTasksOfPerson(
      String personDocId, String? familyDocId) async {
    backfillFilter(Tasks t) =>
        t.personDocId.equals(personDocId) &
        t.retired.isNull() &
        t.syncState.equals(SyncState.pendingDelete.name).not() &
        (familyDocId == null
            ? t.familyDocId.isNotNull()
            : t.familyDocId.equals(familyDocId).not() | t.familyDocId.isNull());

    final diff = TasksCompanion(familyDocId: Value(familyDocId));

    // Preserve pendingCreate rows' state; promote synced/pendingUpdate to
    // pendingUpdate so they get pushed to Firestore on the next sync.
    await (update(tasks)
          ..where((t) =>
              backfillFilter(t) &
              t.syncState.equals(SyncState.pendingCreate.name)))
        .write(diff.copyWith(syncState: Value(SyncState.pendingCreate.name)));

    await (update(tasks)
          ..where((t) =>
              backfillFilter(t) &
              t.syncState.equals(SyncState.pendingCreate.name).not()))
        .write(diff.copyWith(syncState: Value(SyncState.pendingUpdate.name)));
  }

  /// Count of locally-tracked skipped tasks for a user (used to adjust Firestore completed count).
  /// Only counts rows that are already synced (so Firestore's aggregation reflects them) and
  /// have a completionDate set (mirroring the Firestore `completionDate != null` filter).
  Future<int> skippedTaskCount(String personDocId) async {
    final countExpr = tasks.docId.count();
    final query = selectOnly(tasks)
      ..addColumns([countExpr])
      ..where(tasks.personDocId.equals(personDocId) &
          tasks.skipped.equals(true) &
          tasks.retired.isNull() &
          tasks.completionDate.isNotNull() &
          tasks.syncState.equals(SyncState.synced.name));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Rows that need to be pushed to Firestore.
  Future<List<Task>> pendingWrites() {
    return (select(tasks)
          ..where((t) =>
              t.syncState.equals(SyncState.pendingCreate.name) |
              t.syncState.equals(SyncState.pendingUpdate.name) |
              t.syncState.equals(SyncState.pendingDelete.name)))
        .get();
  }
}
