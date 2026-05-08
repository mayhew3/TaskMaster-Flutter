# User Guide — TM-358 Edit Task Screen Redesign

**JIRA:** TM-358 — *Edit Task Screen Update*

The edit-task screen has been rebuilt to match the new TaskMaestro brand. Same data, same providers, same auto-close-on-save behavior — but the visuals and several interactions have changed. This guide walks through what's different and how to use it.

---

## Where to find the screen

Same place as before — tap the FAB on the Tasks tab to add a task, or expand a task card and tap the edit button to edit one. The route hasn't changed.

## Top navigation

Replaces the Material `AppBar`:

| Position  | Control     | Behavior                                                                                                                                                                                        |
|---|---|---|
| Left      | Back arrow  | Pops the screen (same as the system back gesture). Discards uncommitted edits.                                                                                                                 |
| Center    | Title       | "Edit task" when editing, "New task" when adding.                                                                                                                                              |
| Right     | Trash icon  | **Edit mode only.** Opens a confirm dialog ("Delete this task?"). Confirming dispatches the existing delete provider; the screen pops once the deletion is reflected in the task stream. Cancel keeps the screen open. |

> The trash icon is new on this screen. It calls the same delete path the swipe-to-delete on the task list uses.

## Field-by-field tour

### Name

Large borderless input with a thin underline. No label — the input itself carries placeholder "Task name" until you type. Validation is unchanged: empty name shows "Name is required" on save.

### Area

Tap the chevron-style row to open a dark bottom sheet. Inside:

- "None" entry at the top (italic) clears the area.
- Your areas listed with their color dots.
- A pinned **inline "Add new area…" field** at the bottom of the sheet. Type a name and tap Add (or press Enter). Validation messages — "Reserved name", "Already in your list" — surface inline below the field. No separate dialog round-trip anymore.
- Header has Cancel-style "Done" — actually a close affordance — and Select area title.

### Context

Same chevron-style picker as Area. Single-select for now. Hardcoded list (Computer / Home / Office / E-Mail / Phone / Outside / Reading / Planning) plus a "None" entry.

> Multi-select Contexts is tracked under **Epic TM-181**. The picker will switch to multi-select pills once that lands.

### Priority

Five-segment bar with a color ramp (cool blue at low, amber in the middle, coral at high).

- Tap a segment to set the priority to that value.
- All segments **up to** the active one are visually filled (progress-bar style) — but only tapping the **exact active segment** clears the value back to null. Tapping segment 3 when 4 is active sets it to 3, not null.

> **Priority migration:** old data stored priority on a 1–10 scale. The first time you open a legacy task, the value is silently normalized to the 1–5 scale (e.g. an old `8` becomes `4`) and persisted in the background. The Save Changes button stays disabled because you didn't change anything yourself. Card displays read the same normalized value, so the card and edit screen always agree.

### Points

Six segments: `1`, `2`, `3`, `5`, `8`, **`Other...`**. Fibonacci progression. Same fillUpTo + tap-active-clears behavior as Priority.

- Tap a Fibonacci value to set it directly.
- Tap **Other...** (when inactive) to open a numeric input dialog. Enter any number, tap **Set**. The Other slot then displays the actual value (e.g. `13`) instead of the literal word "Other...".
- Tap the active Fibonacci or Other segment to clear back to null. To change a custom value, tap the (now inactive) Other segment again.

### Length

Eight bucket segments: `5m / 15m / 30m / 1h / 2h / 4h / 8h / 1d`.

- Tap a bucket to set it. Tap the active bucket to clear.
- Existing arbitrary minute values (like 90 or 150) **snap to the closest bucket** on display. The free-form numeric input is gone.

### Dates

Single summary row showing pills for any set dates (Start / Target / Urgent / Due) with their accent colors and dates, plus an `n/4` counter and chevron. Empty state: "No dates set" placeholder. Tap the row to open the timeline popup — see below.

### Repeat

A card with a toggle. When on, the card expands to show:

- "Every" — small numeric input.
- "Unit" — segmented bar with Days / Weeks / Months / Years.
- "Anchor" — segmented bar with Completed Date / Schedule Dates.

The card is hidden behind a hint ("Add a date above to enable repeats.") until at least one date is set, since the recurrence anchor needs a date to anchor to. For family-shared tasks without an existing recurrence, the card is replaced with an info row noting that family-shared recurrence isn't supported yet (carries over from TM-335).

> **Inline validation.** If you toggle Repeat on and tap Save Changes without filling in every-N / unit / anchor, the missing fields render with a red border and "Required" caption underneath. Errors clear independently as you fill each field.

### Notes

