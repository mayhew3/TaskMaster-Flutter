import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'family_invitation_dao.g.dart';

@DriftAccessor(tables: [FamilyInvitations])
class FamilyInvitationDao extends DatabaseAccessor<AppDatabase>
    with _$FamilyInvitationDaoMixin {
  FamilyInvitationDao(super.db);

  /// Pending invitations addressed to [email], newest first. Used by the
  /// recipient's UI; [PendingInvitationBanner] takes the head of the list as
  /// "the most recent invite", so the ordering is contractual.
  Stream<List<FamilyInvitation>> watchPendingForEmail(String email) {
    return (select(familyInvitations)
          ..where((i) =>
              i.inviteeEmail.equals(email) &
              i.status.equals('pending') &
              i.syncState.equals(SyncState.pendingDelete.name).not())
          ..orderBy([(i) => OrderingTerm.desc(i.dateAdded)]))
        .watch();
  }

  /// Invitations sent by [personDocId]. Used by the inviter's manage screen
  /// to show "outstanding invites".
  Stream<List<FamilyInvitation>> watchSentByPerson(String personDocId) {
    return (select(familyInvitations)
          ..where((i) =>
              i.inviterPersonDocId.equals(personDocId) &
              i.syncState.equals(SyncState.pendingDelete.name).not()))
        .watch();
  }

  Future<void> upsertFromRemote(FamilyInvitationsCompanion row) async {
    final current = await (select(familyInvitations)
          ..where((i) => i.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null && current.syncState != SyncState.synced.name) {
      return;
    }
    await into(familyInvitations).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> bulkUpsertFromRemote(
      List<FamilyInvitationsCompanion> rows) async {
    if (rows.isEmpty) return;

    final pendingIds = await (select(familyInvitations)
          ..where((i) => i.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .map((i) => i.docId)
        .get();
    final pendingSet = pendingIds.toSet();

    final toUpsert = rows
        .where((r) => !pendingSet.contains(r.docId.value))
        .map((r) => r.copyWith(syncState: Value(SyncState.synced.name)))
        .toList();

    if (toUpsert.isEmpty) return;
    await batch(
        (b) => b.insertAllOnConflictUpdate(familyInvitations, toUpsert));
  }

  Future<void> deleteFromRemote(String docId) async {
    final current = await (select(familyInvitations)
          ..where((i) => i.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(familyInvitations)..where((i) => i.docId.equals(docId))).go();
  }

  Future<void> insertPending(FamilyInvitationsCompanion row) {
    return into(familyInvitations).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> markUpdatePending(
      String docId, FamilyInvitationsCompanion diff) async {
    final current = await (select(familyInvitations)
          ..where((i) => i.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    final nextSyncState = current.syncState == SyncState.pendingCreate.name
        ? SyncState.pendingCreate.name
        : SyncState.pendingUpdate.name;
    await (update(familyInvitations)..where((i) => i.docId.equals(docId)))
        .write(diff.copyWith(syncState: Value(nextSyncState)));
  }

  Future<void> markSynced(String docId) {
    return (update(familyInvitations)..where((i) => i.docId.equals(docId)))
        .write(FamilyInvitationsCompanion(
            syncState: Value(SyncState.synced.name)));
  }

  Future<void> hardDelete(String docId) {
    return (delete(familyInvitations)..where((i) => i.docId.equals(docId)))
        .go();
  }

  /// Delete all `synced` invitation rows for [inviteeEmail] whose docId is
  /// NOT in [remoteIds]. Scoped to the email so a sign-out/sign-in cycle with
  /// a different account never touches the new user's rows.
  Future<void> deleteSyncedNotInForEmail(
      String inviteeEmail, Set<String> remoteIds) {
    if (remoteIds.isEmpty) {
      return (delete(familyInvitations)
            ..where((i) =>
                i.inviteeEmail.equals(inviteeEmail) &
                i.syncState.equals(SyncState.synced.name)))
          .go();
    }
    return (delete(familyInvitations)
          ..where((i) =>
              i.inviteeEmail.equals(inviteeEmail) &
              i.syncState.equals(SyncState.synced.name) &
              i.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  Future<List<FamilyInvitation>> pendingWrites() {
    return (select(familyInvitations)
          ..where((i) => i.syncState.isIn([
                SyncState.pendingCreate.name,
                SyncState.pendingUpdate.name,
                SyncState.pendingDelete.name,
              ])))
        .get();
  }
}
