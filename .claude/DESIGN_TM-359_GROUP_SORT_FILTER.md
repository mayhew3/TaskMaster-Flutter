# DESIGN: TM-359 — Group / Sort / Filter for task lists

**JIRA:** [TM-359](https://mayhew3.atlassian.net/browse/TM-359)
**Branch:** `TM-359-group-sort-filter-options`
**Status:** Under Review
**Authors:** Mayhew Park + Claude (paired)

---

## Why

Pre-TM-359 each of the four task-list surfaces — Tasks tab, Family tab, Sprint tab, plan-mode (Create Sprint / Add Tasks) — implemented its own ad-hoc filter/sort/group logic:

- A small set of boolean filter notifiers (`ShowCompleted`, `ShowScheduled`, `SearchQuery`).
- A hardcoded group taxonomy (Tasks/Family used 6 buckets, plan-mode used 8, Sprint had none).
- Either no in-group sort or a single fixed sort.
- **No user choice** for any of the three axes.

TM-359 unifies all four behind one configurable surface — Group axis + Sort axis + multi-axis Filters + collapse state — used independently per surface and persisted via `shared_preferences`. The pre-TM-359 hardcoded 6-bucket grouping becomes the **default** for "Group by Due Status" and is no longer the only option.

---

## What users can now do

Each list surface gets an `Icons.tune` button in the app bar (`ViewOptionsButton`). A small green dot on the button indicates the saved view differs from defaults in any non-search axis. Tapping opens the **View Options** bottom sheet with these sections:

1. **Group + Sort** — side-by-side dropdowns. Group: `Due Status` (default) / `None` / `Priority` / `Area` / `Points` / `Estimated Time`. Sort: `Urgency` (default) / `Date Added` / `Points` / `Area` / `Estimated Time` / `Priority` / `Efficiency`. Direction toggle (ascending/descending) sits beside the Sort dropdown.
2. **Filter by** — in this order: Due Status (multi-select), Estimated Time (min/max), Points (min/max with "Other" custom input), Priority (min/max), Area + Contexts (multi-select, side-by-side), Recurrence + Age (single-select, side-by-side). Family surface also shows an "Owned by me only" switch.
3. **Header actions** — "Reset to defaults" text button (top-right) reverts the working copy to surface defaults.
4. **Sticky footer** — Cancel + Apply Changes. Apply is disabled until the working copy differs from the saved state.

**Working-copy + Apply pattern.** Edits in the sheet stage in a local working copy (`_working`) and commit only on Apply. Cancel discards. Fields whose working value differs from the surface default render with a 2-px green outline (mirroring `_ChangedFieldHighlight` from the Edit Task screen), so the user can see at a glance what they've changed.

**Persistence** is per-surface (`taskmaestro.listview.v1.<surface>`) and survives app restarts.

---

## Default behaviour per surface

| Surface | Group | Sort | Filter defaults |
|---|---|---|---|
| Tasks | `dueStatus` | `urgency` ascending | dueStatus = `{pastDue, urgent, target, normal}` (hides scheduled + completed) |
| Family | (mirrors Tasks) | (mirrors Tasks) | (mirrors Tasks) + `ownedByMeOnly: false` |
| Sprint | `dueStatus` | `urgency` ascending | empty filter set (= every bucket visible) |
| Plan | `dueStatus` | `urgency` ascending | empty filter set; plan-mode's 8-bucket sprint-history overlay is preserved (see limitations) |

---

## Architecture

### Data model (`lib/models/task_list_view.dart`)

Two **built_value** classes, both immutable, both with hand-rolled `toJson` / `fromJson` for SharedPreferences persistence:

- **`TaskFilters`** — composable filter state. Each axis defaults to "any" so an empty filter is pass-through. Axes:
  - Multi-select sets: `areas`, `contexts`, `dueStatus`.
  - Numeric bounds: `minPriority`/`maxPriority`, `minPoints`/`maxPoints`, `minDuration`/`maxDuration` (minutes).
  - `recurrence` (4-way enum: all / scheduled / completed / none).
  - `maxAgeDays` (preset chips).
  - `ownedByMeOnly` (Family only).
  - `search`.

- **`TaskListView`** — the per-surface view state. Holds `groupAxis`, `sortAxis`, `sortDirection`, `filters`, and `collapsedGroups`.

Six plain Dart enums: `TaskListSurface`, `TaskGroupAxis`, `TaskSortAxis`, `SortDirection`, `RecurrenceFilter`, `DueStatusBucket`. Enums are NOT routed through `serializers.dart` — the model files own their own `toJson` / `fromJson` so we don't have to convert every enum into a `BuiltValueEnum` (a precedent the codebase hasn't set yet).

### Persistence (`lib/features/shared/persistence/task_list_view_storage.dart`)

