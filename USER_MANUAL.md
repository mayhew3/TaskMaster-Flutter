# TaskMaster User Manual

Welcome to TaskMaster, a powerful task management application designed to help you organize your work with recurring tasks, sprint planning, and intelligent date tracking.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Main Navigation](#main-navigation)
3. [Tasks Tab](#tasks-tab)
4. [Plan Tab (Sprint Planning)](#plan-tab-sprint-planning)
5. [Stats Tab](#stats-tab)
6. [Creating and Editing Tasks](#creating-and-editing-tasks)
7. [Understanding Task Dates](#understanding-task-dates)
8. [Recurring Tasks](#recurring-tasks)
9. [Snoozing Tasks](#snoozing-tasks)
10. [Visual Indicators](#visual-indicators)
11. [Tips and Best Practices](#tips-and-best-practices)

---

## Getting Started

### Signing In

When you first launch TaskMaster, you'll see a sign-in screen. TaskMaster uses **Google Sign-In** for authentication:

1. Tap the **Sign in with Google** button
2. Select your Google account or enter your credentials
3. Once authenticated, you'll be taken to the main app

Your data is synced in real-time to the cloud and will be available across devices.

### Signing Out

To sign out:
1. Swipe from the left edge of the screen (or tap the menu icon) to open the **drawer menu**
2. Tap **Sign Out**

---

## Main Navigation

TaskMaster has three main screens accessible via the **bottom navigation bar**:

| Tab | Icon | Purpose |
|-----|------|---------|
| **Plan** | Calendar | Sprint planning and active sprint management |
| **Tasks** | List | View and manage all your tasks |
| **Stats** | Chart | View task completion statistics |

---

## Tasks Tab

The Tasks tab displays all your tasks and provides the main interface for task management.

### Active Sprint Summary

When a sprint is active, the Tasks tab displays a **sprint summary** at the top showing:
- **Progress indicator** - "Day X of Y" showing your position in the sprint
- **Completion count** - "X/Y tasks completed"
- **Show Tasks link** - Tap to reveal tasks assigned to the current sprint

By default, tasks in the active sprint are hidden from the main task list. Tap **Show Tasks** to display them inline with a yellow calendar icon indicating sprint membership.

### Viewing Tasks

Tasks are displayed in a scrollable list. Each task shows:
- **Task name** - The title of the task
- **Context** - The location/context for the task (if set)
- **Date indicator** - Shows the most relevant date status
- **Sprint icon** - A yellow calendar icon on the right (if task is in active sprint and shown)
- **Checkbox** - Shows completion status

### Task Actions

| Action | How to Perform | Result |
|--------|----------------|--------|
| **View details** | Tap on a task | Opens Task Details screen |
| **Complete task** | Tap the checkbox | Marks task as complete |
| **Snooze task** | Long press on a task | Opens Snooze dialog |
| **Delete task** | Swipe right on a task | Deletes the task (with confirmation) |
| **Add new task** | Tap the **+** floating button | Opens Add Task screen |

### Checkbox States

The checkbox has three visual states:
- **Empty circle** - Task is not started
- **Dot in circle** - Task completion is pending (waiting for backend to process)
- **Checkmark** - Task is completed

### Filtering Tasks

Tap the **filter icon** in the app bar to access filter options:

- **Show Scheduled** - Toggle to show/hide tasks with future start dates
- **Show Completed** - Toggle to show/hide completed tasks

### Refreshing Data

Tap the **refresh icon** in the app bar to manually sync data from the cloud.

---

## Plan Tab (Sprint Planning)

The Plan tab helps you organize your work into time-boxed sprints.

### Creating a New Sprint

When no sprint is active, you'll see the **New Sprint** setup screen:

1. **Last Sprint Info** - Shows when your previous sprint ended (if any)
2. **Duration** - Enter a number (e.g., 1, 2, 3)
3. **Duration Unit** - Select: Days, Weeks, Months, or Years
4. **Start Date** - Tap to select when the sprint begins
5. **Start Time** - Tap to set the start time
6. The **End Date** is automatically calculated based on your duration

Tap **Create Sprint** to proceed to task selection.

### Selecting Tasks for Sprint

After creating a sprint, you'll see the **Task Selection** screen:

- All available tasks are listed
- Tasks from your previous sprint are highlighted
- Tasks with due/urgent dates within the sprint period are auto-selected
- **Recurrence previews** are shown for recurring tasks that will generate new instances during the sprint window (even if those instances don't exist yet)
- Tap tasks to select/deselect them for the sprint

Tap **Submit** to assign selected tasks to your sprint.

### Active Sprint View

Once a sprint is active, the Plan tab shows the list of tasks assigned to this sprint.

#### Sprint Task Filters

- **Show Scheduled** - Toggle visibility of scheduled tasks
- **Show Completed** - Toggle visibility of completed tasks

#### Sprint Task Actions

Same as the Tasks tab:
- Tap to view details
- Long press to snooze
- Tap checkbox to complete
- Swipe right to remove from sprint

Note: Sprint progress (Day X of Y, completion count) is displayed on the **Tasks tab**, not the Plan tab.

---

## Stats Tab

The Stats tab provides a simple overview of your task metrics:

- **Completed Tasks** - Total number of tasks you've finished
- **Active Tasks** - Total number of incomplete tasks

---

## Creating and Editing Tasks

### Adding a New Task

1. Tap the **+** floating action button on the Tasks tab
2. Fill in the task details (see fields below)
3. Tap the **checkmark** button to save

### Editing an Existing Task

1. Tap on a task to open the **Task Details** screen
2. Tap the **edit** floating action button (pencil icon)
3. Modify the task details
4. Tap the **checkmark** button to save changes

### Task Fields

#### Basic Information

| Field | Description | Required |
|-------|-------------|----------|
| **Name** | The task title (supports multi-line) | Yes |
| **Project** | Categorize by project area | No |
| **Context** | Where/how you'll do this task | No |
| **Notes** | Additional details or instructions | No |

#### Project Options

- (none)
- Career
- Hobby
- Friends
- Family
- Health
- Maintenance
- Organization
- Shopping
- Entertainment
- WIG Mentorship
- Writing
- Bugs
- Projects

#### Context Options

- (none)
- Computer
- Home
- Office
- E-Mail
- Phone
- Outside
- Reading
- Planning

#### Metrics

| Field | Description |
|-------|-------------|
| **Priority** | Numeric priority level |
| **Points** | Game points for gamification |
| **Length** | Estimated duration |

#### Date Fields

| Field | Description |
|-------|-------------|
| **Start Date** | When the task becomes active (scheduled until then) |
| **Target Date** | Initial goal completion date |
| **Urgent Date** | When the task becomes urgent |
| **Due Date** | Final deadline |

All dates include both date and time components.

### Deleting a Task

1. Open the Task Details screen
2. Tap the **trash icon** in the app bar
3. Confirm the deletion

---

## Understanding Task Dates

TaskMaster uses four date types to help you prioritize and track tasks:

### Date Types

| Date | Purpose | Visual Indicator |
|------|---------|------------------|
| **Start Date** | Task is hidden until this date | Hollow appearance with darker background, light outline (scheduled) |
| **Target Date** | Your initial goal to complete | Yellow when passed |
| **Urgent Date** | Task becomes high priority | Orange when passed |
| **Due Date** | Hard deadline | Red when passed |

### Date Progression

Tasks typically progress through these states:

1. **Scheduled** - Start date is in the future (hollow/muted appearance)
2. **Active** - Start date has passed, working toward target
3. **Target passed** (yellow) - Target date reached, still time before urgent
4. **Urgent** (orange) - Urgent date passed, needs immediate attention
5. **Overdue** (red) - Due date passed, task is late
6. **Completed** (pink) - Task finished

### Date Display

On task lists, dates are shown relative to now:
- "in 3d" - 3 days from now
- "2d ago" - 2 days ago
- "just now" - Very recent

---

## Recurring Tasks

Recurring tasks automatically create new instances when completed.

### Setting Up Recurrence

1. Create or edit a task
2. Set at least one date (Start, Target, Urgent, or Due)
3. Toggle the **Repeat** switch ON
4. Configure:
   - **Num** - How many units between occurrences (e.g., 2)
   - **Unit** - Days, Weeks, Months, or Years
   - **Anchor** - What the recurrence is based on

### Anchor Date Options

| Anchor | Behavior |
|--------|----------|
| **Schedule Dates** | New task dates are calculated from the original schedule |
| **Completed Date** | New task dates are calculated from when you actually completed the task |

#### Example: Weekly Report

- Repeat every 1 Week, anchored to Schedule Dates
- If due every Monday, the next instance is always the following Monday
- Good for fixed-schedule recurring events

#### Example: Haircut

- Repeat every 6 Weeks, anchored to Completed Date
- If you complete it late, the next occurrence is 6 weeks from completion
- Good for tasks that depend on when you last did them

### Completing Recurring Tasks

When you complete a recurring task:

1. Tap the checkbox to mark it complete
2. The checkbox briefly shows the **pending** state (dot icon) while the backend processes
3. Once processed, a new task instance is automatically created with updated dates

The completion process works the same as regular tasks—the key difference is that a new recurring instance is generated automatically.

---

## Snoozing Tasks

Snoozing lets you temporarily delay a task's dates.

### How to Snooze

1. **Long press** on any task (in list or details view)
2. The **Snooze Dialog** appears

### Snooze Options

| Field | Description |
|-------|-------------|
| **Num** | How many units to delay (default: 3) |
| **Unit** | Days, Weeks, Months, or Years |
| **For Date** | Which date to snooze (Start, Target, Urgent, or Due) |

### Schedule Options (Recurring Tasks Only)

For recurring tasks anchored to schedule dates:

| Option | Behavior |
|--------|----------|
| **This Task Only** | Creates an "off-cycle" instance; doesn't affect the recurring schedule |
| **Change Schedule** | Modifies the base schedule for all future instances |

### Snooze Preview

The dialog shows a preview of all task dates after applying the snooze, so you can verify the changes before submitting.

---

## Visual Indicators

### Color Coding

TaskMaster uses colors to quickly communicate task status:

| Color | Meaning |
|-------|---------|
| **Hollow/Muted** | Scheduled (start date in future) - darker background with light outline |
| **Yellow** | Target date has passed |
| **Orange** | Urgent date has passed |
| **Red** | Due date has passed (overdue) |
| **Pink** | Completed |

### Sprint Icon

Tasks assigned to the current sprint display a **yellow calendar icon** on the right side of the task row. This icon appears when you tap "Show Tasks" on the Tasks tab to reveal sprint tasks.

### App Badge

The app icon badge shows the count of urgent and overdue tasks, so you can see at a glance if tasks need attention without opening the app.

---

## Tips and Best Practices

### Effective Sprint Planning

1. **Keep sprints short** - 1-2 weeks works well for most people
2. **Don't overcommit** - Include buffer time for unexpected tasks
3. **Review previous sprint** - Check which tasks carried over and why
4. **Use the auto-select** - Tasks with due dates in the sprint period are selected automatically

### Managing Recurring Tasks

1. **Choose the right anchor**:
   - Use "Schedule Dates" for fixed-schedule items (meetings, reports)
   - Use "Completed Date" for flexible maintenance tasks (cleaning, exercise)

2. **Review before completing** - Before marking a recurring task complete, consider if dates need adjustment via snooze

### Organizing with Projects and Contexts

- **Projects** help you group related work (Career, Family, Health)
- **Contexts** help you batch tasks by location or tool needed (Computer, Phone, Office)

### Date Strategy

- **Start Date** - Use for tasks you can't start until a certain date
- **Target Date** - Your realistic goal; passing this is a gentle reminder
- **Urgent Date** - Set this a few days before the hard deadline
- **Due Date** - The actual deadline; tasks here are truly overdue

### Dealing with Overdue Tasks

When tasks pile up:
1. **Snooze** tasks you genuinely can't do yet
2. **Complete** quick tasks immediately
3. **Delete** tasks that are no longer relevant
4. **Reschedule** by editing dates if priorities changed

---

## Offline Support

TaskMaster has partial offline support:
- **Authentication requires internet** - You must be online to sign in
- **Works if connection drops** - If you lose connection while using the app, you can continue working
- Changes sync automatically when connection is restored
- Data is cached locally for fast access

*Note: Full offline support (including offline authentication) is planned for a future release.*

---

## Need Help?

If you encounter issues or have questions:
- Check your internet connection for sync issues
- Try refreshing with the refresh button
- Sign out and sign back in to reset the connection

---

*TaskMaster - Master Your Tasks, One Sprint at a Time*
