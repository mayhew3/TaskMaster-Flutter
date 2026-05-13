# DESIGN: TM-359 — Group / Sort / Filter for task lists

**JIRA:** [TM-359](https://mayhew3.atlassian.net/browse/TM-359)
**PR:** TM-359-group-sort-filter-options branch
**Status:** Shipped (this PR)
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

Each list surface gets an `Icons.tune` button in the app bar. Tapping it opens the **View Options** bottom sheet with three sections:

1. **Group by** — `Due Status` (default) / `None` / `Priority` / `Area` / `Points` / `Duration`.
2. **Sort by** — `Default` (= bucket-natural sort) / `Date Added` / `Points` / `Area` / `Duration` / `Priority` / `Efficiency` / `Start Date` / `Completion Date`, plus an ascending/descending toggle.
3. **Filter by** — search; multi-select areas + contexts + due-status buckets; range bounds on priority and points; recurrence mode (any / scheduled / completed / none); age preset (any / ≤7d / ≤30d / ≤90d); legacy `Show Scheduled` and `Show Completed` toggles; Family-only `Owned by me only`.
4. **Footer** — Expand All (when groups are collapsed), Reset to defaults.

Selections persist across app restarts and are scoped per surface, so toggling on Tasks doesn't affect Sprint.

---

## Architecture

### Data model (`lib/models/task_list_view.dart`)

Two **built_value** classes, both immutable, both with hand-rolled `toJson` / `fromJson` for SharedPreferences persistence:

- **`TaskFilters`** — composable filter state. Each axis defaults to "any" so an empty filter is pass-through. Axes: `areas` (multi-select), `contexts` (multi-select), `dueStatus` (multi-select), `minPriority`/`maxPriority`, `minPoints`/`maxPoints`, `recurrence` (4-way enum), `maxAgeDays`, `ownedByMeOnly` (Family only), `search`, legacy `showScheduled` / `showCompleted` toggles.
- **`TaskListView`** — the per-surface view state. Holds `groupAxis`, `sortAxis`, `sortDirection`, `filters`, and `collapsedGroups` (set of group keys). Factory constructors per surface (`TaskListView.tasksDefault()`, `.familyDefault()`, `.sprintDefault()`, `.planDefault()`) encode the pre-TM-359 defaults so the user opens the sheet to a recognizable starting point.

Five plain Dart enums cover the axes: `TaskListSurface`, `TaskGroupAxis`, `TaskSortAxis`, `SortDirection`, `RecurrenceFilter`, `DueStatusBucket`. Enums are NOT routed through the `serializers.dart` registry — the model files own their own `toJson` / `fromJson` so we don't have to convert every enum into a `BuiltValueEnum` (a precedent the codebase hasn't set yet).

### Persistence (`lib/features/shared/persistence/task_list_view_storage.dart`)

- One `SharedPreferences` key per surface: `taskmaestro.listview.v1.<surface>`.
- The `v1` version lives in the **key**, not inside the JSON, so a forward-incompatible schema change can stage `v2.*` keys while leaving `v1.*` intact for safe downgrades.
- JSON parse failures fall back to the surface default and log once via `dart:developer` — a corrupt payload can never crash the app.
- **Ghost names policy:** area / context multi-selects store the name string, not the docId, so a since-renamed-or-deleted entry still references the old name. The pipeline treats missing names as "filter still applied but matches nothing" (user sees an empty list). `AreaMultiPicker` renders ghost names with a strike-through and a clear-✕, giving the user an explicit path to remove the dead filter. The persistence layer does **not** auto-scrub — scrubbing risks data loss if the catalog failed to load.

### Provider topology (`lib/features/shared/providers/task_list_view_providers.dart`)

- **`sharedPreferencesProvider`** is a `Future<SharedPreferences>` provider that calls `SharedPreferences.getInstance()`. Production `main.dart` pre-warms it before `runApp` so the future resolves on the first microtask. Tests pick it up automatically via `test/flutter_test_config.dart` (which initializes `TestWidgetsFlutterBinding` and seeds `setMockInitialValues({})`).
- **`taskListViewStateProvider`** is a family-keyed Riverpod notifier (one per `TaskListSurface`). `keepAlive: true` because the selections are stateful user data (TM-368 policy). Mutators emit new state and write through to storage via the in-process `TaskListViewStorage`.
- The build path uses `ref.read` (not `ref.watch`) on `sharedPreferencesProvider` so the Loading→Data transition doesn't re-fire build and stomp user mutations. Initial state is the surface default; once prefs resolves, the microtask either loads from storage (state still equals default → safe to overwrite) or persists the current state (state diverged → preserve the user's in-flight mutation).

