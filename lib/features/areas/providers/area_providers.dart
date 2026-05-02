import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/area.dart';
import '../services/area_service.dart';

part 'area_providers.g.dart';

/// Default areas seeded the first time a user opens the area picker / manage
/// screen with zero existing areas (TM-345).
const List<String> defaultAreaNames = [
  'Home',
  'Work',
  'Finances',
  'Family',
  'Health',
];

/// Stream of the current user's areas, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.
@Riverpod(keepAlive: true)
Stream<List<Area>> areas(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value(const []);

  return db.areaDao.watchAreasForUser(personDocId).map(
    (rows) => rows.map(areaFromRow).toList(),
  );
}

/// Lazily seeds [defaultAreaNames] on first read when the user has zero areas
/// AND the first server snapshot has confirmed they really do have zero.
/// Returns the same data as [areasProvider] but with the side effect of
/// kicking off seeding in the background.
///
/// Two race conditions to avoid:
///   1. Existing user opens the picker before their server-side areas have
///      synced down → local list is empty → without an initial-pull gate, we
///      would seed defaults that then duplicate/conflict with their real
///      areas a few hundred milliseconds later. Fix: await
///      [SyncService.areasInitialPullComplete] before deciding to seed.
///   2. Sign-out → sign-in as a different brand-new user during the same app
///      session. Without per-user state, the "already attempted" flag stays
///      true and the new user gets no defaults. Fix: track a Set of
///      personDocIds we have seeded for, not a single bool.
///
/// Use this from the picker / management screen entry points, not from
/// background queries.
@Riverpod(keepAlive: true)
class AreasWithDefaults extends _$AreasWithDefaults {
  final Set<String> _seededForPersonDocIds = {};

  @override
  AsyncValue<List<Area>> build() {
    final personDocId = ref.watch(personDocIdProvider);
    final asyncAreas = ref.watch(areasProvider);

    if (personDocId != null &&
        !_seededForPersonDocIds.contains(personDocId)) {
      asyncAreas.whenData((areas) {
        if (areas.isEmpty) {
          // Fire-and-forget: actual seeding waits for the server snapshot
          // first, then re-checks emptiness before writing.
          _maybeSeedAfterInitialPull(personDocId);
        }
      });
    }

    return asyncAreas;
  }

  Future<void> _maybeSeedAfterInitialPull(String personDocId) async {
    // Don't double-fire if a previous build already kicked this off for the
    // same user.
    if (_seededForPersonDocIds.contains(personDocId)) return;
    _seededForPersonDocIds.add(personDocId);

    // Wait for the first server snapshot of `areas` so we know an empty list
    // really means empty (not just "not synced yet"). Time out so offline
    // sessions still get defaults eventually.
    //
    // 30s timeout (was 5s): a slow-but-online existing user could have their
    // real areas still in flight when 5s elapsed, causing the seed to
    // overlay defaults onto a populated server list. 30s tolerates realistic
    // mobile networks; truly offline users still get defaults eventually
    // but pay a one-time wait when first opening the picker / manage screen.
    await ref
        .read(syncServiceProvider)
        .areasInitialPullComplete
        .timeout(const Duration(seconds: 30), onTimeout: () {});

    // Bail if anything changed while we were waiting.
    if (ref.read(personDocIdProvider) != personDocId) {
      // User switched accounts mid-wait. Don't seed for them; the rebuild
      // for the new user will re-trigger this path if needed.
      _seededForPersonDocIds.remove(personDocId);
      return;
    }
    final current = ref.read(areasProvider).valueOrNull ?? const <Area>[];
    if (current.isNotEmpty) return; // Server confirmed they have areas.

    final service = ref.read(areaServiceProvider);
    for (final name in defaultAreaNames) {
      try {
        // Pass skipInitialPullWait: true — we've already awaited the gate
        // above. Without this, an offline batch hits the 5s timeout 5 times
        // in a row (~25s before all defaults appear).
        await service.createArea(
          name: name,
          personDocId: personDocId,
          skipInitialPullWait: true,
        );
      } on DuplicateAreaNameException {
        // A default name might have been created during the wait — by the
        // user manually, or via cross-device sync. Skip it and continue
        // seeding the rest. Without this catch the whole pass aborts and
        // _seededForPersonDocIds blocks any retry in this session.
      }
    }
  }
}
