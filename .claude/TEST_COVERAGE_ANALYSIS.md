# TaskMaster Test Coverage Analysis

**Generated:** 2025-10-13
**Total Tests:** 238 passing
**Breakdown:** 41 integration + 96 widget + 101 other (unit/model/etc)

---

## Current Test Coverage

### ✅ Integration Tests (41 tests)
- **Task Display Logic** (14 tests) - Task grouping, date prioritization, project grouping, context/description display
- **Task Filtering** (9 tests) - Active/completed/retired/scheduled filtering, filter combinations
- **Task CRUD Display** (5 tests) - Empty state, viewing tasks, data structure validation
- **Recurring Tasks** (5 tests) - Daily/weekly recurrence display, multiple recurring tasks
- **Sprint Management** (8 tests) - Sprint display, task assignment, multiple sprints, closed sprints

### ✅ Widget Tests (96 tests)
**Simple Widgets (58 tests):**
- DelayedCheckbox, EditableTaskItem, HeaderListItem, ReadOnlyTaskField

**Complex Widgets (38 tests - just added):**
- FilterButton (12 tests) - Popup menu with checkboxes
- NullableDropdown (14 tests) - StatefulWidget with null handling
- EditableTaskField (12 tests) - TextFormField with validation
- StatsCounter (Redux-connected widget)

---

## Missing Test Coverage

### 🔴 HIGH PRIORITY - Critical User Flows (Integration Tests)

#### 1. Task CRUD Operations (4 tests needed)
**Why Critical:** Core functionality that users perform daily. Currently only DISPLAY is tested, not actual CRUD actions.

- [ ] **Task Creation Flow**
  - Open add task screen
  - Fill in form fields (name, dates, project, context, description)
  - Save task
  - Verify task appears in list
  - Verify task persisted to state

- [ ] **Task Editing Flow**
  - Open existing task for edit
  - Modify fields
  - Save changes
  - Verify changes reflected in list
  - Verify state updated

- [ ] **Task Completion (Checkbox)**
  - Tap checkbox on active task
  - Verify completionDate set
  - Verify task moves to completed section (if filter allows)
  - Verify state updated

- [ ] **Task Deletion**
  - Open task details or context menu
  - Delete task
  - Verify task removed from list
  - Verify state updated

**Estimated Effort:** 2-3 hours
**Risk if Untested:** HIGH - Core CRUD broken would be catastrophic

---

#### 2. Sprint Creation & Task Assignment (2 tests needed)

- [ ] **Sprint Creation Flow**
  - Navigate to sprint creation screen
  - Fill sprint form (dates, units, sprint number)
  - Save sprint
  - Verify sprint appears in plan view
  - Verify state updated

- [ ] **Task Assignment to Sprint**
  - Open task for edit
  - Assign to sprint
  - Verify SprintAssignment created
  - Verify task appears in sprint view

**Estimated Effort:** 1-2 hours
**Risk if Untested:** MEDIUM - Sprint feature is important but not used by all users

---

#### 2b. Recurring Task Completion (1 test needed) ⭐ **MOVED FROM MEDIUM TO HIGH PRIORITY**

**Why Critical:** Most tasks in the data have recurrences. Complex date calculation logic with high risk of regression.

- [ ] **Completing Recurring Task Creates Next Iteration**
  - Complete a recurring task (checkbox)
  - Verify new task created with updated dates
  - Verify recurrence metadata maintained (recurNumber, recurUnit, anchorDate)
  - Verify original task marked complete
  - Test with daily, weekly, and monthly recurrence patterns

**Estimated Effort:** 1 hour
**Risk if Untested:** HIGH - Most data uses recurrences, complex logic, creates tasks automatically

---

#### 3. Task Details Screen (1 test needed)

- [ ] **Task Details Display**
  - Tap task to open details
  - Verify all fields display correctly
  - Verify edit button navigates to edit screen
  - Test with various task configurations (with/without dates, projects, etc.)

**Estimated Effort:** 30-45 min
**Risk if Untested:** MEDIUM - Details screen is heavily used

---

### 🟡 MEDIUM PRIORITY - Important But Not Critical

