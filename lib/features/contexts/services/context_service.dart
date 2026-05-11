import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Hide Drift's generated `Context` data class so the domain model wins.
import '../../../core/database/app_database.dart' as db_models;
import '../../../core/database/converters.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/context.dart';
import '../../../models/context_blueprint.dart';

part 'context_service.g.dart';

/// Reserved context names rejected at create/rename time.
///
/// These strings would confuse users if they appeared as real catalog
/// entries:
///   - `(none)` reads like a "clear selection" affordance
///   - `+ Add new context…` reads like an inline-add prompt (the picker
///     does have an inline-add affordance, just not a row labelled this
///     way)
///
/// The current `ContextPicker` and `ContextManageScreen` don't render
/// either string as a selectable row — these aren't picker-UI sentinels
/// in the literal sense — but blocking the names at the service layer
/// keeps the catalog readable and matches the AreaService rejection set
/// (TM-345) so the two catalogs stay symmetric. Validation runs both
/// inline (via `InlineAddField.validator`) and in `createContext` /
/// `renameContext` to catch programmatic callers.
const String kNoneContextSentinelName = '(none)';
const String kAddNewContextSentinelName = '+ Add new context…';
const Set<String> kReservedContextNames = {
  kNoneContextSentinelName,
  kAddNewContextSentinelName,
};

/// Thrown when [ContextService.createContext] / [ContextService.renameContext]
/// would produce a case-insensitive duplicate. UI dialogs validate up front,
/// but the service re-checks just before the write so a stale UI or
/// programmatic caller can't slip in a duplicate within a single device.
class DuplicateContextNameException implements Exception {
  DuplicateContextNameException(this.name);
  final String name;
  @override
  String toString() => 'Context "$name" already exists.';
}

/// Thrown when the requested name matches a picker sentinel (see
/// [kReservedContextNames]).
class ReservedContextNameException implements Exception {
  ReservedContextNameException(this.name);
  final String name;
  @override
  String toString() => 'Context name "$name" is reserved.';
}

/// Service for creating, updating, deleting, and reordering contexts (TM-181).
///
/// Mirrors [AreaService]'s offline-first pattern: writes go to Drift first
/// with pending sync state, then SyncService pushes them to Firestore.
class ContextService {
  ContextService({required this.db, required this.firestore, required this.ref});

  final db_models.AppDatabase db;
  final dynamic firestore; // FirebaseFirestore
  final Ref ref;

  /// Create a new context. See [AreaService.createArea] for the full rationale
  /// behind the `contextsInitialPullComplete` gate and the
  /// [skipInitialPullWait] escape hatch (used by the default-seeding loop).
  Future<Context> createContext({
    required String name,
    required String personDocId,
    String? iconName,
    String? color,
    bool skipInitialPullWait = false,
  }) async {
    if (!skipInitialPullWait) {
      await ref
          .read(syncServiceProvider)
          .contextsInitialPullComplete
          .timeout(const Duration(seconds: 30), onTimeout: () {});
    }

    if (kReservedContextNames.contains(name)) {
      throw ReservedContextNameException(name);
    }

    final now = DateTime.now().toUtc();
    final docId = firestore.collection('contexts').doc().id;

    final existing = await db.contextDao.getContextsForUser(personDocId);

    final lower = name.toLowerCase();
    if (existing.any((c) => c.name.toLowerCase() == lower)) {
      throw DuplicateContextNameException(name);
    }

    final nextSortOrder = existing.isEmpty
        ? 0
        : existing.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final blueprint = ContextBlueprint(
      name: name,
      sortOrder: nextSortOrder,
      personDocId: personDocId,
      iconName: iconName,
      color: color,
    );

    await db.contextDao.insertContextPending(contextBlueprintToCompanion(
      docId: docId,
      dateAdded: now,
      blueprint: blueprint,
    ));

    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ContextService.createContext')
        .ignore();

    return Context((b) => b
      ..docId = docId
      ..dateAdded = now
      ..name = name
      ..sortOrder = nextSortOrder
      ..iconName = iconName
      ..color = color
      ..personDocId = personDocId);
  }

