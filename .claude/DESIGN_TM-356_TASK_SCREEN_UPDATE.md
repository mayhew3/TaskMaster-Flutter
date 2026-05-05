# DESIGN: TM-356 — Task Screen Update

**JIRA:** TM-356 (New Feature)
**Branch:** `TM-356-task-screen-update`
**Design source:** `.claude/design/TM-356-handoff/` (gitignored — bundle exported from Claude Design)

## Overview

Two coupled changes shipped in one PR:

1. **App-wide brand recolor** to the palette derived from the new TaskMaestro logo (TM-355).
2. **Task card redesign** matching the V9 "Refined++" card from the design handoff, with an inline expand-for-detail panel that **replaces** the read-only `TaskDetailsScreen`.

Edit Task screen layout is **out of scope** but is recolored.

## Palette mapping

All surface colors are the **post-tweak** values from the design HTML — `applyTheme(bgDarkness=0.35, cardSaturation=1, cardDarkness=0.08)` applied to brand blue `(44, 116, 197)`. The HTML literally renders the AppBar with raw `var(--brand-blue)`; we override that to the tweaked card color so the bar doesn't read as a bright stripe over the darkened body.

| Token | Old hex | New hex | Role |
|---|---|---|---|
| `menuColor` | `#666ABA` | `#286BB5` | AppBar / nav bar |
| `cardColor` | `#4C4D69` | `#286BB5` | Card surface (same as menuColor) |
| `backgroundColor` | `#373851` | `#1A4676` | Screen background |
| `highlight` | `#D9478E` | `#D83AFF` | Brand magenta — completed checkbox, edit button, FAB |
| `dueText` / `dueColor` | `#EBA7A7` / `#5F2D3F` | `#F4B0B0` / `rgba(180,60,80,0.28)` | Due-date pill |
| `urgentText` / `urgentColor` | `#EBC8A7` / `#5F4742` | `#F4C8A8` / `rgba(180,110,50,0.28)` | Urgent pill |
| `targetText` / `targetColor` | `#EBEBA7` / `#555C3E` | `#EFE0A0` / `rgba(140,130,50,0.28)` | Target pill |
| `startText` | `rgba(235,235,235,0.8)` | `#B3B5DD` | Start text + time-bar fill |
| `scheduledText` / `scheduledColor` / `scheduledOutline` | lavender variants | tweaked from design `start.*` | Start pill |
| `completedText` / `completedColor` | `#EBA7EB` / `#5F315C` | `#F4C8F9` / `rgba(216,58,255,0.18)` | Completed pill |

**New tokens:**

