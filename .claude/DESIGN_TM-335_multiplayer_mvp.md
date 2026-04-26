# Multiplayer MVP — Family-shared Tasks

**JIRA:** TM-335 (this) → TM-336 (Tier 2)
**Branch:** `TM-335-multiplayer-mvp`

## Why

TaskMaster shipped as a single-user app. Every record (task, recurrence, sprint) carries one `personDocId`, the SyncService listener filters by it server-side, and Drift filters by it again locally. Users asked for a way to share their task list with family members so a household can coordinate on chores, errands, and shared work without each person manually duplicating tasks.

This MVP introduces a "Family" concept: invite-by-email, accept, view + add + complete each other's tasks, with live updates as members add/edit/complete. Sprints and recurrence rules stay per-person — full collaboration is Tier 2 (TM-336).

## Data model

```
families/{familyDocId}                        ← new collection
  ownerPersonDocId: pA
  members: [pA, pB]
  dateAdded: ts
  retired: null

persons/{personDocId}                         ← extended (existing collection)
  email, displayName, dateAdded, retired
  familyDocId: {familyDocId}                  ← null when solo

familyInvitations/{auto-id}                   ← new collection
  inviterPersonDocId, inviterFamilyDocId
  inviterDisplayName                          ← denormalized for banner
  inviteeEmail
  status: 'pending' | 'accepted' | 'declined'
  dateAdded: ts

tasks/{taskId}                                ← extended (one new column)
  personDocId: pA                             ← owner; unchanged
  familyDocId: {familyDocId}                  ← stamped on add when in family;
                                                used for fan-out queries
  ...
```

**Why a Family entity (vs per-person `sharedWith` list)?** A single `families/{id}` document with a member array gives Firestore listeners a single anchor (`where members array-contains me`) without N-many sub-listeners, and it sets up cleanly for Tier 2 (multiple groups, group settings, etc.). One family per person for MVP.

**Why both `personDocId` AND `familyDocId` on every task?** The owner attribution (`personDocId`) drives "who completed what?" + permission checks (only owner edits recurrence rules + only owner deletes). The fan-out marker (`familyDocId`) makes "show every family member's tasks" a single Firestore query instead of one per member.

## Sync architecture

### Listeners attached on `start()` (always)

| Listener | Scope | Purpose |
|---|---|---|
| `tasks` | `personDocId == self` | own incomplete tasks (unchanged, pre-TM-335) |
| `taskRecurrences` | `personDocId == self` | own recurrences (TM-343 client-side retired filter) |
| `sprints` | `personDocId == self`, top 3 by sprintNumber | own sprint history (unchanged) |
| `persons/{me}` | single doc | my Person doc — drives the family-listener attach decision |
| `familyInvitations` | `inviteeEmail == myEmail` | pending invites addressed to me |

### Listeners attached when `persons/{me}.familyDocId != null`

| Listener | Scope | Purpose |
|---|---|---|
| `families/{myFamilyDocId}` | single doc | family member roster + ownership |
| `persons` | `documentId in [memberIds]` | display names for the manage screen + "Added by" |
| `tasks` | `familyDocId == myFamilyDocId AND retired == null` | every member's family-shared tasks (incl. completed) |

When `persons/{me}.familyDocId` flips (join / leave / removed), `_onPersonSelfSnapshot` detaches the old family listeners and attaches the new ones (or none, if leaving). The detach skips local data wipe — stale rows are inert (filtered by `currentFamilyDocIdProvider`-based queries) and re-reconciled on next family join.

The family-tasks listener intentionally does **not** filter on `completionDate`. Including completed family tasks is what lets the Family tab's "Show Finished" toggle survive a tab navigation away and back. The trade-off: every completed family task ever flows into Drift; acceptable at MVP family sizes, paginatable in Tier 2.

### Personal-listener / family-listener interaction

