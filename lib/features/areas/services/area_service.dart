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
  Future<Area> createArea({
    required String name,
    required String personDocId,
  }) async {
    // Wait for the first server snapshot of `areas` before deriving the next
    // sortOrder. Areas are NOT part of the blocking initialPullCompleter, so
    // without this guard, a fresh install creating an area before the first
    // areas snapshot arrives could compute sortOrder=0 (or another value) that
    // collides with a remote row syncing in moments later. Falls back to
    // proceeding with local data after a short timeout so offline sessions
    // aren't blocked indefinitely.
    await ref
        .read(syncServiceProvider)
        .areasInitialPullComplete
        .timeout(const Duration(seconds: 5), onTimeout: () {});

    final now = DateTime.now().toUtc();
    final docId = firestore.collection('areas').doc().id;

    final existing = await db.areaDao.getAreasForUser(personDocId);
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
  Future<void> renameArea(Area area, String newName) async {
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
  Future<void> reorderAreas(List<Area> orderedAreas) async {
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