#### 4. Filter Toggle Interaction (1 test)

- [ ] **Filter Button Interaction**
  - Tap filter button
  - Toggle "Show Completed"
  - Verify completed tasks appear/disappear
  - Toggle "Show Scheduled"
  - Verify scheduled tasks appear/disappear

**Estimated Effort:** 30 min
**Risk if Untested:** MEDIUM - Already have widget test for FilterButton, but not integration test

---

#### 5. Snooze Functionality (1 test)

- [ ] **Snooze Task**
  - Open snooze dialog for task
  - Select snooze duration
  - Verify task snoozed (startDate updated)
  - Verify task moves to scheduled section

**Estimated Effort:** 30-45 min
**Risk if Untested:** MEDIUM - Feature exists but less frequently used

---

#### 6. Recurring Task Completion (1 test - commented out) - **MOVED TO HIGH PRIORITY**

**See High Priority section - added as item #2b below.**

---

#### 7. Tab Navigation (1 test)

- [ ] **Navigate Between Tabs**
  - Start on Tasks tab
  - Tap Plan tab
  - Verify plan view loads
  - Tap Stats tab
  - Verify stats display
  - Verify state.activeTab updates

**Estimated Effort:** 20-30 min
**Risk if Untested:** LOW - Simple navigation, unlikely to break

---

### 🔴 HIGH PRIORITY - Complex Widgets (Widget Tests)

#### 8. ClearableDateTimeField (8-10 tests needed)

**Why Critical:** Used extensively in add/edit task screen for all date fields.

- [ ] Displays date picker when tapped
- [ ] Updates value when date selected
- [ ] Displays selected date in readable format
- [ ] Clear button removes date value
- [ ] Null/empty state displays correctly
- [ ] Different date formats (date only vs datetime)
- [ ] Validator integration
- [ ] onChanged callback

**Estimated Effort:** 1-1.5 hours
**Risk if Untested:** HIGH - Heavily used, complex state management

---

#### 9. AddEditScreen (8-10 tests needed)

**Why Critical:** Primary screen for task creation/editing.

- [ ] Form displays with all fields (Redux-connected)
- [ ] Fields populate when editing existing task
- [ ] Save button triggers form validation
- [ ] Save button dispatches correct action
- [ ] Cancel button navigates back
- [ ] Form validation errors display
- [ ] Different field combinations work
- [ ] Dropdown selections work (project, context, recurrence)

**Estimated Effort:** 1.5-2 hours
**Risk if Untested:** HIGH - Complex form with many fields

---

#### 10. DetailsScreen (4-6 tests needed)

- [ ] Displays all task fields (Redux-connected)
- [ ] Edit button navigates to AddEditScreen
- [ ] Task with all fields displays correctly
- [ ] Task with minimal fields displays correctly
- [ ] Recurrence info displays for recurring tasks
- [ ] Sprint assignment info displays

**Estimated Effort:** 45-60 min
**Risk if Untested:** MEDIUM - Mostly read-only display

---

### 🟡 MEDIUM PRIORITY - Complex Widgets

#### 11. NewSprint Widget (6-8 tests)

- [ ] Form displays with all fields
- [ ] Date pickers work
- [ ] Number input validation
- [ ] Save button validation
- [ ] Cancel button works
- [ ] Form state management

**Estimated Effort:** 45-60 min
**Risk if Untested:** MEDIUM - Sprint creation is important but less frequent

---

#### 12. SnoozeDialog (4-6 tests)

- [ ] Dialog displays with duration options
- [ ] Selecting option updates value
- [ ] Save button returns selected duration
- [ ] Cancel button dismisses

**Estimated Effort:** 30-45 min
**Risk if Untested:** LOW-MEDIUM - Self-contained dialog

---

#### 13. TaskItemItem (6-8 tests)

**Note:** This is the individual task row in the list.

- [ ] Displays task name
- [ ] Displays checkbox (unchecked for active)
- [ ] Displays date info (due/urgent/target)
- [ ] Displays project/context badges
- [ ] Tapping navigates to details
- [ ] Checkbox tap triggers completion
- [ ] Completed task styling
- [ ] Recurrence indicator displays

