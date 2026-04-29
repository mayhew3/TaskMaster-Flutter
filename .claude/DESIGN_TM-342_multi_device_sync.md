# DESIGN: Multi-device sync edge cases (TM-342)

**JIRA:** TM-342
**Branch:** `TM-342-multi-device-sync-edge-cases`
**Builds on:** TM-335 (multiplayer MVP), TM-343 (recurrence sync), TM-341 (completed-task purge fix)

---

## Problem

Two latent sync defects surfaced once multiple devices entered the picture:

1. **Cross-device completion deletes local rows.** The personal-tasks Firestore listener filters `completionDate isNull && retired isNull`. When Device B completes a task, Firestore sends a `DocumentChangeType.removed` event to Device A. The previous handler unconditionally hard-deleted the row from Drift, breaking Device A's Sprint Completed view and any other surface that reads completed tasks.

2. **Stale offline edits silently clobber newer remote changes.** `_pushPendingTasks` / `_pushPendingRecurrences` called `docRef.set(json)` with no remote read or timestamp comparison. Device A could come back online after Device B had written a newer version, push its stale edit, and overwrite Device B's change with no warning.

---

## Edge Case 1 — distinguish completion from delete

### Decision tree (personal listener only)

```
on DocumentChangeType.removed:
  if docId in _familyTaskDocIds: return                    # family listener owns it
  task = deserialize(change.doc.data())                    # cached pre/post-change state
  if task != null && (task.completionDate != null || task.retired != null):
    upsertFromRemote(task)                                  # fast path — keep with new state
    return
  try:
    snap = change.doc.reference.get(Source.server)          # confirm
    if !snap.exists:
      deleteFromRemote(docId)                               # truly deleted
    else:
      upsertFromRemote(deserialize(snap.data()))            # still exists
  catch (e):
    log; do nothing                                         # FAIL CLOSED — preserve row
```

### Why these decisions

- **Cached `change.doc.data()` first**: avoids a Firestore round-trip in the common case. Firestore's SDK keeps the last-known field state on `removed` events when the doc moved out of the query (vs. being hard-deleted). When that snapshot already shows `completionDate` or `retired` set, we know the task wasn't deleted — it transitioned to a state that no longer matches the listener's filter. Keep it.
- **Server fetch fallback**: when the cached data lacks the discriminating fields (the SDK can deliver pre-change state, particularly mid-completion), we ask the server to resolve. `Source.server` skips the persisted cache so we get authoritative truth.
- **Fail closed**: if the server fetch throws (offline, rate limit, transient), we log and do nothing. The row stays in Drift. The next snapshot will retry. The previous behavior was fail-open (delete), which permanently lost local data on transient errors.
- **Recurrences listener: no change.** `_onRecurrencesSnapshot` already drops retired recurrences from local Drift on purpose — the converter doesn't write the `retired` column, so a retired row would appear active to `watchActive` (TM-343 design). The same "completion vs delete" ambiguity does not apply because recurrences aren't completed; they are retired or replaced.

### Family listener stays as-is

The family-tasks listener filters on `familyDocId + retired isNull` — it does NOT filter on `completionDate`. A completed family task stays inside the listener's view, so no `removed` event fires on completion. The fix is unnecessary there; the existing flow already keeps the row.

---

## Edge Case 2 — `lastModified`-based conflict detection + resolution UI

### Server-authoritative `lastModified`

Every Drift mutation method (`insertPending`, `markUpdatePending`, `markDeletePending`) stamps `lastModified = DateTime.now().toUtc()` locally as a best-effort optimistic timestamp. On push, the JSON sent to Firestore overrides `lastModified` with `FieldValue.serverTimestamp()` so the server writes the authoritative value. When the post-push snapshot arrives, `markSynced` clears the pending state and the next remote upsert overwrites the local row with the server-stamped `lastModified`.

**Why server-authoritative**: client clock skew can be minutes off. A device with a fast clock would always "win" conflicts on its own writes. Server timestamps are clock-skew-immune. The asymmetry between local-stamp-on-mutation and server-stamp-on-push is acceptable: it only matters when clocks are skewed by more than the conflict window (typically seconds to minutes), which is rare.

### Push-time conflict detection

```
for each pending row:
  remote = docRef.get()
  if !remote.exists:                       push (insert)
  elif remote.lastModified == null:        push (legacy doc, no timestamp)
  elif remote.lastModified <= local.lastModified:  push (local newer or tied)
  else:                                    record conflict; do not push
```

The conflict check happens uniformly on `pendingCreate` / `pendingUpdate` / `pendingDelete`. A pending delete that conflicts with a newer remote update surfaces as a delete-vs-update dialog rather than blowing away the remote change.

### Conflict envelope

When a conflict is detected, the local row's `syncState` becomes `pendingConflict` and `conflictRemoteJson` gets a structured envelope:

