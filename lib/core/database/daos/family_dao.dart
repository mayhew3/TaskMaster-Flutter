import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'family_dao.g.dart';

@DriftAccessor(tables: [Families])
class FamilyDao extends DatabaseAccessor<AppDatabase> with _$FamilyDaoMixin {
  FamilyDao(super.db);

  /// Active family doc by ID (single row stream). Excludes pending-delete.
  Stream<Family?> watchByDocId(String docId) {
    return (select(families)
          ..where((f) =>
              f.docId.equals(docId) &
              f.retired.isNull() &
              f.syncState.equals(SyncState.pendingDelete.name).not()))
        .watchSingleOrNull();
  }

  /// Family doc by ID (one-shot).
  Future<Family?> getByDocId(String docId) {
    return (select(families)..where((f) => f.docId.equals(docId)))
        .getSingleOrNull();
  }

  Future<void> upsertFromRemote(FamiliesCompanion row) async {
    final current = await (select(families)
          ..where((f) => f.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null && current.syncState != SyncState.synced.name) {
      return;
    }
    await into(families).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> bulkUpsertFromRemote(List<FamiliesCompanion> rows) async {
    if (rows.isEmpty) return;

    final pendingIds = await (select(families)
          ..where((f) => f.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .map((f) => f.docId)
        .get();
    final pendingSet = pendingIds.toSet();

    final toUpsert = rows
        .where((r) => !pendingSet.contains(r.docId.value))
        .map((r) => r.copyWith(syncState: Value(SyncState.synced.name)))
        .toList();

    if (toUpsert.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(families, toUpsert));
  }

  Future<void> deleteFromRemote(String docId) async {
    final current = await (select(families)..where((f) => f.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(families)..where((f) => f.docId.equals(docId))).go();
  }

  Future<void> insertPending(FamiliesCompanion row) {
    return into(families).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> markUpdatePending(String docId, FamiliesCompanion diff) async {
    final current =
        await (select(families)..where((f) => f.docId.equals(docId)))
            .getSingleOrNull();
    if (current == null) return;
    final nextSyncState = current.syncState == SyncState.pendingCreate.name
        ? SyncState.pendingCreate.name
        : SyncState.pendingUpdate.name;
    await (update(families)..where((f) => f.docId.equals(docId)))
        .write(diff.copyWith(syncState: Value(nextSyncState)));
  }

  Future<void> markSynced(String docId) {
    return (update(families)..where((f) => f.docId.equals(docId))).write(
        FamiliesCompanion(syncState: Value(SyncState.synced.name)));
  }

  Future<void> hardDelete(String docId) {
    return (delete(families)..where((f) => f.docId.equals(docId))).go();
  }

  /// Delete all `synced` family rows whose docId is NOT in [remoteIds].
  /// Used during the initial snapshot to purge stale rows. The remote listener
  /// is already scoped (`members array-contains me`), so any missing doc means
  /// the user has been removed from that family.
  Future<void> deleteSyncedNotIn(Set<String> remoteIds) {
    return (delete(families)
          ..where((f) =>
              f.syncState.equals(SyncState.synced.name) &
              f.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  Future<List<Family>> pendingWrites() {
    return (select(families)
          ..where((f) => f.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .get();
  }
}