When a user completes their own family-shared task, **both** listeners fire on the same Firestore change:
- The personal listener sees the doc leave its `completionDate isNull` filter and would normally `deleteFromRemote` the row.
- The family listener sees the doc still match (no completionDate filter) and re-upserts it.

Without coordination this races: a winning delete erases the row, leaving "Show Finished" empty after navigation. The personal-listener handler now reads the local row first (`db.taskDao.getByDocId`), and **skips the delete when `familyDocId != null`** — the family listener owns those rows.

### What's *not* synced across family

- **Sprints** stay personal (each person plans their own sprint).
- **Recurrence rules** (the `taskRecurrences` collection) stay personal. Adding a recurrence to a family-shared task is **prevented in the UI** — the Repeat toggle in `TaskAddEditScreen` is hidden when the task is or will be family-shared (with a "Repeating tasks aren't supported in family view yet" hint). Pre-existing broken rows that already have both still show the toggle so the user can turn recurrence off to unblock family completion. Tier 2 will sync recurrences across family.

### No on-join backfill

Tasks created **before** the user joins a family stay personal (no `familyDocId`). Only tasks added **while in a family** get `familyDocId` stamped (by `AddTask`). This matches the user's intuition that the Family tab is what we've added together, not the entire history each member brought in. Earlier iterations did backfill `familyDocId` on every existing task at create/accept time; that surprised users by silently sharing their personal history. The backfill helper (`setFamilyDocIdForAllTasksOfPerson`) is retained for the leave-time clear (zero out `familyDocId` on the removed user's tasks).

### Notification refresh

The notification helper used to be touched only by `CompleteTask` and the startup full-sync (`notificationSyncProvider`). Add / Update / Snooze and remote sync changes now also call `notificationHelper.updateNotificationForTask(taskItem)` fire-and-forget after their writes:
- **Local writes** (`AddTask` / `UpdateTask` / `SnoozeTask`): re-fetch the saved row via `db.taskDao.getByDocId(...)` and refresh notifications. Re-fetching keeps the helper consistent with what actually landed in Drift.
- **Remote sync** (`_onTasksSnapshot` and `_onFamilyTasksSnapshot`): for every non-`removed` change after the initial snapshot, call the helper. Skips on initial because `notificationSyncProvider` does the bulk app-startup sync. This is what lets device B's notifications update when device A changes a date.

The helper internally cancels notifications for completed/retired tasks and schedules them for active ones, so the same call covers both paths.

## Invite lifecycle

```
            ┌──────────┐
inviter →   │ pending  │   ──── inviter cancels (not in MVP)
            └────┬─────┘
                 │
       invitee accepts ──────► invitee added to family.members,
                                 persons.familyDocId set,
                                 invitation.status = 'accepted'
                 │
       invitee declines ─────► invitation.status = 'declined'
```

The invitations collection is keyed by `inviteeEmail`, which is what the recipient's `_invitationsSub` listener filters on. The invitee's app surfaces a `PendingInvitationBanner` above the body of every tab — critical for solo users who don't have the Family tab yet (accepting an invite is what creates the Family tab).

## Permission matrix (MVP)

| Action | Self | Other family member | Non-family |
|---|---|---|---|
| View task | ✓ | ✓ (when in same family) | ✗ |
| Add task | ✓ (stamped with own familyDocId) | n/a | ✗ |
| Complete / un-complete task | ✓ | ✓ (live-syncs to all members) | ✗ |
| Skip / un-skip recurring instance | ✓ | ✓ (subject to recurrence-rule cache; fails gracefully if not synced) | ✗ |
| Snooze / edit task fields | ✓ | ✗ (Edit FAB hidden in TaskDetailsScreen) | ✗ |
| Delete task | ✓ (swipe) | ✗ (swipe aborts + SnackBar "You can only delete tasks you created") | ✗ |
| Edit recurrence rule | ✓ | ✗ (Edit Recurrence card non-tappable; toggle hidden in add/edit screen) | ✗ |
| Invite to family | ✓ (any member) | n/a | n/a |
| Remove member | ✓ (owner only) OR self (leave) | n/a | n/a |
| Leave family | ✓ | n/a | n/a |
| Transfer ownership | implicit on owner-leave (first remaining member) | n/a | n/a |

Non-recurrence editing for family members is *deliberately* out of scope for MVP. The Jira ticket says "all the same options as normal tasks" for the family view, which we read as view+complete options (sort, filter, group), not edit permissions. Tier 2 (TM-336) can open up cross-family editing of non-recurrence fields if the product requires it.

## UI surfaces

- **Family tab** (`family_tab_screen.dart`) — bottom-nav destination, visible only when `currentFamilyDocId != null`. Shows the union of every family member's tasks. AppBar actions: a `_FamilyFilterPopupMenu` (text-labelled "Show Scheduled" / "Show Finished" `CheckedPopupMenuItem` rows, mirroring the Tasks tab's `_FilterPopupMenu`) and a Manage-family icon. No owner badge on tiles — being on the Family tab is itself the indication that these are family tasks; per-task ownership shows up on the detail screen instead.
- **Tasks tab vs Family tab** — `filteredTasksProvider` excludes tasks with `familyDocId != null`, so the Tasks tab is purely the user's personal queue. Family-shared tasks live exclusively on the Family tab. (Notifications and the Stats counter still see both.)
- **Family management** (`family_manage_screen.dart`) — pushed route from the Family tab. Member roster (display name only — email is never a primary identifier in the UI), role chips, per-member Remove (owner only), Invite, Leave.
- **Family setup** (`family_setup_screen.dart`) — pushed route from the drawer's "Family" entry (visible only when solo). Lets a solo user invite their first family member; the family materializes the moment that first invite is sent (the inviter is the owner). On successful invite, the screen pops itself and switches the active bottom-nav tab to index 2 — when the persons-self listener delivers the new `familyDocId`, the Family tab splices in at index 2 and the user is on it.
- **Invite dialog** (`invite_member_dialog.dart`) — themed for the dark Material 3 colorscheme (light label / underline / button text — the M3 defaults render dark-on-dark on this app's theme). Send-invite button stays disabled until the entered email matches a basic regex. Reads `currentUserProvider` for the inviter's display name.
- **Pending invitation banner** (`pending_invitation_banner.dart`) — mounted above the home Scaffold body, visible across every tab (the body is wrapped in `SafeArea(top: true, bottom: false)` so the banner sits below the status bar / camera notch and inner-tab AppBars don't double-inset). Shows the most recent pending invite + Accept / Decline.
- **Drawer entry** — "Family" ListTile in `app_drawer.dart`, shown only when the user is solo. Goes away once they're in a family (the Family tab takes over).
- **Task details "Added by" field** — `TaskDetailsScreen` shows the owner's email in a `ReadOnlyTaskField`. Looked up locally via `currentPersonProvider` (own tasks) + `familyMembersProvider` (family members). Hidden when neither source has the owner.

## Schema migration

Drift `schemaVersion` bumped from **2 → 3** (`app_database.dart`). The migration:
- Adds `familyDocId` column to `Tasks` (nullable text)
- Creates `Families`, `FamilyInvitations`, `Persons` tables

Existing on-device databases run `MigrationStrategy.onUpgrade` and pick up the new column / tables silently. There's no data backfill required — existing tasks have `familyDocId = NULL` and that's correct (the user isn't in a family yet).

## Known limitations / deferred to Tier 2 (TM-336)

1. **Firestore security rules stay open.** Current rules: `allow read, write: if request.auth != null;`. Multi-user reads were already possible before this PR, so it doesn't make things worse — but a rules-tightening pass is required before any real-world rollout. Likely its own ticket.
2. **No FCM / push notifications for invites.** The invitee sees the banner only when they next open the app. Tier 2 wires Cloud Messaging.
3. **Invitees must already have a `persons` doc.** The current sign-in flow rejects unknown emails (`AuthStatus.personNotFound`). Until that's reworked, you can only invite people who've signed in to TaskMaster at least once. The invite dialog surfaces this with a targeted error message.
4. **Recurrence rules don't sync across family.** Completing a family member's recurring task can hit `RecurrenceNotFoundException` if their rule isn't cached locally. The user-facing impact is a SnackBar from TM-343; the task stays uncompleted. Tier 2 adds cross-family recurrence sync.
5. **No editing of family members' tasks.** Recurrence-rule edits are blocked by design; non-recurrence field edits are blocked by hiding the Edit FAB. Tier 2 can open this up with finer-grained permissions.
6. **One family per user.** Person.familyDocId is a single-value field. Tier 2 can model multiple groups by promoting it to a list.
7. **Members list display names.** Rely on `Person.displayName` denormalized into the `persons` doc. If a member changes their display name, the family roster updates only after their next sign-in (which writes the doc). MVP-acceptable.
8. **Owner-leave ownership transfer is "first remaining member"** rather than longest-standing. Members list is a JSON-encoded array without join-time ordering.

## Critical reuse points

- **`TaskRecurrenceDao.deleteSyncedNotInForPerson`** (added in TM-343) — pattern reused by `FamilyInvitationDao.deleteSyncedNotInForEmail` and `TaskDao.deleteSyncedFamilyTasksNotIn`. Person-/email-/family-scoped reconciliation prevents sign-out/sign-in cycles from purging another user's rows.
- **`RecurrenceNotFoundException` + `showTaskActionError`** (TM-343) — all family-task completion paths chain `.catchError(...)` so the SnackBar fires even when the family member doesn't have the recurrence rule cached.
- **`firstWhereOrNull` from `package:collection/collection.dart`** — preferred lookup pattern across the service layer.
- **Riverpod toggle providers** in `task_filter_providers.dart` — mirrored exactly in `family_task_filter_providers.dart` (own keepAlive, persistence, structure) so the Family tab feels native to the existing UX.
- **`SyncService` listener wiring** — the canonical pattern (subscription field, `_*InitialReceived` flag, snapshot handler with `bulkUpsertFromRemote` + person-scoped reconciliation). Family listeners follow it; the only twist is they attach lazily after the persons-self snapshot reveals `familyDocId`.

## Manual verification checklist

Run against the Firestore emulator with two accounts (A and B):

1. Sign in as A → bottom nav shows Plan / Tasks / Stats. Open drawer → tap **Family** → `FamilySetupScreen`.
2. Tap "Invite a family member" → enter B's email → invitation appears in `familyInvitations` collection. A is now in a single-member family; the **Family tab** appears live.
3. Sign in as B (separate device or second emulator session) → still solo → **PendingInvitationBanner** appears at the top → tap Accept.
4. B's bottom nav grows to include **Family**. Tap it → family task list (empty until tasks added). Tap the people icon → `FamilyManageScreen` shows A as Owner, B as Member.
5. Either user adds a task on the Family tab → it appears on the other device live. Tasks created on the Tasks tab while in a family also become family-shared (AddTask stamps `familyDocId` automatically).
6. A completes one of B's tasks on the Family tab → completion propagates to B's app live; the just-completed task stays in its original group on A's tab (TM-323 in-place pattern), and on B's tab arrives in the Completed group with Show Finished on.
7. With Show Finished on, a completed task remains visible across tab navigation (proves the family-tasks listener pulls completed tasks, not just the recently-completed in-memory list).
8. Toggle the filter popup ("Show Scheduled" / "Show Finished") and verify both behaviors match the Tasks tab.
9. A taps a B-owned task → `TaskDetailsScreen` → no Edit FAB; the "Added by" field shows B's email.
10. A swipes left on a B-owned task → SnackBar "You can only delete tasks you created"; the row snaps back.
11. A's Tasks tab still shows ONLY A's own personal tasks (no family bleed).
12. A's TaskAddEditScreen (while in family): the Repeat toggle is hidden with a "Repeating tasks aren't supported in family view yet" hint. A pre-existing recurring family task still shows the toggle so it can be turned off.
13. A changes a date on one of A's family tasks → device B's logs show `[SyncService] notification refresh` for that task; B's notification helper updates schedules.
14. Owner (A) removes B → B's tasks disappear from A's Family tab within seconds; B's bottom nav loses the Family tab; B's drawer regrows the "Family" entry.
15. B re-invited and accepts → B can see the family roster again. **Tasks B created while solo do NOT auto-appear on the Family tab** (intentional, no backfill); only future tasks B adds while in the family will be shared.

## Test coverage

- `test/features/family/data/family_repository_test.dart` — 13 tests covering create, invite (existing / missing person / duplicate), accept (with email match check), decline, remove (owner / non-owner / self), leave (member / owner-with-members → transfer / last-member → delete).
- `test/core/services/sync_service_test.dart` (extended, +2 tests) — family-tasks listener syncs another member's task into Drift; reconciles stale family-task rows on initial snapshot.
- Existing 438 tests still pass; total: **453**.

## Files

| Layer | File | New / modified |
|---|---|---|
| Models | `family.dart`, `family_invitation.dart`, `person.dart` | new |
| Models | `task_item.dart` + `_blueprint.dart` + `task_item_recur_preview.dart` | + `familyDocId` field |
| Models | `serializers.dart` | register new types |
| DB | `tables.dart` | + `Tasks.familyDocId` + `Families` + `FamilyInvitations` + `Persons` |
| DB | `app_database.dart` | schemaVersion 2→3, migration, register new tables/DAOs |
| DB | `converters.dart` | family/person converters; extend task converter |
| DB | `daos/family_dao.dart`, `family_invitation_dao.dart`, `person_dao.dart` | new |
| DB | `daos/task_dao.dart` | + `watchFamilyIncompleteTasks`, `setFamilyDocIdForAllTasksOfPerson`, `deleteSyncedFamilyTasksNotIn` |
| Sync | `core/services/sync_service.dart` | family listeners + persons-self listener + invitations listener; `start()` accepts email |
| Service | `core/services/task_completion_service.dart` | `AddTask` stamps `familyDocId` |
| Family | `features/family/data/family_repository.dart` | new (transactions for create/invite/accept/decline/remove/leave) |
| Family | `features/family/providers/family_providers.dart` | new (currentPerson / currentFamily / members / pendingInvitations + mutation controllers) |
| Family | `features/family/providers/family_task_filter_providers.dart` | new (Family-tab-local filter state + grouping) |
| Family | `features/family/presentation/*.dart` | 5 new files (tab / manage / setup / dialog / banner) |
| UI | `features/shared/providers/navigation_provider.dart` | dynamic `NavTabs.forUser(inFamily:)` |
| UI | `features/shared/presentation/editable_task_item.dart` | optional `ownerLabel` chip |
| UI | `features/shared/presentation/app_drawer.dart` | Family entry shown only when solo |
| UI | `features/tasks/providers/task_providers.dart` | + `familyTasksProvider` |
| UI | `features/tasks/presentation/task_details_screen.dart` | hide Edit FAB + lock recurrence card for non-self |
| UI | `riverpod_app.dart` | dynamic Family `TopNavItem` + mount banner above body; `start()` passes email |
| Tests | `test/features/family/data/family_repository_test.dart` | new |
| Tests | `test/core/services/sync_service_test.dart` | + family listener tests |
| Tests | `test/features/tasks/presentation/task_details_screen_test.dart` | override `personDocIdProvider` so Edit FAB tests still find their target |