  /// Rename an existing context. Tasks tagged with the old name keep that
  /// string value (no cascade) — same loose-coupling design as Areas.
  Future<void> renameContext(Context context, String newName) async {
    if (kReservedContextNames.contains(newName)) {
      throw ReservedContextNameException(newName);
    }

    await ref
        .read(syncServiceProvider)
        .contextsInitialPullComplete
        .timeout(const Duration(seconds: 30), onTimeout: () {});

    final existing =
        await db.contextDao.getContextsForUser(context.personDocId);
    final lower = newName.toLowerCase();
    if (existing.any((c) =>
        c.docId != context.docId && c.name.toLowerCase() == lower)) {
      throw DuplicateContextNameException(newName);
    }

    await db.contextDao.markContextUpdatePending(
      context.docId,
      db_models.ContextsCompanion(name: Value(newName)),
    );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ContextService.renameContext')
        .ignore();
  }

  /// Soft-delete a context. Tasks tagged with this context keep their string
  /// value; it just stops appearing in the picker.
  Future<void> deleteContext(Context context) async {
    await db.contextDao.markContextDeletePending(context.docId);
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ContextService.deleteContext')
        .ignore();
  }

  /// Persist a new ordering. sortOrder is rewritten as 0..N-1 in a single
  /// transaction so a partial failure can't leave the list half-ordered.
  Future<void> reorderContexts(List<Context> orderedContexts) async {
    await ref
        .read(syncServiceProvider)
        .contextsInitialPullComplete
        .timeout(const Duration(seconds: 30), onTimeout: () {});

    await db.transaction(() async {
      for (var i = 0; i < orderedContexts.length; i++) {
        final context = orderedContexts[i];
        if (context.sortOrder == i) continue;
        await db.contextDao.markContextUpdatePending(
          context.docId,
          db_models.ContextsCompanion(sortOrder: Value(i)),
        );
      }
    });
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ContextService.reorderContexts')
        .ignore();
  }

  /// Tier-2 hook: assign or clear a context's icon. Tier 1 only invokes this
  /// at seed time (via [createContext]'s [iconName] param), but the method is
  /// public so the upcoming icon picker can plug in without changes here.
  Future<void> setIconName(Context context, String? iconName) async {
    await db.contextDao.markContextUpdatePending(
      context.docId,
      db_models.ContextsCompanion(iconName: Value(iconName)),
    );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ContextService.setIconName')
        .ignore();
  }

  /// Tier-2 hook: assign or clear a context's accent color (hex string).
  Future<void> setColor(Context context, String? color) async {
    await db.contextDao.markContextUpdatePending(
      context.docId,
      db_models.ContextsCompanion(color: Value(color)),
    );
    ref
        .read(syncServiceProvider)
        .pushPendingWrites(caller: 'ContextService.setColor')
        .ignore();
  }

  /// Count how many of [personDocId]'s tasks are tagged with [contextName].
  ///
  /// Scans the user's Drift task rows and parses each `taskContexts` JSON
  /// blob; comparison is case-insensitive on `name` to match the picker's
  /// duplicate-rejection rule. Family-shared tasks owned by other users are
  /// out of scope — context names live in the per-user catalog, so the
  /// "Remove from tasks?" prompt only cleans up the caller's own rows.
  Future<int> countTasksUsingContext({
    required String contextName,
    required String personDocId,
  }) async {
    final lower = contextName.toLowerCase();
    final rows = await db.taskDao.allForUser(personDocId);
    var count = 0;
    for (final row in rows) {
      if (row.retired != null) continue;
      final contexts = parseTaskContexts(row.taskContexts);
      if (contexts.any((c) => c.name.toLowerCase() == lower)) {
        count++;
      }
    }
    return count;
  }

