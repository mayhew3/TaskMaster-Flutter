# Tech Spec — TM-358 Edit Task Screen Redesign

**JIRA:** TM-358 — *Edit Task Screen Update*
**Related:** TM-355 (icon + splash refresh, same brand pass), TM-199 (rename), TM-345 (Areas), TM-348 (auto-close race), TM-335 (family-shared recurrence rules), TM-181 (Epic — tracks multi-select Contexts follow-up)
**Design source:** Claude Design handoff bundle, file `taskmaestro-redesign/project/edit.jsx` (`EditorFullScreen`, lines 732–954)

## Why

The Edit Task screen carried over from the pre-rebrand visual style: dropdowns, free-form numeric fields, and a Material AppBar / FloatingActionButton chrome that no longer matched the brand-blue card surface introduced in TM-355. This story replaces the field tree, top nav, and save affordance with the redesign while keeping all existing state-management, validation, and auto-close behavior. State management stays Riverpod (already migrated; no Redux involved).

## Decisions captured during planning

| Decision | Rationale |
|---|---|
| **Contexts:** stay single-select for this PR | Multi-select is a real data-model migration (`String? context` → `List<String> contexts`) plus a Firestore back-fill. Captured as a follow-up ticket. |
| **Length:** buckets only (5m/15m/30m/1h/2h/4h/8h/1d) | User accepted the precision loss; existing minute values snap to the closest bucket on render. |
| **Points:** Fibonacci `1, 2, 3, 5, 8, Other` (not the design's 1–8) | User-requested. The "Other" segment opens a numeric input dialog and shows the actual stored value when non-Fibonacci. |
| **Priority migration:** per-task `priorityScaleVersion` field, lazy-migrate on first edit | A stored `4` is genuinely ambiguous between legacy "4 of 10" (low) and modern "4 of 5" (high) without a marker. New `int priorityScaleVersion` field on `TaskItem` (default 1 = legacy) disambiguates: card + edit screen read `displayPriority` which halves on version 1 and passes through on version ≥ 2. The edit screen bumps to version 2 on first open of a legacy task; saving persists the migration. |
| **Delete affordance:** trash icon in top nav with a confirm dialog | Matches the design; calls the existing `deleteTaskProvider`. |
| **Save bar:** sticky bottom Cancel + Save (replaces the FAB on this screen only) | FAB stays on other screens. |
| **Date popup:** in scope, with full timeline + inline calendar + time bucket | Originally planned to use Flutter's `CalendarDatePicker`, but the design's multi-date highlighting (other set dates colored in their accent while editing a different type) and the chronologically-faded out-of-range days aren't supported by that widget. Replaced with a custom `_MiniCalendar` (~120 lines) — month grid, prev/next nav, weekday header, accessible day cells. See the `_MiniCalendar` description below. |
| **Top nav:** custom row (back arrow + centered title + trash icon) | Replaces `Scaffold.appBar` so the editor gradient extends behind it. |

## Color tokens added to `TaskColors`

```dart
static const Color editorBgTop = Color(0xFF2E7CD1);   // top of editor gradient
static const Color popupBg = Color(0xFF243250);       // bottom-sheet / dialog bg
static final Color fieldSurface = Colors.white.withValues(alpha: 0.06);
static final Color fieldBorder = Colors.white.withValues(alpha: 0.10);
static final Color editorLabelHint = Colors.white.withValues(alpha: 0.45);
static final Color segmentInactiveSurface = Colors.white.withValues(alpha: 0.05);
static final Color segmentInactiveBorder = Colors.white.withValues(alpha: 0.16);
static final Color segmentActiveTextOnLight = const Color.fromRGBO(20, 30, 60, 0.92);
```

`cardColor = #286BB5` (already exposed) is reused as the editor body background and matches the design's `EDITOR_BG`. The save accent is `brandMagenta = #D83AFF` (already a brand constant).

## New shared widgets

All under `lib/features/shared/presentation/widgets/`. Each has a corresponding test in `test/widgets/`.

### `field_label.dart` — `FieldLabel`
Uppercase form label + optional hint + optional trailing action. Used everywhere the edit screen labels a field.

```dart
FieldLabel('Priority', hint: '3/5', action: someTrailingWidget)
```

### `segmented_bar.dart` — `SegmentedBar`, `Segment`
Generic N-segment selector. Active segment is filled with the accent color; others show a translucent outline. The internal `Segment` widget is exported so composite pickers (`PointsPicker`) can build their own row with custom click logic.

- Accents: `brand` (light periwinkle), `priority` (red/orange/blue ramp by index), `points` (white).
- `allowZero: true` → tapping the active segment emits `null` (clears).
- `allowZero: false` → taps on the active segment are no-ops.

Used directly for Priority (1–5), Recurrence Unit (Days/Weeks/Months/Years), Recurrence Anchor (Completed Date / Schedule Dates), and the time-bucket picker inside the Date popup.

### `length_bucket_picker.dart` — `LengthBucketPicker`
Wrapper around `SegmentedBar` with the 8 length buckets `5m, 15m, 30m, 1h, 2h, 4h, 8h, 1d`. The `closestBucketIndex(int? minutes)` helper is `static` and unit-tested separately so the snap behavior is deterministic.

### `points_picker.dart` — `PointsPicker`
Fibonacci scale + "Other". Composes `Segment` directly (not `SegmentedBar`) so the "Other" tap can open a numeric-input dialog regardless of whether it's the active segment. `_CustomPointsDialog` accepts an empty input as "clear" and rejects non-numeric values.

`activeSegmentIndex(int? value)` is `static` for testability:
- Fibonacci match → 0..4 (matching index).
- Non-Fibonacci → 5 (the "Other" slot, which renders the actual number, not the literal word).
- Null / 0 / negative → null (no selection).

### `pill.dart` — `Pill`, `AddPill`
Generic chip widgets. `Pill` supports an optional color dot, leading widget, click handler, and remove × button. `AddPill` is the dashed "+ Add" affordance. Reusable for future multi-select Contexts work.

### `tm_bottom_action_bar.dart` — `TmBottomActionBar`
Sticky bottom bar with optional Cancel + primary Save. Uses a vertical gradient (transparent → editor bg) so scrolled content fades behind it; SafeArea handles the home-indicator inset.

### `date_summary_row.dart` — `DateSummaryRow`
Compact row that summarizes a task's set dates as colored pills + chevron. Empty state shows "No dates set". Built directly from the `TaskDateTypes.allTypes` order; consumes a `Map<TaskDateType, DateTime?>`.

### `date_timeline_popup.dart` — `DateTimelinePopup`
Modal bottom sheet with four regions:
1. **Header** — `Cancel` / "Dates" / `Save` row. Save is a filled-magenta `FilledButton`; disabled (faded) when the working copy matches the snapshot taken at popup-open.
2. **Horizontal timeline** with one marker per set date. Markers stack into vertical lanes when they would collide horizontally; lane assignment is via the public `assignTimelineLanes(...)` function with TaskDateTypes ordering as the priority so the visible stack reads top-down Start → Target → Urgent → Due. Each marker's label flag is wrapped with the same green ring as the parent screen when the marker's date differs from the snapshot.
3. **"Add a date" pills** for any unset date types. Tapping adds a default date computed by `defaultDateForNewType(...)`, which respects bounds:
   - both bounds → midpoint in days
   - lower only → `lower + 5d`
   - upper only → `upper − 5d` (the user-reported regression: adding Start when later types existed must land BEFORE the earliest of them)
   - neither → today
4. **Selected date detail** — custom `_MiniCalendar` (replaces Flutter's `CalendarDatePicker` so we can render multi-date highlights), a 5-segment time bucket picker (`9 AM / 12 PM / 2 PM / 5 PM / Other...`), and a Remove pill.
   - Selected day = filled circle in the type's accent + dark text. Other set dates = bold colored text (no fill). Plain in-range days = lighter weight.
   - Days outside `firstDate..lastDate` (computed from the OTHER set dates) are 20% opacity and reject taps.
   - "Other..." opens Flutter's `showTimePicker` so users can dial in any time, including minutes — handy when bounds disable every standard bucket.
   - When a marker is selected, the calendar's `ValueKey('mini-cal-${type.label}')` forces a fresh widget so the displayed month jumps to the new selection while preserving arrow-nav state within one type.

**Deferred-commit model:** edits update a local `_dates` working copy only. `_initialDates` snapshots the input. `Save` diffs the two and emits `onChanged(type, value)` per changed type; `Cancel` (and back/swipe-to-dismiss) discard.

### `repeat_editor_card.dart` — `RepeatEditorCard`
The combined recurrence rule editor: toggle + (when on) "Every N" numeric input + unit `SegmentedBar` + anchor `SegmentedBar`. Anchor labels are normalized to `"Completed Date" | "Schedule Dates"` to match the existing `TaskItemBlueprint` mapping (`recurWait: bool?` ↔ anchor label). When `disabledReason` is supplied, the card replaces itself with a static info row (used for the family-shared-task case from TM-335).

**Inline validation** via `showValidationErrors: bool`. When true (parent flips it on Save with missing fields), each missing required field renders with a red border + "Required" caption underneath. The `_NumberInput` uses Material's standard `errorText` plumbing; the segmented bars use a small `_ErrorBorderWrap` (transparent in non-error state for layout stability). Indicators clear independently as each field is filled.

### Per-task `priorityScaleVersion` — data model migration
Legacy rows stored `priority` on a 1–10 scale (cards halved via `(p/2).round().clamp(0,5)` to fit a 0–5 display). The redesigned bar works on a 1–5 scale, so a stored `4` is genuinely ambiguous between "low on 1–10" and "high on 1–5" without a marker.

- Added `int priorityScaleVersion` to `TaskItem` (built_value, default 1 via `_setDefaults`) and `int? priorityScaleVersion` to `TaskItemBlueprint`.
- Drift `Tasks` table gains the same column with default `Constant(1)`; schema bumps to **v7** with an `addColumn` migration step in `app_database.dart`.
- New `TaskItem.displayPriority` getter normalizes per scale: legacy halves; v2+ passes through. Both `_PriorityBar` (cards) and the redesigned screen read this, so they always agree on what to render.
- `_initializeTask` migrates legacy rows on first open: mirrors `displayPriority` into the blueprint and bumps `priorityScaleVersion = 2`. The persistence is **silent** (a fire-and-forget `updateTaskProvider` write) so the migration doesn't enable the Save Changes button. `taskItem` is rebuilt to the post-migration state so `hasChanges()` compares correctly.
- New tasks save with `priorityScaleVersion = 2` directly.
- Test coverage: `test/models/task_item_priority_scale_test.dart` (7 cases for displayPriority, blueprint round-trip, hasChanges-on-version-only diff, default value).

### Timezone handling
Blueprint dates hydrated from Firestore are UTC. The screen's `_datesMap(timezoneHelper)` wraps each value through `timezoneHelper.getLocalTime(...)` before passing to `DateSummaryRow` and `DateTimelinePopup`. Mirrors the legacy `ClearableDateTimeField` round-trip; the storage layer converts back to UTC on save.

### Changed-field highlight
A 2-px light-green ring (`#8FE5A1`) frames each field whose blueprint value differs from the original `taskItem` (per-field detectors `_areaChanged`, `_priorityChanged`, etc.). New tasks return false everywhere — there's nothing to diff against, so no ring renders. The wrapper widget `_ChangedFieldHighlight` keeps the same 2-px padding in the unchanged state (transparent border) so toggling doesn't shift layout. The Name field (underline-only) recolors its underline to the same green at 2-px width when changed.

The Dates popup mirrors this on the marker labels: changed markers render their flag inside the same green ring.

## Screen refactor — `task_add_edit_screen.dart`

The 802-line legacy file was rewritten end-to-end:

- **Top nav** (custom `_TopNav`): back arrow → `Navigator.pop`; centered title (`"Edit task"` / `"New task"`); trash icon (edit mode only) → confirm dialog → `deleteTaskProvider`.
- **Body** is a `Stack` with the form (in a `SingleChildScrollView` with bottom padding to clear the action bar) plus the `TmBottomActionBar` `Positioned` at the bottom.
- **Editor gradient**: `editorBgTop` → `cardColor` over the first ~280 px, applied via a `Container.decoration.gradient` wrapping the body.
- **Field order:** Name (large borderless input) → Area → Context → Priority → Points → Length → Dates → Repeat → Notes. The two date-related fields are rendered together; tapping Dates opens the timeline popup.
- **Validator parity:** name field still emits "Name is required" on empty submit so existing tests (TM-297) and user-facing message stay identical.
- **Recurrence required-fields validation:** when `_repeatOn` is true, every-N / unit / anchor must all be set. Failure flips `_repeatValidationFailed = true` so `RepeatEditorCard` renders inline error highlights (no SnackBar). The flag clears on Repeat-toggle-off.
- **Auto-close behavior** (TM-348): unchanged. The `_checkForAutoClose` listener and `_scheduleAutoClose` post-frame callback are preserved verbatim.
- **Family-shared rule** (TM-335): unchanged. When a family-shared task without existing recurrence is edited, `RepeatEditorCard` is rendered with `disabledReason: "Repeating tasks aren't supported in family view yet."`.
- **Single-select Context** is rendered by a small inline `_ContextPickerButton` (chevron-style) that opens a bottom sheet listing the hardcoded options. This will be swapped for the multi-select pills + popup once the migration ticket lands.
- **AreaPicker setState bridge:** the screen wraps `AreaPicker.valueSetter` in `setState` so the green changed-border + bottom Save bar update immediately (the redesigned `AreaPicker` is no longer a `FormField`, so `Form.onChanged` doesn't fire).

## Test coverage matrix

| Widget / file | Test file | Cases |
|---|---|---|
| `FieldLabel` | `test/widgets/field_label_test.dart` | label rendering, hint, action slot |
| `SegmentedBar` | `test/widgets/segmented_bar_test.dart` | default 1..N labels, custom labels, tap-inactive emits, allowZero clear, allowZero no-op, asserts on label/segment mismatch |
| `LengthBucketPicker` | `test/widgets/length_bucket_picker_test.dart` | snap helper for exact/between/null/negative, tap emits canonical, active-tap clears (matches priority bar) |
| `PointsPicker` | `test/widgets/points_picker_test.dart` | Fibonacci index map, Other index for non-Fib, null/zero, dialog flow (set / cancel / clear-on-empty / digits-only), tap-active-Fib clears, tap-active-Other clears |
| `Pill` / `AddPill` | `test/widgets/pill_test.dart` | label, onTap, onRemove visible/fires, AddPill icon |
| `TmBottomActionBar` | `test/widgets/tm_bottom_action_bar_test.dart` | save label, cancel hide/show, callbacks, disabled save |
| `DateSummaryRow` | `test/widgets/date_summary_row_test.dart` | empty-state, set-date pills with x/4 counter, date format, onTap |
| `DateTimelinePopup` | `test/widgets/date_timeline_popup_test.dart` | empty hint, Add pills for unset, marker labels for set, Save commits diffs, Cancel discards, Save without changes is a no-op, Remove + Save commits null |
| `assignTimelineLanes` | `test/widgets/date_timeline_popup_lane_test.dart` | single / spaced / colliding / 3-same-x / 4-overlap / lane reuse / threshold edge cases / empty / priority ordering (parallel input/output, full reverse stack, partial overlap) |
| `defaultDateForNewType` | `test/widgets/date_timeline_popup_default_for_test.dart` | lower-only, upper-only (incl. TM-358 user bug — Start before earliest later), both-bounds midpoint, same-day bounds, multi-bound (latest lower / earliest upper), no-bounds today, output normalized to 9 AM |
| `RepeatEditorCard` | `test/widgets/repeat_editor_card_test.dart` | disabled hides controls, enabled shows fields, toggle/unit/anchor callbacks, disabledReason replaces the card, validation-error rendering (all-missing, partial-fix, flag-off) |
| `TaskItem` priority-scale | `test/models/task_item_priority_scale_test.dart` | `displayPriority` for legacy/modern values, blueprint round-trip, hasChanges on scale-only diff, default scale version |
| **Screen integration** | `test/features/tasks/presentation/task_add_edit_navigation_test.dart` (existing, updated) + `task_add_edit_redesign_test.dart` (new) | TM-282 navigate-back-on-save, TM-297 name-required validation, TM-348 lifecycle assertion regression. Selectors updated FAB icon → text button labels (`"Add task"` / `"Save changes"`). Redesign chrome (top nav, sticky save bar, no FAB) + delete confirm flow |

Total: **642 tests**, full green. `flutter analyze` clean.

## Out of scope (deferred to follow-ups)

- **Multi-select Contexts** — tracked under **Epic TM-181**. Field is still `String? context` in `TaskItem`. Migration sketch:
  1. Add `BuiltList<String> get contexts` field with empty-list default.
  2. On read from Firestore, if `contexts` is missing/empty and `context` is non-null, hydrate `contexts = [context]`. Don't write back yet.
  3. Update all selectors / filters that read `taskItem.context` (search `lib/` for `\.context\b`).
  4. Swap the screen's `_ContextPickerButton` for the multi-select pills already designed in `edit.jsx` `ContextsPicker`.
  5. Optional one-shot Firestore migration script to backfill `contexts` from `context` and clear the legacy field.
- **Free-form length input.** Buckets only; precision loss for ~90 / ~150 / ~360 minute values is accepted.
- **Android 13+ monochrome themed icon, iOS 18 dark/tinted icon variants.** (Carried over from TM-355 as deferred-by-user.)

## Verification

- `flutter analyze` clean.
- `flutter test` passes (642 tests).
- `flutter build web` succeeds.
- Manual on Android emulator: name, area picker (chevron + sheet + inline-add field with dashed border), context picker (open / select / clear / scrollable), priority + points + length segmented bars (tap to set, tap-exact-active to clear, fillUpTo visual on priority/points only), dates row → timeline popup (Cancel discards / Save commits / disabled when no changes / mini-calendar with multi-date highlighting / range fading / time buckets including Other...), repeat editor (toggle on/off, unit, anchor, inline error highlights when fields missing), notes, sticky save bar (Cancel pops, Save changes auto-closes).
- Manual delete flow: tap trash → confirm → screen pops, task gone.
- Manual priority migration: open a legacy task with priority > 5 → bar renders normalized value; Save Changes stays disabled because the migration persists silently on open.
- iOS device check is the user's responsibility (not possible from Windows).
