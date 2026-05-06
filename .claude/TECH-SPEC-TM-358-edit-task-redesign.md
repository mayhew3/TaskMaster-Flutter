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
| **Delete affordance:** trash icon in top nav with a confirm dialog | Matches the design; calls the existing `deleteTaskProvider`. |
| **Save bar:** sticky bottom Cancel + Save (replaces the FAB on this screen only) | FAB stays on other screens. |
| **Date popup:** in scope, with full timeline + inline calendar + time bucket | Uses Flutter's `CalendarDatePicker` for the date grid so we don't reinvent month nav / accessibility. |
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
Modal bottom sheet with three regions:
1. **Horizontal timeline** with one marker per set date. Markers are positioned proportionally by `(date.day - minDay) / span`; the inset (`30px`) keeps the leftmost / rightmost markers from clipping.
2. **"Add a date" pills** for any unset date types — tapping adds a default date (start = today, target = +5d, urgent = +13d, due = +20d, all relative to the latest existing date or today).
3. **Selected date detail** — Flutter's `CalendarDatePicker` (themed with the date type's accent color), a 5-segment time bucket picker (`9 AM / 12 PM / 2 PM / 5 PM / All day`), and a Remove pill.

Changes propagate immediately via `onChanged(type, value)`; the Done button just dismisses. The popup uses `DraggableScrollableSheet` so users can grow / shrink it without losing context.

### `repeat_editor_card.dart` — `RepeatEditorCard`
The combined recurrence rule editor: toggle + (when on) "Every N" numeric input + unit `SegmentedBar` + anchor `SegmentedBar`. Anchor labels are normalized to `"Completed Date" | "Schedule Dates"` to match the existing `TaskItemBlueprint` mapping (`recurWait: bool?` ↔ anchor label). When `disabledReason` is supplied, the card replaces itself with a static info row (used for the family-shared-task case from TM-335).

## Screen refactor — `task_add_edit_screen.dart`

The 802-line legacy file was rewritten end-to-end:

- **Top nav** (custom `_TopNav`): back arrow → `Navigator.pop`; centered title (`"Edit task"` / `"New task"`); trash icon (edit mode only) → confirm dialog → `deleteTaskProvider`.
- **Body** is a `Stack` with the form (in a `SingleChildScrollView` with bottom padding to clear the action bar) plus the `TmBottomActionBar` `Positioned` at the bottom.
- **Editor gradient**: `editorBgTop` → `cardColor` over the first ~280 px, applied via a `Container.decoration.gradient` wrapping the body.
- **Field order:** Name (large borderless input) → Area → Context → Priority → Points → Length → Dates → Repeat → Notes. The two date-related fields are rendered together; tapping Dates opens the timeline popup.
- **Validator parity:** name field still emits "Name is required" on empty submit so existing tests (TM-297) and user-facing message stay identical.
- **Auto-close behavior** (TM-348): unchanged. The `_checkForAutoClose` listener and `_scheduleAutoClose` post-frame callback are preserved verbatim.
- **Family-shared rule** (TM-335): unchanged. When a family-shared task without existing recurrence is edited, `RepeatEditorCard` is rendered with `disabledReason: "Repeating tasks aren't supported in family view yet."`.
- **Single-select Context** is rendered by a small inline `_ContextPickerButton` (chevron-style) that opens a bottom sheet listing the hardcoded options. This will be swapped for the multi-select pills + popup once the migration ticket lands.

## Test coverage matrix

| Widget / file | Test file | Cases |
|---|---|---|
| `FieldLabel` | `test/widgets/field_label_test.dart` | label rendering, hint, action slot |
| `SegmentedBar` | `test/widgets/segmented_bar_test.dart` | default 1..N labels, custom labels, tap-inactive emits, allowZero clear, allowZero no-op, asserts on label/segment mismatch |
| `LengthBucketPicker` | `test/widgets/length_bucket_picker_test.dart` | snap helper for exact/between/null/negative, tap emits canonical, active-tap is no-op |
| `PointsPicker` | `test/widgets/points_picker_test.dart` | Fibonacci index map, Other index for non-Fib, null/zero, label rendering, dialog flow (set / cancel / clear-on-empty / digits-only) |
| `Pill` / `AddPill` | `test/widgets/pill_test.dart` | label, onTap, onRemove visible/fires, AddPill icon |
| `TmBottomActionBar` | `test/widgets/tm_bottom_action_bar_test.dart` | save label, cancel hide/show, callbacks, disabled save |
| `DateSummaryRow` | `test/widgets/date_summary_row_test.dart` | empty-state, set-date pills with x/4 counter, date format, onTap |
| `DateTimelinePopup` | `test/widgets/date_timeline_popup_test.dart` | empty hint, Add pills for unset, marker labels for set, Add tap fires onChanged with new date, Remove fires onChanged(null) |
| `RepeatEditorCard` | `test/widgets/repeat_editor_card_test.dart` | disabled hides controls, enabled shows fields, toggle/unit/anchor callbacks, disabledReason replaces the card |
| **Screen integration** | `test/features/tasks/presentation/task_add_edit_navigation_test.dart` (existing, updated) | TM-282 navigate-back-on-save, TM-297 name-required validation, TM-348 lifecycle assertion regression. Selectors updated FAB icon → text button labels (`"Add task"` / `"Save changes"`) |

Total: 39 existing widget tests still pass + **29 new widget tests** + **7 updated screen integration tests** = **597 tests**, full green.

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
- `flutter test` passes (597 tests).
- `flutter build web` succeeds.
- Manual on Android emulator: name, area picker (open / select / cancel), context picker (open / select / clear), priority + points + length segmented bars (tap, retap to clear, Other dialog), dates row → timeline popup (add, edit, remove, time bucket), repeat editor (toggle on / off, unit, anchor), notes, sticky save bar (Cancel pops, Save changes auto-closes).
- Manual delete flow: tap trash → confirm → screen pops, task gone.
- iOS device check is the user's responsibility (not possible from Windows).