**Estimated Effort:** 1 hour
**Risk if Untested:** MEDIUM - Core list item, but display logic already tested in integration

---

### 🟢 LOW PRIORITY - Simple/External

#### 14. Simple Widgets (Low complexity, low risk)

- [ ] **LoadingIndicator** - Just shows spinner
- [ ] **LoadFailed** - Error message display
- [ ] **Splash** - Loading screen
- [ ] **RefreshButton** - Simple icon button
- [ ] **ReadOnlyTaskFieldSmall** - Variant of already-tested widget

**Estimated Effort:** 15-30 min total
**Risk if Untested:** VERY LOW

---

#### 15. External/Platform-Specific (Don't test - out of scope)

- ❌ **SignIn** - External auth (Google Sign-In)
- ❌ **Authentication Flow** - Firebase integration
- ❌ **Offline Mode** - Firebase sync
- ❌ **Notifications** - Platform-specific APIs

---

## Recommended Testing Plan

### Phase 1: Critical User Flows (Est: 4-6 hours)
**Goal:** Ensure core CRUD operations work end-to-end

1. Task Creation Flow (1 hour)
2. Task Editing Flow (1 hour)
3. Task Completion via Checkbox (45 min)
4. Task Deletion (30 min)
5. Task Details Screen (45 min)
6. ClearableDateTimeField Widget (1.5 hours)

**Value:** Covers most critical user journeys. Highest ROI.

---

### Phase 2: Form & Screen Tests (Est: 3-4 hours)
**Goal:** Test complex form screens and widgets

1. AddEditScreen Widget Tests (2 hours)
2. DetailsScreen Widget Tests (1 hour)
3. TaskItemItem Widget Tests (1 hour)

**Value:** Ensures form validation, Redux connections, and display logic work correctly.

---

### Phase 3: Sprint Features (Est: 2-3 hours)
**Goal:** Test sprint creation and management

1. Sprint Creation Flow (1 hour)
2. Task Assignment to Sprint (45 min)
3. NewSprint Widget Tests (1 hour)

**Value:** Important for users who use sprint planning. Medium priority.

---

### Phase 4: Supporting Features (Est: 2-3 hours)
**Goal:** Test remaining interactive features

1. Filter Toggle Integration (30 min)
2. Snooze Functionality (45 min)
3. SnoozeDialog Widget Tests (45 min)
4. Recurring Task Completion (1 hour)
5. Tab Navigation (20 min)

**Value:** Completes coverage of interactive features.

---

### Phase 5: Polish (Est: 30-45 min)
**Goal:** Test simple widgets for completeness

1. Simple widget tests (LoadingIndicator, LoadFailed, Splash, etc.)

**Value:** Minimal, but achieves near-complete coverage.

---

## Summary Statistics

### Current State
- **238 tests** total
- **Strong coverage** on: Task display logic, filtering, grouping, basic data validation
- **Weak coverage** on: User interactions, CRUD operations, forms, complex widgets
- **No coverage** on: Auth, offline, notifications (intentional - external)

### After Phase 1 (Recommended Minimum)
- **~270 tests** (+32 tests)
- **Coverage:** All critical CRUD flows + complex date widget
- **Time Investment:** 4-6 hours
- **Risk Reduction:** 70-80% of critical user-facing bugs

### After Phase 2
- **~310 tests** (+40 tests)
- **Coverage:** All major screens and forms
- **Time Investment:** 7-10 hours total
- **Risk Reduction:** 85-90% of user-facing bugs

### After All Phases
- **~360 tests** (+122 tests)
- **Coverage:** Comprehensive (excluding external systems)
- **Time Investment:** 12-16 hours total
- **Risk Reduction:** 95%+ of user-facing bugs

---

## Recommendation

**Start with Phase 1.** It gives you the highest return on investment:
- Tests the flows users do every day (create, edit, complete, delete tasks)
- Tests the most complex widget (ClearableDateTimeField)
- Only 4-6 hours of work
- Catches 70-80% of potential critical bugs

Then evaluate if you want to continue with Phase 2-4 based on how comfortable you feel with the coverage.

**Skip Phase 5** unless you're going for 100% coverage for its own sake.
