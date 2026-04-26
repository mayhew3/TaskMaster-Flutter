import 'package:drift/drift.dart';

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

  /// Upsert a row coming from Firestore. Skips rows whose current sync_state
  /// is anything other than `synced` (pending-local-wins).
  Future<void> upsertFromRemote(TasksCompanion row) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null &&
        current.syncState != SyncState.synced.name) {
      return;
    }
    await into(tasks).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  /// Bulk upsert rows from a Firestore snapshot. Fetches all pending docIds in
  /// one query (pending-local-wins) then batch-inserts the rest in one shot —
  /// far fewer SQL round-trips than calling [upsertFromRemote] per row.
  Future<void> bulkUpsertFromRemote(List<TasksCompanion> rows) async {
    if (rows.isEmpty) return;

    final pendingIds = await (select(tasks)
          ..where((t) => t.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .map((t) => t.docId)
        .get();
    final pendingSet = pendingIds.toSet();

    final toUpsert = rows
        .where((r) => !pendingSet.contains(r.docId.value))
        .map((r) => r.copyWith(syncState: Value(SyncState.synced.name)))
        .toList();

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

  /// Insert a brand-new locally-created row as pendingCreate.
  Future<void> insertPending(TasksCompanion row) {
    return into(tasks).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Update an existing row, marking it pendingUpdate unless it is already
  /// pendingCreate (in which case it stays pendingCreate).
  Future<void> markUpdatePending(String docId, TasksCompanion diff) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    final nextSyncState =
        current.syncState == SyncState.pendingCreate.name
            ? SyncState.pendingCreate.name
            : SyncState.pendingUpdate.name;
    await (update(tasks)..where((t) => t.docId.equals(docId))).write(
      diff.copyWith(syncState: Value(nextSyncState)),
    );
  }

  /// Mark a row for delete. If it was pendingCreate (never pushed), delete
  /// outright.
  Future<void> markDeletePending(String docId) async {
    final current = await (select(tasks)
          ..where((t) => t.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState == SyncState.pendingCreate.name) {
      await (delete(tasks)..where((t) => t.docId.equals(docId))).go();
      return;
    }
    await (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(syncState: Value(SyncState.pendingDelete.name)),
    );
  }

  /// Mark a row as synced (called after successful push).
  Future<void> markSynced(String docId) {
    return (update(tasks)..where((t) => t.docId.equals(docId))).write(
      TasksCompanion(syncState: Value(SyncState.synced.name)),
    );
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

  /// Stamp [familyDocId] on every active (non-retired, non-pending-delete)
  /// task owned by [personDocId]. Called when a user joins a family so their
  /// existing tasks become visible to the rest of the family. Synced rows are
  /// promoted to pendingUpdate; pendingCreate rows stay pendingCreate; rows
  /// already in [familyDocId] are skipped to avoid pointless writes.
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
