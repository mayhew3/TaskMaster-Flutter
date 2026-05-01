import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'area_dao.g.dart';

@DriftAccessor(tables: [Areas])
class AreaDao extends DatabaseAccessor<AppDatabase> with _$AreaDaoMixin {
  AreaDao(super.db);

  /// Watches non-retired areas for the given user, sorted by sortOrder.
  /// Pending-delete rows are filtered out (they're already retired-locally).
  Stream<List<Area>> watchAreasForUser(String personDocId) {
    return (select(areas)
          ..where((a) =>
              a.personDocId.equals(personDocId) &
              a.retired.isNull() &
              a.syncState.equals(SyncState.pendingDelete.name).not())
          ..orderBy([
            (a) => OrderingTerm(expression: a.sortOrder),
          ]))
        .watch();
  }

  /// Returns non-retired areas for the given user (for one-shot reads, e.g.
  /// computing `max(sortOrder) + 1` when adding a new area).
  Future<List<Area>> getAreasForUser(String personDocId) {
    return (select(areas)
          ..where((a) =>
              a.personDocId.equals(personDocId) &
              a.retired.isNull() &
              a.syncState.equals(SyncState.pendingDelete.name).not())
          ..orderBy([
            (a) => OrderingTerm(expression: a.sortOrder),
          ]))
        .get();
  }

  // ── Remote-driven mutations (Sync-side) ────────────────────────────────────

  Future<void> upsertAreaFromRemote(AreasCompanion row) async {
    final current = await (select(areas)
          ..where((a) => a.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null && current.syncState != SyncState.synced.name) {
      // Pending-local-wins: don't overwrite a row mid-edit.
      return;
    }
    await into(areas).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> deleteAreaFromRemote(String docId) async {
    final current = await (select(areas)
          ..where((a) => a.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(areas)..where((a) => a.docId.equals(docId))).go();
  }

  // ── Local-driven mutations (Service-side) ──────────────────────────────────

  Future<void> insertAreaPending(AreasCompanion row) {
    return into(areas).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Apply a partial update (e.g., name change or sortOrder rewrite) and mark
  /// the row pending update so SyncService pushes it.
  Future<void> markAreaUpdatePending(String docId, AreasCompanion diff) {
    return (update(areas)..where((a) => a.docId.equals(docId)))
        .write(diff.copyWith(syncState: Value(SyncState.pendingUpdate.name)));
  }

  /// Soft-delete: sets `retired = docId` and marks pending delete.
  Future<void> markAreaDeletePending(String docId) {
    final now = DateTime.now().toUtc();
    return (update(areas)..where((a) => a.docId.equals(docId))).write(
      AreasCompanion(
        retired: Value(docId),
        retiredDate: Value(now),
        syncState: Value(SyncState.pendingDelete.name),
      ),
    );
  }

  Future<void> markAreaSynced(String docId) {
    return (update(areas)..where((a) => a.docId.equals(docId)))
        .write(AreasCompanion(syncState: Value(SyncState.synced.name)));
  }

  Future<List<Area>> pendingAreaWrites() {
    return (select(areas)
          ..where((a) =>
              a.syncState.equals(SyncState.pendingCreate.name) |
              a.syncState.equals(SyncState.pendingUpdate.name) |
              a.syncState.equals(SyncState.pendingDelete.name)))
        .get();
  }

  /// Delete `synced` areas whose docId is NOT in [remoteIds]. Called after a
  /// fresh remote pull so phantom rows are pruned. Pending rows are preserved.
  Future<void> deleteSyncedAreasNotIn(Set<String> remoteIds) {
    return (delete(areas)
          ..where((a) =>
              a.syncState.equals(SyncState.synced.name) &
              a.docId.isNotIn(remoteIds.toList())))
        .go();
  }
}