### Pipeline (`lib/features/shared/logic/task_grouping.dart`)

Public surface:

- **`applyTaskFilters(tasks, filters, now, recentlyCompletedDocIds)`** — the filter step alone. Per-surface "filteredTasks" providers call this directly so a flat list comes out the other side without paying for grouping.
- **`groupAndSortTasks(tasks, view, now, areas, recentlyCompletedDocIds)`** — full filter → bucket → sort-within-bucket pipeline. Returns `List<TaskGroupResult>` with stable group keys (`due:urgent`, `area:Work`, `priority:3`, etc.) so collapse state survives axis flips.

The recently-completed bypass (TM-323) is honored: when `showCompleted=false`, tasks in the recently-completed set still pass the filter, and when grouped by `dueStatus` they stay in their *pre-completion* bucket (not "Completed") until the next list refresh.

The `dueStatus` sort axis is a sentinel meaning "use the bucket's natural sort":
- Under `dueStatus` group axis: Scheduled ascends by `startDate`, Completed descends by `completionDate`, others preserve insertion order (matches pre-TM-359 behavior exactly).
- Under any other group axis: preserves input order, so the Sprint surface keeps TM-339's stable sprint-assignment ordering.

### Per-surface plumbing

- **Tasks tab** (`lib/features/tasks/providers/task_filter_providers.dart`): `filteredTasksProvider` overlays surface gates (retired / family-shared / active-sprint hide) onto `applyTaskFilters`. `groupedTasksProvider` wraps `groupAndSortTasks`. Three legacy facades — `showCompletedProvider` / `showScheduledProvider` / `searchQueryProvider` — keep reading/writing through the new state so `sprint_providers.dart`, `navigation_provider.dart`, and a handful of integration tests don't need a one-giant-cross-feature touch-up.
- **Family tab** (`lib/features/family/providers/family_task_filter_providers.dart`): four legacy notifiers deleted outright (no external callers). Adds the new `ownedByMeOnly` Family-specific filter.
- **Sprint tab** (`lib/features/sprints/presentation/sprint_task_items_screen.dart`): two in-file notifiers deleted, new `sprintGroupedTasksProvider` wraps the pipeline. The screen drops its indirection through the legacy `TaskItemList` widget; tiles are built inline so the user's group/sort axis takes effect.
- **Plan mode** (`lib/features/shared/presentation/plan_task_list.dart`): the View Options sheet wires through and filters apply to the TaskItem subset before bucketing. The existing 8-bucket sprint-history-aware grouping is intentionally preserved (see "Known v1 limitations" below).

### UI components

- **`CollapsibleGroupHeader`** (`lib/features/shared/presentation/widgets/`) — replacement for `HeadingItem` with a leading chevron (animates 90° on collapse), trailing count badge, and tap-to-collapse. Drop-in compatible: pass `onTap: null` and it renders identically to the old heading.
- **`AreaMultiPicker`** (`lib/features/areas/presentation/`) — multi-select Area picker mirroring `ContextPicker`'s shape (chips + AddPill + modal bottom sheet with checkboxes). Stages mutations locally and commits on Done so fast multi-selects don't trigger N parent rebuilds. Ghost-area names render with strike-through + remove-✕.
- **`ViewOptionsSheet`** (`lib/features/shared/presentation/`) — the unified Group/Sort/Filter sheet. Single entry point per list surface (`Icons.tune` button). Edits the per-surface `taskListViewStateProvider` directly: every tap writes through SharedPreferences and the list rebuilds in real time, no Apply button. Surface-conditional: the `Owned by me only` switch only renders for `TaskListSurface.family`.

---

## Known v1 limitations (filed as follow-ups)

1. **Plan mode ignores Group/Sort axis selections.** The `Icons.tune` button is wired and **Filter** axes work on the plan screen, but `groupAxis` and `sortAxis` from the View Options sheet are no-ops on plan mode. Root cause: plan mode renders a mix of `TaskItem` rows and synthesized `TaskItemRecurPreview` rows under the `SprintDisplayTask` interface. The universal pipeline operates on `TaskItem` only; migrating it to handle `SprintDisplayTask` polymorphically is a larger refactor than this PR carried. The plan-mode 8-bucket sprint-history-aware grouping stays as the hardcoded default.

2. **`TaskItemList` is now orphan code.** The Sprint screen used to render through `TaskItemList`; commit 7 swapped to inline tile-building. Nothing in `lib/` references `TaskItemList` anymore. Deleted as a small follow-up (kept here for one PR cycle so the diff is reviewable).