- One `SharedPreferences` key per surface: `taskmaestro.listview.v1.<surface>`.
- The `v1` version lives in the **key**, not inside the JSON, so a forward-incompatible schema change can stage `v2.*` keys while leaving `v1.*` intact for safe downgrades.
- JSON parse failures fall back to the surface default and log once via `dart:developer` — a corrupt payload can never crash the app.
- **Ghost names policy:** area / context multi-selects store the name string, not the docId, so a since-renamed-or-deleted entry still references the old name. The pipeline treats missing names as "filter still applied but matches nothing" (user sees an empty list). The persistence layer does not auto-scrub — scrubbing risks data loss if the catalog failed to load.

### Provider topology (`lib/features/shared/providers/task_list_view_providers.dart`)

- **`sharedPreferencesProvider`** is a `Future<SharedPreferences>` provider that calls `SharedPreferences.getInstance()`. Production `main.dart` pre-warms it before `runApp` so the future resolves on the first microtask. Tests pick it up automatically via `test/flutter_test_config.dart` (which initializes `TestWidgetsFlutterBinding` and seeds `setMockInitialValues({})`).
- **`taskListViewStateProvider`** is a family-keyed Riverpod notifier (one per `TaskListSurface`). `keepAlive: true` because the selections are stateful user data (TM-368 policy). Mutators emit new state and write through to storage via the in-process `TaskListViewStorage`.

### Pipeline (`lib/features/shared/logic/task_grouping.dart`)

Public surface:

- **`applyTaskFilters(tasks, filters, now, recentlyCompletedDocIds)`** — the filter step alone.
- **`groupAndSortTasks(tasks, view, now, areas, recentlyCompletedDocIds)`** — full filter → bucket → sort-within-bucket pipeline. Returns `List<TaskGroupResult>` with stable group keys (`due:urgent`, `area:Work`, `priority:3`, etc.) so collapse state survives axis flips.

**Urgency sort** (`_cmpUrgency`). The default sort across every surface. Bucket-aware:

- Tier by `_dueStatusBucketOf(task, now)` — past-due → urgent → target → normal → scheduled → completed.
- Within each tier, secondary keys per the bucket's date-priority semantics:
  - **Past Due**: `dueDate` ascending (most overdue first).
  - **Urgent**: `dueDate` ascending, then `urgentDate` ascending.
  - **Target**: `urgentDate` ascending, then `targetDate` ascending.
  - **Normal**: `targetDate` ascending, then `dateAdded` ascending.
  - **Scheduled**: `startDate` ascending.
  - **Completed**: `completionDate` descending (most recent first).
- Always returns ascending = "most urgent first"; `_sortBucket` flips for descending.

The tier prefix is a no-op when grouped by `dueStatus` (all tasks in a bucket share the tier) but interleaves correctly under `groupAxis: none` or any other group axis. The result: "Urgency" is meaningful whether the user has grouping on or off.

**Recently-completed bypass** (TM-323): when filtering by `dueStatus`, tasks in the recently-completed set are re-bucketed to their pre-completion bucket so a just-completed task doesn't visibly jump to "Completed" while the user is still looking at it.

### Per-surface plumbing

- **Tasks tab** (`lib/features/tasks/providers/task_filter_providers.dart`): `filteredTasksProvider` overlays surface gates (retired / family-shared / active-sprint hide) onto `applyTaskFilters`. `groupedTasksProvider` wraps `groupAndSortTasks`.
- **Family tab** (`lib/features/family/providers/family_task_filter_providers.dart`): legacy filter notifiers deleted; new `ownedByMeOnly` filter exposed.
- **Sprint tab** (`lib/features/sprints/presentation/sprint_task_items_screen.dart`): in-file filter notifiers deleted; `sprintGroupedTasksProvider` wraps the pipeline. Tiles are built inline so the user's group/sort axis takes effect.
- **Plan mode** (`lib/features/shared/presentation/plan_task_list.dart`): View Options sheet wired through; filters apply to the `TaskItem` subset before bucketing. Uses `ref.watch` (not `read`) on `taskListViewStateProvider` so applied filters trigger rebuild. The legacy duplicate `SprintPlanningScreen` was deleted as part of this work; "Create Sprint" now routes through `PlanTaskList`.

### UI components

