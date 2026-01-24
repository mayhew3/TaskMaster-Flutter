#!/usr/bin/env node
/**
 * Firestore Recurrence Repair CLI Tool
 *
 * Detects and repairs bad data from the recurring task duplication bug (TM-324).
 *
 * Usage:
 *   cd bin && npm install   # First time only
 *   node bin/firestore-repair.js --emulator
 *   node bin/firestore-repair.js --emulator --apply
 *   node bin/firestore-repair.js --emulator --email=other@example.com
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const DEFAULT_EMAIL = 'scorpy@gmail.com';
const PROJECT_ID = 'm3-taskmaster-3000';

// ============================================================================
// Main
// ============================================================================

async function main() {
  const config = parseArgs(process.argv.slice(2));

  if (config.showHelp) {
    printUsage();
    process.exit(0);
  }

  console.log('Recurrence Data Repair Tool');
  console.log('===========================');

  // Configure for emulator if specified
  if (config.useEmulator) {
    process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8085';
    console.log('Connected to Firestore emulator at 127.0.0.1:8085');
    admin.initializeApp({ projectId: PROJECT_ID });
  } else if (config.useProduction) {
    if (config.serviceAccount) {
      // Use service account key file
      if (!fs.existsSync(config.serviceAccount)) {
        console.log(`ERROR: Service account file not found: ${config.serviceAccount}`);
        process.exit(1);
      }
      const serviceAccount = JSON.parse(fs.readFileSync(config.serviceAccount, 'utf8'));
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: PROJECT_ID,
      });
      console.log(`Connected to production Firestore (service account: ${path.basename(config.serviceAccount)})`);
    } else {
      // Check for conflicting GOOGLE_APPLICATION_CREDENTIALS
      const gacPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      if (gacPath && !gacPath.includes(PROJECT_ID)) {
        console.log('');
        console.log('WARNING: GOOGLE_APPLICATION_CREDENTIALS is set to:');
        console.log(`  ${gacPath}`);
        console.log('');
        console.log('This may point to a different project. If you get permission errors, either:');
        console.log('  1. Unset GOOGLE_APPLICATION_CREDENTIALS before running');
        console.log('  2. Use --service-account with a key for this project');
        console.log('');
      }
      // Use Application Default Credentials (from gcloud auth application-default login)
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        projectId: PROJECT_ID,
      });
      console.log('Connected to production Firestore (using gcloud credentials)');
    }
  } else {
    console.log('ERROR: Must specify --emulator or --production');
    printUsage();
    process.exit(1);
  }

  const db = admin.firestore();

  console.log(`Mode: ${config.applyRepairs ? 'APPLY' : 'DRY-RUN (use --apply to make changes)'}`);
  console.log('');

  // Resolve personDocId
  let personDocId = config.personDocId;
  const email = config.email || (personDocId ? null : DEFAULT_EMAIL);

  if (email && !personDocId) {
    console.log(`Looking up personDocId for email: ${email}`);
    personDocId = await lookupPersonDocId(db, email);
    if (!personDocId) {
      console.log(`ERROR: Could not find person with email: ${email}`);
      process.exit(1);
    }
  }

  console.log(`Target: ${email || 'unknown email'} (personDocId: ${personDocId})`);
  console.log('');

  // Run the repair tool
  const repairTool = new RecurrenceRepairTool(db, personDocId, config.applyRepairs);
  await repairTool.run();

  process.exit(0);
}

// ============================================================================
// Argument Parsing
// ============================================================================

function parseArgs(args) {
  const config = {
    useEmulator: false,
    useProduction: false,
    serviceAccount: null,
    email: null,
    personDocId: null,
    applyRepairs: false,
    showHelp: false,
  };

  for (const arg of args) {
    if (arg === '--emulator') {
      config.useEmulator = true;
    } else if (arg === '--production') {
      config.useProduction = true;
    } else if (arg === '--apply') {
      config.applyRepairs = true;
    } else if (arg === '--help' || arg === '-h') {
      config.showHelp = true;
    } else if (arg.startsWith('--email=')) {
      config.email = arg.substring('--email='.length);
    } else if (arg.startsWith('--person-doc-id=')) {
      config.personDocId = arg.substring('--person-doc-id='.length);
    } else if (arg.startsWith('--service-account=')) {
      config.serviceAccount = arg.substring('--service-account='.length);
    }
  }

  return config;
}

function printUsage() {
  console.log(`
Recurrence Data Repair Tool
============================

Detects and repairs bad data from the recurring task duplication bug (TM-324).

Usage:
  node bin/firestore-repair.js --emulator
  node bin/firestore-repair.js --production --service-account=<path>
  node bin/firestore-repair.js --emulator --apply

Options:
  --emulator               Connect to Firestore emulator (127.0.0.1:8085)
  --production             Connect to production Firestore (requires auth)
  --service-account=<path> Path to service account JSON key file (for production)
  --email=<email>          Filter by user email (looks up personDocId)
  --person-doc-id=<id>     Filter by personDocId directly
  --apply                  Apply repairs (default is dry-run analysis only)
  --help, -h               Show this help message

Default behavior:
  - Uses email: ${DEFAULT_EMAIL} when no filter is specified
  - Runs in dry-run mode (analysis only) unless --apply is specified

Bad Data Scenarios Detected:
  1. Out-of-sync iterations - recurrence.recurIteration < highest task iteration
  2. Duplicate iterations - Multiple non-retired tasks with same recurIteration
  3. Orphaned tasks - Task has recurrenceDocId but recurrence doesn't exist
  4. Duplicate recurrences - Multiple recurrence docs for same task family

Examples:
  # First time setup
  cd bin && npm install

  # Analyze data on emulator (dry-run)
  node bin/firestore-repair.js --emulator

  # Apply repairs on emulator
  node bin/firestore-repair.js --emulator --apply

  # Analyze production data
  node bin/firestore-repair.js --production --service-account=./serviceAccountKey.json

  # Apply repairs to production (CAUTION!)
  node bin/firestore-repair.js --production --service-account=./serviceAccountKey.json --apply

Production Authentication:
  Uses your existing gcloud credentials. If not authenticated, run:
    gcloud auth application-default login

  Alternatively, use a service account key file:
    --service-account=./serviceAccountKey.json
`);
}

async function lookupPersonDocId(db, email) {
  try {
    const snapshot = await db.collection('persons')
      .where('email', '==', email)
      .limit(1)
      .get();

    if (snapshot.empty) return null;
    return snapshot.docs[0].id;
  } catch (error) {
    if (error.code === 7 || error.message?.includes('PERMISSION_DENIED')) {
      console.log('');
      console.log('ERROR: Permission denied accessing Firestore.');
      console.log('');
      console.log('For production access, you need one of:');
      console.log('');
      console.log('1. Application Default Credentials with Firestore permissions:');
      console.log('   gcloud auth application-default login');
      console.log('   (Your account needs "Cloud Datastore User" role on the project)');
      console.log('');
      console.log('2. Service account key file:');
      console.log('   node bin/firestore-repair.js --production --service-account=./serviceAccountKey.json');
      console.log('   (Get key from Firebase Console > Project Settings > Service Accounts)');
      console.log('');
      process.exit(1);
    }
    throw error;
  }
}

// ============================================================================
// Repair Tool Class
// ============================================================================

class RecurrenceRepairTool {
  constructor(db, personDocId, applyRepairs = false) {
    this.db = db;
    this.personDocId = personDocId;
    this.applyRepairs = applyRepairs;

    // Analysis results
    this.outOfSyncRecurrences = [];
    this.duplicateIterations = [];
    this.orphanedTasks = [];
    this.duplicateRecurrenceFamilies = [];
    this.corruptedRecurrences = [];

    // Cached data
    this.recurrencesById = new Map();
    this.tasksByRecurrenceId = new Map();

    // Change log for audit trail
    this.changeLog = [];
  }

  log(phase, action, details) {
    const entry = {
      timestamp: new Date().toISOString(),
      phase,
      action,
      ...details,
    };
    this.changeLog.push(entry);
  }

  async writeChangeLog() {
    if (this.changeLog.length === 0) {
      console.log('No changes to log.');
      return;
    }

    const outputDir = './exports';
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    const timestamp = new Date().toISOString().replace(/:/g, '-').split('.')[0];
    const filename = `${timestamp}_repair_log.json`;
    const filePath = path.join(outputDir, filename);

    fs.writeFileSync(filePath, JSON.stringify(this.changeLog, null, 2), 'utf8');
    console.log(`Change log written to: ${filePath}`);
  }

  async run() {
    await this.loadData();
    await this.analyze();

    if (this.hasIssues()) {
      this.printRepairPlan();
      if (this.applyRepairs) {
        await this.executeRepairs();
        await this.writeChangeLog();
        console.log('');
        console.log('Repairs complete! Re-run without --apply to verify.');
      } else {
        console.log('');
        console.log('Run with --apply to execute repairs.');
      }
    } else {
      console.log('No issues found. Data is clean!');
    }
  }

  hasIssues() {
    return this.outOfSyncRecurrences.length > 0 ||
      this.duplicateIterations.length > 0 ||
      this.orphanedTasks.length > 0 ||
      this.duplicateRecurrenceFamilies.length > 0 ||
      this.corruptedRecurrences.length > 0;
  }

  // ==========================================================================
  // Data Loading
  // ==========================================================================

  async loadData() {
    console.log('Loading data...');

    // Load recurrences
    const recurrencesSnapshot = await this.db.collection('taskRecurrences')
      .where('personDocId', '==', this.personDocId)
      .get();

    this.recurrencesById = new Map();
    for (const doc of recurrencesSnapshot.docs) {
      const data = doc.data();
      this.recurrencesById.set(doc.id, {
        docId: doc.id,
        name: data.name || '',
        personDocId: data.personDocId || '',
        recurIteration: data.recurIteration || 0,
        recurNumber: data.recurNumber,
        recurUnit: data.recurUnit,
        recurWait: data.recurWait,
      });
    }
    console.log(`  Loaded ${this.recurrencesById.size} recurrences`);

    // Load tasks
    const tasksSnapshot = await this.db.collection('tasks')
      .where('personDocId', '==', this.personDocId)
      .get();

    this.tasksByRecurrenceId = new Map();
    let activeCount = 0;
    let retiredCount = 0;

    for (const doc of tasksSnapshot.docs) {
      const data = doc.data();
      const recurrenceDocId = data.recurrenceDocId;
      if (!recurrenceDocId) continue; // Skip non-recurring tasks

      const isRetired = data.retired != null;
      if (isRetired) {
        retiredCount++;
      } else {
        activeCount++;
      }

      const task = {
        docId: doc.id,
        name: data.name || '',
        dateAdded: data.dateAdded?.toDate() || new Date(),
        recurIteration: data.recurIteration,
        recurrenceDocId: recurrenceDocId,
        hasRecurrenceMetadata: data.recurNumber != null && data.recurUnit != null,
        recurNumber: data.recurNumber,
        recurUnit: data.recurUnit,
        recurWait: data.recurWait,
        retired: isRetired,
      };

      if (!this.tasksByRecurrenceId.has(recurrenceDocId)) {
        this.tasksByRecurrenceId.set(recurrenceDocId, []);
      }
      this.tasksByRecurrenceId.get(recurrenceDocId).push(task);
    }
    console.log(`  Loaded ${activeCount} active + ${retiredCount} retired recurring tasks`);
    console.log('');
  }

  // ==========================================================================
  // Analysis
  // ==========================================================================

  async analyze() {
    console.log('ANALYSIS RESULTS');
    console.log('----------------');

    this.findOutOfSyncRecurrences();
    this.findDuplicateIterations();
    this.findOrphanedTasks();
    this.findDuplicateRecurrences();
    this.findCorruptedRecurrences();
  }

  findOutOfSyncRecurrences() {
    this.outOfSyncRecurrences = [];

    for (const recurrence of this.recurrencesById.values()) {
      const allTasks = this.tasksByRecurrenceId.get(recurrence.docId) || [];
      // Only consider non-retired tasks for iteration sync
      const activeTasks = allTasks.filter(t => !t.retired);
      if (activeTasks.length === 0) continue;

      const maxTaskIteration = Math.max(...activeTasks.map(t => t.recurIteration || 0));

      if (recurrence.recurIteration < maxTaskIteration) {
        this.outOfSyncRecurrences.push({
          recurrenceDocId: recurrence.docId,
          name: recurrence.name,
          currentIteration: recurrence.recurIteration,
          maxTaskIteration: maxTaskIteration,
        });
      }
    }

    console.log(`Out-of-sync recurrences: ${this.outOfSyncRecurrences.length}`);
    for (const item of this.outOfSyncRecurrences) {
      console.log(`  - "${item.name}" (${item.recurrenceDocId}): expects ${item.currentIteration}, found tasks up to ${item.maxTaskIteration}`);
    }
    console.log('');
  }

  findDuplicateIterations() {
    this.duplicateIterations = [];

    for (const [recurrenceDocId, allTasks] of this.tasksByRecurrenceId.entries()) {
      const recurrence = this.recurrencesById.get(recurrenceDocId);
      // Only consider non-retired tasks for duplicate detection
      const tasks = allTasks.filter(t => !t.retired);

      // Group tasks by iteration
      const byIteration = new Map();
      for (const task of tasks) {
        const iteration = task.recurIteration;
        if (iteration != null) {
          if (!byIteration.has(iteration)) {
            byIteration.set(iteration, []);
          }
          byIteration.get(iteration).push(task);
        }
      }

      // Find iterations with duplicates
      for (const [iteration, iterTasks] of byIteration.entries()) {
        if (iterTasks.length > 1) {
          // Sort by dateAdded so oldest is first
          iterTasks.sort((a, b) => a.dateAdded - b.dateAdded);
          this.duplicateIterations.push({
            recurrenceDocId: recurrenceDocId,
            recurrenceName: recurrence?.name || 'Unknown',
            iteration: iteration,
            tasks: iterTasks,
          });
        }
      }
    }

    console.log(`Duplicate iterations: ${this.duplicateIterations.length}`);
    for (const item of this.duplicateIterations) {
      const taskIds = item.tasks.map(t => t.docId).join(', ');
      console.log(`  - "${item.recurrenceName}" (${item.recurrenceDocId}), iteration #${item.iteration}: ${item.tasks.length} tasks (${taskIds})`);
    }
    console.log('');
  }

  findOrphanedTasks() {
    this.orphanedTasks = [];

    for (const tasks of this.tasksByRecurrenceId.values()) {
      for (const task of tasks) {
        if (task.recurrenceDocId && !this.recurrencesById.has(task.recurrenceDocId)) {
          this.orphanedTasks.push({
            task: task,
            missingRecurrenceDocId: task.recurrenceDocId,
          });
        }
      }
    }

    console.log(`Orphaned tasks: ${this.orphanedTasks.length}`);
    for (const item of this.orphanedTasks) {
      console.log(`  - "${item.task.name}" (${item.task.docId}): references missing recurrence ${item.missingRecurrenceDocId}`);
    }
    console.log('');
  }

  findDuplicateRecurrences() {
    this.duplicateRecurrenceFamilies = [];

    // Group recurrences by (personDocId, name)
    const byKey = new Map();
    for (const recurrence of this.recurrencesById.values()) {
      const key = `${recurrence.personDocId}::${recurrence.name}`;
      if (!byKey.has(key)) {
        byKey.set(key, []);
      }
      byKey.get(key).push(recurrence);
    }

    // Find families with duplicates
    for (const [key, recurrences] of byKey.entries()) {
      if (recurrences.length > 1) {
        // Sort by recurIteration descending - highest is canonical
        recurrences.sort((a, b) => b.recurIteration - a.recurIteration);
        const [personDocId, name] = key.split('::');
        this.duplicateRecurrenceFamilies.push({
          personDocId: personDocId,
          name: name || '',
          recurrences: recurrences,
          canonical: recurrences[0],
          nonCanonical: recurrences.slice(1),
        });
      }
    }

    console.log(`Duplicate recurrence families: ${this.duplicateRecurrenceFamilies.length}`);
    for (const item of this.duplicateRecurrenceFamilies) {
      const ids = item.recurrences.map(r => r.docId).join(', ');
      console.log(`  - "${item.name}": ${item.recurrences.length} recurrences (${ids})`);
    }
    console.log('');
  }

  findCorruptedRecurrences() {
    this.corruptedRecurrences = [];

    for (const recurrence of this.recurrencesById.values()) {
      if (!recurrence.name) {
        this.corruptedRecurrences.push({
          docId: recurrence.docId,
          name: recurrence.name,
          personDocId: recurrence.personDocId,
          issue: 'null or empty name',
        });
      } else if (!recurrence.personDocId) {
        this.corruptedRecurrences.push({
          docId: recurrence.docId,
          name: recurrence.name,
          personDocId: recurrence.personDocId,
          issue: 'null or empty personDocId',
        });
      }
    }

    if (this.corruptedRecurrences.length > 0) {
      console.log(`Corrupted recurrences: ${this.corruptedRecurrences.length}`);
      for (const item of this.corruptedRecurrences) {
        console.log(`  - ${item.docId}: ${item.issue}`);
      }
      console.log('');
    }
  }

  // ==========================================================================
  // Repair Plan
  // ==========================================================================

  printRepairPlan() {
    console.log('REPAIR PLAN');
    console.log('-----------');

    // Phase 1: Fix orphaned tasks (first, so they can be included in merge)
    const orphansToFix = this.orphanedTasks;
    const recurrenceNames = new Set([...this.recurrencesById.values()].map(r => r.name).filter(Boolean));
    const canRetarget = orphansToFix.filter(o => recurrenceNames.has(o.task.name)).length;
    const needsNewRecurrence = orphansToFix.filter(o => !recurrenceNames.has(o.task.name) && o.task.hasRecurrenceMetadata).length;
    const needsClear = orphansToFix.filter(o => !recurrenceNames.has(o.task.name) && !o.task.hasRecurrenceMetadata).length;
    if (orphansToFix.length === 0) {
      console.log('Phase 1: No orphaned tasks to fix');
    } else {
      console.log(`Phase 1: Would retarget ${canRetarget} orphans to existing recurrences, create ${needsNewRecurrence} new recurrences, clear ${needsClear} references`);
    }

    // Phase 2: Merge duplicate recurrences
    const recurrencesToDelete = this.duplicateRecurrenceFamilies
      .flatMap(f => f.nonCanonical).length;
    if (this.duplicateRecurrenceFamilies.length === 0) {
      console.log('Phase 2: No duplicate recurrences to merge');
    } else {
      console.log(`Phase 2: Would merge ${this.duplicateRecurrenceFamilies.length} recurrence families (delete ${recurrencesToDelete} recurrences)`);
    }

    // Phase 3: Renumber iterations (after merge, which may create more duplicates)
    const recurrencesToRenumber = new Set(this.duplicateIterations.map(d => d.recurrenceDocId)).size;
    console.log(`Phase 3: Would renumber iterations for ${recurrencesToRenumber} recurrences (may increase after merge)`);

    // Phase 4: Sync iterations (final cleanup)
    console.log(`Phase 4: Would update ${this.outOfSyncRecurrences.length} recurrence iterations (may change after earlier phases)`);
  }

  // ==========================================================================
  // Execute Repairs
  // ==========================================================================

  async executeRepairs() {
    console.log('');
    console.log('EXECUTING REPAIRS');
    console.log('-----------------');

    // New order: Fix orphans -> Merge duplicates -> Resolve duplicate iterations -> Sync iterations
    await this.executePhase1FixOrphanedTasks();
    await this.executePhase2MergeDuplicateRecurrences();

    // Reload data after merge to find new duplicate iterations
    if (this.duplicateRecurrenceFamilies.length > 0) {
      console.log('  Reloading data after merge...');
      await this.loadData();
      this.findDuplicateIterations();
      this.findOutOfSyncRecurrences();
    }

    await this.executePhase3RenumberIterations();

    // Reload data after renumbering to get accurate iteration counts for Phase 4
    if (this.duplicateIterations.length > 0) {
      console.log('  Reloading data after renumbering...');
      await this.loadData();
      this.findOutOfSyncRecurrences();
    }

    await this.executePhase4SyncIterations();
  }

  // Phase 1: Fix orphaned tasks (retarget to existing recurrences)
  async executePhase1FixOrphanedTasks() {
    if (this.orphanedTasks.length === 0) {
      console.log('Phase 1: No orphaned tasks to fix');
      return;
    }

    console.log(`Phase 1: Fixing ${this.orphanedTasks.length} orphaned tasks...`);

    // Build a map of recurrence name -> recurrence for quick lookup
    const recurrencesByName = new Map();
    for (const recurrence of this.recurrencesById.values()) {
      if (recurrence.name) {
        recurrencesByName.set(recurrence.name, recurrence);
      }
    }

    let retargetedToExisting = 0;
    let createdRecurrences = 0;
    let clearedReferences = 0;

    for (const orphan of this.orphanedTasks) {
      const taskRef = this.db.collection('tasks').doc(orphan.task.docId);

      // First, try to find an existing recurrence with the same name
      const existingRecurrence = recurrencesByName.get(orphan.task.name);
      if (existingRecurrence) {
        // Retarget to existing recurrence
        await taskRef.update({ recurrenceDocId: existingRecurrence.docId });
        this.log('Phase 1', 'retarget_orphan', {
          taskDocId: orphan.task.docId,
          taskName: orphan.task.name,
          oldRecurrenceDocId: orphan.missingRecurrenceDocId,
          newRecurrenceDocId: existingRecurrence.docId,
        });
        retargetedToExisting++;
      } else if (orphan.task.hasRecurrenceMetadata) {
        // Create a new recurrence document
        const recurrenceRef = this.db.collection('taskRecurrences').doc();

        await recurrenceRef.set({
          name: orphan.task.name,
          personDocId: this.personDocId,
          recurNumber: orphan.task.recurNumber,
          recurUnit: orphan.task.recurUnit,
          recurWait: orphan.task.recurWait || false,
          recurIteration: orphan.task.recurIteration || 1,
          dateAdded: new Date(),
          anchorDate: {},
        });

        // Update task to point to new recurrence
        await taskRef.update({ recurrenceDocId: recurrenceRef.id });
        this.log('Phase 1', 'create_recurrence', {
          taskDocId: orphan.task.docId,
          taskName: orphan.task.name,
          oldRecurrenceDocId: orphan.missingRecurrenceDocId,
          newRecurrenceDocId: recurrenceRef.id,
        });
        createdRecurrences++;

        // Add to map so subsequent orphans with same name use this recurrence
        recurrencesByName.set(orphan.task.name, {
          docId: recurrenceRef.id,
          name: orphan.task.name,
        });
      } else {
        // Clear the invalid recurrence reference
        await taskRef.update({ recurrenceDocId: null });
        this.log('Phase 1', 'clear_reference', {
          taskDocId: orphan.task.docId,
          taskName: orphan.task.name,
          oldRecurrenceDocId: orphan.missingRecurrenceDocId,
        });
        clearedReferences++;
      }
    }

    console.log(`  Retargeted ${retargetedToExisting} tasks to existing recurrences`);
    console.log(`  Created ${createdRecurrences} new recurrences`);
    console.log(`  Cleared ${clearedReferences} invalid references`);
  }

  // Phase 2: Merge duplicate recurrences
  async executePhase2MergeDuplicateRecurrences() {
    if (this.duplicateRecurrenceFamilies.length === 0) {
      console.log('Phase 2: No duplicate recurrences to merge');
      return;
    }

    console.log(`Phase 2: Merging ${this.duplicateRecurrenceFamilies.length} duplicate recurrence families...`);

    let mergedFamilies = 0;
    let deletedRecurrences = 0;
    let retargetedTasks = 0;

    for (const family of this.duplicateRecurrenceFamilies) {
      const batch = this.db.batch();

      // Retarget ALL tasks (including retired!) from non-canonical recurrences to canonical
      // We must query Firestore directly since this.tasksByRecurrenceId may not have all tasks
      for (const nonCanonical of family.nonCanonical) {
        const tasksSnapshot = await this.db.collection('tasks')
          .where('recurrenceDocId', '==', nonCanonical.docId)
          .get();

        for (const doc of tasksSnapshot.docs) {
          batch.update(doc.ref, { recurrenceDocId: family.canonical.docId });
          this.log('Phase 2', 'retarget_task', {
            taskDocId: doc.id,
            recurrenceName: family.name,
            oldRecurrenceDocId: nonCanonical.docId,
            newRecurrenceDocId: family.canonical.docId,
          });
          retargetedTasks++;
        }

        // Delete the non-canonical recurrence
        const recurrenceRef = this.db.collection('taskRecurrences').doc(nonCanonical.docId);
        batch.delete(recurrenceRef);
        this.log('Phase 2', 'delete_recurrence', {
          recurrenceDocId: nonCanonical.docId,
          recurrenceName: family.name,
          canonicalRecurrenceDocId: family.canonical.docId,
        });
        deletedRecurrences++;
      }

      // Update canonical recurrence iteration to be the max
      const maxIteration = Math.max(...family.recurrences.map(r => r.recurIteration));
      const canonicalRef = this.db.collection('taskRecurrences').doc(family.canonical.docId);
      batch.update(canonicalRef, { recurIteration: maxIteration });
      this.log('Phase 2', 'update_canonical_iteration', {
        recurrenceDocId: family.canonical.docId,
        recurrenceName: family.name,
        newIteration: maxIteration,
      });

      await batch.commit();
      mergedFamilies++;
    }

    console.log(`  Merged ${mergedFamilies} families`);
    console.log(`  Retargeted ${retargetedTasks} tasks (including retired)`);
    console.log(`  Deleted ${deletedRecurrences} duplicate recurrences`);
  }

  // Phase 3: Renumber iterations for recurrences with duplicates
  async executePhase3RenumberIterations() {
    if (this.duplicateIterations.length === 0) {
      console.log('Phase 3: No duplicate iterations to renumber');
      return;
    }

    // Get unique recurrence IDs that have duplicate iterations
    const recurrenceIdsToFix = new Set(this.duplicateIterations.map(d => d.recurrenceDocId));
    console.log(`Phase 3: Renumbering iterations for ${recurrenceIdsToFix.size} recurrences...`);

    const batch = this.db.batch();
    let tasksUpdated = 0;

    for (const recurrenceDocId of recurrenceIdsToFix) {
      // Get all non-retired tasks for this recurrence, sorted by dateAdded
      const allTasks = this.tasksByRecurrenceId.get(recurrenceDocId) || [];
      const activeTasks = allTasks
        .filter(t => !t.retired)
        .sort((a, b) => a.dateAdded - b.dateAdded);

      // Renumber sequentially starting from 0
      const recurrence = this.recurrencesById.get(recurrenceDocId);
      for (let i = 0; i < activeTasks.length; i++) {
        const task = activeTasks[i];
        if (task.recurIteration !== i) {
          const docRef = this.db.collection('tasks').doc(task.docId);
          batch.update(docRef, { recurIteration: i });
          this.log('Phase 3', 'renumber_task', {
            taskDocId: task.docId,
            taskName: task.name,
            recurrenceDocId: recurrenceDocId,
            recurrenceName: recurrence?.name || 'Unknown',
            oldIteration: task.recurIteration,
            newIteration: i,
          });
          tasksUpdated++;
        }
      }

      // Update recurrence iteration to match highest
      const maxIteration = activeTasks.length - 1;
      if (recurrence && recurrence.recurIteration !== maxIteration) {
        const recurrenceRef = this.db.collection('taskRecurrences').doc(recurrenceDocId);
        batch.update(recurrenceRef, { recurIteration: maxIteration });
        this.log('Phase 3', 'update_recurrence_iteration', {
          recurrenceDocId: recurrenceDocId,
          recurrenceName: recurrence.name,
          oldIteration: recurrence.recurIteration,
          newIteration: maxIteration,
        });
      }
    }

    await batch.commit();
    console.log(`  Renumbered ${tasksUpdated} tasks`);
  }

  // Phase 4: Sync iterations (final cleanup)
  async executePhase4SyncIterations() {
    if (this.outOfSyncRecurrences.length === 0) {
      console.log('Phase 4: No out-of-sync recurrences to fix');
      return;
    }

    console.log(`Phase 4: Syncing ${this.outOfSyncRecurrences.length} recurrence iterations...`);

    const batch = this.db.batch();

    for (const item of this.outOfSyncRecurrences) {
      const docRef = this.db.collection('taskRecurrences').doc(item.recurrenceDocId);
      batch.update(docRef, { recurIteration: item.maxTaskIteration });
      this.log('Phase 4', 'sync_iteration', {
        recurrenceDocId: item.recurrenceDocId,
        recurrenceName: item.name,
        oldIteration: item.currentIteration,
        newIteration: item.maxTaskIteration,
      });
    }

    await batch.commit();
    console.log(`  Updated ${this.outOfSyncRecurrences.length} recurrences`);
  }
}

// Run main
main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
