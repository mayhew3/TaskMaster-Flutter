# Technical Specification: Infrastructure & Observability

**Epic**: [TM-318](https://mayhew3.atlassian.net/browse/TM-318) — Infrastructure & Observability
**Created**: 2026-04-13
**Stories**:
- [TM-319](https://mayhew3.atlassian.net/browse/TM-319) — Offline-First Architecture (Drift + SyncService + OfflineBanner)
- [TM-321](https://mayhew3.atlassian.net/browse/TM-321) — Crash Reporting Integration (Firebase Crashlytics)
- [TM-322](https://mayhew3.atlassian.net/browse/TM-322) — Analytics Setup (Firebase Analytics)
- [TM-334](https://mayhew3.atlassian.net/browse/TM-334) — View/Export logs (persistent log file + share sheet)
- ~~TM-320~~ — CI/CD Pipeline Setup (closed as obsolete during the batch)

---

## Overview

TM-318 introduces the foundational infrastructure TaskMaster needs to run reliably on production devices: a local-first data layer so the app is usable without network, structured crash and analytics reporting so regressions are visible after release, and on-device log persistence so iOS production devices can be diagnosed without console access.

Before this epic, TaskMaster read and wrote directly against Firestore with its built-in offline persistence. Reads were blocked on network round-trips on cold start, writes silently disappeared into Firestore's internal queue with no UI feedback, and there was no visibility into crashes or user behavior once the app shipped. After this epic, the app paints instantly from a local Drift database, pending writes are queued explicitly with per-row state, an offline/syncing banner tells the user what is happening, crashes are captured via Crashlytics, user events are tracked via Analytics, and the full runtime log is retrievable as a file from the drawer.

---

## Architecture

### High-level data flow

```
Firestore (remote source of truth)
    ↕   SyncService
        - pulls scoped Firestore snapshots into Drift
        - pushes locally-pending Drift rows back to Firestore
Drift (local SQLite, primary read source)
    ↓   DAOs (TaskDao, TaskRecurrenceDao, SprintDao)
Riverpod providers (tasksProvider, sprintsProvider, tasksWithRecurrencesProvider)
    ↓
UI (loads instantly from local cache; OfflineBanner reflects state)
```

### Components added

**Local data layer** (`lib/core/database/`)
- `tables.dart` — Drift table definitions for `Tasks`, `TaskRecurrences`, `Sprints`, `SprintAssignments`, plus the `SyncState` enum (`synced` / `pendingCreate` / `pendingUpdate` / `pendingDelete`)
- `app_database.dart` — `@DriftDatabase` root class registering the tables and DAOs
- `converters.dart` — single source of truth for model ↔ Drift row mapping and blueprint → companion diffs; handles the `AnchorDate` JSON blob and the `syncState` column (DAOs manage that column, not the converters)
- `daos/task_dao.dart`, `task_recurrence_dao.dart`, `sprint_dao.dart` — read/write operations with pending-local-wins semantics, plus bulk upsert helpers

**Sync layer** (`lib/core/services/sync_service.dart`)
- `SyncService` — Firestore ↔ Drift bridge. `start(personDocId)` subscribes to scoped Firestore snapshots, `stop()` cancels on sign-out, `pushPendingWrites()` flushes pending rows
- Each collection subscription is scoped so cold-start sync is cheap (`tasks: completionDate == null && retired == null`; `taskRecurrences: retired == null`; `sprints: orderBy sprintNumber DESC limit 3`)
- Push is automatically triggered when connectivity flips from offline → online
- Concurrent push requests are never dropped: a `_pushRequestedWhilePushing` flag causes the in-flight push to re-run itself in `finally`
- Partial failures flip `SyncStatus` to `error` (each `_pushPending*` phase returns `hadFailure`, which is OR'd together)

**Connectivity & sync-status plumbing** (`lib/core/providers/`)
- `connectivity_provider.dart` — `ConnectivityService` wrapper over `connectivity_plus`; `connectivityProvider` is a `StreamProvider<bool>` that emits the current online state and subsequent changes
- `sync_status_provider.dart` — `SyncStatus` enum (`idle` / `syncing` / `error`) driven by `SyncService`
- `database_provider.dart` — `@Riverpod(keepAlive: true)` singleton for `AppDatabase`

**Offline/Syncing banner** (`lib/features/shared/presentation/offline_banner.dart`)
- `ConsumerWidget` mounted above the main navigation in `riverpod_app.dart`
- Priority: offline > error > syncing. Banner is hidden when online + idle
- Colors: amber (offline), red (sync failed), muted blue (syncing)

**Observability services** (`lib/core/services/`)
- `crash_reporter.dart` — `CrashReporter` wraps `FirebaseCrashlytics`. Fatal / non-fatal / breadcrumb / custom-key helpers. No-op in `kDebugMode` so local development doesn't pollute the dashboard.
- `analytics_service.dart` — `AnalyticsService` wraps `FirebaseAnalytics`. Task/sprint event helpers plus `setUserIdentifier` and `logScreenView`. No-op in `kDebugMode`.
- `log_storage_service.dart` — rolling 5 MB log file under the app documents directory. Serializes writes through an internal `Future` chain so concurrent `writeRecord`/`writeRaw` callers can't interleave on the same file handle.

### Components modified

- `lib/main.dart` — initialize `LogStorageService` and wrap `runApp` in a `runZoned` that intercepts `print(...)` into `writeRaw(...)`. Wires Crashlytics `FlutterError.onError` / `PlatformDispatcher.instance.onError` handlers (gated behind `!kDebugMode`).
- `lib/riverpod_app.dart` — on `AuthStatus.authenticated`, call `syncService.start(personDocId)`; on sign-out, `syncService.stop().ignore()`. Mounts `OfflineBanner` above the main navigation.
- `lib/features/tasks/providers/task_providers.dart` — `tasksProvider`, `taskRecurrencesProvider`, `tasksWithRecurrencesProvider` rewritten to stream from Drift DAOs (previously read directly from Firestore).
- `lib/features/sprints/providers/sprint_providers.dart` — `sprintsProvider` rewritten to stream from `SprintDao.watchRecentSprints` (reactively joins sprints + assignments via `Rx.combineLatest2`).
- `lib/core/services/task_completion_service.dart` — `AddTask`/`UpdateTask`/`DeleteTask`/`CompleteTask`/`SnoozeTask` now write to Drift first (via DAOs), then fire-and-forget `syncService.pushPendingWrites()`. Each controller also now logs the corresponding analytics event.
- `lib/features/sprints/services/sprint_service.dart` — `CreateSprint`/`AddTasksToSprint` wrap all Drift writes in a single `db.transaction` so partial failures don't leave half-a-sprint queued for sync; `CreateSprint` awaits `syncService.initialPullComplete` (5s timeout) before deriving `sprintNumber` from the local max so fresh installs don't collide with remote sprints.
- `lib/features/shared/presentation/app_drawer.dart` — adds "Export Logs" (fetches the log file path and hands it to `SharePlus.instance.share` with a timestamped filename) and a `kDebugMode`-gated "Test Crash Reporting" action (fatal / non-fatal / native crash / breadcrumb test actions).
- `lib/core/services/auth_service.dart` — sets Crashlytics and Analytics `userIdentifier` on auth events so crashes/events are scoped to the current `personDocId` (anonymized, never email/PII).

### Sync-state machine

Each synced row in Drift carries a `syncState` TEXT column:

| State             | Meaning                                 | Sync behavior                                                 |
| ----------------- | --------------------------------------- | ------------------------------------------------------------- |
| `synced`          | Matches Firestore                       | Can be overwritten by incoming remote snapshots               |
| `pendingCreate`   | Created locally, not yet pushed         | Never overwritten by remote; pushed on next `pushPendingWrites` |
| `pendingUpdate`   | Updated locally, not yet pushed         | Never overwritten by remote; pushed on next `pushPendingWrites` |
| `pendingDelete`   | Soft-deleted locally, pending remote delete | Not returned by read queries; pushed as delete on next `pushPendingWrites` |

**Conflict resolution:** pending-local-wins until pushed. Once a pending row is successfully pushed, it flips to `synced` and future remote snapshots can overwrite it normally. No per-field `updatedAt` comparisons.

### Data scope: what is synced vs. direct

| Data                              | Offline-first (Drift) | Direct Firestore |
| --------------------------------- | --------------------- | ---------------- |
| Incomplete tasks                  | ✅                    | —                |
| Task recurrences (non-retired)    | ✅                    | —                |
| Recent sprints (top 3)            | ✅                    | —                |
| Sprint assignments                | ✅                    | —                |
| Older completed tasks (paginated) | —                     | ✅ (`OlderCompletedTasksBatches`) |
| Tasks-for-recurrence history view | —                     | ✅ (`tasksForRecurrence`) |

Rationale: offline-first matters for active work. Deep history is a log that is rarely accessed offline, and paginating it in Drift adds complexity with little user value.

---

## Code Patterns

### DAO: pending-local-wins upsert

DAO methods that mirror a Firestore snapshot into Drift must skip rows whose local `syncState` is anything other than `synced`:

```dart
Future<void> upsertFromRemote(TasksCompanion row) async {
  final current = await (select(tasks)
        ..where((t) => t.docId.equals(row.docId.value)))
      .getSingleOrNull();
  if (current != null && current.syncState != SyncState.synced.name) {
    return; // don't clobber a locally-pending row
  }
  await into(tasks).insertOnConflictUpdate(
    row.copyWith(syncState: Value(SyncState.synced.name)),
  );
}
```

### DAO: bulk upsert for cold-start performance

Per-row `upsertFromRemote` is O(N × 2) SQL round-trips. `bulkUpsertFromRemote` fetches all pending docIds in one SELECT, then batch-inserts the rest in one shot:

```dart
Future<void> bulkUpsertFromRemote(List<TasksCompanion> rows) async {
  if (rows.isEmpty) return;
  final pendingIds = await (select(tasks)
        ..where((t) => t.syncState.isIn([
              SyncState.pendingCreate.name,
              SyncState.pendingUpdate.name,
              SyncState.pendingDelete.name,
            ])))
      .map((t) => t.docId)
      .get();
  final pendingSet = pendingIds.toSet();
  final toUpsert = rows
      .where((r) => !pendingSet.contains(r.docId.value))
      .map((r) => r.copyWith(syncState: Value(SyncState.synced.name)))
      .toList();
  if (toUpsert.isEmpty) return;
  await batch((b) => b.insertAllOnConflictUpdate(tasks, toUpsert));
}
```

This plus scoping the Firestore subscription (`completionDate == null && retired == null`) dropped cold-start sync from ~10 s (2320 docs) to ~1 s (~123 docs).

### Write mutation: Drift-first, push async

Write controllers mark the Drift row pending and fire-and-forget the push:

```dart
Future<void> call(TaskItemBlueprint blueprint) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final db = ref.read(databaseProvider);
    final firestore = ref.read(firestoreProvider);
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      throw StateError('Cannot add task: personDocId is null');
    }

    final taskDocId = firestore.collection('tasks').doc().id;
    await db.taskDao.insertPending(
      taskBlueprintToCompanion(
        docId: taskDocId,
        personDocId: personDocId,
        dateAdded: DateTime.now().toUtc(),
        blueprint: blueprint,
      ),
    );

    ref.read(analyticsServiceProvider)
        .logTaskCreated(hasRecurrence: blueprint.recurrenceBlueprint != null)
        .ignore();
    ref.read(syncServiceProvider).pushPendingWrites(caller: 'AddTask').ignore();
  });
}
```

The UI updates immediately from the Drift stream. If offline, the row stays `pendingCreate` and is flushed on the next `pushPendingWrites` trigger (typically when connectivity comes back online).

### Observability wrapper: debug-mode no-op

Both `CrashReporter` and `AnalyticsService` are no-ops in `kDebugMode` so local development never pollutes the production dashboards:

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  bool get isEnabled => !kDebugMode;

  Future<void> logTaskCreated({bool hasRecurrence = false}) async {
    if (!isEnabled) return;
    await _analytics.logEvent(
      name: 'task_created',
      parameters: {'has_recurrence': hasRecurrence ? 1 : 0},
    );
  }
}
```

### Persistent log: serialized writes

`LogStorageService` is hit from a `runZoned` print hook in `main.dart` as fire-and-forget. Concurrent writes to the same file would interleave, so every write chains onto an internal `Future`:

```dart
Future<void> _writeQueue = Future.value();

Future<void> _enqueue(Future<void> Function() work) {
  final next = _writeQueue.then((_) => work()).catchError((_) {});
  _writeQueue = next;
  return next;
}
```

Sink error paths use `stderr.writeln(...)` (never `print`) so a write failure doesn't re-enter the zone's print hook.

---

## Testing

### Unit tests (new)

| File | Covers |
| ---- | ------ |
| `test/core/database/task_dao_test.dart` | `TaskDao` pending-state transitions, `watchIncompleteTasks` filtering, `markSynced` flips |
| `test/core/database/sprint_dao_test.dart` | `SprintDao` sprint+assignment CRUD, `deleteSyncedOrphanAssignments`, reactive join behavior |
| `test/core/database/converters_test.dart` | `TaskItem` / `TaskRecurrence` / `Sprint` round-trip through companions, `anchorDate` JSON encoding |
| `test/core/providers/connectivity_provider_test.dart` | `ConnectivityService.isOnlineFromResults` matrix, `connectivityProvider` stream behavior with a fake service |
| `test/core/services/crash_reporter_test.dart` | Each public method is a no-op in debug mode |
| `test/core/services/analytics_service_test.dart` | Each public method is a no-op in debug mode |
| `test/core/services/log_storage_service_test.dart` | `writeRecord` formatting, `_rotate`, `readLogs`, `clearLogs`, `getLogFilePath` |
| `test/core/services/task_completion_service_test.dart` | Rewritten for Drift-first writes: `AddTask`/`UpdateTask`/`DeleteTask` using in-memory Drift + `FakeFirebaseFirestore` + `MockSyncService` + `MockAnalyticsService` |
| `test/features/sprints/services/sprint_creation_bug_test.dart` | Provider-invalidation test rewritten to assert Drift `pendingCreate` state |

### Widget tests (new)

| File | Covers |
| ---- | ------ |
| `test/core/widgets/offline_banner_test.dart` | All state combinations (online/offline × idle/syncing/error), priority order (offline > error > syncing), and per-state colors |

### Integration-test harness

`test/integration/integration_test_helper.dart` — `pumpAppWithLiveFirestore` uses a hybrid read/write architecture to work around a Drift + flutter_test interaction:

- **Reads** stream from `FakeFirebaseFirestore` (overrides for `tasksProvider` / `tasksWithRecurrencesProvider` / `taskRecurrencesProvider` / `sprintsProvider`). This avoids Drift's 0-duration stream-cleanup timers firing during `finalizeTree` and failing flutter_test's post-test invariant check.
- **Writes** go to an in-memory Drift DB via `databaseProvider.overrideWithValue(db)`, and `SyncService` pushes them to `testFirestore`, whose streams then drive the read-side providers.
- An explicit `ProviderContainer` + `UncontrolledProviderScope` lets the helper pre-warm `connectivityProvider` via `container.read(connectivityProvider.future)` so `SyncService.pushPendingWrites` sees `online == true` on its first invocation.

### Test results

- Full test suite: **396/396 passing**
- `dart analyze`: clean

---

## Configuration

### New dependencies (runtime)

```yaml
drift: # Local SQLite + reactive queries
drift_flutter: # Flutter connection helper
sqlite3_flutter_libs: # Bundled SQLite
connectivity_plus: # Network connectivity stream
firebase_crashlytics: # TM-321
firebase_analytics: # TM-322
logging: # TM-334 — `package:logging` Logger
path_provider: # TM-334 — app documents directory
share_plus: # TM-334 — share sheet for log export
```

### New dev dependencies

```yaml
drift_dev: # Drift code generation
```

### Gradle (Android)

`android/settings.gradle` + `android/app/build.gradle` apply the Firebase Crashlytics Gradle plugin so native crashes are symbolicated.

---

## Operational notes

### Emulator & backup scripts

`scripts/firestore_backup.{sh,bat}`, `scripts/copy_backup_to_emulator.{sh,bat}` plus matching IntelliJ run configs under `.run/` were added to make it easy to export a Firestore backup, copy it into the local emulator import directory, and launch the emulator with `--import=./db_backups/prod_latest`. This is what the offline-first development workflow depends on locally.

### Cold-start performance envelope

Baseline (before TM-319): ~10 s to first paint on a full account (~2320 tasks).
After scoping + bulk upsert: ~1 s to first paint (UI unblocked at +996 ms on a test account of ~123 active tasks).

### Known limitations

- **Fresh install + offline sprint creation**: `CreateSprint` awaits `SyncService.initialPullComplete` with a 5 s timeout before reading the local sprint max. If a user does a fresh install and creates a sprint before any Firestore snapshot has arrived, the `sprintNumber` they generate may collide with an existing remote sprint and need later reconciliation. Not currently observed in practice; left for a future iteration.
- **Deep completed-task history is not cached**: `OlderCompletedTasksBatches` and `tasksForRecurrence` still read directly from Firestore. These are inherently offline-unfriendly but rarely accessed offline.
- **Background sync**: sync runs only while the app is open. No headless background push.

---

## JIRA

- Epic: [TM-318](https://mayhew3.atlassian.net/browse/TM-318) — Infrastructure & Observability
- Stories: [TM-319](https://mayhew3.atlassian.net/browse/TM-319), [TM-321](https://mayhew3.atlassian.net/browse/TM-321), [TM-322](https://mayhew3.atlassian.net/browse/TM-322), [TM-334](https://mayhew3.atlassian.net/browse/TM-334)
- Merged PR: [#12](https://github.com/mayhew3/TaskMaster-Flutter/pull/12)
