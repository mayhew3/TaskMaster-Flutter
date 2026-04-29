# TaskMaster Scribbles Synthesis

**Source documents:**
- `E:\OneDrive\Projects\TaskMaster\TaskMaster Scribbles.pdf` (original design notes)
- `E:\OneDrive\Projects\TaskMaster\40 Hour Teacher Work Week\Highlights from the 40HTW.pdf`

**Date synthesized:** 2026-04-29

This document organizes the original design scribbles and 40HTW reactions into actionable feature areas, noting what's already been built, what's already been designed, and what's new.

---

## Already Implemented

These items from the scribbles appear to be done (strikethrough in original or known to exist):

- **Start Date, Due Date, Priority** — core TaskItem fields
- **Recurring tasks** with snooze/postpone — TaskRecurrence system
- **Search** — strikethrough in original
- **Tags / Business Hours / Reminders** — strikethrough in original (evolved into Contexts)
- **Shared tasks** — TM-335 multiplayer MVP
- **Soft delete** ("remove tasks without marking complete") — `retired` field pattern
- **Sprints** — sprint system with assignments
- **Estimated time** — already exists on TaskItem as the `duration` field

## Already Designed (This Conversation)

- **Areas** (TM-345) — rename Project to Area, user-customizable
- **Yearly Goals** (TM-346) — foundation for goal tracking
- **Telescoping Planning** — yearly → monthly → weekly → daily cadence (`.claude/DESIGN_TELESCOPING_PLANNING.md`)

---

## New Feature Ideas

### 1. Smart Task Suggestion Engine

**Source:** Scribbles pp. 1-2

The idea of conversational, context-aware task suggestions. Not just filtering — actively proposing plans.

**Prompt-style interactions:**
- "It's Saturday. Give me a to-do list for today."
  - Suggestions with checkbox add. "Those are good, give me other options..."
  - Respects task-level preferences like "Prefer weekends"
- "I have 4 hours. Give me some options."
  - Multiple plan options: one big task, or several smaller tasks
- "I need to feel productive. Give me low-hanging fruit."
  - Best ratio of value/time, biased toward shorter tasks

**Design notes:**
- This is essentially the "Daily Focus" layer from the telescoping plan, but with a more conversational/AI-assisted feel
- Requires tasks to have **estimated time** and some notion of **value/points**
- Could be implemented as a "Plan My Day" wizard that asks what kind of day you want
- The multiple-plan-options idea is strong — presenting 2-3 curated lists rather than one is more empowering

**Relationship to existing design:** This enriches Phase 5 (Daily Focus) of the telescoping plan. Rather than just filtering by context, the daily planner could offer these prompt-style modes.

---

### 2. Points & Rewards System

**Source:** Scribbles pp. 1-2, 5

A gamification layer to make task completion feel rewarding and track productivity over time.

**Core ideas:**
- Points earned for completing tasks (based on difficulty, priority, time)
- Some tasks could also *cost* points (treats, rewards you "buy" with productivity)
- Customizable reward mapping (e.g., "$10 toward vacation per X points")
- Track progress over time: compare months, weeks, completion by priority
- "Hall of Fame" dashboard for high-point completed tasks
- Star or sticker for completed goals
- Bonus points for early completion (flagged a hard task, completed it quickly)
- "How much crap is building up?" metric — backlog health indicator

**Completion tracking details:**
- Main flow: "Completed now" button
- Secondary: "Completed X days ago" for retroactive logging
- Track actual time spent (completion button can ask "how long did this take?")

**Design notes:**
- Points system needs to feel motivating, not punitive. The "non-judgy" tone from the Reading use case applies broadly.
- The backlog health metric is interesting — some ratio of tasks added vs completed, or age distribution of open tasks.
- Reward customization is important for broad appeal — some people want virtual stickers, others want to map to real rewards.

---

### 3. Priority / Value as a Fluid Concept

**Source:** Scribbles p. 1

Priority (or "value") should be treated as something that changes over time, not a static field.

**Ideas:**
- Track *when* priority was assigned or last changed
- During review sessions (weekly/monthly), prompt for re-evaluation of stale priorities
- Value/time ratio is the key metric for the suggestion engine
- Separate "priority" (how important) from "urgency" (time pressure) — though the scribbles note this might be solved by other features (urgentDate, contexts)

