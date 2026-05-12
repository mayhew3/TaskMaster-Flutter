import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Hide Drift's generated `Area` data class so the domain model wins.
import '../../../core/database/app_database.dart' hide Area;
import '../../../core/database/converters.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/area.dart';
import '../../../models/area_blueprint.dart';

part 'area_service.g.dart';

/// Names the picker UI uses as sentinels in the dropdown. Creating or
/// renaming an area to one of these breaks the picker's contract:
///   - `(none)` would re-persist as `null` when selected later
///   - `+ Add new area…` would reopen the inline-add dialog instead of
///     selecting the area
/// The service rejects these names up front via [ReservedAreaNameException].
const String kNoneSentinelName = '(none)';
const String kAddNewSentinelName = '+ Add new area…';
const Set<String> kReservedAreaNames = {
  kNoneSentinelName,
  kAddNewSentinelName,
};

/// Thrown by [AreaService.createArea] / [AreaService.renameArea] when the
/// requested name (case-insensitive) collides with another non-retired area
/// the same user already has. UI dialogs validate against the in-memory list
/// up front, but the service re-checks just before the write so a stale UI
/// or programmatic caller still can't create duplicates within a single
/// device. Cross-device simultaneous creation can still produce two docs
/// briefly; the user can resolve from the management screen.
class DuplicateAreaNameException implements Exception {
  DuplicateAreaNameException(this.name);
  final String name;
  @override
  String toString() => 'Area "$name" already exists.';
}

/// Thrown by [AreaService.createArea] / [AreaService.renameArea] when the
/// requested name matches a picker sentinel (see [kReservedAreaNames]).
class ReservedAreaNameException implements Exception {
  ReservedAreaNameException(this.name);
  final String name;
  @override
  String toString() => 'Area name "$name" is reserved.';
}

/// Service for creating, updating, deleting, and reordering areas (TM-345).
///
/// Mirrors the offline-first pattern used by SprintService: writes go to Drift
/// first with pending sync state, then SyncService pushes them to Firestore.
class AreaService {
  AreaService({required this.db, required this.firestore, required this.ref});

  final AppDatabase db;
  final dynamic firestore; // FirebaseFirestore
  final Ref ref;

  /// Create a new area. Computes the next sortOrder as `max(existing) + 1`
  /// so new areas land at the bottom of the user's list.
  ///
  /// [skipInitialPullWait] is for batch callers (like the default-seeding
  /// loop) that have already awaited [SyncService.areasInitialPullComplete]
  /// once at the call site. Without this, an offline batch of N creates
  /// would hit the 30s timeout N times in a row. Defaults to false; safe
  /// to omit for normal user-driven creates.
  Future<Area> createArea({
    required String name,
    required String personDocId,
    bool skipInitialPullWait = false,
  }) async {
    // Wait for the first server snapshot of `areas` before deriving the next
    // sortOrder. Areas are NOT part of the blocking initialPullCompleter, so
    // without this guard, a fresh install creating an area before the first
    // areas snapshot arrives could compute sortOrder=0 (or another value) that
    // collides with a remote row syncing in moments later.
    //
    // 30s timeout (was 5s): bounds offline waits but tolerates slow networks.
    // A 5s ceiling treated slow-but-online the same as offline, which let an
    // existing user with un-synced areas slip past the gate and create a
    // duplicate-sortOrder row. 30s covers realistic mobile-network round
    // trips; truly offline users still get unblocked but pay a one-time wait.
    if (!skipInitialPullWait) {
      await ref
          .read(syncServiceProvider)
          .areasInitialPullComplete
          .timeout(const Duration(seconds: 30), onTimeout: () {});
    }

    // Reject reserved sentinel names — the picker can't represent them.
    if (kReservedAreaNames.contains(name)) {
      throw ReservedAreaNameException(name);
    }

    final now = DateTime.now().toUtc();
    final docId = firestore.collection('areas').doc().id;

    final existing = await db.areaDao.getAreasForUser(personDocId);

    // Service-level duplicate-name check (case-insensitive). Belt-and-
    // suspenders against a stale UI list — by this point the await above has
    // ensured the local cache reflects the server's view of this user.
    final lower = name.toLowerCase();
    if (existing.any((a) => a.name.toLowerCase() == lower)) {
      throw DuplicateAreaNameException(name);
    }

    final nextSortOrder = existing.isEmpty
        ? 0
        : existing.map((a) => a.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final blueprint = AreaBlueprint(
      name: name,
      sortOrder: nextSortOrder,
      personDocId: personDocId,
    );

    await db.areaDao.insertAreaPending(areaBlueprintToCompanion(
      docId: docId,
      dateAdded: now,
      blueprint: blueprint,
    ));

    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'AreaService.createArea')
        .ignore();

    return Area((b) => b
      ..docId = docId
      ..dateAdded = now
      ..name = name
      ..sortOrder = nextSortOrder
      ..personDocId = personDocId);
  }