```json
{
  "priorSyncState": "pendingUpdate",
  "remote": { "...full TaskItem.toJson()..." }
}
```

The local row's data fields are intentionally preserved so the resolution UI can render the user's pending edit alongside the remote version. `priorSyncState` lets "Keep mine" restore the correct pending state (pendingUpdate vs pendingDelete) when refreshing the timestamp for the next push.

DateTime fields in the envelope are converted to ISO strings via a `toEncodable` callback during `jsonEncode`. On decode, `DatePassThroughSerializer` already handles String → DateTime so no extra work is needed.

### Resolution UI

The pattern mirrors TM-335's `PendingInvitationBanner`:

- **`SyncConflictBanner`** (`features/sync/presentation/sync_conflict_banner.dart`) — mounted in the home Scaffold's body Column above the tab content, alongside the pending-invitation banner. Visible from every tab. Returns `SizedBox.shrink` when no conflicts exist.
- **`SyncConflictsScreen`** — pushed route from the banner. Lists tasks and recurrences in conflict with a one-line summary per row.
- **`SyncConflictDetailDialog`** — modal opened from the list. Shows local vs remote side-by-side, highlights differing fields. Three actions: **Keep mine** (force-push local), **Use latest** (overwrite local with remote), **Cancel** (defer; banner stays up).

**Resolution actions:**

- *Keep mine*: `clearConflictAndRestorePending(docId, priorSyncState, now: DateTime.now().toUtc())` then trigger a push. The refreshed `lastModified` makes the next push win against the remote that previously beat us.
- *Use latest*: `clearConflictAndAcceptRemote(docId, taskItemToCompanion(remote))` writes the remote into Drift and marks synced. No push is triggered (the row already matches Firestore).

### `upsertFromRemote` invariant

`upsertFromRemote` and `bulkUpsertFromRemote` skip rows in any non-synced state — that includes the new `pendingConflict`. While a conflict is open, incoming remote snapshots do NOT overwrite the conflict envelope or the local pending edit. When the user resolves, the syncState transitions back to `synced` (Use latest) or to a pending state (Keep mine), and normal sync resumes.

### Race window

Between the pre-push `docRef.get()` (T1) and the `docRef.set()` (T2), another device could write. The window is on the order of milliseconds (one Firestore round-trip per pending row). For TaskMaster's usage profile (a few writes per minute, infrequent multi-device editing), this is acceptable. A Firestore transaction would close the window completely but adds complexity for marginal benefit. Deferred for follow-up if real-world conflicts surface.

---

## Schema migration (v3 → v4)

Drift `schemaVersion` bumped from 3 to 4. The migration adds two columns to each of `tasks` and `task_recurrences`:

```sql
ALTER TABLE tasks ADD COLUMN last_modified INTEGER;            -- Drift stores DateTime as ms epoch
ALTER TABLE tasks ADD COLUMN conflict_remote_json TEXT;
ALTER TABLE task_recurrences ADD COLUMN last_modified INTEGER;
ALTER TABLE task_recurrences ADD COLUMN conflict_remote_json TEXT;

UPDATE tasks SET last_modified = date_added WHERE last_modified IS NULL;
UPDATE task_recurrences SET last_modified = date_added WHERE last_modified IS NULL;
```

The backfill `lastModified = dateAdded` gives existing rows a best-effort baseline timestamp. The next push from any TM-342 client will overwrite with the server-stamped value. The `SyncState` enum gains a `pendingConflict` variant; this is a string in the column, so no DDL change is needed.

### Cross-version interop

- **Old client → new client**: an old client writes without `lastModified`. The new client's push-time conflict check treats null remote `lastModified` as "legacy" and pushes (last-write-wins by client request order). Once the new client pushes, the field is populated with `serverTimestamp()` and subsequent comparisons work normally.
- **New client → old client**: the new client writes with `lastModified` set. The old client ignores the unknown field. No regression.

The interop window is the period between when the first user upgrades and when all users have upgraded. During that window, conflicts are detected only between two new clients; old-vs-new still has the silent-clobber risk. Acceptable for personal-use scope.

---

## Files modified / added

