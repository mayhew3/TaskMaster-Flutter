# User Guide: TM-356 — Task Screen Update

**JIRA:** [TM-356](https://mayhew3.atlassian.net/browse/TM-356)

This release refreshes the entire app's color palette to match the new TaskMaestro logo and redesigns the task card with an inline expand-for-detail pattern. No data changes — your tasks, sprints, areas, and family setup are untouched.

## What's new

### A new look

The app picks up the brand palette from the new logo (TM-355):

- **App bar / bottom nav / cards** — a softer dark blue (`#286BB5`) replacing the lavender from before.
- **Screen background** — a deeper navy (`#1A4676`) so cards lift cleanly off the surface.
- **FAB (the `+` button) and primary buttons** — bright magenta (`#D83AFF`), the brand accent. The Edit button inside an expanded task card uses the same color so primary actions read consistently.
- **Date pills, area dots, dialog buttons, etc.** — restyled to match.

Everything is the same dark theme, just retuned. Splash screen and app icon were updated in TM-355.

### Redesigned task card

Each task in a list now shows in one compact row:

```
┌─ 3px area-color stripe
│ [ ] Task name                              [ DUE in 2d ]
│     ● Area name             30m ─── ▮▮▮▯▯  (5)        ☐ ← checkbox
└─────────────────────────────────────────────────────────
```

- **Title** — line-through and dimmed when the task is completed or skipped.
- **Date pill** (top-right) — calls out the next milestone (the next *upcoming* date type within its display window, falling back to the most-recently-passed). Text color identifies which milestone (DUE / URGENT / TARGET / START); background color identifies the task's *current* state (e.g., a future-due task with an already-passed urgent date shows DUE-red text on an urgent-orange background — "you're reading about due, but the task is already in urgent territory").
- **Area dot + name** — area gets a unique color from a 16-color palette, assigned by your areas' sortOrder, so distinct areas stay distinct.
- **Right cluster** (fixed widths so they line up across cards):
  - Estimated time and a tiny log-scale bar
  - Priority bar (5 segments — fills `priority/2` rounded, capped at 5; coral for high, yellow for medium, lavender for low)
  - Points bubble (numeric, em-dash for null)
- **Sprint icon** — a yellow clipboard appears on the right when the card is active in the current sprint.
- **Scheduled tasks** (start date in future) — render hollow with a thin lavender outline, signaling "not yet active."
- **Completed / skipped** — card surface shifts to a muted purple, the area stripe turns magenta, and the pill swaps to COMPLETED / SKIPPED.

### Tap to expand — replaces the old detail screen

Tap any card body → it expands inline. Tap again, or tap a different card, to collapse (one card open at a time across all lists). The expanded panel shows:

- Up to four date rows in a 2×2 grid (Start / Target / Urgent / Due) — only the ones you've set, with absolute date + relative time.
- Recurrence — `Every 2 weeks`, `Every 3 weeks (after completion)`, etc.
- Notes (the description field).
- Context — your single context label.
- A magenta **Edit** button (bottom-right) — opens the existing edit screen.

The old read-only "Task Item Details" screen is gone. The Edit flow now: tap card → expand → tap Edit. Save returns you straight to the list (no intermediate detail screen).

#### Long task names

Collapsed cards always keep the title on one line with the pill on the right (titles longer than that ellipsis as before). When a card is expanded, if the title would have been cut off, the layout breaks: the title takes the full row and wraps to up to three lines, and the date pill drops to a row below it (right-aligned).

### Family tab — read-only on others' tasks

Tasks owned by other family members still appear in the Family tab and still expand to show their detail panel — but the **Edit** button is hidden for tasks you don't own. (Swipe-to-delete was already gated this way.)

### Dialogs

The Snooze dialog (and the area-edit / area-delete dialogs) now follow a consistent pattern: **Cancel** is a white outlined text button; **Submit / Save / Skip This Instance / Delete** are filled magenta buttons. Buttons stand out against the blue dialog surface.

## What hasn't changed

- All your data — tasks, sprints, areas, family members, recurrence rules, snoozes — is untouched.
- The Edit Task screen layout is the same; only its colors picked up the new palette (no more pink-on-pink toggles or light-blue dropdown items).
- Filters, search, sprint planning, sync, family sharing — all behave the same.

## Gotchas / things to know

- **Hot reload doesn't always pick up theme changes.** If after pulling this PR the AppBar/FAB/dialog colors look stale, do a **hot restart** (`R` in `flutter run`, not `r`) or `flutter clean && flutter run`.
- **Native splash + icon** are from TM-355, not this ticket. They live in `assets/launcher/` and `android/app/src/main/res/`. They require a clean rebuild to refresh on a real device, since launcher resources are cached aggressively.
- **Area colors** are derived from each area's sortOrder in your areas list — so the first 16 areas get distinct palette slots. Beyond 16, colors begin to repeat (the same area always picks the same color). Renaming an area keeps its color; reordering areas can shift colors.
- **Cross-tab accordion**: only one card stays expanded across both the Tasks tab and the Family tab. Switching tabs collapses any open card. This is intentional.
- **The pill's text color and background color may differ** — the text names the milestone you're reading (e.g., DUE), the background reflects the task's current state (e.g., urgent if urgent has already passed). This was the OLD card-coloring behavior, just relocated to the pill.
