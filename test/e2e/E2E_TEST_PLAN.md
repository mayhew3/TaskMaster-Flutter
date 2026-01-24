# TaskMaster E2E Test Plan

This document outlines end-to-end tests using a **hybrid approach**:
- **Isolated tests** (~80%) for core functionality - fast feedback, easy debugging
- **Flow tests** (~20%) for critical user journeys - catch integration bugs

---

## Table of Contents

### Part 1: Isolated Tests
1. [Authentication](#1-authentication)
2. [Task CRUD](#2-task-crud)
3. [Task Completion](#3-task-completion)
4. [Task Filtering](#4-task-filtering)
5. [Visual Indicators](#5-visual-indicators)
6. [Snooze Dialog](#6-snooze-dialog)
7. [Sprint Setup](#7-sprint-setup)
8. [Stats Tab](#8-stats-tab)

### Part 2: Critical Flow Tests
9. [Flow: Complete Sprint Lifecycle](#9-flow-complete-sprint-lifecycle)
10. [Flow: Recurring Task Lifecycle](#10-flow-recurring-task-lifecycle)
11. [Flow: Snooze Recurring Task (Schedule Anchor)](#11-flow-snooze-recurring-task-schedule-anchor)
12. [Flow: Snooze Recurring Task (Completion Anchor)](#12-flow-snooze-recurring-task-completion-anchor)
13. [Flow: Task Date Progression](#13-flow-task-date-progression)

### Appendix
- [Test Data Helpers](#test-data-helpers)
- [Priority Matrix](#priority-matrix)

---

# Part 1: Isolated Tests

These tests verify individual features work correctly in isolation.

---

## 1. Authentication

### 1.1 Sign In Displays Correctly
```
GIVEN the user is not authenticated
WHEN the app launches
THEN the sign-in screen should display
AND the "Sign in with Google" button should be visible and tappable
```

**Assertions:**
- [ ] Sign-in screen is displayed
- [ ] Google sign-in button exists and is enabled

### 1.2 Sign Out Works
```
GIVEN the user is authenticated
WHEN the user opens drawer and taps "Sign Out"
THEN the sign-in screen should display
```

**Assertions:**
- [ ] Drawer opens from left edge swipe
- [ ] "Sign Out" option is visible
- [ ] After tap, sign-in screen appears

### 1.3 Session Persists Across Restart
```
GIVEN the user previously signed in
WHEN the app is restarted
THEN the user should be automatically authenticated
AND tasks should load
```

**Assertions:**
- [ ] No sign-in prompt on restart
- [ ] Tasks tab displays with user data

---

## 2. Task CRUD

### 2.1 Create Task - Minimum Fields
```
GIVEN the user is on Tasks tab
WHEN user taps + FAB, enters name "Test Task", taps save
THEN the task should appear in the list
```

**Assertions:**
- [ ] Add screen opens on FAB tap
- [ ] Save FAB appears after entering name
- [ ] Task "Test Task" appears in list after save
- [ ] Navigates back to task list

### 2.2 Create Task - All Fields
```
GIVEN the user is on Add Task screen
WHEN user fills all fields:
  - Name: "Full Task"
  - Project: "Career"
  - Context: "Computer"
  - Priority: 5, Points: 10, Length: 2
  - Start: tomorrow, Target: +3d, Urgent: +5d, Due: +7d
  - Notes: "Test notes"
AND saves
THEN all fields should be persisted
```

**Assertions:**
- [ ] All dropdowns contain expected options
- [ ] Date pickers function correctly
- [ ] Task details show all entered values

### 2.3 Create Task - Name Required
```
GIVEN the user is on Add Task screen
WHEN name field is empty
THEN save FAB should not appear
```

**Assertions:**
- [ ] Save FAB is hidden/disabled when name empty

### 2.4 Edit Task - Change Name
```
GIVEN task "Original" exists
WHEN user opens details, taps edit, changes to "Updated", saves
THEN task list should show "Updated"
```

**Assertions:**
- [ ] Edit screen pre-populates current values
- [ ] Save FAB appears on change
- [ ] Updated name appears in list and details

### 2.5 Edit Task - No Changes = No Save Button
```
GIVEN a task exists
WHEN user opens edit screen without changes
THEN save FAB should not appear
```

**Assertions:**
- [ ] Save FAB hidden when no modifications made

### 2.6 Delete Task
```
GIVEN task "ToDelete" exists
WHEN user opens details and taps delete button
THEN task should be removed from list
```

**Assertions:**
- [ ] Delete button (trash icon) visible in details
- [ ] Task removed after deletion
- [ ] Navigates back to list

### 2.7 Delete Task via Swipe
```
GIVEN task exists in list
WHEN user swipes right on task
THEN task should be deleted
```

**Assertions:**
- [ ] Swipe gesture triggers deletion
- [ ] Task removed from list

---

## 3. Task Completion

### 3.1 Complete Task from List
```
GIVEN incomplete task exists
WHEN user taps checkbox in list
THEN checkbox should show checkmark
AND task should appear pink
```

**Assertions:**
- [ ] Checkbox transitions: empty → pending (dot) → checked
- [ ] Task row color changes to pink
- [ ] Completion date is set

### 3.2 Complete Task from Details
```
GIVEN incomplete task exists
WHEN user opens details and taps checkbox
THEN task should be marked complete
```

**Assertions:**
- [ ] Checkbox in details is tappable
- [ ] Completion date appears in details view

### 3.3 Uncomplete Task
```
GIVEN completed task exists
WHEN user taps checkbox
THEN task should become incomplete
AND checkmark should be removed
```

**Assertions:**
- [ ] Checkbox becomes empty
- [ ] Pink color removed
- [ ] Completion date cleared

---

## 4. Task Filtering

### 4.1 Hide Scheduled Tasks
```
GIVEN tasks with future start dates exist
AND "Show Scheduled" is ON
WHEN user toggles "Show Scheduled" OFF
THEN scheduled tasks should disappear
```

**Assertions:**
- [ ] Filter menu accessible via filter icon
- [ ] Toggle exists for "Show Scheduled"
- [ ] Scheduled tasks hidden when OFF
- [ ] Scheduled tasks visible when ON

### 4.2 Hide Completed Tasks
```
GIVEN completed tasks exist
AND "Show Completed" is ON
WHEN user toggles "Show Completed" OFF
THEN completed tasks should disappear
```

**Assertions:**
- [ ] Toggle exists for "Show Completed"
- [ ] Completed (pink) tasks hidden when OFF
- [ ] Completed tasks visible when ON

### 4.3 Both Filters Combined
```
GIVEN scheduled AND completed tasks exist
WHEN both filters are OFF
THEN only active, non-scheduled tasks visible
```

**Assertions:**
- [ ] Filters combine correctly
- [ ] Only matching tasks shown

---

## 5. Visual Indicators

### 5.1 Scheduled Task - Hollow Appearance
```
GIVEN task with start date = tomorrow
WHEN viewing task list
THEN task should have hollow/muted appearance with light outline
```

**Assertions:**
- [ ] Darker background visible
- [ ] Light outline present
- [ ] Distinct from other task states

### 5.2 Target Passed - Yellow
```
GIVEN task with target date = yesterday (no urgent/due)
WHEN viewing task list
THEN task should appear yellow
```

**Assertions:**
- [ ] Yellow background/indicator visible
- [ ] Date shows "1d ago" or similar

### 5.3 Urgent Passed - Orange
```
GIVEN task with urgent date = yesterday (no due date passed)
WHEN viewing task list
THEN task should appear orange
```

**Assertions:**
- [ ] Orange background/indicator visible
- [ ] Orange takes precedence over yellow

### 5.4 Due Passed - Red
```
GIVEN task with due date = yesterday
WHEN viewing task list
THEN task should appear red
```

**Assertions:**
- [ ] Red background/indicator visible
- [ ] Red takes precedence over orange/yellow

### 5.5 Completed - Pink
```
GIVEN completed task
WHEN viewing task list
THEN task should appear pink with checkmark
```

**Assertions:**
- [ ] Pink background/indicator visible
- [ ] Checkmark shown

### 5.6 Date Display Format
```
GIVEN task with target in 3 days
THEN should display "in 3d"

GIVEN task completed 2 days ago
THEN should display "2d ago"
```

**Assertions:**
- [ ] Future dates: "in Xd" format
- [ ] Past dates: "Xd ago" format
- [ ] Recent: "just now"

---

## 6. Snooze Dialog

### 6.1 Open Snooze via Long Press
```
GIVEN task exists
WHEN user long-presses on task
THEN Snooze Dialog should appear
```

**Assertions:**
- [ ] Dialog title "Snooze Task"
- [ ] Num field (default 3)
- [ ] Unit dropdown (Days, Weeks, Months, Years)
- [ ] "For Date" dropdown

### 6.2 Snooze Shows Only Existing Dates
```
GIVEN task with only Target and Due dates set
WHEN viewing snooze dialog
THEN "For Date" should only show Target and Due options
```

**Assertions:**
- [ ] Only dates the task has are shown
- [ ] Start/Urgent not shown if not set

### 6.3 Snooze Preview Updates
```
GIVEN task with target = today
WHEN user sets Num=5, Unit=Days in snooze
THEN preview should show target = today + 5 days
```

**Assertions:**
- [ ] Date preview visible in dialog
- [ ] Preview updates as values change

### 6.4 Snooze Non-Recurring Task
```
GIVEN non-recurring task with target = today
WHEN user snoozes by 3 days
THEN target should be today + 3 days
```

**Assertions:**
- [ ] No "Change" option for non-recurring
- [ ] Date updated correctly

---

## 7. Sprint Setup

### 7.1 New Sprint Form Displays
```
GIVEN no active sprint
WHEN user navigates to Plan tab
THEN New Sprint form should display
```

**Assertions:**
- [ ] Duration number field visible
- [ ] Duration unit dropdown visible
- [ ] Start Date picker visible
- [ ] End Date (calculated) visible
- [ ] "Create Sprint" button visible

### 7.2 End Date Calculates Correctly
```
GIVEN New Sprint form
WHEN user sets Duration=2, Unit=Weeks, Start=today
THEN End Date should show today + 2 weeks
```

**Assertions:**
- [ ] End date updates on duration change
- [ ] End date updates on unit change
- [ ] End date updates on start date change

### 7.3 Task Selection Shows Available Tasks
```
GIVEN tasks exist
WHEN user creates sprint and reaches task selection
THEN available tasks should be listed
```

**Assertions:**
- [ ] Non-completed tasks appear
- [ ] Tasks are selectable (tap to toggle)

### 7.4 Sprint Summary on Tasks Tab
```
GIVEN active sprint exists
WHEN viewing Tasks tab
THEN sprint summary should show at top
```

**Assertions:**
- [ ] "Day X of Y" visible
- [ ] "X/Y tasks completed" visible
- [ ] "Show Tasks" link visible

### 7.5 Show/Hide Sprint Tasks
```
GIVEN active sprint with tasks
WHEN user taps "Show Tasks" on Tasks tab
THEN sprint tasks should appear with yellow calendar icon
```

**Assertions:**
- [ ] Sprint tasks appear in list
- [ ] Yellow calendar icon on right side
- [ ] Tapping again hides them

---

## 8. Stats Tab

### 8.1 Stats Display Correctly
```
GIVEN 5 completed and 10 active tasks
WHEN viewing Stats tab
THEN should show "5" completed and "10" active
```

**Assertions:**
- [ ] Completed count accurate
- [ ] Active count accurate

### 8.2 Stats Update on Completion
```
GIVEN stats show X completed, Y active
WHEN user completes a task
THEN stats should show X+1 completed, Y-1 active
```

**Assertions:**
- [ ] Counts update after task completion

---

# Part 2: Critical Flow Tests

These tests verify complete user journeys where step interactions matter.

---

## 9. Flow: Complete Sprint Lifecycle

**Purpose:** Verify the entire sprint workflow from creation to completion.

```
SETUP:
  - Create 3 tasks: "Task A", "Task B" (due in 5 days), "Task C"
  - Ensure no active sprint

FLOW:

Step 1: Navigate to Plan tab
  → ASSERT: New Sprint form is displayed
  → ASSERT: "Create Sprint" button visible

Step 2: Configure sprint (1 week starting today)
  → ASSERT: End date shows today + 7 days

Step 3: Tap "Create Sprint"
  → ASSERT: Task Selection screen appears
  → ASSERT: All 3 tasks are listed
  → ASSERT: "Task B" is pre-selected (due within sprint window)

Step 4: Select "Task A" additionally, submit
  → ASSERT: Navigates to Plan tab with sprint tasks
  → ASSERT: "Task A" and "Task B" shown (2 tasks)

Step 5: Navigate to Tasks tab
  → ASSERT: Sprint summary visible at top
  → ASSERT: Shows "Day 1 of 7"
  → ASSERT: Shows "0/2 tasks completed"
  → ASSERT: "Task A" and "Task B" NOT in main list (hidden)

Step 6: Tap "Show Tasks"
  → ASSERT: "Task A" and "Task B" appear with yellow calendar icons
  → ASSERT: "Task C" does NOT have calendar icon

Step 7: Complete "Task A" via checkbox
  → ASSERT: Summary updates to "1/2 tasks completed"
  → ASSERT: "Task A" shows pink with checkmark

Step 8: Complete "Task B"
  → ASSERT: Summary updates to "2/2 tasks completed"

CLEANUP: Delete test tasks and sprint
```

**Why this flow matters:** Sprint creation, task auto-selection, summary display, and completion tracking all interact. A bug in any step affects the whole experience.

---

## 10. Flow: Recurring Task Lifecycle

**Purpose:** Verify recurring tasks create new instances correctly on completion.

```
SETUP:
  - No existing test tasks

FLOW:

Step 1: Create recurring task
  - Name: "Weekly Review"
  - Target Date: today
  - Enable Repeat: Num=1, Unit=Weeks, Anchor=Schedule Dates
  → ASSERT: Task created successfully
  → ASSERT: Task visible in list with today's target

Step 2: View task details
  → ASSERT: Shows "Every 1 Week" or similar recurrence info
  → ASSERT: Target date shows today

Step 3: Complete the task
  → ASSERT: Original task shows completed (pink, checkmark)
  → ASSERT: NEW task instance created
  → ASSERT: New task name is "Weekly Review"
  → ASSERT: New task target date = today + 7 days
  → ASSERT: New task is NOT completed

Step 4: Verify new task details
  → ASSERT: Recurrence info preserved
  → ASSERT: recurIteration incremented

Step 5: Complete new instance
  → ASSERT: Another new instance created
  → ASSERT: Target = today + 14 days

CLEANUP: Delete test tasks
```

**Why this flow matters:** The recurring task system involves multiple components (recurrence helper, middleware, repository). Completing a task triggers instance creation with date calculations.

---

## 11. Flow: Snooze Recurring Task (Schedule Anchor)

**Purpose:** Verify snoozing with "This Task Only" vs "Change Schedule" works correctly.

```
SETUP:
  - Create recurring task:
    - Name: "Scheduled Recurring"
    - Target: today
    - Repeat: 1 Week, Schedule Dates anchor

FLOW - Part A: "This Task Only" (Off-Cycle)

Step 1: Long-press task to open snooze
  → ASSERT: Snooze dialog appears
  → ASSERT: "Change" dropdown visible with options:
    - "This Task Only"
    - "Change Schedule"

Step 2: Set Num=3, Unit=Days, For Date=Target, Change="This Task Only"
  → ASSERT: Preview shows target = today + 3 days

Step 3: Submit snooze
  → ASSERT: Task target is now today + 3 days
  → ASSERT: Task is marked as off-cycle

Step 4: Complete the snoozed task
  → ASSERT: New instance created
  → ASSERT: New instance target = today + 7 days (original schedule, NOT +3+7)
  → ASSERT: New instance is NOT off-cycle

CLEANUP: Delete test tasks

---

FLOW - Part B: "Change Schedule"

Step 1: Create fresh recurring task (same as setup)

Step 2: Snooze with Num=3, Unit=Days, Change="Change Schedule"
  → ASSERT: Task target = today + 3 days
  → ASSERT: Task is NOT marked off-cycle

Step 3: Complete the task
  → ASSERT: New instance target = today + 3 + 7 = today + 10 days
  → ASSERT: Schedule has shifted

CLEANUP: Delete test tasks
```

**Why this flow matters:** The off-cycle flag determines whether snoozing affects just this instance or the entire recurring schedule. This is complex logic that's easy to break.

---

## 12. Flow: Snooze Recurring Task (Completion Anchor)

**Purpose:** Verify completion-anchored recurring tasks calculate dates from actual completion.

```
SETUP:
  - Create recurring task:
    - Name: "Completion Anchored"
    - Target: 3 days ago (overdue)
    - Repeat: 2 Weeks, Completed Date anchor

FLOW:

Step 1: Verify task shows overdue (red or appropriate color)
  → ASSERT: Task visible and appears overdue

Step 2: Snooze is NOT needed - just complete the task
  → ASSERT: Task marked complete

Step 3: Verify new instance
  → ASSERT: New task created
  → ASSERT: New target = TODAY + 14 days (not 3 days ago + 14)
  → ASSERT: Dates calculated from completion, not original schedule

Step 4: Wait simulation - complete new task "late"
  (If possible, manipulate dates or just verify the pattern)
  → ASSERT: Next instance = completion date + 14 days

CLEANUP: Delete test tasks
```

**Why this flow matters:** Completion-anchored tasks must calculate from when the user actually completes, not from scheduled dates. This affects users who complete tasks late.

---

## 13. Flow: Task Date Progression

**Purpose:** Verify a single task progresses through visual states as time passes.

```
SETUP:
  - Create task:
    - Name: "Progressing Task"
    - Start: today - 1 (yesterday, so not scheduled)
    - Target: today
    - Urgent: today + 2
    - Due: today + 4

FLOW:

Step 1: Initial state (target = today)
  → ASSERT: Task appears yellow (target passed or at target)

Step 2: Simulate time passing - urgent date passes
  (Edit task: urgent = yesterday, or create with past dates)
  → ASSERT: Task appears orange
  → ASSERT: Orange takes precedence over yellow

Step 3: Simulate due date passing
  (Edit task: due = yesterday)
  → ASSERT: Task appears red
  → ASSERT: Red takes precedence over orange

Step 4: Complete the task
  → ASSERT: Task appears pink
  → ASSERT: Pink takes precedence over red

Step 5: Uncomplete the task
  → ASSERT: Task returns to red (overdue)

CLEANUP: Delete test task
```

**Why this flow matters:** Color priority logic must work correctly. Users rely on visual cues to prioritize work.

---

# Appendix

## Test Data Helpers

```dart
/// Creates a task with specified properties
Future<TaskItem> createTestTask({
  required String name,
  String? project,
  String? context,
  int? priority,
  int? points,
  int? duration,
  DateTime? startDate,
  DateTime? targetDate,
  DateTime? urgentDate,
  DateTime? dueDate,
  String? notes,
  // Recurrence
  bool recurring = false,
  int? recurNumber,
  String? recurUnit,        // 'Days', 'Weeks', 'Months', 'Years'
  String? recurAnchor,      // 'Schedule Dates', 'Completed Date'
});

/// Creates a sprint and optionally assigns tasks
Future<Sprint> createTestSprint({
  required int durationNumber,
  required String durationUnit,
  required DateTime startDate,
  List<String>? taskIdsToAssign,
});

/// Completes a task by ID
Future<void> completeTask(String taskId);

/// Snoozes a task
Future<void> snoozeTask({
  required String taskId,
  required int numUnits,
  required String unit,
  required String forDate,
  String? scheduleOption,  // 'This Task Only' or 'Change Schedule'
});

/// Deletes all test data (call in tearDown)
Future<void> cleanUpTestData();

/// Gets current task count by status
Future<Map<String, int>> getTaskCounts();
```

## Priority Matrix

### P0 - Must Pass (Blocks Release)

| Test | Reason |
|------|--------|
| 2.1 Create Task - Minimum | Core functionality |
| 3.1 Complete Task from List | Core functionality |
| 9. Flow: Sprint Lifecycle | Critical user journey |
| 10. Flow: Recurring Task Lifecycle | Complex, high-value feature |
| 11. Flow: Snooze Recurring (Schedule) | Easy to break, hard to debug |

### P1 - Should Pass (High Priority)

| Test | Reason |
|------|--------|
| 1.1-1.3 Authentication | Blocking if broken |
| 2.4 Edit Task | Common operation |
| 4.1-4.2 Filtering | Daily use feature |
| 5.1-5.5 Visual Indicators | User relies on these |
| 7.4-7.5 Sprint Summary | Sprint UX |
| 12. Flow: Snooze Recurring (Completion) | Different code path |

### P2 - Should Pass (Medium Priority)

| Test | Reason |
|------|--------|
| 2.2 Create Task - All Fields | Less common path |
| 2.3, 2.5 Validation | Edge cases |
| 6.1-6.4 Snooze Dialog | Important but isolated |
| 8.1-8.2 Stats | Nice to have |
| 13. Flow: Date Progression | Visual verification |

### P3 - Nice to Have

| Test | Reason |
|------|--------|
| 2.6-2.7 Delete variations | Multiple ways to same result |
| 5.6 Date format | Cosmetic |

---

## Execution Notes

1. **Test Isolation**: Each test creates own data, cleans up after
2. **Flow Test Failure**: If step N fails, log which step and continue to cleanup
3. **Parallelization**: Isolated tests can run in parallel; flow tests run sequentially
4. **CI Integration**: Run P0 on every PR, P0+P1 on merge to main, all tests nightly
5. **Flakiness**: If a test fails intermittently, add retry logic or increase timeouts before disabling
6. **Screenshots**: Capture on failure for visual debugging
7. **Emulator**: Use Firestore emulator for consistent, fast tests
