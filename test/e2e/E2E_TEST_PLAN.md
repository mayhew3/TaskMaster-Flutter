# TaskMaster E2E Test Plan

This document outlines comprehensive end-to-end tests to ensure critical user flows work correctly and breaking changes are detected.

---

## Test Categories

1. [Authentication](#1-authentication)
2. [Navigation](#2-navigation)
3. [Task Creation](#3-task-creation)
4. [Task Editing](#4-task-editing)
5. [Task Completion](#5-task-completion)
6. [Task Deletion](#6-task-deletion)
7. [Task Filtering](#7-task-filtering)
8. [Task Visual Indicators](#8-task-visual-indicators)
9. [Recurring Tasks](#9-recurring-tasks)
10. [Snoozing Tasks](#10-snoozing-tasks)
11. [Sprint Creation](#11-sprint-creation)
12. [Sprint Task Selection](#12-sprint-task-selection)
13. [Active Sprint Management](#13-active-sprint-management)
14. [Stats Tab](#14-stats-tab)
15. [Offline Behavior](#15-offline-behavior)
16. [Data Persistence](#16-data-persistence)

---

## 1. Authentication

### 1.1 Sign In Flow
```
GIVEN the user is not authenticated
WHEN the app launches
THEN the sign-in screen should be displayed
AND the "Sign in with Google" button should be visible
```

**Assertions:**
- Sign-in screen is displayed
- Google sign-in button is tappable
- Loading indicator appears during authentication
- On success, user is redirected to Tasks tab
- User's data loads after sign-in

### 1.2 Sign Out Flow
```
GIVEN the user is authenticated
WHEN the user opens the drawer menu
AND taps "Sign Out"
THEN the user should be signed out
AND redirected to the sign-in screen
```

**Assertions:**
- Drawer menu opens from left swipe or menu icon
- "Sign Out" option is visible
- After sign out, sign-in screen is displayed
- Previous user data is not accessible

### 1.3 Session Persistence
```
GIVEN the user has previously signed in
WHEN the app is closed and reopened
THEN the user should be automatically signed in (silent sign-in)
AND their tasks should load
```

**Assertions:**
- No sign-in prompt on app restart
- User data loads automatically
- Tasks tab is displayed

---

## 2. Navigation

### 2.1 Bottom Navigation - Tasks Tab
```
GIVEN the user is on any tab
WHEN the user taps the Tasks tab icon
THEN the Tasks tab should be displayed
```

**Assertions:**
- Tasks list is visible
- Add task FAB (+) is visible
- Filter icon is in app bar
- Refresh icon is in app bar

### 2.2 Bottom Navigation - Plan Tab
```
GIVEN the user is on any tab
WHEN the user taps the Plan tab icon
THEN the Plan tab should be displayed
```

**Assertions:**
- Plan tab content is visible
- Either "New Sprint" form or active sprint tasks are shown

### 2.3 Bottom Navigation - Stats Tab
```
GIVEN the user is on any tab
WHEN the user taps the Stats tab icon
THEN the Stats tab should be displayed
```

**Assertions:**
- "Completed Tasks" count is visible
- "Active Tasks" count is visible

### 2.4 Task List to Task Details Navigation
```
GIVEN the user is on the Tasks tab with tasks visible
WHEN the user taps on a task
THEN the Task Details screen should open
```

**Assertions:**
- Task Details screen is displayed
- Task name is shown
- All task fields are displayed (dates, project, context, etc.)
- Edit FAB (pencil icon) is visible
- Delete button (trash icon) is visible
- Checkbox is visible

### 2.5 Task Details to Edit Screen Navigation
```
GIVEN the user is on the Task Details screen
WHEN the user taps the Edit FAB
THEN the Edit Task screen should open
```

**Assertions:**
- Edit screen is displayed with "Task Details" title
- All fields are pre-populated with current task values
- Save FAB appears when changes are made

### 2.6 Drawer Menu Access
```
GIVEN the user is on any main screen
WHEN the user swipes from the left edge (or taps menu icon)
THEN the drawer menu should open
```

**Assertions:**
- Drawer slides in from left
- "Actions" header is visible
- "Sign Out" option is visible

---

## 3. Task Creation

### 3.1 Create Basic Task
```
GIVEN the user is on the Tasks tab
WHEN the user taps the + FAB
AND enters a task name "Test Task"
AND taps the save button
THEN a new task should be created
AND appear in the task list
```

**Assertions:**
- Add Task screen opens
- Name field is empty initially
- Save FAB appears after entering name
- After save, navigates back to task list
- New task "Test Task" appears in list

### 3.2 Create Task with All Fields
```
GIVEN the user is on the Add Task screen
WHEN the user fills in:
  - Name: "Complete Task"
  - Project: "Career"
  - Context: "Computer"
  - Priority: 5
  - Points: 10
  - Length: 2
  - Start Date: tomorrow
  - Target Date: in 3 days
  - Urgent Date: in 5 days
  - Due Date: in 7 days
  - Notes: "Test notes"
AND taps save
THEN the task should be created with all fields populated
```

**Assertions:**
- All dropdown fields show correct options
- Date pickers function correctly
- Numeric fields accept numbers only
- All values are saved correctly
- Task details show all entered values

### 3.3 Create Task - Name Required Validation
```
GIVEN the user is on the Add Task screen
WHEN the user does not enter a name
THEN the save button should not appear
OR validation error should be shown
```

**Assertions:**
- Save FAB is hidden when name is empty
- Cannot submit form without name

### 3.4 Create Task with Project Selection
```
GIVEN the user is on the Add Task screen
WHEN the user taps the Project dropdown
THEN all project options should be available:
  - (none), Career, Hobby, Friends, Family, Health,
    Maintenance, Organization, Shopping, Entertainment,
    WIG Mentorship, Writing, Bugs, Projects
```

**Assertions:**
- All 14 project options are visible
- Selection updates the field
- "(none)" clears the project

### 3.5 Create Task with Context Selection
```
GIVEN the user is on the Add Task screen
WHEN the user taps the Context dropdown
THEN all context options should be available:
  - (none), Computer, Home, Office, E-Mail, Phone,
    Outside, Reading, Planning
```

**Assertions:**
- All 9 context options are visible
- Selection updates the field
- "(none)" clears the context

---

## 4. Task Editing

### 4.1 Edit Task Name
```
GIVEN a task "Original Name" exists
WHEN the user opens the task details
AND taps edit
AND changes the name to "Updated Name"
AND saves
THEN the task name should be updated
```

**Assertions:**
- Edit screen shows current name
- Save FAB appears after change
- After save, task list shows "Updated Name"
- Task details show "Updated Name"

### 4.2 Edit Task Dates
```
GIVEN a task exists without dates
WHEN the user edits the task
AND adds a Start Date
AND adds a Target Date
AND saves
THEN the task should display the new dates
```

**Assertions:**
- Date fields are clearable
- Date picker shows correct initial date
- Time can be set along with date
- Saved dates appear in task details

### 4.3 Clear Task Field
```
GIVEN a task with a Project set
WHEN the user edits the task
AND changes Project to "(none)"
AND saves
THEN the project should be cleared
```

**Assertions:**
- Selecting "(none)" clears the field
- Task details no longer show project

### 4.4 Edit Without Changes - No Save Button
```
GIVEN a task exists
WHEN the user opens edit screen
AND makes no changes
THEN the save FAB should not appear
```

**Assertions:**
- Save FAB is hidden when no changes made
- Navigating back doesn't modify task

---

## 5. Task Completion

### 5.1 Complete Task from List
```
GIVEN an incomplete task exists
WHEN the user taps the checkbox in the task list
THEN the task should be marked as complete
AND show a checkmark
AND the task should appear pink (completed color)
```

**Assertions:**
- Checkbox changes from empty to pending (dot)
- Checkbox changes from pending to checked
- Task row color changes to pink
- Completion date is set

### 5.2 Complete Task from Details
```
GIVEN an incomplete task exists
WHEN the user opens task details
AND taps the checkbox
THEN the task should be marked as complete
```

**Assertions:**
- Checkbox in details view is tappable
- Task completion updates immediately
- Completion date appears in details

### 5.3 Uncomplete Task
```
GIVEN a completed task exists
WHEN the user taps the checkbox
THEN the task should be marked as incomplete
AND the checkmark should be removed
```

**Assertions:**
- Checkbox becomes empty
- Completion date is cleared
- Task color changes from pink

### 5.4 Pending State During Completion
```
GIVEN an incomplete task exists
WHEN the user taps the checkbox
THEN a pending state (dot icon) should briefly appear
THEN the checkmark should appear after backend processing
```

**Assertions:**
- Dot icon appears during processing
- Transitions to checkmark on success

---

## 6. Task Deletion

### 6.1 Delete Task from Details
```
GIVEN a task exists
WHEN the user opens task details
AND taps the delete (trash) button
AND confirms deletion
THEN the task should be deleted
AND removed from the task list
```

**Assertions:**
- Delete button is visible in details
- Confirmation dialog appears (if implemented)
- Task is removed from list
- Navigates back to task list

### 6.2 Delete Task via Swipe
```
GIVEN a task exists in the list
WHEN the user swipes right on the task
THEN the task should be deleted (with confirmation if implemented)
```

**Assertions:**
- Swipe gesture is recognized
- Task is removed from list

---

## 7. Task Filtering

### 7.1 Filter - Hide Scheduled Tasks
```
GIVEN tasks exist with future start dates (scheduled)
AND "Show Scheduled" is ON
WHEN the user taps filter and turns OFF "Show Scheduled"
THEN scheduled tasks should be hidden from the list
```

**Assertions:**
- Filter menu opens on tap
- "Show Scheduled" toggle is visible
- Scheduled tasks disappear when toggled off
- Scheduled tasks reappear when toggled on

### 7.2 Filter - Hide Completed Tasks
```
GIVEN completed tasks exist
AND "Show Completed" is ON
WHEN the user taps filter and turns OFF "Show Completed"
THEN completed tasks should be hidden from the list
```

**Assertions:**
- "Show Completed" toggle is visible
- Completed tasks (pink) disappear when toggled off
- Completed tasks reappear when toggled on

### 7.3 Multiple Filters Combined
```
GIVEN scheduled and completed tasks exist
WHEN both "Show Scheduled" and "Show Completed" are OFF
THEN only active, non-scheduled tasks should be visible
```

**Assertions:**
- Both filters can be applied simultaneously
- Only matching tasks are shown

---

## 8. Task Visual Indicators

### 8.1 Scheduled Task Appearance
```
GIVEN a task with a future start date
WHEN viewing the task list
THEN the task should have a hollow/muted appearance
WITH darker background and light outline
```

**Assertions:**
- Task has distinct visual style (not solid color)
- Light outline is visible
- Background is darker/muted

### 8.2 Target Date Passed - Yellow
```
GIVEN a task with target date in the past
AND no urgent or due date passed
WHEN viewing the task list
THEN the task should appear yellow
```

**Assertions:**
- Task row has yellow background/indicator
- Date display shows target info

### 8.3 Urgent Date Passed - Orange
```
GIVEN a task with urgent date in the past
AND no due date passed
WHEN viewing the task list
THEN the task should appear orange
```

**Assertions:**
- Task row has orange background/indicator
- Takes precedence over yellow (target)

### 8.4 Due Date Passed - Red
```
GIVEN a task with due date in the past
WHEN viewing the task list
THEN the task should appear red
```

**Assertions:**
- Task row has red background/indicator
- Takes precedence over orange and yellow

### 8.5 Completed Task - Pink
```
GIVEN a completed task
WHEN viewing the task list
THEN the task should appear pink
```

**Assertions:**
- Task row has pink background/indicator
- Checkmark is visible

### 8.6 Date Display Format
```
GIVEN a task with a target date 3 days in the future
WHEN viewing the task list
THEN the date should display as "in 3d"

GIVEN a task completed 2 days ago
WHEN viewing the task list
THEN it should display as "2d ago"
```

**Assertions:**
- Relative dates are formatted correctly
- "in Xd" for future dates
- "Xd ago" for past dates
- "just now" for very recent

---

## 9. Recurring Tasks

### 9.1 Create Recurring Task - Schedule Anchor
```
GIVEN the user is creating a task
WHEN they set a target date
AND enable Repeat
AND set: Num=1, Unit=Weeks, Anchor=Schedule Dates
AND save
THEN the task should be created as recurring
```

**Assertions:**
- Repeat toggle appears after setting a date
- Repeat fields appear when toggled on
- Num, Unit, and Anchor fields are required
- Task is saved with recurrence settings
- Task details show "Every 1 Week" recurrence info

### 9.2 Create Recurring Task - Completion Anchor
```
GIVEN the user is creating a task
WHEN they set a due date
AND enable Repeat
AND set: Num=2, Unit=Weeks, Anchor=Completed Date
AND save
THEN the task should be created as recurring from completion
```

**Assertions:**
- Anchor shows "Completed Date" option
- Task is saved with recurWait=true
- Task details show "Every 2 Weeks (after completion)"

### 9.3 Complete Recurring Task - New Instance Created
```
GIVEN a recurring task exists (weekly, schedule anchor)
WITH target date = today
WHEN the user completes the task
THEN the task should be marked complete
AND a new task instance should be created
WITH target date = 1 week from original target
```

**Assertions:**
- Original task shows as completed
- New task appears in list (or becomes visible after filter)
- New task has updated dates based on recurrence
- New task has incremented recurIteration

### 9.4 Complete Recurring Task - Completion Anchor Dates
```
GIVEN a recurring task with completion anchor
WITH target date = 3 days ago (overdue)
WHEN the user completes the task today
THEN a new task should be created
WITH target date = recurrence interval from TODAY (not original date)
```

**Assertions:**
- New task dates calculated from completion date
- Not from original scheduled date

### 9.5 Recurring Task Validation
```
GIVEN the user is creating a task with Repeat enabled
WHEN Num is empty
OR Unit is "(none)"
OR Anchor is "(none)"
THEN validation errors should appear
AND save should be prevented
```

**Assertions:**
- "Required" error on empty Num
- "Unit is required for repeat" error
- "Anchor Date is required for repeat" error

### 9.6 Disable Recurrence on Existing Task
```
GIVEN a recurring task exists
WHEN the user edits it
AND toggles Repeat OFF
AND saves
THEN the task should no longer be recurring
```

**Assertions:**
- Repeat toggle can be turned off
- Recurrence fields are cleared
- Completing task no longer creates new instance

---

## 10. Snoozing Tasks

### 10.1 Open Snooze Dialog
```
GIVEN a task exists
WHEN the user long-presses on the task
THEN the Snooze Dialog should appear
```

**Assertions:**
- Long press triggers dialog
- Dialog title is "Snooze Task"
- Num, Unit, and For Date fields are visible

### 10.2 Snooze Task - Basic
```
GIVEN a task with target date = today
WHEN the user opens snooze dialog
AND sets Num=3, Unit=Days, For Date=Target
AND taps Submit
THEN the task's target date should be 3 days from now
```

**Assertions:**
- Date preview shows updated date before submit
- After submit, task list reflects new date
- Task details show updated target date

### 10.3 Snooze Different Date Types
```
GIVEN a task with Start, Target, Urgent, and Due dates
WHEN the user opens snooze dialog
THEN "For Date" dropdown should show all 4 date types
AND selecting each should snooze that specific date
```

**Assertions:**
- All set dates appear in dropdown
- Only dates the task has are shown
- Correct date is modified

### 10.4 Snooze Recurring Task - This Task Only
```
GIVEN a recurring task (schedule anchor)
WHEN the user opens snooze dialog
THEN "Change" option should appear with:
  - "This Task Only"
  - "Change Schedule"
WHEN user selects "This Task Only" and submits
THEN only this instance should be snoozed
AND the task should be marked as off-cycle
```

**Assertions:**
- Schedule option appears for recurring tasks
- Off-cycle flag is set
- Future instances maintain original schedule

### 10.5 Snooze Recurring Task - Change Schedule
```
GIVEN a recurring task (schedule anchor)
WHEN the user selects "Change Schedule" and submits
THEN the base schedule should be modified
AND future instances will use new dates
```

**Assertions:**
- Off-cycle flag is NOT set
- Recurrence schedule is updated

### 10.6 Snooze Preview
```
GIVEN a task with multiple dates set
WHEN the user opens snooze dialog
AND modifies snooze values
THEN all task dates should be previewed in the dialog
```

**Assertions:**
- All current dates are displayed
- Preview updates as values change
- Dates formatted correctly (day of week, month, day)

---

## 11. Sprint Creation

### 11.1 Create Sprint - Basic
```
GIVEN no active sprint exists
WHEN the user navigates to Plan tab
THEN the "New Sprint" form should be displayed
```

**Assertions:**
- Duration number field is visible
- Duration unit dropdown (Days, Weeks, Months, Years)
- Start Date picker is visible
- Start Time picker is visible
- End Date is calculated and displayed
- "Create Sprint" button is visible

### 11.2 Create Sprint - Set Duration
```
GIVEN the New Sprint form
WHEN the user sets Duration=2, Unit=Weeks
AND sets Start Date to today
THEN End Date should show 2 weeks from today
```

**Assertions:**
- End date auto-calculates
- Updates when duration or unit changes

### 11.3 Create Sprint - Navigate to Task Selection
```
GIVEN the New Sprint form is filled
WHEN the user taps "Create Sprint"
THEN the Task Selection screen should appear
```

**Assertions:**
- Sprint is created (but not finalized until tasks selected)
- Task selection list appears
- Available tasks are listed

### 11.4 Last Sprint Information
```
GIVEN a previous sprint was completed
WHEN viewing the New Sprint form
THEN information about the last sprint should be displayed
```

**Assertions:**
- Shows when last sprint ended
- Helps user plan next sprint start

---

## 12. Sprint Task Selection

### 12.1 View Available Tasks
```
GIVEN the user is on Task Selection screen
THEN all non-completed, non-retired tasks should be listed
```

**Assertions:**
- Tasks are selectable (checkbox or tap to toggle)
- Task names are visible
- Date warnings are shown

### 12.2 Auto-Select Urgent/Due Tasks
```
GIVEN tasks with urgent/due dates within sprint window
WHEN viewing Task Selection
THEN those tasks should be pre-selected
```

**Assertions:**
- Tasks due before sprint end are checked
- Tasks urgent before sprint end are checked

### 12.3 Highlight Previous Sprint Tasks
```
GIVEN tasks were in the previous sprint
WHEN viewing Task Selection
THEN those tasks should be visually highlighted
```

**Assertions:**
- Previous sprint tasks have distinct styling
- Easy to identify carryover tasks

### 12.4 Show Recurrence Previews
```
GIVEN a recurring task that will generate a new instance during sprint
WHEN viewing Task Selection
THEN the preview of the future instance should be shown
AND be selectable
```

**Assertions:**
- Preview tasks are distinguishable from real tasks
- Selecting preview assigns future instance to sprint
- Preview shows expected dates

### 12.5 Submit Task Selection
```
GIVEN the user has selected tasks
WHEN the user taps "Submit"
THEN the sprint should be activated
AND selected tasks assigned to it
```

**Assertions:**
- Sprint becomes active
- Tasks are linked to sprint
- Plan tab shows sprint tasks
- Tasks tab shows sprint summary

---

## 13. Active Sprint Management

### 13.1 Sprint Summary on Tasks Tab
```
GIVEN an active sprint exists
WHEN the user views the Tasks tab
THEN a sprint summary should appear at the top showing:
  - "Day X of Y"
  - "X/Y tasks completed"
  - "Show Tasks" link
```

**Assertions:**
- Summary is visible at top of task list
- Day count is accurate
- Completion count is accurate
- "Show Tasks" link is tappable

### 13.2 Show/Hide Sprint Tasks
```
GIVEN sprint summary is visible on Tasks tab
WHEN the user taps "Show Tasks"
THEN tasks in the active sprint should appear in the list
WITH yellow calendar icons
```

**Assertions:**
- Sprint tasks appear inline
- Yellow calendar icon on right side of each
- Tapping again hides sprint tasks

### 13.3 Sprint Tasks Hidden by Default
```
GIVEN an active sprint with tasks
WHEN viewing Tasks tab (without clicking Show Tasks)
THEN sprint tasks should NOT appear in the main list
```

**Assertions:**
- Sprint tasks are hidden initially
- Regular tasks are still visible
- Sprint summary provides access to sprint tasks

### 13.4 Plan Tab - Active Sprint Tasks
```
GIVEN an active sprint exists
WHEN the user views the Plan tab
THEN the sprint task list should be displayed
```

**Assertions:**
- Sprint tasks are listed
- Tasks can be completed from Plan tab
- Filter options are available

### 13.5 Complete Sprint Task
```
GIVEN an active sprint with tasks
WHEN the user completes a sprint task
THEN the completion count should update
AND the task should show as completed
```

**Assertions:**
- Count updates from "X/Y" to "X+1/Y"
- Task shows checkmark and pink color
- Works from both Tasks and Plan tabs

### 13.6 Remove Task from Sprint (via swipe)
```
GIVEN a task is in the active sprint
WHEN the user swipes right on the task (in Plan tab)
THEN the task should be removed from the sprint
```

**Assertions:**
- Task no longer appears in sprint list
- Task still exists (not deleted)
- Task appears in regular task list

### 13.7 Sprint Filters
```
GIVEN an active sprint with scheduled and completed tasks
WHEN user toggles "Show Scheduled" OFF in Plan tab
THEN scheduled sprint tasks should be hidden

WHEN user toggles "Show Completed" OFF
THEN completed sprint tasks should be hidden
```

**Assertions:**
- Filters work on Plan tab sprint list
- Independent from Tasks tab filters

---

## 14. Stats Tab

### 14.1 Completed Tasks Count
```
GIVEN some tasks are completed
WHEN viewing the Stats tab
THEN "Completed Tasks" should show the correct count
```

**Assertions:**
- Count matches actual completed tasks
- Updates when tasks are completed

### 14.2 Active Tasks Count
```
GIVEN some tasks are incomplete
WHEN viewing the Stats tab
THEN "Active Tasks" should show the correct count
```

**Assertions:**
- Count matches actual incomplete tasks
- Updates when tasks are completed or added

### 14.3 Stats Update on Task Changes
```
GIVEN Stats tab shows X completed, Y active
WHEN the user completes a task
THEN stats should update to X+1 completed, Y-1 active
```

**Assertions:**
- Stats update in real-time (or on tab focus)
- Counts are accurate

---

## 15. Offline Behavior

### 15.1 Continue Working After Connection Loss
```
GIVEN the user is authenticated and viewing tasks
WHEN the network connection is lost
THEN the user should still be able to:
  - View existing tasks
  - Complete tasks
  - Edit tasks
```

**Assertions:**
- App doesn't crash on connection loss
- Local data remains accessible
- Changes are queued for sync

### 15.2 Sync on Reconnection
```
GIVEN changes were made while offline
WHEN the network connection is restored
THEN changes should sync to the server
```

**Assertions:**
- Queued changes are sent
- Server data is updated
- No data loss

### 15.3 Authentication Requires Network
```
GIVEN the user is not authenticated
AND there is no network connection
WHEN the app launches
THEN sign-in should fail or wait for connection
```

**Assertions:**
- Cannot authenticate without network
- Appropriate error or waiting state shown

---

## 16. Data Persistence

### 16.1 Data Survives App Restart
```
GIVEN tasks, sprints, and settings exist
WHEN the app is closed and reopened
THEN all data should be preserved
```

**Assertions:**
- Tasks appear as before
- Active sprint is still active
- Filter settings are remembered
- Completion states are preserved

### 16.2 Real-time Sync
```
GIVEN the user makes a change on one device
WHEN viewing on another device (or after refresh)
THEN the change should appear
```

**Assertions:**
- Changes sync across sessions
- Refresh button triggers sync
- Real-time listeners update UI

### 16.3 App Badge Count
```
GIVEN tasks with urgent or due dates passed
WHEN viewing the app icon
THEN the badge should show the count of urgent/overdue tasks
```

**Assertions:**
- Badge count matches urgent + overdue incomplete tasks
- Badge updates when tasks change
- Badge clears when all urgent/overdue tasks are completed

---

## Test Data Setup Helpers

### Create Test Task
```dart
Future<TaskItem> createTestTask({
  required String name,
  String? project,
  String? context,
  DateTime? startDate,
  DateTime? targetDate,
  DateTime? urgentDate,
  DateTime? dueDate,
  bool recurring = false,
  int? recurNumber,
  String? recurUnit,
  bool? recurWait,
});
```

### Create Test Sprint
```dart
Future<Sprint> createTestSprint({
  required int durationNumber,
  required String durationUnit,
  required DateTime startDate,
  List<String>? taskIds,
});
```

### Complete Test Task
```dart
Future<void> completeTask(String taskId);
```

### Clean Up Test Data
```dart
Future<void> cleanUpTestData();
```

---

## Priority Levels

### P0 - Critical (Must Pass)
- 3.1 Create Basic Task
- 5.1 Complete Task from List
- 9.3 Complete Recurring Task - New Instance Created
- 11.3 Create Sprint - Navigate to Task Selection
- 12.5 Submit Task Selection
- 13.1 Sprint Summary on Tasks Tab

### P1 - High (Should Pass)
- 1.1 Sign In Flow
- 4.1 Edit Task Name
- 7.1 Filter - Hide Scheduled Tasks
- 8.1-8.5 All Visual Indicators
- 10.2 Snooze Task - Basic
- 13.5 Complete Sprint Task

### P2 - Medium (Important)
- All remaining tests

---

## Implementation Notes

1. **Test Isolation**: Each test should create its own data and clean up after
2. **Authentication**: Use a test account or mock authentication for CI
3. **Timing**: Add appropriate waits for async operations and animations
4. **Assertions**: Verify both UI state and data state where possible
5. **Screenshots**: Capture screenshots on failure for debugging
6. **Firestore Emulator**: Use local emulator for consistent test environment
