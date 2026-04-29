# Telescoping Planning & Goals System

**Status**: Design / Brainstorming
**Date**: 2026-04-28
**Related Jira**: TM-345 (Area rename — prerequisite)

## Vision

A multi-layered planning and check-in system that telescopes from yearly goals down to daily focus, helping users move from big-picture intentions to concrete daily action. The core insight: each layer is a **curation moment** — an active decision about what matters in this period — not just a filtered view of all tasks.

Inspired by planning frameworks like "40 Hour Teacher Workweek" (Angela Watson), "12 Week Year" (Brian Moran), and "Full Focus Planner" (Michael Hyatt). The 40 Hour Teacher Workweek's yearly → monthly → weekly telescoping structure is the closest match to this design, though adapted beyond the teaching context.

## The Planning Layers

```
Yearly Goals (set once, review quarterly)
     │
     ▼
Monthly Check-in (prompted, reviews yearly goals)
     │
     ▼
Weekly Planning (core atomic unit)
     │
     ▼
Daily Focus (opt-in, on-demand)
```

### Layer 1: Yearly Goals

Set broad intentions for the year. Goals range from concrete and measurable to fuzzy and aspirational — the system should support both gracefully.

**Examples from real usage:**
1. Learning/self-improvement
   - Choose 1 Project/month
   - Continue learning new technologies
   - Reading: 1 hr/wk
2. Connect with friends more
   - Stephen, Hunter, Alcides
3. Health
   - Dermatologist, Urologist
4. Activities for myself
   - More softball? Tv discussion group? New singing group?

**Key properties of a Goal:**
- Name and optional description/notes
- Optional Area association (links to Area system from TM-345)
- Timeframe (default: calendar year; advanced: custom timeframe with optional recurrence)
- Sub-items (notes, child tasks, or sub-goals)
- **Optional** metric for pace tracking:
  - Target type: hours, count, or custom
  - Target value and period (e.g., 1 hr/wk, 24 books/year, 1 project/month)
  - Suggested chunk size (e.g., 1 hour sessions)
- Status: active, paused, completed, abandoned

**Fuzzy goals** (no metric) are first-class citizens — they show up in check-ins as qualitative reflection prompts rather than progress bars.

**Measurable goals** (with metric) unlock:
- Pace calculation (are you ahead/behind?)
- Auto-generated tasks when falling behind pace
- Progress visualization
- "On a roll?" prompts — option to continue when completing a chunk ahead of pace

### Layer 2: Monthly Check-in

A prompted review session (notification-driven, user chooses when).

**Flow:**
1. Review yearly goals — reminded of each goal and its rationale
2. For measurable goals: show pace (ahead/behind/on track)
3. For fuzzy goals: qualitative prompt ("How's this going? Still important?")
4. Select/create tasks and projects for the coming month
5. Optional: adjust goal pace if reminders are too frequent/infrequent
6. Record brief reflection (helps end-of-year review)

### Layer 3: Weekly Planning (Core Atomic Unit)

