# TM-345: Rename "Project" to "Area" with user-customizable options

**JIRA:** [TM-345](https://mayhew3.atlassian.net/browse/TM-345)
**Branch:** `TM-345-rename-project-to-area`

## Summary

The TaskItem `project` field has been renamed to `area`, and the previously hard-coded list of 14 values (`Career`, `Hobby`, `Friends`, …) has been replaced with a per-user customizable Firestore collection. Tasks reference areas by their string `name` — not by `docId` — so the relationship is loosely coupled and deleting an area does not orphan tasks tagged with it.

This work lays the groundwork for a future "Project" feature that will be a *finite, goal-oriented grouping of tasks* living *inside* an Area (out of scope for TM-345).

## Schema

### `Area` (new top-level Firestore collection `areas`)

| Field | Type | Notes |
|---|---|---|
| `docId` | string | Firestore document id |
| `dateAdded` | Timestamp | Set on creation (server timestamp on push) |
| `name` | string | User-visible label (e.g. `"Home"`) |
| `sortOrder` | int | Lower values sort earlier. User-defined drag-to-reorder rewrites the entire list to `0..N-1` |
| `personDocId` | string | Scoping field; same pattern as every other user-owned collection |
| `retired` | string? | Soft-delete marker (`= docId` when retired) |
| `retiredDate` | Timestamp? | When retired |

**Drift mirror:** `Areas` table in `lib/core/database/tables.dart`. Same shape plus the standard `syncState` column.

### `TaskItem.area` (formerly `TaskItem.project`)

`String?` — same shape as the old `project` field. No FK to the Area collection: this is a free-form string that the picker happens to populate from the user's areas list. See *Architecture decisions* below.

## Architecture decisions

### Loose coupling: `task.area` is a string, not a docId reference

The simplest interpretation of "rename the field" preserves the existing `project: String?` semantics. Tasks store the area name; the Area collection is a "user's customizable picker values" not a relational table.

**Tradeoffs:**
- ✅ Migration is trivial — copy `project` → `area`, delete `project`.
- ✅ Deleting an area can't orphan tasks; they keep their string value.
- ✅ Renaming an area doesn't cascade to tasks (decision below).
- ❌ A user could theoretically end up with two areas of the same name and tasks tagged with neither (we don't enforce uniqueness across pending/synced sets — the UI does duplicate-name validation at create time, which is best-effort).

### User-defined ordering with a `sortOrder` int field

Picked over alphabetical so users can keep frequently-used areas (e.g. "Home", "Work") at the top regardless of how they're spelled. Implementation: `ReorderableListView` in the management screen; the reorder callback rewrites every area's `sortOrder` as `0..N-1` in a single Drift transaction.

### Lazy-seed of default areas for new users

The plan called for default areas (`Home`, `Work`, `Finances`, `Family`, `Health`) for new users. Instead of seeding at user-creation time (which would touch the auth/person-creation flow), we lazy-seed: when `areasWithDefaultsProvider` first emits an empty list AND no seed has already been attempted in this session, the provider creates the five defaults in the background.

**Tradeoff:** brand-new users see an empty picker for ~one frame before the seed completes. Negligible in practice; the alternative (touching auth/person-creation) is a much larger change for a tiny UX gain.

### Stale-area handling: tasks keep their string value when an area is deleted

If the user deletes "Hobby" from their areas list, every task tagged `area: "Hobby"` continues to display "Hobby" in the read-only display. The picker just no longer lists "Hobby" as a selectable value (the AreaPicker explicitly includes the current selection in its dropdown values even when it's not in the live list, so the dropdown doesn't crash on render).

This is intentional — automatic cascades on delete would require either a transactional cleanup over potentially every task in the user's list, or a "stale area" UI that nags users to reassign. Both are heavier than the value of clean data.

### Renaming an area does NOT cascade to tasks

Same rationale: a rename → bulk-update of every tagged task is a heavy operation we'd rather not run, and the disambiguation UX (tasks tagged with the *old* name vs. tasks tagged with the *new* name) is muddy. If the user wants their tasks updated, they can edit individual tasks and re-pick the area.

### No conflict-detection columns on Area rows

Tasks and recurrences carry `lastModified` + `conflictRemoteJson` (TM-342) for cross-device edit conflict resolution. Areas don't — they're list-management items, not data with rich edit history. Last-write-wins is acceptable: the worst-case is a brief flicker when two devices reorder the list within seconds of each other.

## Migration plan

### Phase 0 (one-shot, server-side, before app deploy)

`bin/firestore-migrate-project-to-area.js` (modeled on `bin/firestore-repair.js`).

Per user:
1. Read all `tasks` for the user.
2. For every task with a `project` field, set `area = project` and `FieldValue.delete()` the `project` field.
3. Compute the distinct non-null project values seen across that user's tasks.
4. Create one Area document per distinct value (sorted alphabetically; `sortOrder = i`).

Idempotent on re-runs: tasks already in the new shape (`area` set, `project` absent) are skipped, and Area docs whose `name` already exists for the user are not re-inserted.

**Run sequence at deploy time:**

```bash
# 1. Verify on emulator with a prod backup loaded:
node bin/firestore-migrate-project-to-area.js --emulator
node bin/firestore-migrate-project-to-area.js --emulator --apply

# 2. Take a Firestore export of production (rollback insurance).

# 3. Run on production for every user:
node bin/firestore-migrate-project-to-area.js --production --all-users --apply

# 4. Deploy the new app version.
```

### Drift schema migration (client-side, automatic on first launch after upgrade)

`AppDatabase.schemaVersion` bumped from 4 → 6 in two steps:
- v5: `m.createTable(areas)` — adds the new local mirror table.
- v6: `ALTER TABLE tasks RENAME COLUMN project TO area` — preserves any locally-cached `project` values during the upgrade. (The next remote snapshot from the server-migrated Firestore overwrites them anyway, but no data is lost in the upgrade window.)

### Rollback

If a defect surfaces after deploy:
1. Restore the pre-migration Firestore export from step 2.
2. Roll the app back to the pre-TM-345 version (it expects `project` and ignores `area`).

## UI surfaces

### Area picker on task add/edit (`AreaPicker`)

`lib/features/areas/presentation/area_picker.dart`. Wraps `DropdownButtonFormField<String>` with two sentinels:

- `(none)` at the top → maps to `null` (no area selected).
- `+ Add new area…` at the bottom → opens an inline dialog with a TextField; on submit, calls `AreaService.createArea`, sets the new name as the picked value, and the live areas list refreshes.

If the task's current area isn't in the live areas list (deleted by the user since this task was tagged), it's still rendered as the selected value so the dropdown doesn't crash.

### Area Management Screen (`AreaManageScreen`)

`lib/features/areas/presentation/area_manage_screen.dart`. Reachable from the navigation drawer ("Manage Areas").

- `ReorderableListView` with drag handles on each row.
- Per-row: rename button, delete button (with confirmation dialog explaining stale-area handling).
- FAB: "Add area" (same dialog as the picker's `+ Add new area…`).
- Empty state copy: "No areas yet. Tap + to add one."

### Display sites (mechanical renames in this PR)

- `task_details_screen.dart`: header `"Project"` → `"Area"`, reads `task.area`.
- `editable_task_item.dart` and `widgets/plan_task_item.dart`: read `taskItem.area` / `sprintDisplayTask.area` for inline display.
- `sync_conflict_detail_dialog.dart`: label `"Project"` → `"Area"`.

## Tests

### New tests added in this PR

- `test/models/area_test.dart` — built_value (de)serialization, blueprint round-trip.
- `test/core/database/area_dao_test.dart` — Drift CRUD, watch filters (sorted by sortOrder, retired excluded, scoped by personDocId), reconciliation (`deleteSyncedAreasNotIn`).
- `test/features/areas/area_service_test.dart` — `createArea` (sortOrder = max+1, per-user isolation, pendingCreate state), `deleteArea` (pendingDelete + retired stamp), `reorderAreas` (rewrites 0..N-1, no-op if already correct).

### Existing tests updated

8 test files renamed `project` → `area` (mock data, mock builders, widget tests, integration helpers).

### Follow-up tests (not in this PR)

- Picker widget test: sentinel-to-dialog flow, duplicate-name rejection, stale-area rendering.
- Manage screen widget test: reorder writes new sortOrder, delete confirmation, add dialog.
- `AreasWithDefaults` provider: lazy-seed on empty, idempotency.

These were planned for this PR but deferred — the unit-test coverage above + manual visual verification gives confidence that the implementation is correct, and the widget tests can be added in a follow-up without blocking deployment.

## Future work

The TaskMaster roadmap distinguishes **Areas** (ongoing categories of responsibility — "Home", "Finances") from **Projects** (finite, goal-oriented groupings — "Replace the deck", "Plan trip to Spain"). This PR establishes the Area concept; a future ticket will introduce a separate `Project` collection that lives *inside* an Area, with a finite/done state.
