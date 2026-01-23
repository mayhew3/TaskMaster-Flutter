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
    this.snoozedTaskIds = new Set();
  }

  async run() {
    await this.loadData();
    await this.analyze();

    if (this.hasIssues()) {
      this.printRepairPlan();
      if (this.applyRepairs) {
        await this.executeRepairs();
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
    let recurringTaskCount = 0;

    for (const doc of tasksSnapshot.docs) {
      const data = doc.data();
      if (data.retired != null) continue; // Skip retired tasks

      const recurrenceDocId = data.recurrenceDocId;
      if (!recurrenceDocId) continue; // Skip non-recurring tasks

      recurringTaskCount++;
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
      };

      if (!this.tasksByRecurrenceId.has(recurrenceDocId)) {
        this.tasksByRecurrenceId.set(recurrenceDocId, []);
      }
      this.tasksByRecurrenceId.get(recurrenceDocId).push(task);
    }
    console.log(`  Loaded ${recurringTaskCount} non-retired recurring tasks`);

    // Load snoozes to identify snoozed tasks
    const snoozesSnapshot = await this.db.collection('snoozes').get();
    this.snoozedTaskIds = new Set();
    for (const doc of snoozesSnapshot.docs) {
      const taskDocId = doc.data().taskDocId;
      if (taskDocId) {
        this.snoozedTaskIds.add(taskDocId);
      }
    }
    console.log(`  Found ${this.snoozedTaskIds.size} snoozed tasks`);
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
      const tasks = this.tasksByRecurrenceId.get(recurrence.docId) || [];
      if (tasks.length === 0) continue;

      const maxTaskIteration = Math.max(...tasks.map(t => t.recurIteration || 0));

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

    for (const [recurrenceDocId, tasks] of this.tasksByRecurrenceId.entries()) {
      const recurrence = this.recurrencesById.get(recurrenceDocId);

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

    // Phase 1: Sync iterations
    console.log(`Phase 1: Would update ${this.outOfSyncRecurrences.length} recurrence iterations`);

    // Phase 2: Resolve duplicate iterations
    const tasksToRetire = this.duplicateIterations
      .flatMap(d => d.tasks.slice(1)) // Skip oldest (keep it)
      .filter(t => !this.snoozedTaskIds.has(t.docId));
    console.log(`Phase 2: Would retire ${tasksToRetire.length} duplicate tasks`);

    // Phase 3: Fix orphaned tasks
    const orphansToFix = this.orphanedTasks.filter(o => !this.snoozedTaskIds.has(o.task.docId));
    const orphansWithMetadata = orphansToFix.filter(o => o.task.hasRecurrenceMetadata).length;
    const orphansWithoutMetadata = orphansToFix.length - orphansWithMetadata;
    if (orphansToFix.length === 0) {
      console.log('Phase 3: No orphaned tasks to fix');
    } else {
      console.log(`Phase 3: Would create ${orphansWithMetadata} recurrences, clear ${orphansWithoutMetadata} task references`);
    }

    // Phase 4: Merge duplicate recurrences
    const recurrencesToDelete = this.duplicateRecurrenceFamilies
      .flatMap(f => f.nonCanonical).length;
    if (this.duplicateRecurrenceFamilies.length === 0) {
      console.log('Phase 4: No duplicate recurrences to merge');
    } else {
      console.log(`Phase 4: Would merge ${this.duplicateRecurrenceFamilies.length} recurrence families (delete ${recurrencesToDelete} recurrences)`);
    }
  }

  // ==========================================================================
  // Execute Repairs
  // ==========================================================================

  async executeRepairs() {
    console.log('');
    console.log('EXECUTING REPAIRS');
    console.log('-----------------');

    await this.phase1SyncIterations();
    await this.phase2ResolveDuplicateIterations();
    await this.phase3FixOrphanedTasks();
    await this.phase4MergeDuplicateRecurrences();
  }

  async phase1SyncIterations() {
    if (this.outOfSyncRecurrences.length === 0) {
      console.log('Phase 1: No out-of-sync recurrences to fix');
      return;
    }

    console.log(`Phase 1: Syncing ${this.outOfSyncRecurrences.length} recurrence iterations...`);

    const batch = this.db.batch();

    for (const item of this.outOfSyncRecurrences) {
      const docRef = this.db.collection('taskRecurrences').doc(item.recurrenceDocId);
      batch.update(docRef, { recurIteration: item.maxTaskIteration });
    }

    await batch.commit();
    console.log(`  Updated ${this.outOfSyncRecurrences.length} recurrences`);
  }

  async phase2ResolveDuplicateIterations() {
    if (this.duplicateIterations.length === 0) {
      console.log('Phase 2: No duplicate iterations to fix');
      return;
    }

    console.log(`Phase 2: Resolving ${this.duplicateIterations.length} duplicate iteration groups...`);

    const batch = this.db.batch();
    let retiredCount = 0;

    for (const dup of this.duplicateIterations) {
      // Skip the oldest task (first after sort), retire the rest
      const tasksToRetire = dup.tasks.slice(1);

      for (const task of tasksToRetire) {
        // Don't retire snoozed tasks
        if (this.snoozedTaskIds.has(task.docId)) {
          console.log(`  Skipping snoozed task: ${task.docId}`);
          continue;
        }

        const docRef = this.db.collection('tasks').doc(task.docId);
        batch.update(docRef, {
          retired: task.docId,
          retiredDate: new Date(),
        });
        retiredCount++;
      }
    }

    await batch.commit();
    console.log(`  Retired ${retiredCount} duplicate tasks`);

    // After retiring duplicates, re-sync iterations
    if (retiredCount > 0) {
      console.log('  Re-syncing iterations after retiring duplicates...');
      await this.loadData();
      this.findOutOfSyncRecurrences();
      await this.phase1SyncIterations();
    }
  }

  async phase3FixOrphanedTasks() {
    if (this.orphanedTasks.length === 0) {
      console.log('Phase 3: No orphaned tasks to fix');
      return;
    }

    console.log(`Phase 3: Fixing ${this.orphanedTasks.length} orphaned tasks...`);

    let createdRecurrences = 0;
    let clearedReferences = 0;

    for (const orphan of this.orphanedTasks) {
      // Don't modify snoozed tasks
      if (this.snoozedTaskIds.has(orphan.task.docId)) {
        console.log(`  Skipping snoozed task: ${orphan.task.docId}`);
        continue;
      }

      const taskRef = this.db.collection('tasks').doc(orphan.task.docId);

      if (orphan.task.hasRecurrenceMetadata) {
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
        createdRecurrences++;
      } else {
        // Clear the invalid recurrence reference
        await taskRef.update({ recurrenceDocId: null });
        clearedReferences++;
      }
    }

    console.log(`  Created ${createdRecurrences} new recurrences`);
    console.log(`  Cleared ${clearedReferences} invalid references`);
  }

  async phase4MergeDuplicateRecurrences() {
    if (this.duplicateRecurrenceFamilies.length === 0) {
      console.log('Phase 4: No duplicate recurrences to merge');
      return;
    }

    console.log(`Phase 4: Merging ${this.duplicateRecurrenceFamilies.length} duplicate recurrence families...`);

    let mergedFamilies = 0;
    let deletedRecurrences = 0;
    let retargetedTasks = 0;

    for (const family of this.duplicateRecurrenceFamilies) {
      const batch = this.db.batch();

      // Retarget all tasks from non-canonical recurrences to canonical
      for (const nonCanonical of family.nonCanonical) {
        const tasks = this.tasksByRecurrenceId.get(nonCanonical.docId) || [];

        for (const task of tasks) {
          const taskRef = this.db.collection('tasks').doc(task.docId);
          batch.update(taskRef, { recurrenceDocId: family.canonical.docId });
          retargetedTasks++;
        }

        // Delete the non-canonical recurrence
        const recurrenceRef = this.db.collection('taskRecurrences').doc(nonCanonical.docId);
        batch.delete(recurrenceRef);
        deletedRecurrences++;
      }

      // Update canonical recurrence iteration to be the max
      const maxIteration = Math.max(...family.recurrences.map(r => r.recurIteration));
      const canonicalRef = this.db.collection('taskRecurrences').doc(family.canonical.docId);
      batch.update(canonicalRef, { recurIteration: maxIteration });

      await batch.commit();
      mergedFamilies++;
    }

    console.log(`  Merged ${mergedFamilies} families`);
    console.log(`  Retargeted ${retargetedTasks} tasks`);
    console.log(`  Deleted ${deletedRecurrences} duplicate recurrences`);
  }
}

// Run main
main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
