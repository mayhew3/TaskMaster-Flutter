# Design: Web Interface Tier 1 — Wide / Responsive Layout

**JIRA Epic**: [TM-188](https://mayhew3.atlassian.net/browse/TM-188)
**Design umbrella**: [TM-354](https://mayhew3.atlassian.net/browse/TM-354) (kept open; this doc + the stories are its decomposition)
**Branch**: TM-188-web-interface-tier-1
**Status**: 🚧 IN PROGRESS

## Goal

Give TaskMaestro a polished large-screen (web / tablet / large Android) layout. Today every device renders the phone-shape single column; on wide screens it just stretches and wastes space. Adopt **Direction A — Navigation-forward (Sidebar)**: an adaptive shell that, above a width breakpoint, splits into a persistent left navigation **sidebar**, a center **task list** (calm max-width column), and a contextual **right pane** (docked editor / View Options panel / empty state). Phone is untouched. Visuals are reused verbatim from the already-shipped phone redesign (V9 card, editor widgets, brand-blue chrome, theme tokens).

**Design source of truth:** Claude Design handoff bundle `TaskMaestro Redesign-handoff(1)` — `TaskMaestro Wide.html` + `wide-chrome.jsx` / `wide-screens.jsx` / `wide-editor.jsx` / `wide-view-options.jsx`. Recreate those visuals pixel-faithfully in Flutter; reuse existing widgets/tokens, do not re-derive a new look.

## Architecture

### Current State

- **Root shell:** `lib/riverpod_app.dart` — `_AuthenticatedHome` / `_AuthenticatedHomeState` (≈342–525). Owns a Material 3 `NavigationBar` (bottom), builds `_navItems` (Plan → `PlanningHome`, Tasks → `TaskListScreen`, Stats → `StatsScreen`; Family spliced when in a family), renders `Column[ PendingInvitationBanner, SyncConflictBanner, Expanded(tabBody) ]`. Tab index = `activeTabIndexProvider` (`ActiveTabIndex`, `lib/features/shared/providers/navigation_provider.dart`, `keepAlive`, `setTab` / `clampToLayout`).
- **Breakpoint helper:** `lib/core/platform/form_factor.dart` — `kPhoneShortestSideBreakpoint = 600.0`, `isPhoneFormFactor(Size)`, `shouldLockPortrait({isWeb, logicalSize})`. TM-371 already locks phones to portrait; tablets/web are unlocked. **No UI consumes a wide breakpoint yet** — only one `LayoutBuilder` exists in the whole presentation layer (`date_timeline_popup.dart`); no two-pane / master-detail / orientation logic anywhere.
- **Task list:** `lib/features/tasks/presentation/task_list_screen.dart` — `TaskListScreen` + `_TaskListBody` (135–379). Watches `groupedTasksProvider` (`task_filter_providers.dart`), renders `CollapsibleGroupHeader` (`widgets/collapsible_group_header.dart`) sections + an active-sprint banner (`_buildSprintBanner`, 268–342). Detail = inline accordion via `expandedTaskProvider` (`ExpandedTask`, `expanded_task_provider.dart`).
- **Editor:** `lib/features/tasks/presentation/task_add_edit_screen.dart` — `TaskAddEditScreen` (full-screen route), composing `AreaPicker`, `ContextPicker`, `DateTimeline` (date_timeline_popup), `SegmentedBar`, `LengthBucketPicker`, `PointsPicker`, `RepeatEditorCard`.
- **View options:** `lib/features/shared/presentation/view_options_sheet.dart` — `ViewOptionsButton` (app-bar `Icons.tune`) opens `ViewOptionsSheet` as a **modal bottom sheet**; state persists via `taskListViewStateProvider(surface)` (`task_list_view_providers.dart`), surfaces `TaskListSurface { tasks, family, sprint, plan }`. Areas filter already exists (`_AreasDropdown`, reads `areasProvider`).
- **Areas:** `lib/models/area.dart`; `lib/features/areas/providers/area_providers.dart` (`areasProvider`, `AreasWithDefaults`).

### Target State

An adaptive shell selected by a single width breakpoint:

- **Compact (< ~600dp, phone):** unchanged — bottom `NavigationBar`, V9 list, FAB, full-screen editor, View-Options bottom sheet.
- **Medium / Expanded (tablet / web):** three regions —
  - **Left Sidebar** (brand-blue): brand strip, "+ Add task", Search, collapsible Destinations (Plan/Tasks/Family/Stats — absorbs the bottom-nav destinations), collapsible Areas (scope the list, == Areas filter), collapsible "Coming Soon" locked placeholders (Yearly Goals / Monthly Plan / Projects), profile footer. FAB relocates here.
  - **Center**: the existing grouped list (grouping + View-Options group axis **unchanged**) recomposed into a calm centered max-width (~720dp) column with a list app bar, a View-Options summary chip bar, the active-sprint banner, and a selection ring on the selected row.
  - **Right pane** (one at a time): empty state · docked editor · View Options panel (collapsible → slim handle). Editor and View Options are mutually exclusive.

Selection + right-pane state lives above the layout (a `StateProvider<TaskItem?>`-style selected-task provider + a right-pane mode provider) so the same screens render in either form. All visuals reuse existing widgets/tokens.

## Implementation Plan

> **Testing:** native-mobile responsive feature → the Epic E2E/UI-test directive does **not** apply (per `epic-start` guidance). Each story still ships `flutter test` widget/unit coverage per CLAUDE.md (no skipped tests).

### Story 1: Adaptive shell + Direction-A sidebar (~900–1200 LOC)

Introduce the width-breakpoint shell and the left navigation sidebar; phone path byte-for-byte unchanged. Sidebar carries the destinations (absorbing the bottom-nav set), the Areas list (selecting an area scopes the Tasks list — reuse the existing Areas filter), locked "Coming Soon" placeholders, search field, "+ Add task", profile footer; `PendingInvitationBanner` / `SyncConflictBanner` carry into the wide layout.

**Files to create/modify:**
- `lib/riverpod_app.dart` — `_AuthenticatedHome`: branch on a wide breakpoint; wrap/relocate the destination set + banners; keep the compact path intact
- `lib/core/platform/form_factor.dart` — add a wide/expanded breakpoint predicate alongside `isPhoneFormFactor`
- `lib/features/shared/providers/navigation_provider.dart` — `activeTabIndexProvider` reused as the shared destination selection across nav-bar/sidebar
- New: wide sidebar widget(s) under `lib/features/shared/presentation/` (brand strip, collapsible sections, area rows, locked items, footer)
- `lib/features/areas/providers/area_providers.dart` + the existing Areas-filter path (`view_options_sheet.dart` `_AreasDropdown` / `taskListViewStateProvider`) — wire "select area → scope list"
- `lib/features/family/presentation/pending_invitation_banner.dart`, `lib/features/sync/presentation/sync_conflict_banner.dart` — reused as-is in the wide shell

**Significant UI addition?** No — native-mobile responsive layout (no new E2E directive). Widget tests: breakpoint switch renders sidebar vs. bottom-nav; destination + area-scoping navigation; locked placeholders; banners present.

### Story 2: Center list pane + selection state + right-pane scaffold (~700–1000 LOC)

Recompose the existing grouped list into the center column with a list app bar, a View-Options summary chip bar, the active-sprint banner, and a selection ring — **grouping and the View-Options group axis are unchanged** (prototype section headers were illustrative only). Add the selected-task provider and the contextual right-pane container with the on-brand empty state; selection resets on destination switch; ~720dp max column at expanded width.

**Files to create/modify:**
- `lib/features/tasks/presentation/task_list_screen.dart` — `_TaskListBody`: extract/compose into the center pane; selection ring on rows; max-width column in wide mode (phone rendering unchanged)
- New: selected-task provider + right-pane mode provider (`lib/features/shared/providers/`)
- New: right-pane container + empty-state widget (`lib/features/shared/presentation/`)
- `lib/features/tasks/providers/expanded_task_provider.dart` — reconcile inline-accordion (phone) vs. selection (wide); accordion stays the phone behavior
- `lib/features/shared/presentation/widgets/collapsible_group_header.dart` — reused as-is

**Significant UI addition?** No — native-mobile responsive layout. Widget tests: selection sets provider + ring; selection resets on destination switch; empty state renders; grouping unchanged.

### Story 3: Docked editor pane (~800–1100 LOC)

Re-chrome `TaskAddEditScreen`'s content as the docked right pane: header strip (area/project + Delete/Close, no back chevron), sticky Cancel/Save bar, pickers overlay within the pane. On wide, selecting a row populates the editor inline (no route push); phone keeps the full-screen route. **The "+ Add task" action (sidebar / FAB) likewise opens the docked editor in *new-task* mode on wide — not a full-screen route; in Story 1 it intentionally still pushes the full-screen route as a placeholder.** Editor and View Options mutually exclusive in the right region.

**Files to create/modify:**
- `lib/features/tasks/presentation/task_add_edit_screen.dart` — factor the editor body into a shared widget consumed by both the full-screen route (phone) and the docked pane (wide)
- New: docked-editor pane wrapper (`lib/features/shared/presentation/`)
- Reused as-is: `area_picker.dart`, `context_picker.dart`, `date_timeline_popup.dart`, `segmented_bar.dart`, `length_bucket_picker.dart`, `points_picker.dart`, `repeat_editor_card.dart`
- Right-pane mode provider (from Story 2) — enforce editor ⟺ View-Options exclusivity

**Significant UI addition?** No — native-mobile responsive layout. Widget tests: select populates editor in-pane (no nav push); fields/pickers work; save/cancel; phone full-screen path unchanged; editor/View-Options exclusivity.

### Story 4: View Options side panel + collapsible handle + keyboard/mouse polish (~600–900 LOC)

Port `ViewOptionsSheet` content to a right-pane side panel with a collapse-to-handle + the summary chip bar; phone keeps the modal bottom sheet. Fold in the keyboard/mouse polish across all regions (Shortcuts/Actions: j/k move, e edit, c complete, `/` focus search, ⌘/Ctrl+N add; hover states; tab order through the docked editor; verify Areas-reorder / Contexts-reorder / date-timeline drags work under mouse on web/desktop). Cuttable tail if time-boxed: resizable split + persisted ratio, large-size text scaling.

**Files to create/modify:**
- `lib/features/shared/presentation/view_options_sheet.dart` — extract the sheet content into a panel form reused by the bottom sheet (phone) and the side panel (wide); collapsed handle + summary chip bar
- `lib/features/shared/providers/task_list_view_providers.dart` — reused; add View-Options open/collapsed UI state (persisted)
- Shell/list/editor widgets from Stories 1–3 — `Shortcuts`/`Actions`, hover, tab order
- `area_manage_screen.dart`, `context_manage_screen.dart`, `date_timeline_popup.dart` — mouse-drag verification only (no behavior change expected)

**Significant UI addition?** No — native-mobile responsive layout. Widget tests: panel open/collapse + handle; controls match the bottom sheet; Apply/Reset/Cancel; phone bottom-sheet path unchanged; key shortcut intents fire.

## Key Decisions

- **Direction A (sidebar), not master-detail-of-editor, not Direction B (NavigationRail).** The original "list left / editor right" premise died when phone detail became the inline accordion; B was explored and rejected. (TM-354.)
- **Phone is frozen.** Compact path is unchanged; wide is purely additive behind a breakpoint. Reduces regression risk and keeps the V9 redesign intact.
- **Reuse, don't redesign.** V9 card, editor field widgets, brand tokens, chrome are reused verbatim from the phone redesign; the wide work is composition + new sidebar/panels only.
- **Grouping unchanged.** The app's existing grouping + View-Options group axis stay; the prototype's section headers were illustrative filler.
- **Editor ⟺ View Options are mutually exclusive** in the right region (single contextual pane).
- **Premium gating deferred (TM-352).** The breakpoint switch is the single future gate point; no pre-emptive wiring (no architectural lock-in).
- **Story sizing:** ~4 right-sized stories (~1000 LOC each), foundations folded into first consumers, keyboard/polish folded into Story 4 rather than a thin 5th — per the `epic-start` sizing guidance and the user's explicit confirmation.

## References

- Design umbrella + full strategy / resolved questions: TM-354
- Claude Design handoff: `TaskMaestro Redesign-handoff(1)` (`TaskMaestro Wide.html`, `wide-*.jsx`)
- Related: TM-353 (web platform — merged), TM-352 (paywall — future gate), TM-371 (phone portrait lock — already gates wide to tablet/web), TM-381 (drag-and-drop sprint planning — separate post-MVP idea)

---
**Created**: 2026-05-18
**Last Updated**: 2026-05-18