  /// Rename an existing area. Tasks tagged with the old name keep the old
  /// string value (no cascade) — see DESIGN doc for rationale.
  ///
  /// Throws [DuplicateAreaNameException] if another non-retired area in the
  /// same user's list already has [newName] (case-insensitive), or
  /// [ReservedAreaNameException] if [newName] matches a picker sentinel.
  Future<void> renameArea(Area area, String newName) async {
    // Reject reserved sentinel names — the picker can't represent them.
    if (kReservedAreaNames.contains(newName)) {
      throw ReservedAreaNameException(newName);
    }

    // Wait for the server snapshot so the duplicate check below is against
    // the user's true area set, not a stale local cache. 30s tolerates slow
    // mobile networks; same rationale as createArea.
    await ref
        .read(syncServiceProvider)
        .areasInitialPullComplete
        .timeout(const Duration(seconds: 30), onTimeout: () {});

    final existing = await db.areaDao.getAreasForUser(area.personDocId);
    final lower = newName.toLowerCase();
    if (existing.any((a) =>
        a.docId != area.docId && a.name.toLowerCase() == lower)) {
      throw DuplicateAreaNameException(newName);
    }

    await db.areaDao.markAreaUpdatePending(
      area.docId,
      AreasCompanion(name: Value(newName)),
    );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'AreaService.renameArea')
        .ignore();
  }

  /// Soft-delete an area. Tasks tagged with this area keep their string value;
  /// the value just no longer appears in the picker.
  Future<void> deleteArea(Area area) async {
    await db.areaDao.markAreaDeletePending(area.docId);
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'AreaService.deleteArea')
        .ignore();
  }

  /// Count how many of [personDocId]'s tasks are tagged with [areaName].
  ///
  /// Comparison is case-insensitive on the area name to match the picker's
  /// duplicate-rejection rule. Family-shared tasks owned by other users are
  /// out of scope — area names live in the per-user catalog, so the
  /// "Remove from tasks?" prompt only cleans up the caller's own rows.
  Future<int> countTasksUsingArea({
    required String areaName,
    required String personDocId,
  }) async {
    final lower = areaName.toLowerCase();
    final rows = await db.taskDao.allForUser(personDocId);
    var count = 0;
    for (final row in rows) {
      if (row.retired != null) continue;
      if (row.area?.toLowerCase() == lower) count++;
    }
    return count;
  }

  /// Replace every occurrence of [oldName] with [newName] in the `area`
  /// column of tasks owned by [personDocId]. Each affected task is marked
  /// pendingUpdate so SyncService pushes the change to Firestore on the
  /// next push.
  ///
  /// Returns the number of tasks updated.
  Future<int> renameAreaOnAllTasks({
    required String oldName,
    required String newName,
    required String personDocId,
  }) async {
    final lower = oldName.toLowerCase();
    final rows = await db.taskDao.allForUser(personDocId);
    // Run all per-task writes inside a single Drift transaction so a
    // mid-iteration crash leaves no half-state (e.g. some tasks renamed,
    // others still on the old value). SyncService is fine either way —
    // it pushes whatever the next push call sees — but the local view
    // stays consistent.
    var updated = 0;
    await db.transaction(() async {
      for (final row in rows) {
        if (row.retired != null) continue;
        if (row.area?.toLowerCase() != lower) continue;
        await db.taskDao.markUpdatePending(
          row.docId,
          TasksCompanion(area: Value(newName)),
        );
        updated++;
      }
    });
    if (updated > 0) {
      ref
          .read(syncServiceProvider)
          .pushPendingWrites(caller: 'AreaService.renameAreaOnAllTasks')
          .ignore();
    }
    return updated;
  }

  /// Clear [areaName] (set the column to null) on every task owned by
  /// [personDocId] that currently carries it. Each affected task is marked
  /// pendingUpdate so SyncService pushes the change to Firestore on the
  /// next push.
  ///
  /// Returns the number of tasks updated. Idempotent — tasks not tagged
  /// with [areaName] are skipped.
  Future<int> removeAreaFromAllTasks({
    required String areaName,
    required String personDocId,
  }) async {
    final lower = areaName.toLowerCase();
    final rows = await db.taskDao.allForUser(personDocId);
    // Transaction-wrapped — see [renameAreaOnAllTasks] for rationale.
    var updated = 0;
    await db.transaction(() async {
      for (final row in rows) {
        if (row.retired != null) continue;
        if (row.area?.toLowerCase() != lower) continue;
        await db.taskDao.markUpdatePending(
          row.docId,
          const TasksCompanion(area: Value(null)),
        );
        updated++;
      }
    });
    if (updated > 0) {
      ref
          .read(syncServiceProvider)
          .pushPendingWrites(caller: 'AreaService.removeAreaFromAllTasks')
          .ignore();
    }
    return updated;
  }

  /// Persist a new ordering. sortOrder is rewritten as 0..N-1 in a single
  /// transaction so a partial failure can't leave the list half-ordered.
  ///
  /// Waits for [SyncService.areasInitialPullComplete] before rewriting so a
  /// stale local cache (snapshot not yet pulled) doesn't assign 0..N-1 over
  /// an incomplete subset, which would let later remote rows arrive with
  /// duplicate sortOrders and unstable ordering.
  Future<void> reorderAreas(List<Area> orderedAreas) async {
    await ref
        .read(syncServiceProvider)
        .areasInitialPullComplete
        .timeout(const Duration(seconds: 30), onTimeout: () {});

    await db.transaction(() async {
      for (var i = 0; i < orderedAreas.length; i++) {
        final area = orderedAreas[i];
        if (area.sortOrder == i) continue; // No-op if unchanged.
        await db.areaDao.markAreaUpdatePending(
          area.docId,
          AreasCompanion(sortOrder: Value(i)),
        );
      }
    });
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'AreaService.reorderAreas')
        .ignore();
  }
}

// TM-361: see ContextService for the Riverpod 4 keepAlive rationale.
@Riverpod(keepAlive: true)
AreaService areaService(Ref ref) {
  return AreaService(
    db: ref.watch(databaseProvider),
    firestore: ref.watch(firestoreProvider),
    ref: ref,
  );
}
