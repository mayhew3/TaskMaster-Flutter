#!/usr/bin/env node
/**
 * Firestore project → area Migration (TM-345)
 *
 * One-shot migration: rewrites every task's `project` field to `area`, then
 * deletes the `project` field. For each user, also seeds the new top-level
 * `areas` collection with one Area document per distinct project value the
 * user had on their tasks (so their picker isn't empty after the rename).
 *
 * Run sequence at deploy time:
 *   1. node bin/firestore-migrate-project-to-area.js --emulator        (dry run)
 *   2. node bin/firestore-migrate-project-to-area.js --emulator --apply (verify)
 *   3. (Take a Firestore export of production)
 *   4. node bin/firestore-migrate-project-to-area.js --production --apply
 *   5. Deploy the new app version (which reads/writes only `area`).
 *
 * Idempotent: tasks already migrated (`area` set, `project` absent) are
 * skipped; duplicate Area docs for the same name are not re-inserted.
 *
 * Usage:
 *   cd bin && npm install   # First time only
 *   node bin/firestore-migrate-project-to-area.js --emulator
 *   node bin/firestore-migrate-project-to-area.js --emulator --apply
 *   node bin/firestore-migrate-project-to-area.js --emulator --email=other@example.com
 *   node bin/firestore-migrate-project-to-area.js --production --apply --service-account=<key.json>
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const DEFAULT_EMAIL = 'scorpy@gmail.com';
const PROJECT_ID = 'm3-taskmaster-3000';

// Names the picker UI reserves as sentinels (see lib/features/areas/services/
// area_service.dart). Seeding an Area with one of these would break the
// picker's contract — skip them at migration time even if the user happened
// to have a `project` value with that exact text.
const RESERVED_AREA_NAMES = new Set(['(none)', '+ Add new area…']);

async function main() {
  const config = parseArgs(process.argv.slice(2));

  if (config.showHelp) {
    printUsage();
    process.exit(0);
  }

  console.log('TM-345 project → area Migration');
  console.log('================================');

  if (config.useEmulator) {
    process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8085';
    console.log('Connected to Firestore emulator at 127.0.0.1:8085');
    admin.initializeApp({ projectId: PROJECT_ID });
  } else if (config.useProduction) {
    if (config.serviceAccount) {
      if (!fs.existsSync(config.serviceAccount)) {
        console.log(`ERROR: Service account file not found: ${config.serviceAccount}`);
        process.exit(1);
      }
      const serviceAccount = JSON.parse(
        fs.readFileSync(config.serviceAccount, 'utf8'),
      );
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: PROJECT_ID,
      });
      console.log(
        `Connected to production Firestore (service account: ${path.basename(
          config.serviceAccount,
        )})`,
      );
    } else {
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

  console.log(
    `Mode: ${config.apply ? 'APPLY' : 'DRY-RUN (use --apply to make changes)'}`,
  );
  console.log('');

  const targetPersonDocIds = await resolveTargetPersonIds(db, config);
  if (targetPersonDocIds.length === 0) {
    console.log('No matching users found.');
    process.exit(0);
  }
  console.log(`Migrating ${targetPersonDocIds.length} user(s).`);
  console.log('');

  let totalTasksMigrated = 0;
  let totalAreasCreated = 0;

  for (const personDocId of targetPersonDocIds) {
    console.log(`--- Person ${personDocId} ---`);
    const { tasksMigrated, areasCreated } = await migrateUser(
      db,
      personDocId,
      config.apply,
    );
    totalTasksMigrated += tasksMigrated;
    totalAreasCreated += areasCreated;
    console.log('');
  }

  console.log('================================');
  console.log(
    `${config.apply ? 'Migrated' : 'Would migrate'} ${totalTasksMigrated} task(s) ` +
      `and ${config.apply ? 'created' : 'would create'} ${totalAreasCreated} area(s).`,
  );
  process.exit(0);
}

async function resolveTargetPersonIds(db, config) {
  if (config.personDocId) return [config.personDocId];

  if (config.email) {
    const id = await lookupPersonDocId(db, config.email);
    return id ? [id] : [];
  }

  if (config.allUsers) {
    const snap = await db.collection('persons').get();
    return snap.docs.map((d) => d.id);
  }

  // Default: lookup the default email.
  const id = await lookupPersonDocId(db, DEFAULT_EMAIL);
  return id ? [id] : [];
}

async function lookupPersonDocId(db, email) {
  const snap = await db
    .collection('persons')
    .where('email', '==', email)
    .limit(1)
    .get();
  return snap.empty ? null : snap.docs[0].id;
}

async function migrateUser(db, personDocId, apply) {
  // 1. Find this user's tasks. The `project` field is a String?, so we can't
  //    Firestore-query for "where project != null" — pull all the user's tasks
  //    and filter client-side. Volume is small (single user's task list).
  const tasksSnap = await db
    .collection('tasks')
    .where('personDocId', '==', personDocId)
    .get();

  const distinctProjectValues = new Set();
  let tasksMigrated = 0;

  for (const doc of tasksSnap.docs) {
    const data = doc.data();
    const project = data.project;
    const area = data.area;

    if (project == null && area == null) continue;

    if (project != null) {
      distinctProjectValues.add(project);
    }

    // Idempotency: skip tasks already in the new shape.
    if (project == null && area != null) continue;

    // If project is set, copy to area (unless area is already set to the same
    // value, in which case just delete project).
    const update = {
      project: admin.firestore.FieldValue.delete(),
    };
    if (area == null && project != null) {
      update.area = project;
    }

    if (apply) {
      await doc.ref.update(update);
    }
    tasksMigrated += 1;
  }

  console.log(
    `  tasks: ${tasksMigrated} ${apply ? 'migrated' : 'would migrate'} ` +
      `(distinct project values: ${distinctProjectValues.size})`,
  );

  // 2. Seed Area documents for each distinct project value, sorted alphabetically.
  // Skip values that already have an Area doc (idempotency on re-runs).
  const existingAreasSnap = await db
    .collection('areas')
    .where('personDocId', '==', personDocId)
    .get();
  const existingNames = new Set(existingAreasSnap.docs.map((d) => d.data().name));

  let areasCreated = 0;
  const sorted = [...distinctProjectValues].sort((a, b) =>
    a.localeCompare(b, undefined, { sensitivity: 'base' }),
  );
  const now = admin.firestore.FieldValue.serverTimestamp();
  for (let i = 0; i < sorted.length; i++) {
    const name = sorted[i];
    if (RESERVED_AREA_NAMES.has(name)) continue;
    if (existingNames.has(name)) continue;
    if (apply) {
      await db.collection('areas').add({
        name,
        sortOrder: i,
        personDocId,
        dateAdded: now,
        retired: null,
        retiredDate: null,
      });
    }
    areasCreated += 1;
  }

  console.log(
    `  areas: ${areasCreated} ${apply ? 'created' : 'would create'} ` +
      `(${existingNames.size} already existed)`,
  );

  return { tasksMigrated, areasCreated };
}

function parseArgs(args) {
  const config = {
    useEmulator: false,
    useProduction: false,
    serviceAccount: null,
    email: null,
    personDocId: null,
    allUsers: false,
    apply: false,
    showHelp: false,
  };

  for (const arg of args) {
    if (arg === '--emulator') config.useEmulator = true;
    else if (arg === '--production') config.useProduction = true;
    else if (arg === '--apply') config.apply = true;
    else if (arg === '--all-users') config.allUsers = true;
    else if (arg === '--help' || arg === '-h') config.showHelp = true;
    else if (arg.startsWith('--email=')) config.email = arg.substring('--email='.length);
    else if (arg.startsWith('--person-doc-id='))
      config.personDocId = arg.substring('--person-doc-id='.length);
    else if (arg.startsWith('--service-account='))
      config.serviceAccount = arg.substring('--service-account='.length);
  }

  return config;
}

function printUsage() {
  console.log(`
TM-345 project → area Migration
================================

Renames the \`project\` field to \`area\` on every task and seeds the new
\`areas\` collection with one document per distinct project value per user.

Usage:
  node bin/firestore-migrate-project-to-area.js --emulator
  node bin/firestore-migrate-project-to-area.js --emulator --apply
  node bin/firestore-migrate-project-to-area.js --production --apply --service-account=<path>

Options:
  --emulator               Connect to Firestore emulator (127.0.0.1:8085)
  --production             Connect to production Firestore (requires auth)
  --service-account=<path> Path to service account JSON key file (for production)
  --email=<email>          Filter by user email (looks up personDocId)
  --person-doc-id=<id>     Filter by personDocId directly
  --all-users              Migrate every user under persons/
  --apply                  Apply changes (default is dry-run)
  --help, -h               Show this help message

Default behavior:
  - Uses email: ${DEFAULT_EMAIL} when no filter is specified
  - Runs in dry-run mode unless --apply is specified

Idempotent:
  - Tasks already migrated (area set, project absent) are skipped.
  - Duplicate Area docs for the same name are NOT re-inserted (matched by name).

Examples:
  # First time setup
  cd bin && npm install

  # Dry-run on the default user, emulator
  node bin/firestore-migrate-project-to-area.js --emulator

  # Apply on the default user, emulator
  node bin/firestore-migrate-project-to-area.js --emulator --apply

  # Apply for ALL users on production
  node bin/firestore-migrate-project-to-area.js --production --all-users --apply
`);
}

main().catch((err) => {
  console.error('FATAL:', err);
  process.exit(1);
});
