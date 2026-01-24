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
| `--service-account=<path>` | Path to service account JSON key file (for production) |
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
- **Dates are formatted for Excel** (`YYYY-MM-DD HH:MM:SS`) - automatically recognized as datetime values
- All document fields are included, with consistent column ordering
- Complex fields (maps, arrays) are converted to JSON string

### Collection-Specific Transformations

**taskRecurrences**: The `anchorDate` object is flattened into two columns:
- `anchorDate` - The date value (e.g., `2023-02-16 19:56:01`)
- `anchorType` - The date type (e.g., `Urgent`, `Target`, `Completion`)

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
| `--service-account=<path>` | Path to service account JSON key file (for production) |
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

Phases run in this order to handle dependencies correctly:

1. **Phase 1: Fix Orphaned Tasks** (MEDIUM RISK)
   - Finds tasks referencing non-existent recurrences
   - Retargets to existing recurrence with same name if found
   - Creates new recurrence if task has metadata (`recurNumber`, `recurUnit`)
   - Clears `recurrenceDocId` if task has no recurrence metadata

2. **Phase 2: Merge Duplicate Recurrences** (HIGH RISK)
   - Groups recurrences by `(personDocId, name)`
   - Selects canonical recurrence (highest iteration)
   - Retargets all tasks (including retired) to canonical recurrence
   - Deletes non-canonical recurrence documents

3. **Phase 3: Renumber Iterations** (LOW RISK)
   - Finds recurrences with duplicate iteration numbers
   - Renumbers all non-retired tasks sequentially by `dateAdded`
   - Preserves all tasks (no data loss)

4. **Phase 4: Sync Iterations** (LOW RISK)
   - Finds recurrences where iteration < max task iteration
   - Updates recurrence to match highest non-retired task

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
Phase 1: No orphaned tasks to fix
Phase 2: Would merge 2 recurrence families (delete 3 recurrences)
Phase 3: Would renumber iterations for 1 recurrence
Phase 4: Would update 3 recurrence iterations

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
- **No data loss** - Duplicate iterations are renumbered, not retired
- **Batch operations** - Uses Firestore WriteBatch for atomic commits
- **Idempotent** - Running multiple times produces same result

---

## Production Authentication

Both tools support production Firestore access via two authentication methods:

### Option 1: Application Default Credentials (ADC)

Uses your existing gcloud credentials:

```bash
# Authenticate (one-time setup)
gcloud auth application-default login

# Run tool
node bin/firestore-export.js --production
```

**Requirements:** Your Google account must have the "Cloud Datastore User" IAM role on the project.

### Option 2: Service Account Key File

Uses a service account JSON key file:

```bash
# Download key from Firebase Console > Project Settings > Service Accounts
node bin/firestore-export.js --production --service-account=./serviceAccountKey.json
```

**Note:** Service account key files are gitignored (`**/serviceAccountKey*.json`) to prevent accidental commits.

---

## Notes

- Default email filter is `scorpy@gmail.com` when no filter is specified
- The `exports/` directory is gitignored by default