- **`CollapsibleGroupHeader`** (`lib/features/shared/presentation/widgets/`) — section header with a leading chevron (animates 90° on collapse), task-count badge, and optional points-total badge (`{N} pts` when non-zero). Click area enlarged from the initial 3-px vertical padding to 10 px after touch-target feedback.
- **`AreaMultiPicker`** (deleted in favor of the unified multi-select in `ViewOptionsSheet`). Areas and Contexts share the same `_MultiSelectDropdown` widget — opens a chip-grid modal with `_SelectableChip` (pill, leading check, fill on select) instead of checkbox lists.
- **`ViewOptionsSheet`** (`lib/features/shared/presentation/`) — the per-surface View Options sheet. Working-copy + Apply pattern. Sticky bottom bar with Cancel / Apply Changes (theme `secondary` color for Apply). Header shows the title + a Reset-to-defaults action. Fields that differ from the surface default render with a 2-px green outline (`_ChangedFieldHighlight`, mirroring the Edit Task screen).
- **`ViewOptionsButton`** — the `Icons.tune` AppBar action. Overlays a small green dot when the saved view differs from defaults on any non-search axis. Shared by all four list surfaces.

---

## Side fixes landed alongside

The branch carries a handful of bug fixes that surfaced during manual testing of the new sheet. Worth calling out because they touch sync correctness:

### TM-367 round 2 — stale-anchor false-positive conflicts

**Symptom.** Editing a recurring task's date field produced a spurious recurrence conflict popup with no visible field diffs.

**Root cause.** `TaskRecurrenceDao.bulkUpsertFromRemote` (and its `TaskDao` sibling) skipped any pending row when the listener brought a server-confirmed update — preserving local pending content but also keeping `lastSyncedRemoteVersion` stuck at whatever it was before. If a prior listener fire arrived while the row happened to be in pendingUpdate, the anchor stayed stale. Next push: `_checkAndRecordConflict` re-read from server, saw a remote `lastModified` newer than the stale anchor, and recorded a conflict — even though this device's own earlier write produced that remote.

**Fix.** Both DAOs' `bulkUpsertFromRemote` now refresh `lastSyncedRemoteVersion` for pending rows when **both**:
1. The incoming remote's `lastModified` is strictly newer than the current anchor (at second precision), and
2. The local pending edit's `lastModified` is at least as recent as the incoming remote.

Rule (2) is the safety guard: a remote that's newer than *both* the anchor *and* the local pending edit represents a genuine cross-device write and must remain a conflict candidate. Three new tests in `test/core/database/task_dao_test.dart` cover the spurious-conflict case (anchor refreshes), the cross-device case (anchor stays stale), and a race against a parallel writer (WHERE clause guards `IS NULL OR < newRemote` so we never regress).

### Recurrence conflict dialog — Anchor row

`SyncConflictDetailDialog.recurrence` previously surfaced only Name / Recur every / Wait / Iteration. The anchor (which date drives the recurrence schedule — `due → urgent → target → start` priority) wasn't shown, so a recurrence diff caused purely by a task-date edit displayed with zero rows. Added an "Anchor" row formatted as `{dateType.label}: {date}` (e.g., `Urgent: 5/14/2026, 9:19 PM`).

### Edit screen startup race

`TaskAddEditScreen.didChangeDependencies()` was doing a one-shot `ref.read(taskProvider(id))` to look up the task. During the brief window between screen mount and Drift/Firestore hydration that returned `null`, the screen latched into "create new task / blank form" mode and never recovered. Moved the lookup into `build()` via `ref.watch`; while the task is still resolving the screen shows a loading spinner. New regression test in `task_add_edit_redesign_test.dart`.

### Contexts default-seed via task-list icon lookup

`contextIconLookupProvider` (read by every task-card pill row) used to route through the raw `contextsProvider`. New users with zero contexts wouldn't see the default-seed flow trigger until they visited Manage Contexts. Routed through `contextsWithDefaultsProvider` instead so the seed fires the first time anything renders task pills.

---

## Known v1 limitations

1. **Plan mode ignores Group/Sort axis selections.** Filter axes work; group/sort axes are no-ops. Root cause: plan mode renders a mix of `TaskItem` rows and synthesized `TaskItemRecurPreview` rows under the `SprintDisplayTask` interface, and the universal pipeline operates on `TaskItem` only. Migration to a polymorphic pipeline is a larger refactor than this PR carries.
2. **`TaskItemList` is orphaned.** No callers in `lib/`. Deletion deferred one PR cycle.
3. **`TaskDisplayGrouping` is now used only by plan mode.** Once #1 lands, this model class can also be deleted.
4. **`TaskItemRecurPreview` rows aren't user-filtered on plan mode** — they flow through unfiltered. Acceptable for v1.
5. **No custom age range** — preset chips only (Any / ≤7d / ≤30d / ≤90d).
6. **Group/sort selections don't persist across devices** — local-only via `shared_preferences`. Cross-device sync was an explicit scope decision; defer until there's a clearer user need.

---

## Persistence schema (v1)