Translucent multi-line textarea with placeholder "Add notes...". Auto-scrolls above the keyboard when focused (extra 120-px scrollPadding so the sticky save bar doesn't cover the field).

---

## Dates popup

Tap the Dates row to open a draggable bottom sheet.

### Header

`Cancel` (left) | "Dates" (centered) | `Save` (right, magenta `FilledButton`).

- **Edits are deferred** — changing dates inside the popup updates a local working copy only. Nothing persists to your task until you tap **Save**.
- **Cancel** (or back gesture / swipe-down) discards your edits.
- Save is **disabled** when the working copy matches what was there when you opened the popup.

### Timeline

A horizontal track with one marker per set date. Each marker is a colored flag (Start / Target / Urgent / Due) with the date below, a vertical connector, and a dot on the track.

- **Stacking:** if two or more markers would overlap, they stack into vertical lanes. Top-down is **Start → Target → Urgent → Due** (priority-ordered) — the chronologically-first type in any cluster sits highest.
- **Tap targets:** tapping the label region selects that marker. The connector area is non-interactive (so a higher-lane marker can't occlude a lower one), and the dot is also tappable.
- **Changed-marker highlight:** any marker whose date differs from the popup-open snapshot gets a light-green ring around its label flag.

### Add a date

Below the timeline, a row of dashed-border pills for any unset date types. Tapping adds a default date computed to **respect the chronological order**:

- Both bounds set (e.g. adding Target between existing Start and Due) → midpoint in days.
- Only earlier types set → 5 days after the latest of them.
- Only later types set (e.g. adding Start when Target/Urgent/Due exist) → 5 days **before** the earliest of them. *(This is the bug fix — previously Start could land after Due if you added it last.)*
- Nothing set → today.

Default time is 9 AM.

### Selected date detail

When a marker is selected, the popup reveals:

- A row with the type's color dot, label, full date, and **Remove** pill (clears that single date).
- A custom mini-calendar:
  - **Selected day** = filled circle in the type's accent color, dark text, bold.
  - **Other set dates** = bold colored text in their own accent (visible while editing a different type).
  - Plain in-range days = lighter weight white.
  - **Days outside the chronologically-allowed range** = 20% white, non-tappable. The range is computed from the OTHER set dates (e.g. Target between Start and Due is restricted to that span).
- **Time bucket picker:** `9 AM / 12 PM / 2 PM / 5 PM / Other...`
  - On the boundary day itself (when the selected date equals a constraining date), buckets outside the time bound fade and disable.
  - **Other...** opens Flutter's standard time picker so you can dial in any time, including minutes (e.g. `8:30 PM`). Always enabled — useful when bounds disable every standard bucket. The Other slot shows the chosen time when active.

> The previous "All day" option is gone. The team felt it was ambiguous (when does the reminder fire?). Other... replaces it; you pick whatever you want.

---

## Save bar

Bottom of the screen, sticky. **Cancel** (outlined) and **Save changes** / **Add task** (magenta filled). Save is disabled when there are no pending edits.

- **Save Changes** dispatches the same providers the FAB used to (`updateTaskProvider` / `addTaskProvider`).
- The screen auto-closes once the change is reflected in the task stream (TM-348 race-safe behavior preserved).
- **Cancel** pops the screen and discards your edits.

---

## What changed in storage

- `TaskItem.priorityScaleVersion` is a new field (default 1 = legacy 1–10). Drift schema bumped to v7. Saves from the new screen always write `priorityScaleVersion = 2`. Card displays use the new `displayPriority` getter so they normalize via the per-task scale instead of the old hard-coded `(p/2).round()` formula.
- `TaskItem.context` is **unchanged** — still single-select. Multi-select migration is **TM-181** (Epic).
- `TaskItem.duration` is unchanged. Existing arbitrary values display by snapping to the closest bucket; saves only emit canonical bucket values.

## What carried over unchanged

- Form validation message: "Name is required" on empty name.
- Auto-close-on-save (TM-348).
- Family-shared recurrence rule (TM-335) — same disabled state.
- Riverpod state-management — every provider this screen touches is the same one the legacy screen used.
- The FAB on the Tasks tab still opens this screen (just with the new chrome). The task list, list-swipe-to-delete, expanded card, etc. are unchanged.

## Known behaviors worth flagging

- **Migration write happens once per legacy task on first open.** If you open a priority>5 task and immediately swipe back, the migration still persisted in the background. The next open will see the normalized value with no further write.
- **Length bucket snapping is lossy.** A task with `90 minutes` displays as `1h` (closest bucket = 60). Saving that task without changing length writes the original value back; tapping a bucket rewrites it to the canonical bucket value.
- **Dates popup discards on Cancel.** Including bulk add/remove sequences. There's no "undo last edit" — Save commits everything, Cancel reverts everything.
- **Stacking markers on the same day.** Up to four markers can stack vertically; the popup auto-grows to fit. With four same-day markers the timeline region is ~190 px tall.

---

## Related

- **TM-358** — this story.
- **TM-355** — icon + splash brand pass; this screen reuses the brand-blue (`#286BB5`) and magenta (`#D83AFF`) tokens.
- **TM-181** — Epic that tracks the multi-select Contexts migration (deferred from TM-358).
- **TM-348** — auto-close race fix; preserved.
- **TM-345** — Areas collection; the new chevron-style picker still uses `areasWithDefaultsProvider` as its source of truth.
- **TM-335** — family-shared task recurrence guardrail; preserved.
- **TM-282 / TM-297** — earlier validation/navigation regression tests; updated to use the new "Add task" / "Save changes" button labels.
