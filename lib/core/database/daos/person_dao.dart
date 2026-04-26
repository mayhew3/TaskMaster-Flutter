import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'person_dao.g.dart';

@DriftAccessor(tables: [Persons])
class PersonDao extends DatabaseAccessor<AppDatabase> with _$PersonDaoMixin {
  PersonDao(super.db);

  Stream<Person?> watchByDocId(String docId) {
    return (select(persons)
          ..where((p) =>
              p.docId.equals(docId) &
              p.retired.isNull() &
              p.syncState.equals(SyncState.pendingDelete.name).not()))
        .watchSingleOrNull();
  }

  Future<Person?> getByDocId(String docId) {
    return (select(persons)..where((p) => p.docId.equals(docId)))
        .getSingleOrNull();
  }

  /// Stream of persons in [familyDocId] (used to render member list).
  Stream<List<Person>> watchByFamily(String familyDocId) {
    return (select(persons)
          ..where((p) =>
              p.familyDocId.equals(familyDocId) &
              p.retired.isNull() &
              p.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  Future<void> upsertFromRemote(PersonsCompanion row) async {
    final current = await (select(persons)
          ..where((p) => p.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null && current.syncState != SyncState.synced.name) {
      return;
    }
    await into(persons).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> bulkUpsertFromRemote(List<PersonsCompanion> rows) async {
    if (rows.isEmpty) return;

    final pendingIds = await (select(persons)
          ..where((p) => p.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .map((p) => p.docId)
        .get();
    final pendingSet = pendingIds.toSet();

    final toUpsert = rows
        .where((r) => !pendingSet.contains(r.docId.value))
        .map((r) => r.copyWith(syncState: Value(SyncState.synced.name)))
        .toList();

    if (toUpsert.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(persons, toUpsert));
  }

  Future<void> deleteFromRemote(String docId) async {
    final current = await (select(persons)..where((p) => p.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(persons)..where((p) => p.docId.equals(docId))).go();
  }

  Future<void> markUpdatePending(String docId, PersonsCompanion diff) async {
    final current =
        await (select(persons)..where((p) => p.docId.equals(docId)))
            .getSingleOrNull();
    if (current == null) return;
    final nextSyncState = current.syncState == SyncState.pendingCreate.name
        ? SyncState.pendingCreate.name
        : SyncState.pendingUpdate.name;
    await (update(persons)..where((p) => p.docId.equals(docId)))
        .write(diff.copyWith(syncState: Value(nextSyncState)));
  }

  Future<void> markSynced(String docId) {
    return (update(persons)..where((p) => p.docId.equals(docId))).write(
        PersonsCompanion(syncState: Value(SyncState.synced.name)));
  }

  Future<void> hardDelete(String docId) {
    return (delete(persons)..where((p) => p.docId.equals(docId))).go();
  }

  /// Delete all `synced` person rows whose docId is NOT in [remoteIds].
  /// The Persons listener fans out to "my own + my family members", so any
  /// docId that drops out of the snapshot is no longer accessible to me.
  Future<void> deleteSyncedNotIn(Set<String> remoteIds) {
    return (delete(persons)
          ..where((p) =>
              p.syncState.equals(SyncState.synced.name) &
              p.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  Future<List<Person>> pendingWrites() {
    return (select(persons)
          ..where((p) => p.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .get();
  }
}