3. **`TaskDisplayGrouping` is now used only by plan mode.** Once #1 lands, this model class can also be deleted.

4. **Legacy filter facades.** `ShowCompleted` / `ShowScheduled` / `SearchQuery` in `task_filter_providers.dart` are still around as facades over the new state. They have <10 remaining callers (`sprint_providers.dart`, `navigation_provider.dart`, three integration tests). Once those are migrated, the facades can be deleted.

5. **`TaskItemRecurPreview` rows aren't user-filtered on plan mode.** They flow through unfiltered. Acceptable for v1 since previews are forward-looking — but the filter pipeline could be extended to operate over `SprintDisplayTask` in the same refactor as #1.

6. **No custom age range.** v1 ships preset chips only (Any / ≤7d / ≤30d / ≤90d). A custom-days input was out of scope.

7. **Group/sort selections don't persist across devices.** Local-only via `shared_preferences`. Cross-device sync (Firestore user_preferences) was an explicit scope decision in planning — defer to a follow-up when there's a clearer user need.

---

## Persistence schema (v1)

```jsonc
// Stored as a single string per surface under key
// `taskmaestro.listview.v1.<surface>`.
{
  "groupAxis": "dueStatus",        // TaskGroupAxis.name
  "sortAxis": "dateAdded",         // TaskSortAxis.name
  "sortDirection": "descending",   // SortDirection.name
  "filters": {
    "areas": ["Work", "Home"],
    "contexts": ["Phone"],
    "dueStatus": ["urgent", "pastDue"],  // DueStatusBucket.name list
    "minPriority": 2,            // omitted when null
    "maxPriority": 5,
    "minPoints": 1,
    "maxPoints": 8,
    "recurrence": "scheduled",
    "maxAgeDays": 30,
    "ownedByMeOnly": false,
    "search": "demo",
    "showScheduled": false,
    "showCompleted": false
  },
  "collapsedGroups": ["due:completed"]
}
```

**Forward-compatibility:** `fromJson` ignores unknown keys (returns the surface default for that field) and rejects unknown enum values silently (falls back to default). Unknown JSON shapes return the whole surface default. So a v2 schema can add keys freely; downgrading from v2 to v1 keeps reading the original v1 entry untouched (because v2 writes under `v2.*` keys).

---

## Test coverage

| Layer | File | Notes |
|---|---|---|
| Models | `test/models/task_list_view_test.dart` | 16 tests — defaults, mutation, JSON round-trip, graceful degradation paths |
| Persistence | `test/features/shared/persistence/task_list_view_storage_test.dart` | 6 tests — round-trip, clear, malformed-payload fallback, per-surface key isolation |
| Provider | `test/features/shared/providers/task_list_view_provider_test.dart` | 11 tests — every mutator path, cross-container rehydration, per-surface independence, override semantics |
| Pipeline | `test/features/shared/logic/task_grouping_test.dart` | 25 tests — every filter axis, every group axis, key sort axes, plan-mode-overlay branching, recently-completed bypass |
| UI | `test/widgets/collapsible_group_header_test.dart`, `test/features/areas/area_multi_picker_test.dart`, `test/features/shared/presentation/view_options_sheet_test.dart` | 9 widget tests covering rendering, taps, and the surface-conditional Owned-by-me switch |
| Test infra | `test/flutter_test_config.dart` | Initializes `TestWidgetsFlutterBinding` once per test file + seeds `SharedPreferences.setMockInitialValues({})`. Tests that need state isolation between cases call `(await SharedPreferences.getInstance()).clear()` in setUp. |

End-of-PR: **813 tests passing**, `dart analyze` clean at the 24-issue info-only baseline.

---

## Commit map

The PR lands as 10 commits, each leaving the test suite green:

1. TaskListView + TaskFilters models + serializers
2. SharedPreferences provider + storage + per-surface family provider
3. `groupAndSortTasks` pipeline + comprehensive unit tests
4. `CollapsibleGroupHeader` + `AreaMultiPicker` + `ViewOptionsSheet` widgets
5. Tasks tab uses TaskListView (plus the major architecture pivot to async-prefs + `flutter_test_config.dart`)
6. Family tab uses TaskListView
7. Sprint tab uses TaskListView (drops `TaskItemList`, sprint-assignment-order preserved via sort sentinel)
8. Plan mode wires View Options sheet + filters (group/sort deferred — see limitations)
9. Delete `FilterButton` (now dead)
10. This design doc

Reviewer can stop after any commit and the app is still green.