**Design notes:**
- This connects to the review/check-in cadence. During weekly planning, the system could surface tasks whose priority hasn't been reviewed in X weeks: "Is this still a 5?"
- Could be as simple as adding a `priorityUpdatedDate` field and a review prompt

---

### 4. Urgent After / Failed After

**Source:** Scribbles p. 3

Two time-based state transitions for tasks:

**Urgent After:** Configurable delay before a task becomes "urgent"
- Examples: Cat box → urgent day-of. Reading → never urgent.
- Currently `urgentDate` exists on TaskItem — this may already be partially implemented
- The "never" option is key: some tasks should never escalate in urgency

**Failed After:** Hard deadline after which a task is no longer possible
- Task becomes ineligible, marked as "failed" (not completed, not deleted)
- Less judgmental term needed — "expired"? "missed"?
- Should appear in review sessions: "These tasks expired last week"
- Distinct from soft-delete: there's a record it was logged but didn't happen
- Optional point loss or just visibility in reviews

**Design notes:**
- "Failed/expired" is a genuinely missing task lifecycle state. Most apps only have open/complete/deleted. Having "expired" allows honest tracking without the guilt of leaving things open forever or the data loss of deleting.
- Connects to the rewards system — expired tasks could show in retrospectives without necessarily penalizing points.

---

### 5. Multi-Part Tasks with Dependencies

**Source:** Scribbles p. 3

Tasks that are really a sequence (or graph) of steps.

**Levels of complexity:**
1. **Simple sequential list** — ordered steps, complete one to reveal the next
2. **Parallel steps** — completing one step unlocks multiple next steps
3. **"Wait" steps** — e.g., "Order on Amazon" then auto-hide for X days, then next step appears
4. **Partial definition** — know the first step but not the rest; SWAG estimate for the whole thing, add specifics later

**Example:** Buy MacBook → subscribe to developers → write first app → sell in app store

**Design notes:**
- The "wait" step is a standout idea — very common real-world pattern (order something, wait for delivery, then act). This could integrate with the snooze system.
- First pass should be the simple sequential list. That alone adds huge value.
- This is essentially the **Project** concept (finite, goal-oriented task grouping) from our Area/Project/Goal taxonomy. Projects contain ordered tasks with optional dependencies.
- Progress bar on the parent project based on sub-task completion.

**Relationship to existing design:** This IS the future "Project" feature. The scribbles give us the detailed requirements for it.

---

### 6. Weekly Planner with Day Assignment (40HTW-Inspired)

**Source:** 40HTW notes pp. 1-2

Detailed design for how weekly and daily planning should work, enriching the telescoping plan.

**Weekly planning session:**
- View the coming week (40HTW suggests viewing TWO weeks ahead)
- Show "inflexible" items (calendar events, hard deadlines) — GCal integration
- Assign some tasks to specific days
- Remaining tasks go in an "Anytime this week" bucket
- Under-commit intentionally

**Three-moment daily task selection:**
1. **During weekly planning** — pin must-do items to specific days
2. **Start of day** — add a commitment or two from the weekly list
3. **After completing committed tasks** — bonus round! Pick from "Anytime this week" as a reward

**"The Main Thing":**
- Optional: designate one task per day as THE thing that matters
- "Even if nothing else gets done, completing this means the day was a success"
- Might not apply every day — make it optional, not required

**End-of-day review:**
- Unfinished daily tasks: move to another day, back to "anytime", or defer
- Track completion rate — aim for ~75% daily completion
- Use historical data to help calibrate: "You typically complete 4 tasks on weekdays. You've planned 7."

**Design notes:**
- The three-moment model is really elegant. The "bonus round" after completing committed tasks is psychologically smart — it turns extra work into a choice rather than an obligation.
- The 75% completion rate target + capacity learning is a great feature. The app can learn your actual throughput and gently suggest when you're overcommitting.
- GCal integration during planning is valuable but could be a later enhancement. Start with manual awareness of fixed commitments.

