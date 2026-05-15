# User Guide — TM-359: Group / Sort / Filter for task lists

**JIRA:** [TM-359](https://mayhew3.atlassian.net/browse/TM-359)

This guide covers what changed for the user and how to use it. Pair with `DESIGN_TM-359_GROUP_SORT_FILTER.md` for the engineering side.

---

## What changed

The four task-list surfaces — **Tasks**, **Family**, **Sprint**, and **Create Sprint / Add to Sprint** — used to render with hardcoded grouping and a tiny set of toggles (`Show Scheduled`, `Show Completed`, search). They now share a unified **View Options** sheet that lets you configure how the list is grouped, sorted, and filtered. Selections persist per surface (Tasks and Sprint remember their own settings independently) and survive app restarts.

A few smaller changes also rode along:

- A new **Urgency** sort surfaces "what's most pressing" first within each Due-Status bucket — and is the new default.
- The **group headers** are bigger (easier to tap to collapse/expand) and now show both task count and total points in the group.
- The **recurrence conflict dialog** now shows the anchor date as a field row, so a recurrence diff caused purely by a task-date edit displays correctly instead of looking empty.
- A startup race that could make **Edit Task** open as a blank New Task form has been fixed.

---

## Opening the View Options sheet

Each list surface's app bar has a `tune` (sliders) icon next to the search icon. Tap it.

The icon shows a small **green dot** when the saved view differs from the surface's defaults — a passive reminder that filters are active without needing to open the sheet.

---

## The sheet layout

### Header

- **Title:** "View options".
- **Reset to defaults:** top-right text button. Tapping reverts the working copy to that surface's defaults. You still need to tap **Apply Changes** to commit.

### Group + Sort

Side-by-side dropdowns, plus a small arrow icon for direction:

- **Group** — choose how tasks bucket: `Due Status` (default), `None` (flat list), `Priority`, `Area`, `Points`, `Estimated Time`.
- **Sort** — choose how tasks order within each group: `Urgency` (default), `Date Added`, `Points`, `Area`, `Estimated Time`, `Priority`, `Efficiency`.
- **Direction toggle** — arrow icon flips ascending ↔ descending.

#### What "Urgency" sort does

It's bucket-aware. Within each Due-Status bucket the secondary sort is tuned to surface the next-pressing task:

- **Past Due** — by `Due Date` ascending (most overdue first).
- **Urgent** — by `Due Date`, then `Urgent Date`.
- **Target** — by `Urgent Date`, then `Target Date`.
- **Tasks** (normal) — by `Target Date`, then `Date Added`.
- **Scheduled** — by `Start Date` ascending.
- **Completed** — by `Completion Date` descending (most recent first).

If you turn grouping off (`Group: None`), Urgency interleaves all tasks by tier: past-due first, then urgent, target, normal, scheduled, completed — same per-tier secondary keys. So it works whether you have grouping on or off.

### Filter by

Filter rows, in this order:

1. **Due Status** — multi-select chip dropdown. Determines which buckets render. *Default for Tasks/Family:* `Past Due / Urgent / Target / Tasks` (Scheduled + Completed hidden). *Default for Sprint/Plan:* empty (= every bucket visible).
2. **Estimated Time** — min + max sliders snapped to the standard 5m / 15m / 30m / 1h / 2h / 4h / 8h / 1d buckets.
3. **Points** — min + max sliders, Fibonacci scale (1 / 2 / 3 / 5 / 8) plus an **Other** segment that opens a numeric-input dialog for arbitrary values.
4. **Priority** — min + max sliders, 1–5 scale.
5. **Area + Contexts** — multi-select chip dropdowns, rendered side-by-side. Empty set = "all" (no filter). Each opens a chip grid where you can tap individual chips to toggle, plus Select All / Deselect All.
6. **Recurrence + Age** — single-select dropdowns, side-by-side. Recurrence: `Any` / `Scheduled` / `Completed` / `None`. Age: `Any` / `Last 7 days` / `Last 30 days` / `Last 90 days`.
7. **Owned by me only** (Family surface only) — switch.

#### What the green outlines mean

When the working copy for a field differs from the surface's default, that field gets a 2-px green ring around it. Same visual language as the Edit Task screen, so non-default state is easy to spot.

Combined with the green dot on the AppBar `tune` icon, you can tell at a glance which axes you've changed.

### Sticky footer

- **Cancel** — discards your working-copy edits and closes the sheet.
- **Apply Changes** — commits the working copy. Disabled (greyed) until the working copy actually differs from the saved state — so an unchanged sheet won't write nothing-changed to storage or trigger a re-grouping pass.

The two are distinct: Cancel discards in-flight edits; Reset-to-defaults *fills* the working copy with surface defaults. Reset-then-Cancel keeps your existing saved state intact.

### Min/Max validation

For Priority and Points, raising the **Min** above the current Max auto-bumps Max to match. Lowering Max below Min auto-bumps Min down. So you can't end up with an impossible range like Min=3 / Max=2.

---

## Defaults by surface

| Surface | Group | Sort | Direction | Filter |
|---|---|---|---|---|
| Tasks | Due Status | Urgency | Ascending | Hide Scheduled + Completed |
| Family | Due Status | Urgency | Ascending | Hide Scheduled + Completed |
| Sprint | Due Status | Urgency | Ascending | Show all buckets |
| Plan | Due Status | Urgency | Ascending | Show all buckets |

Sprint and Plan default to showing every bucket because their lists are scoped (sprint membership; plan-mode candidates) — there's no need to also hide by Due Status.

---

## Group headers

Headers in any grouped surface are now tappable to collapse/expand the group:

- Leading chevron rotates 90° when collapsed.
- The label (e.g. `URGENT`) is followed by:
  - A **task-count** badge (e.g. `3`).
  - A **points-total** badge (e.g. `13 pts`) when the group's gamePoints sum is non-zero.

Vertical padding has been increased so the whole row is a comfortable tap target.

Collapse state is per-group-key, so collapsing `Urgent` once stays collapsed when you switch grouping axes and return.

---

## Plan-mode notes

The View Options sheet on the **Create Sprint** / **Add to Sprint** screen ("Select Tasks") supports the **Filter** axes — Areas, Contexts, Due Status, Estimated Time, Points, Priority, Recurrence, Age all take effect.

**Group axis and Sort axis are no-ops** on plan mode for now: the plan screen renders a mix of real tasks and synthesized recurrence-preview rows under a special 8-bucket sprint-history-aware overlay (Last Sprint / Older Sprints / Due Soon / Urgent Soon / etc.), and the universal pipeline doesn't yet handle the polymorphic row type. Filed as a follow-up; the sheet displays normally but those two axes don't change the plan-mode bucketing.

---

## Recurrence conflict dialog — Anchor row

If a recurring task ever produces a real (cross-device) sync conflict, the dialog now shows the **Anchor** field alongside Name / Recur every / Wait until complete / Iteration.

The anchor formats as `{type}: {date}` (e.g. `Urgent: 5/14/2026, 9:19 PM`) and reflects which of the task's dates (`Due > Urgent > Target > Start`) currently drives the recurrence schedule. Before this, a recurrence diff caused purely by a task-date edit would show zero changed fields in the dialog — making "Keep mine" vs "Use latest" hard to reason about.

---

## Edit Task — startup-race fix

If you launched the app and *immediately* tapped Edit on a task, the screen would occasionally pop up as **New task** with all fields blank — the screen was looking up the task synchronously before Drift / Firestore had finished hydrating its in-memory caches, and once it concluded the task was "missing" it stayed in create-new mode.

The screen now shows a loading spinner until the task data is actually available, then renders the edit form populated as expected. No more accidental "create a duplicate of nothing" submissions.

---

## Gotchas

- **First save after an app update.** Existing users opening the app for the first time post-update will see Urgency as the default sort. Any earlier per-surface preferences they had saved (back when the default was `Date Added` or `Default`) are preserved as-is — only newly-set defaults change.
- **"Deselect all" in the area/context picker.** Deselect All clears the working-copy chips so you can start fresh. If you Apply with no chips selected, that's treated as "no filter applied → show all" (same as an empty filter from the start). The picker's chip overlay shows everything as deselected during that interaction; on next reopen the visual state will resolve back to "All".
- **Ghost areas/contexts.** If you've filtered by an area or context that's since been deleted or renamed, the filter stays applied against the old name and matches nothing — your list will look empty. Open the View Options sheet and remove the ghost chip(s) to recover. The system doesn't auto-scrub these because a transient catalog-load failure would otherwise destroy your filter.
- **Sprint sort order under Urgency.** With Urgency as the default, the Sprint surface's per-bucket ordering is by urgency rather than the original sprint-assignment order. If you want the "in the order I assigned tasks" ordering back, that option is gone — `Date Added` is the closest substitute.

---

## Quick reference

| If you want… | Do this |
|---|---|
| Hide completed tasks | (Tasks/Family) Already hidden by default. (Sprint/Plan) Open sheet → Due Status → deselect Completed → Apply. |
| Show only your own family tasks | (Family) Open sheet → Owned by me only → Apply. |
| See what's most overdue first | Default sort already does this (Urgency, ascending). |
| Flatten the list (no grouping) | Open sheet → Group → None → Apply. |
| Filter to a single area | Open sheet → Areas → Deselect All → tap that one area → Apply. |
| Reset everything on one surface | Open sheet → Reset to defaults (top-right) → Apply. |
| Tell at a glance if filters are active | Look for the green dot on the `tune` AppBar icon. |
