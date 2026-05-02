# User Guide — Areas (TM-345)

**JIRA:** TM-345
**Affects:** All users

---

## What's new

The **Project** field on tasks has been renamed to **Area**. The old hard-coded list of project options has been replaced by a customizable list you control. You can add, rename, delete, and reorder your own areas.

Existing tasks keep their old project value as their new area — nothing was lost in the rename.

---

## What's an Area?

An Area is an ongoing category of responsibility — *Home*, *Work*, *Family*, *Health*, *Finances*. It's a tag you attach to tasks so you can group and filter them. Areas don't have a "done" state — they exist as long as you want them in your list.

(A future *Project* feature will be different: finite, goal-oriented groupings of tasks that live inside an Area. Not part of this release.)

---

## Picking an area on a task

In the task add/edit screen, the **Area** dropdown shows:

- `(none)` — no area selected
- Your areas, in the order you've arranged them
- `+ Add new area…` — opens an inline dialog to create a new area without leaving the screen

Pick `+ Add new area…`, type the name, hit **Add**, and it's both saved to your list and selected for the current task.

If you cancel the dialog, the dropdown snaps back to whatever was selected before.

---

## Managing your areas

Open the **drawer** (hamburger menu) and tap **Manage Areas**.

- **Reorder** — grab the drag handle on the left of any row and drag to a new position. The order you set here is the order the picker uses.
- **Rename** — tap the pencil icon. Existing tasks keep the old name (they're not auto-updated).
- **Delete** — tap the trash icon and confirm. Tasks tagged with this area keep the old value, but it disappears from the picker.
- **Add** — tap the **+** floating button.

Empty list? You'll see a hint to tap **+** to add one.

---

## First time?

If you're brand new (no tasks, no areas yet), the first time you open the area picker or the Manage Areas screen, five default areas are seeded for you:

> Home · Work · Finances · Family · Health

You can rename, delete, or reorder these freely. They're just a starting point.

If you migrated from the old Project field, your areas list is pre-populated with the project values you'd been using — alphabetically ordered.

---

## Where else "Area" shows up

| Screen | What changed |
|---|---|
| Task list cards | The little label that used to read your project value now reads your area value (look the same; just different name) |
| Task details | The "Project" header is now "Area" |
| Sync conflict resolution dialog | The "Project" comparison row is now "Area" |
| Task add/edit | The dropdown labelled "Project" is now "Area" with the new picker (above) |

---

## Gotchas

- **Renaming an area doesn't update tasks.** If you rename "Home" to "House", tasks tagged "Home" keep the string "Home" until you re-pick the area on each task. The picker just lists the new "House" option going forward.
- **Deleting an area doesn't delete tasks tagged with it.** They keep their string value, just disappear from the picker. If you want to clean them up, edit each task and re-pick.
- **No duplicate names.** The picker rejects an area name that already exists in your list (case-insensitive).
- **One areas list per person.** Areas are per-user, not per-family. Family-shared tasks display whoever's area string they were tagged with at creation time.
- **Sync is offline-first.** Adding/deleting an area works while offline; the change syncs when you're back online. Two devices reordering at the same time = last-write-wins (you might see a brief flicker).

---

## What if I want my old hard-coded list back?

You can re-create any of the old defaults manually: *Career, Hobby, Friends, Family, Health, Maintenance, Organization, Shopping, Entertainment, WIG Mentorship, Writing, Bugs, Projects.* If your account had tasks tagged with these before the migration, they were already auto-imported as areas — open Manage Areas to see your current list.

---

## Reporting problems

If something looks off — a task showing the wrong area, the picker missing an area you expect, an area that won't delete — note the area name and which screen and file an issue against TM-345.
