# User Guide — Family-shared Tasks (TM-335)

**JIRA:** TM-335
**Affects:** All users

---

## What's new

You can now share tasks with family members. Invite someone by email, and once they accept, you'll each see the other's tasks in a new **Family** tab. Completing, adding, and editing tasks syncs live across devices.

---

## Getting started

### Invite someone

1. Open the **drawer** (hamburger menu) and tap **Family**.
2. Tap **Invite a family member** and enter their email address.
   - They must have signed in to TaskMaster at least once. If the email isn't found, ask them to open the app and sign in first.
3. The invite is sent. Your **Family** tab appears immediately — you're now the family owner.

### Accept an invite

When someone invites you, a banner appears at the top of every screen:

> *"[Name] invited you to a family."* — **Decline** / **Accept**

Tap **Accept**. The **Family** tab appears in your bottom navigation.

---

## The Family tab

The Family tab shows **all active tasks across every family member** — yours and theirs — in one list.

- Each task tile shows an **owner badge** ("Added by [Name]") for tasks that belong to someone else.
- The **FAB (+)** adds a task owned by you, shared with the family. Tasks added here appear in every family member's Family tab.
- **Show Completed** and **Show Scheduled** filters work the same as the Tasks tab.

Your personal **Tasks tab** is unchanged — it shows only your own tasks, with no family tasks mixed in.

---

## Completing and editing tasks

| Action | Your own task | Family member's task |
|--------|---------------|----------------------|
| Complete | ✅ | ✅ |
| Edit name / dates | ✅ | ✅ |
| Edit recurrence rule | ✅ | ❌ (button hidden) |
| Delete | ✅ | ❌ (shows "not owner" toast) |

Completing a recurring task owned by someone else schedules their next occurrence as normal.

---

## Managing the family

Tap **Members** (action row at the top of the Family tab) to open the manage screen:

- **Member list** — shows everyone with their role (Owner / Member).
- **Invite by email** — send another invite.
- **Remove** (owner only) — remove a specific member. Their tasks immediately stop appearing in your Family tab.
- **Leave family** — remove yourself. If you're the owner and others remain, ownership transfers to the longest-standing member. If you're the only member, the family is deleted.

---

## Gotchas

- **Tasks you created before joining stay personal.** Only tasks added after you're in a family get the family label and appear on the Family tab.
- **Invites require the invitee to have signed in at least once.** There's no email-based signup flow yet.
- **One family per person.** You can't be in two families at the same time.
- **Sprints are still personal.** Only tasks are shared; sprint planning stays per-person.
- **You can't edit a family member's recurrence rule.** The button is hidden on tasks you don't own.
- **Member removal is eventually consistent.** In rare cases (network error during cleanup), a removed member's tasks may briefly remain visible. A full sync resolves this.

---

## Known limitations (deferred to TM-336)

- No push notification for incoming invites — you see the banner next time you open the app.
- Can't invite users who haven't signed in yet.
- No sprint sharing.
- Firestore security rules are wide-open at MVP; tightening is a separate ticket.
