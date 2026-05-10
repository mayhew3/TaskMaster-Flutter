# Design: Contexts: Tier 1

**JIRA Epic:** [TM-181](https://mayhew3.atlassian.net/browse/TM-181)
**Branch:** `TM-181-contexts-tier-1`
**Status:** 🚧 IMPLEMENTATION COMPLETE — pending user verification + tests

## Goal

Replace the single hardcoded `context: String?` per task with a user-defined, multi-select **per-person** Contexts collection. Tier 1 ships the **full schema shape** (`{name, value?}` per assignment) but only exposes the name-selection UX; numeric weights, scoring, family-sharing, per-context colours, and hierarchy are deferred to Tier 2 / 3 — but **only at the UI layer**, never the schema.

The schema-from-day-one principle is the key trade-off: the Epic description explicitly says *"design the DB so that it makes sense to add it later"* and *"make the number optional. It can either be a boolean tag, or a tag with a degree on it."* Migrating from `List<String>` → `List<{name, value?}>` later would require rewriting every Firestore task doc, backfilling local Drift rows, and shipping a deserialization fallback for the legacy shape. Shipping the object shape now makes Tier 2 purely additive (UI for the value field only) — no schema migration, no fallback logic.

By the end of this Epic:
- Each task carries 0+ contexts (was: 0 or 1).
- Schema stores each context as `{name, value: int?}`. Tier 1 always sets `value: null`; Tier 2 adds the UI to set it.
- Users have a "Manage Contexts" screen to add / remove / rename / reorder their contexts.
- The task edit screen swaps the hardcoded picker for a multi-select bottom sheet sourced from the user's Contexts collection.
- Existing tasks with a single `context` value migrate cleanly to the new list shape with `value: null`.

## Architecture

### Current state

- **Domain:** `TaskItem.context: String?` (single value), with corresponding mutable field on `TaskItemBlueprint` and `TaskItemRecurPreview`.
- **Drift column:** `Tasks.taskContext` (renamed from `context` to avoid colliding with `BuildContext` imports).
- **Firestore field:** `context` (json_serializable inferred; no manual mapping).
- **Picker source:** hardcoded list in `lib/features/tasks/presentation/task_add_edit_screen.dart:75-84` — `[Computer, Home, Office, E-Mail, Phone, Outside, Reading, Planning]`. No other reference.
- **Display:** `_ExpandedRow(label: 'CONTEXT', value: ctx)` in the expanded panel of `editable_task_item.dart`. No filter / grouping uses `context` yet.
- **Schema version:** Drift `schemaVersion = 7` (last migration was TM-358's `priorityScaleVersion` column).

### Target state — mirrors the TM-345 Areas migration

The Areas Epic (TM-345) already migrated a hardcoded `project: String` field to a per-person `Areas` Firestore collection. Tier 1 of Contexts is structurally identical, so we copy that pattern verbatim:

| Areas (existing)                                  | Contexts (this Epic)                              |
|---------------------------------------------------|---------------------------------------------------|
| `lib/models/area.dart` — `Area` domain model      | `lib/models/context.dart` — `Context` model       |
| `Areas` Drift table (per-person)                  | `Contexts` Drift table (per-person)               |
| `AreaDao` with `watchAreasForUser` / pending state | `ContextDao` mirroring the same DAO surface        |
| `AreaService` (create / rename / delete / reorder) | `ContextService` (same surface)                    |
| `areasProvider` + `areasWithDefaultsProvider`     | `contextsProvider` + `contextsWithDefaultsProvider` |
| `AreaPicker` — single-select chevron + sheet      | `ContextPicker` — **multi-select** pills + sheet  |
| `AreaManageScreen` — reorderable list             | `ContextManageScreen` — same shape                 |
| `tasks.area: String?` (refers to `Area.name`)     | `tasks.contexts: List<String>` (refers to `Context.name`) |

The chief shape difference: a task references **multiple** context names instead of one. We store a JSON-encoded list in Drift (TEXT column) and a Firestore array. References are by **name**, not docId — same loose coupling Areas uses, so renaming a context is purely cosmetic and doesn't require backfill.

### Why per-person and not family-shared (yet)

The original Epic description hints at a future "explicitly public, opt-in" sharing model. That's substantially more design work (visibility states, opt-in/opt-out flows, family-vs-personal merge in the picker). Tier 1 stays per-person to match Areas and ship a usable foundation; Tier 2 introduces the public/shareable layer once we have one round of Tier-1 usage feedback.

## Implementation Plan

### Story 1 — TM-226: DB schema + multi-context model

**The keystone migration.** Lands first; everything else depends on it.

- **New `TaskContext` value object** (`lib/models/task_context.dart`) — the per-task representation:
  ```dart
  class TaskContext {
    final String name;   // references Context.name (loose coupling)
    final int? value;    // optional numeric weight; Tier 1 always null
    const TaskContext({required this.name, this.value});
  }
  ```
  Tier 1 always sets `value: null`; Tier 2 adds the UI to set it. Storing the object shape now means Tier 2 is purely additive UI work — no Firestore-doc rewrite, no Drift backfill, no deserialization fallback.
- **New `Contexts` Drift table** (the catalog — mirror of `Areas`):
  ```dart
  class Contexts extends Table {
    TextColumn get docId => text()();
    DateTimeColumn get dateAdded => dateTime()();
    TextColumn get name => text()();
    IntColumn get sortOrder => integer()();
    TextColumn get personDocId => text()();
    TextColumn get retired => text().nullable()();
    DateTimeColumn get retiredDate => dateTime().nullable()();
    DateTimeColumn get lastModified => dateTime().nullable()();
    TextColumn get conflictRemoteJson => text().nullable()();
    TextColumn get syncState => text().withDefault(const Constant('synced'))();
    @override Set<Column> get primaryKey => {docId};
  }
  ```
  Note: the catalog `Context` model itself is just `{docId, name, sortOrder, personDocId, ...}` — it does NOT carry a `value`. The numeric weight is per-assignment (lives on `TaskContext`), not per-catalog-entry. Per-catalog colours and per-context scale customization come in later tiers.
- **`tasks` table**: rename `taskContext` → `taskContexts`, store a JSON-encoded `List<TaskContext>` (`[{"name":"Phone","value":null},{"name":"Office","value":null}]`). NULL or empty list both mean "no contexts."
- Schema bumped to **v8**. Migration:
  ```dart
  if (from < 8) {
    await m.createTable(contexts);
    await customStatement('ALTER TABLE tasks RENAME COLUMN task_context TO task_contexts');
    // No row-level UPDATE needed: the new converter accepts both shapes
    // on read — a bare-string legacy value becomes
    // [{name:<string>, value:null}], and the JSON-array shape passes
    // through. Subsequent writes use the new shape.
  }
  ```
- **Domain models**: `TaskItem.context: String?` → `TaskItem.contexts: BuiltList<TaskContext>` (empty list when none). `TaskItemBlueprint.context` → `TaskItemBlueprint.contexts: List<TaskContext>`. Same on `TaskItemRecurPreview`.
- Built_value codegen rerun (`flutter pub run build_runner build --delete-conflicting-outputs`).
- **Firestore**: array field `contexts` of maps `{name, value}`. Legacy single-string `context` field stays readable for one release cycle via a deserialization fallback that wraps a bare string into `[{name: <string>, value: null}]` — same pattern Areas used during the project→area transition.
- `lib/features/shared/presentation/editable_task_item.dart`: the expanded-panel CONTEXT row renders the joined names (Tier 1 ignores `value`); e.g. "Phone · Office". Empty list → row hidden.
- `lib/core/database/converters.dart`: add a JSON `List<TaskContext>` ↔ Drift TEXT converter that handles both the new shape and the legacy bare-string fallback.

**Acceptance:**
- Existing tasks with `context: "Phone"` survive migration with `contexts: [TaskContext(name: "Phone", value: null)]`.
- New tasks default to empty list.
- A Firestore doc still carrying the legacy singular `context` field reads cleanly via the fallback.
- Schema v8 migration runs cleanly on a v7 database.
- `flutter analyze` clean; `flutter test` passes (existing context-related tests updated for the new field shape; new tests for the legacy-fallback read path).

**Files:**
- `lib/models/task_context.dart` (new)
- `lib/core/database/tables.dart`, `app_database.dart`, `converters.dart`
- `lib/models/task_item.dart`, `task_item_blueprint.dart`, `task_item_recur_preview.dart`
- `lib/features/shared/presentation/editable_task_item.dart` (display only)

### Story 2 — TM-225: View list of contexts (Manage Contexts screen)

The "destination" screen the user lands on from a settings menu / drawer entry. Mirrors `AreaManageScreen`.

- New `lib/models/context.dart` — `Context` value object: `docId`, `name`, `sortOrder`, `personDocId`, `dateAdded`.
- New `lib/features/contexts/services/context_service.dart` — create / rename / delete / reorder. Reserved names + duplicate-name guards (`DuplicateContextNameException`, `ReservedContextNameException`).
- New `lib/core/database/daos/context_dao.dart` — `watchContextsForUser`, `getContextsForUser`, plus the standard pending-sync mutations.
- New `lib/features/contexts/providers/context_providers.dart` — `contextsProvider`, `contextsWithDefaultsProvider` (lazy-seeds defaults if empty + initial pull complete).
- Defaults seeded for new users on first read: same set we currently hardcode (`Computer, Home, Office, E-Mail, Phone, Outside, Reading, Planning`) — preserves continuity for new accounts.
- New `lib/features/contexts/presentation/context_manage_screen.dart` — `ReorderableListView` with rename / delete dialogs.
- Hook the screen up via the app drawer (next to "Manage Areas").

**Acceptance:**
- Screen lists the user's contexts in `sortOrder`.
- Stream-driven: edits in the service surface immediately.
- Drag-to-reorder rewrites every row's `sortOrder`.
- New users see the 8 defaults on first load.

### Story 3 — TM-227: Add context from Manage screen

- Inline add field on the Manage screen — same dashed-border `+ Add new context…` pattern AreaPicker uses (`_InlineAddAreaField` in `area_picker.dart:365`+).
- Validation: trimmed name non-empty, not duplicate (case-insensitive), not reserved. Errors render inline below the field, not in a dialog.
- Submit creates the context with the next-available `sortOrder` (max+1).

**Acceptance:**
- Tap the dashed-border field, type a name, hit Enter or the Add button → context appears at the bottom of the list.
- Duplicate / reserved / empty names render an inline error and don't create.

### Story 4 — TM-228: Remove context from Manage screen

- Each row gets a trailing trash icon (or swipe-to-delete) → confirm dialog → soft-delete via `ContextService.deleteContext()` (sets `retired` + `retiredDate`).
- Removing a context does **NOT** touch tasks that reference it by name. Those tasks keep the orphan name in their `contexts` list, displayed normally in the expanded card. The picker just won't offer it as a choice anymore.
- Discoverability: rename via long-press OR an inline pencil icon — match whatever AreaManageScreen does.

**Acceptance:**
- Confirm dialog gates the delete.
- Deleted context disappears from the picker on the edit screen but still renders on tasks that referenced it.
- Soft-delete is undoable via Firestore (the row is just `retired`-stamped, not removed).

### Story 5 — TM-230: Multi-select pills on task edit

The big UX piece. Replace `_ContextPickerButton` (single-select chevron + sheet) with a multi-select pills row.

- New `lib/features/contexts/presentation/context_picker.dart` (or extend AreaPicker's pattern):
  - The card body shows zero-or-more context pills (uses the existing `Pill` widget from TM-358 — `lib/features/shared/presentation/widgets/pill.dart`).
  - A trailing `+` chip (dashed border) opens the bottom sheet.
  - Bottom sheet lists the user's contexts; each row toggles inclusion (checkmark on already-selected ones).
  - Tap a selected pill on the card → removes it (with subtle confirm via long-press? or just instant remove — match the design language).
  - Inline `+ Add new context…` field at the bottom of the sheet (per Story 3) so users can create a context mid-task-edit.
- The hardcoded `possibleContexts` list in `task_add_edit_screen.dart` deletes; the screen now reads `contextsWithDefaultsProvider`.

**Acceptance:**
- Adding a context from the sheet appends to the task's `contexts` list and dismisses the sheet (or stays open for multi-add — TBD spot-check).
- Removing a pill removes it from the task's `contexts` list immediately.
- The Save button re-enables when contexts change (the `_hasChanges()` getter compares list contents).
- Adding a brand-new context inline from the sheet creates the context in the user's collection AND adds it to the current task's list.

### Story 6 — TM-229: Add new context from task edit (covered by Story 5)

The Jira description for TM-229 is "When viewing contexts to add to task, have Add New Context option that brings a new popup where you can name it." That's exactly the inline `+ Add new context…` field at the bottom of the picker sheet from Story 5. Treat TM-229 as the acceptance for that sub-feature; mark it Done when Story 5's inline-add path lands and is tested.

## Key Decisions

- **Per-person scope, not family-shared.** Matches Areas; defers the public/private/sharing complexity to Tier 2.
- **Reference contexts by name, not docId.** Same loose-coupling Areas use. Renaming a context is cosmetic; orphan references survive deletion. This is what makes the Tier-2 sharing migration tractable later.
- **Schema includes the optional value field from day one.** Numeric weights are central to the Epic's vision (`{Descriptor, Number}` tags), and migrating from `List<String>` to `List<{name, value?}>` later would require rewriting every Firestore task doc plus a deserialization fallback for the legacy shape. Shipping the object shape now keeps Tier 1 small (UI exposes name only) while making Tier 2 purely additive.
- **JSON-encoded TEXT column for `tasks.contexts`** rather than a join table. Keeps Drift mirror simple and matches Firestore's array shape. Acceptable because we always read the full list per task; we never query "tasks where Phone is in contexts" (yet).
- **Schema v8 migration** is purely additive (new table + column rename). No row-level data movement; the converter handles legacy bare-string values on read.
- **Defaults seeded for new users only** via `contextsWithDefaultsProvider`. Existing users with a `context` value already keep that value through migration; new accounts get the 8-item starter list.

## Visual: prototype-aligned icons (added during planning)

Late in plan-mode review the user surfaced the Claude Design prototype at `~/Downloads/TaskMaestro Redesign-handoff.zip` (extracted to `C:\tmp\tm-358-design\taskmaestro-redesign\project\`). The prototype's `ContextsPicker` (edit.jsx:284-337) and `ContextIcon` (cards.jsx:47-69) drove three additional Tier-1 decisions:

- **`iconName: String?` column on the `Contexts` catalog table.** Closed icon set in code (~14 built-in glyphs keyed by canonical lowercase name: phone, email, computer, home, office, outside, reading, planning, people, errand, car, shopping, writing, anywhere). User-created contexts default to `null` until the Tier-2 icon-picker UI lands. Default seeds get an `iconName` mapped to the closed set so new users see icons immediately.
- **Task-list card meta row renders the context icons.** `editable_task_item.dart` `_metaRow` now inserts an icons-only cluster between the area badge and the time/priority/points block. Resolution happens at render time off `contextsProvider` so user-renamed-but-still-iconned contexts keep their glyph; bare names without a catalog match silently drop out of the cluster.
- **Picker bottom sheet uses a 2-column grid showing only REMAINING contexts.** Already-selected contexts don't appear (mirrors the prototype's hide-already-selected behaviour). An inline "+ Add new context…" field at the bottom of the sheet creates AND selects the new context in one tap, satisfying TM-229.

Implementation lives in `lib/features/shared/presentation/widgets/context_icon.dart` (icon widget), `lib/features/contexts/presentation/context_picker.dart` (picker + sheet), and the `_metaRow` / `_areaLabel` updates in `lib/features/shared/presentation/editable_task_item.dart`.

## Out of scope (UI only — schema-from-day-one principle)

The schema lands fully shaped in Tier 1 (per the Key Decisions section). What's deferred is the *UI surface* for these features, not their data model:

- **UI to set numeric values on contexts** ("Difficult: 3", "Scary: 7"). Schema slot is in place (`TaskContext.value: int?`); Tier 2 just adds the picker UI.
- **User-defined scoring formulas** across multiple contexts.
- **Public / shareable contexts; opt-in / opt-out.** New `Context.visibility` enum field comes in Tier 2 — no migration since it'll default `private`.
- **Per-context colours.** Stored on the `Context` catalog model — added in Tier 2 with a default colour, no migration.
- **Hierarchical contexts.**
- **Filtering / grouping the task list by context (and by context value).**

## References

- TM-345 (Areas migration, the closest pattern) — `lib/features/areas/`
- TM-358 (Edit Task redesign — Pill widget, dashed-border inline-add) — `lib/features/shared/presentation/widgets/pill.dart`, `lib/features/areas/presentation/area_picker.dart`
- Drift migration history: `lib/core/database/app_database.dart` v6→v7 sets the precedent for additive column adds.

---
**Created:** 2026-05-09
**Last Updated:** 2026-05-09