| Layer | File | Change |
|-------|------|--------|
| DB | `lib/core/database/tables.dart` | Add `lastModified`, `conflictRemoteJson` columns; add `pendingConflict` SyncState |
| DB | `lib/core/database/app_database.dart` | schemaVersion 3 → 4; migration step |
| DB | `lib/core/database/converters.dart` | Round-trip `lastModified` for tasks + recurrences |
| DB | `lib/core/database/daos/task_dao.dart` | Stamp `lastModified` on mutations; add `markPendingConflict`, `clearConflictAndAcceptRemote`, `clearConflictAndRestorePending`, `watchTasksWithConflicts` |
| DB | `lib/core/database/daos/task_recurrence_dao.dart` | Same as above for recurrences |
| Models | `lib/models/task_item.dart` + blueprint | Add `lastModified` field |
| Models | `lib/models/task_recurrence.dart` + blueprint | Add `lastModified` field |
| Sync | `lib/core/services/sync_service.dart` | `_resolveRemovedTask` (Edge Case 1); `_checkAndRecordConflict` + `_encodeConflictEnvelope` (Edge Case 2); `FieldValue.serverTimestamp()` on push |
| UI | `lib/features/sync/providers/sync_conflict_providers.dart` | `taskConflictsProvider`, `recurrenceConflictsProvider`, `allConflictsCountProvider`, `KeepLocalConflict`, `AcceptRemoteConflict` |
| UI | `lib/features/sync/presentation/sync_conflict_banner.dart` | New |
| UI | `lib/features/sync/presentation/sync_conflicts_screen.dart` | New |
| UI | `lib/features/sync/presentation/sync_conflict_detail_dialog.dart` | New |
| UI | `lib/riverpod_app.dart` | Mount `SyncConflictBanner` in Scaffold body Column |
| Tests | `test/core/services/sync_service_test.dart` | TM-342 cross-device-completion + conflict-detection groups |
| Tests | `test/features/sync/presentation/sync_conflict_banner_test.dart` | New |
| Tests | `test/features/sync/presentation/sync_conflict_detail_dialog_test.dart` | New |

---

## Verification

### Automated
- `flutter analyze` — clean
- `flutter test` — all 460+ tests pass, including new sync_service / banner / dialog tests

### Manual (Firestore emulator + 2 emulator instances)

**Edge Case 1**:
1. Sign in same user on Devices A and B.
2. Add a task on A; verify it appears on B.
3. Complete the task on B.
4. Verify on A: task disappears from incomplete list but **remains in Sprint Completed view** (Drift row preserved with `completionDate` set).

**Edge Case 2 happy path**:
1. Both devices online; A edits task → push proceeds (older remote `lastModified`).
2. Open task on B → sees A's change.

**Edge Case 2 conflict (edit-vs-edit)**:
1. A goes offline (airplane mode or stop emulator network).
2. A edits task → "A's name" (queued as pendingUpdate).
3. B (online) edits same task → "B's name" (Firestore writes with newer `serverTimestamp`).
4. A comes back online → push detects conflict, marks pendingConflict.
5. Verify on A: orange banner appears at top of all tabs.
6. Tap Resolve → list shows the task; tap to open dialog.
7. Dialog shows "Local: A's name" vs "Remote: B's name", with the Name row highlighted.
8. Tap "Use latest" → task becomes "B's name" on A; banner clears.
9. Re-run; tap "Keep mine" → task pushes "A's name" to Firestore; B sees the update.

**Edge Case 2 conflict (delete-vs-edit)**:
1. A goes offline; deletes task X (pendingDelete).
2. B edits task X.
3. A comes back online → conflict surfaced.
4. Dialog wording reflects delete-vs-edit; "Keep delete" vs "Use latest" both work.

**Recurrence conflict**:
1. Repeat the offline conflict flow on a recurring task's recurrence rule (edit `recurNumber`).
2. Verify banner counts both tasks and recurrences; per-kind dialogs render the right fields.

---

## Deferred (follow-up tickets)

- **Sprint + sprint-assignment + family-invitation collections.** Same `lastModified` mechanism would apply for symmetry. Sprints rarely conflict (single-writer pattern); assignments are append-mostly; invitations are short-lived. Deferred to keep this PR's review surface manageable.
- **Field-level merge.** "Use latest" overwrites the local row entirely, losing any non-conflicting fields the user changed. A future iteration could diff field-by-field and merge non-overlapping changes. The current full-replace mirrors how `upsertFromRemote` behaves in the listener path, so it's at least internally consistent.
- **Inline conflict surfacing on edit screen.** Currently the banner is asynchronous — it appears after the user has navigated away from the edit screen. A more immediate UX would have `UpdateTask.call` await the push result and pop a dialog if a conflict was detected, blocking the user on the edit screen. Heavier, deferred.
- **Firestore transaction on push.** Closes the T1=read / T2=write race window completely. Acceptable for now given the small window and low conflict frequency.
- **Migration test scaffolding.** Drift's `verifyDatabase` API requires generated schema dump files. Adding the dump-generation pipeline is out of scope; the migration is exercised by all device upgrades and is simple enough that on-device testing is the primary validation.

---

## References
- TM-335 — `PendingInvitationBanner` and `_familyTaskDocIds` patterns reused here.
- TM-341 — `deleteSyncedIncompleteNotIn` invariant preserved (only purges incomplete rows on initial snapshot).
- TM-343 — `RecurrenceNotFoundException` graceful surfacing pattern; recurrence retire-vs-delete design.