| Token | Hex / value | Role |
|---|---|---|
| `brandBlue` | `#2C74C5` | Raw brand blue — logo / splash only |
| `brandMagentaMuted` | `#C45EE0` | Reserved (design's muted FAB variant; not currently used after user opted to use the brighter `highlight` for the FAB too) |
| `bgDeep` | `#133255` | Even-darker shell behind background |
| `textPrimary` | `#F2F4FA` | Primary text |
| `textDim` | `rgba(255,255,255,0.72)` | Secondary text |
| `textFaint` | `rgba(255,255,255,0.55)` | Faint text |
| `hairline` | `rgba(255,255,255,0.08)` | Dividers |
| `cardCompletedTint` | `rgba(72,73,163,0.92)` | Completed card surface — precomputed `mix(card 55%, #6E1F8E 45%)` |
| `dueBorder`, `urgentBorder`, `targetBorder`, `startBorder`, `completedBorder` | from design `DATE_TONES.*.border` | Date pill borders |
| `areaPalette` | 16-color list | Source for area-color assignment (provider-mapped + hash fallback) |

## Card layout decisions (V9, scoped down)

The V9 card from the handoff has features the current data model doesn't carry yet. Per user direction, the following are **stripped** from the implementation:

- **Energy / effort dots** — TaskItem has no energy field.
- **Project header strip** — no Project model exists.
- **Context icons row** in the summary — current TaskItem has only a single string `context`, not a multi-icon list. Rendering icons would require an icon mapping that's premature.

The expanded panel **keeps** a single `CONTEXT` row showing the `task.context` string (when set).

Layout:

- **Outer `Card`**, radius 6, color = `cardColor` (or `cardCompletedTint` when completed/skipped).
- **Area stripe**, 3px wide, left edge, color from `AreaColorHelper`. When completed/skipped, the stripe goes magenta (`highlight`).
- **Title row**: title + single date pill on the right. Title gets `lineThrough` when completed/skipped.
- **Meta row**: area dot + area name | (right cluster) `_TimeBlock` (mini log-scale bar + formatted duration) + `_PriorityBar` + `_PointsCircle`.
- **Checkbox** (existing `DelayedCheckbox`) on the right of the body, vertically aligned.
- **Expanded panel** (in `AnimatedSize`, 200ms easeInOut): 2×2 date grid (only non-null dates), context row, recurrence row, notes row, magenta Edit button bottom-right.

### Date pill selection

The card shows **one** date pill. The label is picked by `_displayDateType()` in `editable_task_item.dart`, which mirrors the iteration order from the pre-redesign widget's `_getDateWarnings()`:

1. Walk the dates in priority order (start, target, urgent, due) and return the first one that is in the future *and* within its display window — i.e. the next milestone the user has to act on.
2. If none are upcoming, walk in reverse (due, urgent, target — `start` is excluded once it's behind us) and return the most-recently-crossed.

This is intentionally **different** from `DateHolder.getAnchorDateType()`, which always returns the highest-priority non-null date (used for recurrence anchoring). For display purposes, an earlier-priority date that's the next thing the user must act on (e.g. urgent in 4h) is more relevant than a later-priority date that's farther out (due in 2d).

Pill colors use a **split-tone**: text color from `_displayDateType` (the milestone the label names — DUE / URGENT / TARGET / START), background from `_toneForCurrentState` (the most recently crossed threshold — task's actual current state). Completed/skipped tasks bypass both and show the COMPLETED / SKIPPED pill instead.

### Priority bar

5-segment vertical bar. Filled count = `(priority / 2).clamp(0, 5).round()` because TaskItem's `priority` is in practice 1–10 and the design draws a 1–5 bar. Color shifts: ≥4 → coral `#FFA08C`, ≥3 → warm yellow `#FFCE80`, else neutral lavender (`startText`).

## Accordion state pattern

`ExpandedTask` (Riverpod, codegen) at `lib/features/tasks/providers/expanded_task_provider.dart`:

```dart
@riverpod
class ExpandedTask extends _$ExpandedTask {
  @override
  String? build() => null;
  void toggle(String docId) { state = state == docId ? null : docId; }
  void collapse() { state = null; }
}
```

- **State:** `String?` — the docId of the currently-expanded card, or null.
- **Scope:** Session-only (no `keepAlive`). Switching tabs collapses any open card. This is acceptable per the user decision and keeps the implementation simple — accordion state across tabs would require persisting docId references that may no longer be visible.
- **Cross-list behavior:** All lists share one provider, so tapping a card in the Family tab while another is expanded in the Tasks tab will collapse the first. (Both cards being mounted simultaneously is rare in practice; this is the spec'd accordion behavior.)
- **Where it's read:** `EditableTaskItemWidget.build(...)` watches the provider; `_summaryRow` reads `notifier.toggle(docId)` on tap.

## Area-color assignment

There are two layers, in order of precedence:

1. **Sort-order based (`areaColorsProvider`)** — the primary path. Watches `areasProvider`, which streams the user's areas already sorted by `Area.sortOrder`. Each area gets `palette[index % palette.length]` where `palette = TaskColors.areaPalette` (currently 16 colors). This guarantees distinct colors for the user's first 16 areas without collisions.

2. **Hash-based fallback (`AreaColorHelper.colorForArea`)** — used when an area name on a task isn't found in the provider's map (stale data, race during area load, etc.):
   ```
   key = name.trim().toLowerCase()
   index = key.hashCode.abs() % TaskColors.areaPalette.length
   color = palette[index]
   ```
   Null/empty → `Color(0x4DFFFFFF)` (30% white) fallback.

**Determinism caveat:** `String.hashCode` is deterministic *within* a Dart SDK version. An SDK upgrade could rotate the hash-fallback colors. This is acceptable for visual decoration; if Areas grow ownership semantics later, we'll add a `color` column to the `Area` entity (out of TM-356 scope).

The palette's first 10 colors come from `cards.jsx > AREA_COLORS` (Family / Maintenance / Friends / Hobby / Shopping / Organization / Career / Health / Entertainment / Projects); the next 6 are additional hues to cover users with more than 10 areas before slot reuse begins.

## Recurrence formatter contract

`RecurrenceFormatter.format({recurNumber, recurUnit, recurWait})` at `lib/helpers/recurrence_formatter.dart`:

| Inputs | Output |
|---|---|
| `recurNumber: null` (any unit) | `null` |
| `recurUnit: null` or `''` | `null` |
| `recurUnit` not in `Days/Weeks/Months/Years` (case-insensitive) | `null` |
| `1, 'Days'` | `'Every day'` |
| `1, 'Weeks'` | `'Every week'` |
| `2, 'Weeks'` | `'Every 2 weeks'` |
| `3, 'Weeks', recurWait: true` | `'Every 3 weeks (after completion)'` |
| `2, 'Months', recurWait: false` | `'Every 2 months'` |

The card hides the REPEAT row when `format(...)` returns `null`.

## Removed routes

`TaskDetailsScreen` is **deleted**. The three former call sites — `task_list_screen.dart`, `family_tab_screen.dart`, `task_item_list.dart` — now pass an `onEdit` callback that pushes `TaskAddEditScreen` directly. The flow is: tap card → expand inline → tap Edit → edit screen → save → back to list (no longer back to a read-only details screen).

`task_add_edit_navigation_test.dart` was updated to drive this new flow via `TaskMaestroKeys.editableTaskItemEditButton`.

## Files touched

| Phase | File | Change |
|---|---|---|
| 1 | `lib/models/task_colors.dart` | Palette swap + new tokens |
| 2 | `lib/app_theme.dart` | FAB → `TaskColors.highlight` (brand magenta) + foreground white; divider → hairline; FilledButton → magenta CTA; TextButton → outlined white pill; recurrence Switch keeps a white thumb on the magenta active track |
| 3 | `lib/helpers/recurrence_formatter.dart` | New |
| 3 | `lib/helpers/area_color_helper.dart` | New |
| 3 | `test/helpers/recurrence_formatter_test.dart` | New (8 tests) |
| 3 | `test/helpers/area_color_helper_test.dart` | New (7 tests) |
| 4–5 | `lib/features/shared/presentation/editable_task_item.dart` | Full rewrite to V9 |
| 5 | `lib/features/tasks/providers/expanded_task_provider.dart` | New (+ generated `.g.dart`) |
| 4 | `lib/keys.dart` | Added `editableTaskItemDatePill` / `…ExpandedPanel` / `…EditButton` |
| 6 | `lib/features/tasks/presentation/task_list_screen.dart` | Drop onTap; add onEdit |
| 6 | `lib/features/family/presentation/family_tab_screen.dart` | Drop onTap; add onEdit |
| 6 | `lib/features/shared/presentation/task_item_list.dart` | Drop onTap; add onEdit; widen list type to `List<Widget>` |
| 6 | `lib/features/family/presentation/family_manage_screen.dart` | Trim stale doc comment |
| 6 | `lib/features/tasks/presentation/task_details_screen.dart` | **Deleted** |
| 6 | `test/features/tasks/presentation/task_details_screen_test.dart` | **Deleted** |
| 7 | `lib/features/tasks/presentation/task_add_edit_screen.dart` | `pinkAccent` / `pink` → `highlight`; `white38` → `textFaint`; `white54` → `textDim` |
| 7 | `lib/features/shared/presentation/widgets/nullable_dropdown.dart` | `lightBlueAccent` → `primaryLight` |
| 7 | `lib/features/tasks/presentation/recurrence_detail_screen.dart` | 4 hex literals → `TaskColors` tokens; `Colors.grey.shade800` → `hairline` |
| 8 | `test/widget/editable_task_item_widget_test.dart` | Rewritten for V9 (14 tests) |
| 8 | `test/widget/editable_task_item_expanded_test.dart` | New (8 tests) |
| 8 | `test/features/tasks/presentation/task_add_edit_navigation_test.dart` | Drive edit flow via expanded card |
| — | `.gitignore` | Exclude `.claude/design/` (handoff PNGs/JSX) |

## Verification

- `flutter analyze` — clean.
- `flutter test test/helpers/ test/widget/editable_task_item_widget_test.dart test/widget/editable_task_item_expanded_test.dart` — 49 / 49 pass locally.
- Full suite (`flutter test`) gated by the task-test workflow until user verification.
- Manual QA against the design HTML still pending (run the app, confirm AppBar / FAB / card surfaces, test accordion across Tasks and Family tabs, complete a task to see the magenta tint, open the edit screen to confirm the recolor).