**Relationship to existing design:** This dramatically enriches Phases 4 and 5 of the telescoping plan. Updating that doc with these specifics would be valuable.

---

### 7. Task Hierarchy / Parent-Child Display

**Source:** Scribbles p. 5

How to display tasks that have sub-tasks without overwhelming the list view.

**Approaches (user's notes suggest all should be options):**
- Every view shows hierarchy with collapsible parents
- Parent tasks show summary info by default (X of Y complete), expand for details
- User choice: show parent or show next sub-task in list views
- For sequential sub-tasks: show next actionable step, with parent as context info

**Design notes:**
- This connects to Multi-Part Tasks (#5). Once tasks can have children, the display question becomes critical.
- The "show next actionable step" approach is probably the best default for list views — you want to see what you can *do*, not organizational containers.
- Detail/project views can show the full hierarchy.

---

### 8. First Use Interview / Onboarding

**Source:** Scribbles p. 5

A conversational onboarding flow that configures the app based on user preferences.

**Ideas:**
- "Do you dislike phone calls? 1-10?" → influences default tags/contexts
- Conversational style for setting up global settings
- Initializes Areas, Contexts, and default preferences based on answers

**Design notes:**
- This is a nice-to-have polish feature, not a priority for core functionality
- Could be revisited once Areas, Contexts, and Goals are all in place — the onboarding can set all three up at once
- Modern approach might be more like a few quick "pick what applies" screens rather than a long interview

---

### 9. Dashboard / Home Screen

**Source:** Scribbles p. 4

A pluggable widget-based home screen.

**Original vision:**
- Dashboard of "pluggable apps" (ToDo, TV, Games — referencing MediaMogul companion app)
- Should work cleanly with just one app
- Open API for extensibility

**Design notes:**
- The multi-app vision may have narrowed to just TaskMaster, but the dashboard concept is still valuable
- Home screen with widgets: today's tasks, goal progress, sprint status, backlog health, streak/points
- This becomes the natural landing page once there's enough data to surface (goals, planning sessions, completion stats)

---

## Cross-Cutting Themes

Several ideas span multiple features:

### The "Budget" Metaphor
The scribbles compare goal pace tracking to a budget — you have a time/effort budget for the period, and you're spending it. This is a powerful mental model that could unify:
- Goal pace tracking (hours/week budget)
- Weekly capacity planning (don't overcommit)
- Points/rewards (earning and spending)

### Non-Judgmental Tone
Repeated emphasis on not being punitive: "not in a judgy way", "less judgy term", friendly reminders not guilt trips. The app should feel like a supportive coach, not a disappointed parent. This should be a core design principle for all notification copy, overdue displays, and missed task handling.

### Estimated Time on Tasks (Already Exists)
The `duration` field on TaskItem already provides estimated time. Several features can build on this directly:
- Smart suggestions ("I have 4 hours")
- Weekly capacity planning
- Goal pace tracking (suggested chunk size)
- Points calibration

Worth auditing how widely `duration` is currently surfaced in the UI and how reliably users actually fill it in — features that depend on it will need that data to be present and reasonably accurate.

### Completion With Metadata
The scribbles envision completion as more than a boolean:
- When was it completed?
- How long did it actually take? (vs estimate)
- Was it on time, early, or late?
- Did it contribute to a goal?

This enriches the completion flow and feeds into rewards, goal tracking, and capacity learning.

---

## Suggested Priority Ordering

Based on dependencies and value, a rough ordering for future work:

1. **Areas** (TM-345) — already filed, foundation for organization
2. **Yearly Goals** (TM-346) — already filed, foundation for planning
3. **Weekly Planner** (telescoping Phase 4 + 40HTW enrichments) — the core planning cadence
4. **Multi-Part Tasks / Projects** — the missing organizational layer
5. **Points & Completion Tracking** — gamification and retrospectives
6. **Daily Focus / Smart Suggestions** — telescoping Phase 5 + suggestion engine
7. **Monthly / Yearly Check-ins** — telescoping Phases 2-3
8. **Urgent After / Failed After** — task lifecycle refinements
9. **Dashboard** — becomes valuable once there's data to display
10. **First Use Interview** — polish, once the feature set stabilizes
