import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
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

/// Lazily seeds [defaultAreaNames] on first read if the user has zero areas.
/// Returns the same data as [areasProvider] but with the side effect of
/// kicking off seeding in the background. Idempotent: only seeds once per
/// session (the in-memory `_seedAttempted` flag is reset only by hot restart).
///
/// Use this from the picker / management screen entry points, not from
/// background queries — those should use [areasProvider] directly to avoid
/// triggering a seed on a transient empty state during initial pull.
@Riverpod(keepAlive: true)
class AreasWithDefaults extends _$AreasWithDefaults {
  bool _seedAttempted = false;

  @override
  AsyncValue<List<Area>> build() {
    final asyncAreas = ref.watch(areasProvider);
    asyncAreas.whenData((areas) {
      if (areas.isEmpty && !_seedAttempted) {
        _seedAttempted = true;
        _seedDefaults();
      }
    });
    return asyncAreas;
  }

  Future<void> _seedDefaults() async {
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    final service = ref.read(areaServiceProvider);
    for (final name in defaultAreaNames) {
      await service.createArea(name: name, personDocId: personDocId);
    }
  }
}