The primary planning cadence. Weekly planning pulls from:
- Monthly commitments (what did I say I'd do this month?)
- Goal pace (what's needed to stay on track?)
- Due dates and recurring tasks (what's urgent/scheduled?)
- Area health (anything neglected?)
- Inflexible items for the week (calendar events, hard deadlines) — eventual GCal integration

**Two-week lookahead:** Following the 40HTW pattern, the planning view shows the current week AND the following week, so commitments naturally roll forward without surprises.

**Output:** A curated set of tasks for the week, organized into two buckets:
- **Day-assigned tasks** — pinned to a specific day because they must happen then (recurring, deadline-driven, or context-locked)
- **"Anytime this week"** — committed to the week but flexible on day

This dual-bucket approach is intentional: assigning every task to a day is too rigid, but leaving everything floating loses the benefit of pre-planning. The bucket split is the "best of both worlds."

**Capacity-aware planning:**
- Aim for ~75% completion rate as a healthy target
- Track historical completion to learn the user's actual throughput
- Gently flag overcommitment: "You typically complete ~5 tasks per weekday. You've planned 8 for Tuesday."
- Use task `duration` estimates to roll up weekly time commitment
- Under-committing is a feature, not a bug — finishing the list and *then* picking more is more rewarding than missing half of it

### Layer 4: Daily Focus (Opt-in, On-demand)

**Critical design principle:** This adds NO daily noise unless the user asks for it. No morning notifications, no guilt-tripping. It's a tool you reach for, not one that reaches for you.

**Three moments of daily task selection** (drawn from 40HTW):

1. **During weekly planning** — pin must-do items to specific days (already part of Layer 3)
2. **Start of day** — opportunity to add a commitment or two from the "Anytime this week" bucket
3. **Bonus round** — after completing all committed tasks for the day, get to pick another one as a reward. This turns extra work into a choice, not an obligation.

**"The Main Thing" (optional):**
- Optionally designate one task per day as THE thing that matters most
- "Even if nothing else gets done, completing this means the day was a success"
- Make it optional — not every day needs a Main Thing
- When set, it gets visual prominence and is the first thing offered if the user has limited time

**"Plan my day" flow:**
1. User initiates (button, not automatic)
2. System pulls from weekly plan (day-assigned tasks for today + opt-in from "Anytime this week")
3. Filters by today's context (working day? home? errands planned?)
4. Suggests a focused list for today, optionally proposing a Main Thing
5. User curates — adds, removes, reorders, sets Main Thing

**Smart suggestion modes** (alternatives to the default flow):
- **"It's [day]. Give me a to-do list."** — context-aware suggestions (weekend-flagged tasks on weekends, etc.)
- **"I have N hours."** — uses task `duration` to propose 2-3 plan options (one big task vs. several small)
- **"Give me low-hanging fruit."** — best value/duration ratio, biased toward shorter tasks for quick wins
- The system offers multiple curated lists rather than one — feels empowering rather than prescriptive

**End-of-day review (optional):**
- Brief prompt at end of day to handle unfinished tasks
- Options per task: move to another day, return to "Anytime this week", defer entirely
- Feeds the capacity-learning model — completion rate informs future weekly planning suggestions

## How It Connects to Other Features

| Feature | Role in Planning |
|---------|-----------------|
| **Areas** (TM-345) | Organize goals and tasks by life domain |
| **Goals** | Define what you're aiming for across the year |
| **Contexts** | Filter what's possible right now (location, time, energy) |
| **Projects** (future) | Finite work packages that may contribute to a goal |
| **Planning cadence** | Where you decide what to actually *do* |

## Data Model Sketch

### Goal Entity
```
goals (collection, scoped by personDocId)
  - name: String
  - description: String? (rationale, notes)
  - areaDocId: String? (link to Area)
  - timeframeStart: DateTime (default: Jan 1)
  - timeframeEnd: DateTime (default: Dec 31)
  - timeframeRecurrence: String? (advanced: annual, quarterly, custom)
  - metricType: String? (hours, count, custom, null = fuzzy)
  - metricTarget: num? (e.g., 52 for 52 hours, 24 for 24 books)
  - metricUnit: String? (hours, books, projects, sessions)
  - metricChunkSize: num? (suggested session size, e.g., 1 hour)
  - metricChunkUnit: String? (hours, count)
  - status: String (active, paused, completed, abandoned)
  - sortOrder: int
  - personDocId: String
  - dateAdded: DateTime
  - retired: String? (soft delete)
  - retiredDate: DateTime?
```

### Goal Sub-items
```
goalItems (subcollection under goals)
  - name: String
  - type: String (note, task_link, sub_goal)
  - taskDocId: String? (if linked to a task)
  - completed: bool
  - sortOrder: int
```

### Goal Progress Entries
```
goalProgress (subcollection under goals)
  - date: DateTime
  - value: num (hours logged, count increment)
  - taskDocId: String? (if progress came from completing a task)
  - notes: String?
```

### Planning Sessions
```
planningSessions (collection, scoped by personDocId)
  - type: String (yearly, monthly, weekly, daily)
  - periodStart: DateTime
  - periodEnd: DateTime
  - reflectionNotes: String?
  - dateAdded: DateTime
```

## Implementation Phases

### Phase 1: Yearly Goals (Foundation)
- Goal CRUD (create, edit, archive)
- Sub-items (notes and simple checklists)
- Area association
- Goals list/detail screens
- Support both fuzzy and measurable goals
- No pace tracking yet — just capture and display

### Phase 2: Pace Tracking & Auto-tasks
- Metric configuration on goals
- Pace calculation engine
- Progress logging (manual + task completion)
- Auto-generated tasks when behind pace
- "On a roll?" continuation prompts
- Progress visualization

### Phase 3: Monthly Check-ins
- Check-in prompt/notification
- Review flow with goal summaries
- Qualitative prompts for fuzzy goals
- Pace adjustment UI
- Reflection notes

### Phase 4: Weekly Planning
- Weekly planning session flow
- Pull from monthly commitments, goal pace, due dates, recurring tasks
- Two-bucket weekly list: day-assigned + "Anytime this week"
- Two-week lookahead view
- Area health check (neglected areas)
- Capacity awareness using task `duration` rollups
- Historical completion tracking (foundation for capacity learning)

### Phase 5: Daily Focus
- Opt-in "plan my day" flow
- Context-aware filtering
- Pull from weekly plan (day-assigned + opt-in from "Anytime this week")
- Three-moment task selection: weekly pin → start-of-day → bonus round
- Optional "Main Thing" per day
- Smart suggestion modes ("I have N hours", "low-hanging fruit", etc.)
- End-of-day review for unfinished tasks

### Phase 6: Reporting & Review
- End-of-year goal reports
- Mid-point progress check-ins
- Historical planning session review
- Goal completion trends

## Open Questions

- How does goal progress interact with the sprint system? Are they parallel concepts or should sprints evolve into the weekly planning layer?
- Should goals be shareable in the multiplayer context (family goals)?
- What's the right notification cadence for monthly check-in prompts?
- Should "plan my day" integrate with calendar data for time-blocking?
- How granular should the "on a roll?" feature be — per-session or per-day?
- Capacity learning: per-day-of-week (Tuesdays vs. weekends) or single average? How much history before suggestions kick in?
- How does "The Main Thing" interact with goal pace? Should pace-driven auto-tasks be eligible to be the Main Thing?
- Bonus round mechanic: should it be tied to the points/rewards system, or stand on its own?
