# TaskMaster CLI Tools

This directory contains Node.js CLI tools for debugging and maintenance of TaskMaster Firestore data.

## Setup

```bash
cd bin
npm install
```

---

## Firestore Export Tool

Exports Firestore collections to CSV files for analysis.

### Usage

```bash
# Export all collections from emulator
node bin/firestore-export.js --emulator

# Export specific collections
node bin/firestore-export.js --emulator --collections=tasks,taskRecurrences

# Export by specific email
node bin/firestore-export.js --emulator --email=other@example.com

# Export by personDocId
node bin/firestore-export.js --emulator --person-doc-id=abc123

# Custom output directory
node bin/firestore-export.js --emulator --output=./my-exports

# Show help
node bin/firestore-export.js --help
```

### Options

| Option | Description |
|--------|-------------|
| `--emulator` | Connect to Firestore emulator (localhost:8085) |
| `--production` | Connect to production Firestore (requires auth) |
| `--email=<email>` | Filter by user email (looks up personDocId) |
| `--person-doc-id=<id>` | Filter by personDocId directly |
| `--collections=<list>` | Comma-separated list of collections to export |
| `--output=<dir>` | Output directory (default: `./exports`) |
| `--help, -h` | Show help message |

### Supported Collections

- `tasks` - Task items
- `taskRecurrences` - Recurrence rules
- `sprints` - Sprint definitions
- `snoozes` - Snooze records
- `persons` - User records
- `sprintAssignments` - Sprint-task assignments (subcollection, exported when `sprints` is included)

### Output Format

- Files are saved as CSV with timestamp in filename
- Timestamps are exported as ISO8601 UTC format
- All document fields are included, with consistent column ordering
- Complex fields (maps, arrays) are converted to JSON string

### Examples

#### Investigating Recurring Task Duplication

```bash
# Export tasks and recurrences to analyze iteration numbers
node bin/firestore-export.js --emulator --collections=tasks,taskRecurrences

# Open exports/tasks_*.csv in a spreadsheet
# Sort by recurrenceDocId, then recurIteration to find duplicates
```

#### Full Data Export for Backup

```bash
# Export all collections
node bin/firestore-export.js --emulator

# Files created:
# - exports/tasks_2024-01-15T10-30-00.csv
# - exports/taskRecurrences_2024-01-15T10-30-00.csv
# - exports/sprints_2024-01-15T10-30-00.csv
# - exports/snoozes_2024-01-15T10-30-00.csv
# - exports/persons_2024-01-15T10-30-00.csv
# - exports/sprintAssignments_2024-01-15T10-30-00.csv
```

---

## Firestore Repair Tool

Detects and repairs bad data from the recurring task duplication bug (TM-324). The bug caused duplicate recurrence documents and mismatched iteration values during sprint creation.

**Note:** The bug has been fixed in `sprint_service.dart` and `task_repository.dart`. This script repairs existing data only.

### Usage

```bash
# Analyze data on emulator (dry-run, default behavior)
node bin/firestore-repair.js --emulator

# Apply repairs on emulator
node bin/firestore-repair.js --emulator --apply

# Analyze specific user by email
node bin/firestore-repair.js --emulator --email=other@example.com

# Analyze specific user by personDocId
node bin/firestore-repair.js --emulator --person-doc-id=abc123

# Show help
node bin/firestore-repair.js --help
```

### Options

| Option | Description |
|--------|-------------|
| `--emulator` | Connect to Firestore emulator (localhost:8085) |
| `--production` | Connect to production Firestore (requires auth) |
| `--email=<email>` | Filter by user email (looks up personDocId) |
| `--person-doc-id=<id>` | Filter by personDocId directly |
| `--apply` | Apply repairs (default is dry-run analysis only) |
| `--help, -h` | Show help message |

### Bad Data Scenarios Detected