  /// Replace every occurrence of [oldName] with [newName] in the contexts
  /// list of tasks owned by [personDocId]. Each affected task is marked
  /// pendingUpdate so SyncService pushes the change to Firestore on the
  /// next push.
  ///
  /// Returns the number of tasks updated. Preserves any per-context
  /// [TaskContext.value] that may already be set (Tier 2 schema slot) —
  /// only the `name` field is rewritten.
  Future<int> renameContextOnAllTasks({
    required String oldName,
    required String newName,
    required String personDocId,
  }) async {
    final lower = oldName.toLowerCase();
    final rows = await db.taskDao.allForUser(personDocId);
    // Transaction-wrapped per `AreaService.renameAreaOnAllTasks` — keeps
    // the local view consistent if a mid-iteration crash leaves some
    // tasks rewritten and others not.
    var updated = 0;
    await db.transaction(() async {
      for (final row in rows) {
        if (row.retired != null) continue;
        final contexts = parseTaskContexts(row.taskContexts);
        if (!contexts.any((c) => c.name.toLowerCase() == lower)) continue;
        final rewritten = contexts
            .map((c) => c.name.toLowerCase() == lower
                ? c.rebuild((b) => b..name = newName)
                : c)
            .toList();
        await db.taskDao.markUpdatePending(
          row.docId,
          db_models.TasksCompanion(
            taskContexts: Value(serializeTaskContexts(rewritten)),
          ),
        );
        updated++;
      }
    });
    if (updated > 0) {
      ref
          .read(syncServiceProvider)
          .pushPendingWrites(
              caller: 'ContextService.renameContextOnAllTasks')
          .ignore();
    }
    return updated;
  }

  /// Remove [contextName] from every task owned by [personDocId] that
  /// currently carries it. Each affected task is marked pendingUpdate so
  /// SyncService pushes the change to Firestore on the next push.
  ///
  /// Returns the number of tasks updated. Idempotent — tasks without the
  /// context are skipped.
  Future<int> removeContextFromAllTasks({
    required String contextName,
    required String personDocId,
  }) async {
    final lower = contextName.toLowerCase();
    final rows = await db.taskDao.allForUser(personDocId);
    // Transaction-wrapped — see [renameContextOnAllTasks].
    var updated = 0;
    await db.transaction(() async {
      for (final row in rows) {
        if (row.retired != null) continue;
        final contexts = parseTaskContexts(row.taskContexts);
        if (!contexts.any((c) => c.name.toLowerCase() == lower)) continue;
        final filtered =
            contexts.where((c) => c.name.toLowerCase() != lower).toList();
        await db.taskDao.markUpdatePending(
          row.docId,
          db_models.TasksCompanion(
            taskContexts: Value(serializeTaskContexts(filtered)),
          ),
        );
        updated++;
      }
    });
    if (updated > 0) {
      ref
          .read(syncServiceProvider)
          .pushPendingWrites(
              caller: 'ContextService.removeContextFromAllTasks')
          .ignore();
    }
    return updated;
  }
}

// TM-361 Riverpod 4 migration: services need `keepAlive: true` because
// Riverpod 4 changed the @riverpod default from keep-alive to
// auto-dispose. The seed-defaults loop in `ContextsWithDefaults` reads
// this once, captures the service instance, then awaits Drift writes;
// each await yielded control back to the event loop, the auto-dispose
// timer fired, and the captured service's `ref` became closed — so the
// second iteration's `ref.read(syncServiceProvider).pushPendingWrites()`
// threw and bailed the loop after only the first seed had landed.
// Same fix on AreaService.
@Riverpod(keepAlive: true)
ContextService contextService(Ref ref) {
  return ContextService(
    db: ref.watch(databaseProvider),
    firestore: ref.watch(firestoreProvider),
    ref: ref,
  );
}
