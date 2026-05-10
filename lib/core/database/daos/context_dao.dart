import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'context_dao.g.dart';

@DriftAccessor(tables: [Contexts])
class ContextDao extends DatabaseAccessor<AppDatabase>
    with _$ContextDaoMixin {
  ContextDao(super.db);

  /// Watches non-retired contexts for the given user, sorted by sortOrder.
  /// Pending-delete rows are filtered out (already retired-locally).
  Stream<List<Context>> watchContextsForUser(String personDocId) {
    return (select(contexts)
          ..where((c) =>
              c.personDocId.equals(personDocId) &
              c.retired.isNull() &
              c.syncState.equals(SyncState.pendingDelete.name).not())
          ..orderBy([
            (c) => OrderingTerm(expression: c.sortOrder),
          ]))
        .watch();
  }

  /// Returns non-retired contexts for the given user (one-shot read used by
  /// the service layer when computing `max(sortOrder) + 1` etc.).
  Future<List<Context>> getContextsForUser(String personDocId) {
    return (select(contexts)
          ..where((c) =>
              c.personDocId.equals(personDocId) &
              c.retired.isNull() &
              c.syncState.equals(SyncState.pendingDelete.name).not())
          ..orderBy([
            (c) => OrderingTerm(expression: c.sortOrder),
          ]))
        .get();
  }

  // ── Remote-driven mutations (Sync-side) ────────────────────────────────────

  Future<void> upsertContextFromRemote(ContextsCompanion row) async {
    final current = await (select(contexts)
          ..where((c) => c.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null && current.syncState != SyncState.synced.name) {
      // Pending-local-wins: don't overwrite a row mid-edit.
      return;
    }
    await into(contexts).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> deleteContextFromRemote(String docId) async {
    final current = await (select(contexts)
          ..where((c) => c.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(contexts)..where((c) => c.docId.equals(docId))).go();
  }

  // ── Local-driven mutations (Service-side) ──────────────────────────────────

  Future<void> insertContextPending(ContextsCompanion row) {
    return into(contexts).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> markContextUpdatePending(
      String docId, ContextsCompanion diff) {
    return (update(contexts)..where((c) => c.docId.equals(docId)))
        .write(diff.copyWith(syncState: Value(SyncState.pendingUpdate.name)));
  }

  Future<void> markContextDeletePending(String docId) {
    final now = DateTime.now().toUtc();
    return (update(contexts)..where((c) => c.docId.equals(docId))).write(
      ContextsCompanion(
        retired: Value(docId),
        retiredDate: Value(now),
        syncState: Value(SyncState.pendingDelete.name),
      ),
    );
  }

  Future<void> markContextSynced(String docId) {
    return (update(contexts)..where((c) => c.docId.equals(docId)))
        .write(ContextsCompanion(syncState: Value(SyncState.synced.name)));
  }

  Future<List<Context>> pendingContextWrites() {
    return (select(contexts)
          ..where((c) =>
              c.syncState.equals(SyncState.pendingCreate.name) |
              c.syncState.equals(SyncState.pendingUpdate.name) |
              c.syncState.equals(SyncState.pendingDelete.name)))
        .get();
  }

  /// Delete `synced` contexts for [personDocId] whose docId is NOT in
  /// [remoteIds]. Called after a fresh remote pull so phantom rows are pruned.
  /// Pending rows are preserved. See `AreaDao.deleteSyncedAreasNotInForPerson`
  /// for the rationale around the empty-set branch and the personDocId scope.
  Future<void> deleteSyncedContextsNotInForPerson(
      String personDocId, Set<String> remoteIds) {
    if (remoteIds.isEmpty) {
      return (delete(contexts)
            ..where((c) =>
                c.personDocId.equals(personDocId) &
                c.syncState.equals(SyncState.synced.name)))
          .go();
    }
    return (delete(contexts)
          ..where((c) =>
              c.personDocId.equals(personDocId) &
              c.syncState.equals(SyncState.synced.name) &
              c.docId.isNotIn(remoteIds.toList())))
        .go();
  }
}
