import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/context.dart';
import '../services/context_service.dart';

part 'context_providers.g.dart';

/// Default contexts seeded the first time a user opens the manage / picker
/// screen with zero existing contexts (TM-181). The list is the same eight
/// hard-coded names the pre-181 picker shipped with, plus an [iconName]
/// keyed into the closed `ContextIcon` set so new users see icons out of the
/// box.
const List<({String name, String iconName})> defaultContextSeeds = [
  (name: 'Computer', iconName: 'computer'),
  (name: 'Home', iconName: 'home'),
  (name: 'Office', iconName: 'office'),
  (name: 'E-Mail', iconName: 'email'),
  (name: 'Phone', iconName: 'phone'),
  (name: 'Outside', iconName: 'outside'),
  (name: 'Reading', iconName: 'reading'),
  (name: 'Planning', iconName: 'planning'),
];

/// Per-context task counts for the current user. Keyed by lowercased
/// context name; the value is the number of non-retired tasks (active +
/// completed) tagged with that context. Used by the Manage Contexts screen
/// to render count badges (TM-181). See `areaTaskCountsProvider` for the
/// rationale behind including completed tasks.
@riverpod
Stream<Map<String, int>> contextTaskCounts(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);
  if (personDocId == null) return Stream.value(const {});
  return db.taskDao.watchAllNonRetiredForUser(personDocId).map((rows) {
    final counts = <String, int>{};
    for (final row in rows) {
      final taskContexts = parseTaskContexts(row.taskContexts);
      for (final tc in taskContexts) {
        final key = tc.name.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  });
}

/// Stream of the current user's contexts, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.
@Riverpod(keepAlive: true)
Stream<List<Context>> contexts(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value(const []);

  return db.contextDao.watchContextsForUser(personDocId).map(
        (rows) => rows.map(contextFromRow).toList(),
      );
}

/// Lazily seeds [defaultContextSeeds] on first read when the user has zero
/// contexts AND the first server snapshot has confirmed they really do have
/// zero. Mirrors `AreasWithDefaults` (TM-345) — see that provider for the
/// detailed rationale around the two race conditions (initial-pull gate and
/// per-personDocId tracking).
@Riverpod(keepAlive: true)
class ContextsWithDefaults extends _$ContextsWithDefaults {
  final Set<String> _seededForPersonDocIds = {};

  @override
  AsyncValue<List<Context>> build() {
    final personDocId = ref.watch(personDocIdProvider);
    final asyncContexts = ref.watch(contextsProvider);

    if (personDocId != null &&
        !_seededForPersonDocIds.contains(personDocId)) {
      asyncContexts.whenData((contexts) {
        if (contexts.isEmpty) {
          _maybeSeedAfterInitialPull(personDocId);
        }
      });
    }

    return asyncContexts;
  }

  Future<void> _maybeSeedAfterInitialPull(String personDocId) async {
    if (_seededForPersonDocIds.contains(personDocId)) return;
    _seededForPersonDocIds.add(personDocId);

    await ref
        .read(syncServiceProvider)
        .contextsInitialPullComplete
        .timeout(const Duration(seconds: 30), onTimeout: () {});

    if (ref.read(personDocIdProvider) != personDocId) {
      _seededForPersonDocIds.remove(personDocId);
      return;
    }
    final current = ref.read(contextsProvider).valueOrNull ?? const <Context>[];
    if (current.isNotEmpty) return;

    final service = ref.read(contextServiceProvider);
    for (final seed in defaultContextSeeds) {
      try {
        await service.createContext(
          name: seed.name,
          iconName: seed.iconName,
          personDocId: personDocId,
          skipInitialPullWait: true,
        );
      } on DuplicateContextNameException {
        // Race: a default name was already created (e.g. by the user manually
        // or via cross-device sync mid-wait). Skip and keep seeding the rest.
      }
    }
  }
}
