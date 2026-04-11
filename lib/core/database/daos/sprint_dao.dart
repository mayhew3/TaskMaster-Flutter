import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'sprint_dao.g.dart';

/// Projection: sprint + its assignments, returned as a single unit.
class SprintWithAssignments {
  const SprintWithAssignments(this.sprint, this.assignments);
  final Sprint sprint;
  final List<SprintAssignment> assignments;
}

@DriftAccessor(tables: [Sprints, SprintAssignments])
class SprintDao extends DatabaseAccessor<AppDatabase>
    with _$SprintDaoMixin {
  SprintDao(super.db);

  /// Watches the N most recent sprints (by sprintNumber desc) for a user,
  /// with their assignments joined in.
  Stream<List<SprintWithAssignments>> watchRecentSprints({
    required String personDocId,
    int limit = 3,
  }) {
    final query = select(sprints)
      ..where((s) =>
          s.personDocId.equals(personDocId) &
          s.retired.isNull() &
          s.syncState.equals(SyncState.pendingDelete.name).not())
      ..orderBy([
        (s) => OrderingTerm(expression: s.sprintNumber, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return <SprintWithAssignments>[];
      final sprintIds = rows.map((s) => s.docId).toList();
      final assignments = await (select(sprintAssignments)
            ..where((a) =>
                a.sprintDocId.isIn(sprintIds) &
                a.retired.isNull() &
                a.syncState.equals(SyncState.pendingDelete.name).not()))
          .get();
      final grouped = <String, List<SprintAssignment>>{};
      for (final a in assignments) {
        (grouped[a.sprintDocId] ??= []).add(a);
      }
      return rows
          .map((s) => SprintWithAssignments(s, grouped[s.docId] ?? const []))
          .toList();
    });
  }

  // ── Sprint upserts ─────────────────────────────────────────────────────────

  Future<void> upsertSprintFromRemote(SprintsCompanion row) async {
    final current = await (select(sprints)
          ..where((s) => s.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null &&
        current.syncState != SyncState.synced.name) {
      return;
    }
    await into(sprints).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> deleteSprintFromRemote(String docId) async {
    final current = await (select(sprints)
          ..where((s) => s.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(sprints)..where((s) => s.docId.equals(docId))).go();
  }

  Future<void> insertSprintPending(SprintsCompanion row) {
    return into(sprints).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> markSprintSynced(String docId) {
    return (update(sprints)..where((s) => s.docId.equals(docId)))
        .write(SprintsCompanion(syncState: Value(SyncState.synced.name)));
  }

  /// Delete all `synced` sprints whose docId is NOT in [remoteIds].
  /// Safe to call because only the top-N sprints are ever synced to Drift,
  /// so any synced sprint absent from the remote snapshot is a phantom.
  Future<void> deleteSyncedSprintsNotIn(Set<String> remoteIds) {
    return (delete(sprints)
          ..where((s) =>
              s.syncState.equals(SyncState.synced.name) &
              s.docId.isNotIn(remoteIds.toList())))
        .go();
  }

  /// Delete synced assignments whose sprint no longer exists in Drift.
  /// Called after purging phantom sprints to remove their orphaned assignments.
  Future<void> deleteSyncedOrphanAssignments() async {
    final allSprints = await (select(sprints)).get();
    final allSprintIds = allSprints.map((s) => s.docId).toList();
    if (allSprintIds.isEmpty) {
      await (delete(sprintAssignments)
            ..where((a) => a.syncState.equals(SyncState.synced.name)))
          .go();
      return;
    }
    await (delete(sprintAssignments)
          ..where((a) =>
              a.syncState.equals(SyncState.synced.name) &
              a.sprintDocId.isNotIn(allSprintIds)))
        .go();
  }

  Future<List<Sprint>> pendingSprintWrites() {
    return (select(sprints)
          ..where((s) =>
              s.syncState.equals(SyncState.pendingCreate.name) |
              s.syncState.equals(SyncState.pendingUpdate.name) |
              s.syncState.equals(SyncState.pendingDelete.name)))
        .get();
  }

  // ── Assignment upserts ─────────────────────────────────────────────────────

  Future<void> upsertAssignmentFromRemote(
      SprintAssignmentsCompanion row) async {
    final current = await (select(sprintAssignments)
          ..where((a) => a.docId.equals(row.docId.value)))
        .getSingleOrNull();
    if (current != null &&
        current.syncState != SyncState.synced.name) {
      return;
    }
    await into(sprintAssignments).insertOnConflictUpdate(
      row.copyWith(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> deleteAssignmentFromRemote(String docId) async {
    final current = await (select(sprintAssignments)
          ..where((a) => a.docId.equals(docId)))
        .getSingleOrNull();
    if (current == null) return;
    if (current.syncState != SyncState.synced.name) return;
    await (delete(sprintAssignments)..where((a) => a.docId.equals(docId))).go();
  }

  Future<void> insertAssignmentPending(SprintAssignmentsCompanion row) {
    return into(sprintAssignments).insert(
      row.copyWith(syncState: Value(SyncState.pendingCreate.name)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> markAssignmentSynced(String docId) {
    return (update(sprintAssignments)..where((a) => a.docId.equals(docId)))
        .write(SprintAssignmentsCompanion(
            syncState: Value(SyncState.synced.name)));
  }

  Future<List<SprintAssignment>> pendingAssignmentWrites() {
    return (select(sprintAssignments)
          ..where((a) =>
              a.syncState.equals(SyncState.pendingCreate.name) |
              a.syncState.equals(SyncState.pendingUpdate.name) |
              a.syncState.equals(SyncState.pendingDelete.name)))
        .get();
  }

  /// Current assignments for a given sprint (synced + pending, excluding delete).
  Future<List<SprintAssignment>> assignmentsForSprint(String sprintDocId) {
    return (select(sprintAssignments)
          ..where((a) =>
              a.sprintDocId.equals(sprintDocId) &
              a.retired.isNull() &
              a.syncState.equals(SyncState.pendingDelete.name).not()))
        .get();
  }
}
