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
  /// same user's list already has [newName] (case-insensitive).
  Future<void> renameArea(Area area, String newName) async {
    // Wait for the server snapshot so the duplicate check below is against
    // the user's true area set, not a stale local cache.
    await ref
        .read(syncServiceProvider)
        .areasInitialPullComplete
        .timeout(const Duration(seconds: 5), onTimeout: () {});

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

@riverpod
AreaService areaService(Ref ref) {
  return AreaService(
    db: ref.watch(databaseProvider),
    firestore: ref.watch(firestoreProvider),
    ref: ref,
  );
}
