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

  Future<void> upsertFromRemote(TaskRecurrencesCompanion row) async {
    final current = await (select(taskRecurrences)
          ..where((r) => r.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null &&
        current.syncState != SyncState.synced.name) {
      return;
    }
    await into(taskRecurrences).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> deleteFromRemote(String docId) async {
    final current = await (select(taskRecurrences)
          ..where((r) => r.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(taskRecurrences)..where((r) => r.docId.equals(docId))).go();
  }

  Future<void> insertPending(TaskRecurrencesCompanion row) {
    return into(taskRecurrences).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> markUpdatePending(
      String docId, TaskRecurrencesCompanion diff) async {
    final current = await (select(taskRecurrences)
          ..where((r) => r.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    final nextSyncState =
        current.syncState == SyncState.pendingCreate.name
            ? SyncState.pendingCreate.name
            : SyncState.pendingUpdate.name;
    await (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(diff.copyWith(syncState: Value(nextSyncState)));
  }

  Future<void> markSynced(String docId) {
    return (update(taskRecurrences)..where((r) => r.docId.equals(docId)))
        .write(TaskRecurrencesCompanion(
            syncState: Value(SyncState.synced.name)));
  }

  Future<void> hardDelete(String docId) {
    return (delete(taskRecurrences)..where((r) => r.docId.equals(docId))).go();
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