```jsonc
// Stored as a single string per surface under key
// `taskmaestro.listview.v1.<surface>`.
{
  "groupAxis": "dueStatus",        // TaskGroupAxis.name
  "sortAxis": "urgency",           // TaskSortAxis.name
  "sortDirection": "ascending",
  "filters": {
    "areas": ["Work", "Home"],
    "contexts": ["Phone"],
    "dueStatus": ["urgent", "pastDue"],
    "minPriority": 2,              // omitted when null
    "maxPriority": 5,
    "minPoints": 1,
    "maxPoints": 8,
    "minDuration": 15,
    "maxDuration": 240,
    "recurrence": "scheduled",
    "maxAgeDays": 30,
    "ownedByMeOnly": false,
    "search": "demo"
  },
  "collapsedGroups": ["due:completed"]
}
```

**Forward-compatibility.** `fromJson` ignores unknown keys (returns the surface default for that field) and rejects unknown enum values silently. So a v2 schema can add keys freely; downgrading from v2 to v1 keeps reading the original v1 entry untouched (because v2 writes under `v2.*` keys).

**Legacy values.** Saved payloads from earlier branch commits with `"sortAxis": "dueStatus"` (the removed sentinel), `"startDate"`, or `"completionDate"` fall back to the surface default (`urgency`) via `_byNameOr`. The legacy `"showScheduled"` / `"showCompleted"` boolean toggles were removed in favor of the `dueStatus` whitelist — old payloads with those keys are silently ignored.

---

## Test coverage

End-of-PR: **822 tests passing**, `flutter analyze` clean at the 23-issue info-only baseline.

Highlights:

| Layer | File | Coverage |
|---|---|---|
| Models | `test/models/task_list_view_test.dart` | Defaults per surface, JSON round-trip including new duration fields, graceful degradation |
| Persistence | `test/features/shared/persistence/task_list_view_storage_test.dart` | Round-trip, clear, malformed-payload fallback, per-surface key isolation |
| Provider | `test/features/shared/providers/task_list_view_provider_test.dart` | Every mutator path, cross-container rehydration, per-surface independence |
| Pipeline | `test/features/shared/logic/task_grouping_test.dart` | Every filter axis (incl. duration bounds), every group axis, urgency sort across all six tiers, recently-completed bypass |
| UI | `test/widgets/collapsible_group_header_test.dart`, `test/features/shared/presentation/view_options_sheet_test.dart` | Renders, taps, points-total badge, surface-conditional Owned-by-me, Apply/Cancel commit semantics |
| Sync correctness | `test/core/database/task_dao_test.dart` | TM-367 stale-anchor refresh, cross-device-divergence guard, race-against-parallel-writer guard |
| Edit screen | `test/features/tasks/presentation/task_add_edit_redesign_test.dart` | Loading-state-during-startup-race regression test |

---

## Commit map

The PR lands as a foundation (commits 1–10) plus follow-up iteration rounds (commits 11+). Each commit leaves the test suite green.

**Foundation (1–10):**

1. TaskListView + TaskFilters models + serializers
2. SharedPreferences provider + storage + per-surface family provider
3. `groupAndSortTasks` pipeline + comprehensive unit tests
4. `CollapsibleGroupHeader` + `AreaMultiPicker` + `ViewOptionsSheet` widgets
5. Tasks tab uses TaskListView (plus the major architecture pivot to async-prefs + `flutter_test_config.dart`)
6. Family tab uses TaskListView
7. Sprint tab uses TaskListView (drops `TaskItemList`, sprint-assignment-order preserved via sort sentinel)
8. Plan mode wires View Options sheet + filters (group/sort deferred — see limitations)
9. Delete `FilterButton` (now dead)
10. Initial design doc

**Iteration (11+):**

11. Sheet UX revision per review notes (sticky bar, side-by-side dropdowns, multi-select consolidation, Reset action)
12. Trigger context default-seed from the task-list icon lookup
13. Round 2: status-bar SafeArea, theme colors match app, chip-style multi-select, Min/Max validation, Points "Other" custom input
14. Round 3: add Estimated Time filter + sort relabel, Apply Changes uses secondary color, filter row order, side-by-side Area/Contexts and Recurrence/Age, Reset-to-defaults header button
15. Round 4: enlarged group headers + points-total badge, green-outline on non-default fields, Apply Changes gated on dirty, plan-mode filter button restored, green badge on filter button, deleted orphaned `SprintPlanningScreen`, plan-mode filter wired via `ref.watch`, Sprint default group = Due Status
16. Urgency sort: new `TaskSortAxis.urgency` bucket-aware comparator, set as default across all surfaces, removed legacy `dueStatus` sentinel + `startDate` + `completionDate` enum values
17. Sync correctness: TM-367 round 2 stale-anchor refresh (TaskDao + TaskRecurrenceDao), Anchor row in recurrence conflict dialog, edit-screen startup race fix, this design doc refresh

Reviewer can stop after any commit and the app is still green.
