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

  /// Stream of a single task by docId (or null if not present).
  Stream<Task?> watchTaskById(String docId) {
    return (select(tasks)..where((t) => t.docId.equals(docId)))
        .watchSingleOrNull();
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