| # | Scenario | Description | Risk |
|---|----------|-------------|------|
| 1 | Out-of-sync iterations | `recurrence.recurIteration` < highest task iteration | LOW |
| 2 | Duplicate iterations | Multiple non-retired tasks with same `recurIteration` | MEDIUM |
| 3 | Orphaned tasks | Task has `recurrenceDocId` but recurrence doesn't exist | MEDIUM |
| 4 | Duplicate recurrences | Multiple recurrence docs for same task family | HIGH |

### Repair Phases

1. **Phase 1: Sync Iterations** (LOW RISK)
   - Finds recurrences where iteration < max task iteration
   - Updates recurrence to match highest non-retired task

2. **Phase 2: Resolve Duplicate Iterations** (MEDIUM RISK)
   - Finds tasks with same `(recurrenceDocId, recurIteration)`
   - Keeps oldest task by `dateAdded`, retires others
   - Protects snoozed tasks from retirement

3. **Phase 3: Fix Orphaned Tasks** (MEDIUM RISK)
   - Finds tasks referencing non-existent recurrences
   - Creates new recurrence if task has metadata (`recurNumber`, `recurUnit`)
   - Clears `recurrenceDocId` if task has no recurrence metadata

4. **Phase 4: Merge Duplicate Recurrences** (HIGH RISK)
   - Groups recurrences by `(personDocId, name)`
   - Selects canonical recurrence (highest iteration)
   - Retargets all tasks to canonical recurrence
   - Deletes non-canonical recurrence documents

### Example Output

```
Recurrence Data Repair Tool
===========================
Mode: DRY-RUN (use --apply to make changes)
Target: scorpy@gmail.com (personDocId: abc123)

ANALYSIS RESULTS
----------------
Out-of-sync recurrences: 3
  - "Take Out Recycling" (rec-1): expects 5, found tasks up to 8
  - "Weekly Review" (rec-2): expects 10, found tasks up to 12
  - "Daily Standup" (rec-3): expects 20, found tasks up to 21

Duplicate iterations: 1
  - "Weekly Review" (rec-2), iteration #10: 2 tasks (task-50, task-51)

Orphaned tasks: 0

Duplicate recurrence families: 2
  - "Take Out Recycling": 2 recurrences (rec-1, rec-4)
  - "Code Review": 3 recurrences (rec-5, rec-6, rec-7)

REPAIR PLAN
-----------
Phase 1: Would update 3 recurrence iterations
Phase 2: Would retire 1 duplicate task
Phase 3: No orphaned tasks to fix
Phase 4: Would merge 2 recurrence families (delete 3 recurrences)

Run with --apply to execute repairs.
```

### Verification Process

1. **Run analysis first** (dry-run):
   ```bash
   node bin/firestore-repair.js --emulator
   ```

2. **Review findings** and confirm scope is correct

3. **Apply repairs**:
   ```bash
   node bin/firestore-repair.js --emulator --apply
   ```

4. **Re-run analysis** to confirm all issues resolved:
   ```bash
   node bin/firestore-repair.js --emulator
   ```
   Expected: All counts should be 0

5. **Use RecurrenceDetailScreen** in the app to manually verify a few recurrences look correct

### Safety Features

- **Dry-run by default** - Always analyzes first without making changes
- **Snoozed task protection** - Won't retire tasks that have active snoozes
- **Keeps oldest duplicate** - When retiring duplicates, keeps the oldest by `dateAdded`
- **Batch operations** - Uses Firestore WriteBatch for atomic commits
- **Idempotent** - Running multiple times produces same result

---

## Dart Unit Tests

The repair logic is also tested using `fake_cloud_firestore` in Dart tests:

```bash
# Run all repair tool tests
flutter test test/bin/firestore_repair_test.dart

# Run with verbose output
flutter test test/bin/firestore_repair_test.dart -v
```

These tests verify the repair logic works correctly for all 4 bad data scenarios.

---

## Notes

- Default email filter is `scorpy@gmail.com` when no filter is specified
- Production mode requires proper Firebase authentication (not yet fully implemented)
- The `exports/` directory is gitignored by default
- The Dart versions (`bin/firestore_*.dart`) cannot be run directly due to Flutter dependencies, but the repair logic is tested via `flutter test`
