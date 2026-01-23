#!/usr/bin/env node
/**
 * Firestore Export CLI Tool
 *
 * Exports Firestore collections to CSV files for analysis.
 *
 * Usage:
 *   cd bin && npm install   # First time only
 *   node bin/firestore-export.js --emulator
 *   node bin/firestore-export.js --emulator --collections=tasks,taskRecurrences
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const DEFAULT_EMAIL = 'scorpy@gmail.com';
const PROJECT_ID = 'm3-taskmaster-3000';
const ALL_COLLECTIONS = ['tasks', 'taskRecurrences', 'sprints', 'snoozes', 'persons'];

// ============================================================================
// Main
// ============================================================================

async function main() {
  const config = parseArgs(process.argv.slice(2));

  if (config.showHelp) {
    printUsage();
    process.exit(0);
  }

  console.log('Firestore Export Tool');
  console.log('=====================');

  // Configure for emulator if specified
  if (config.useEmulator) {
    process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8085';
    console.log('Connected to Firestore emulator at 127.0.0.1:8085');
  } else if (config.useProduction) {
    console.log('Connected to production Firestore');
  } else {
    console.log('ERROR: Must specify --emulator or --production');
    printUsage();
    process.exit(1);
  }

  // Initialize Firebase Admin
  admin.initializeApp({ projectId: PROJECT_ID });
  const db = admin.firestore();

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
    console.log(`Found personDocId: ${personDocId}`);
  }

  // Create output directory
  const outputDir = config.outputDir;
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
    console.log(`Created output directory: ${outputDir}`);
  }

  // Export collections
  const collectionsToExport = config.collections || ALL_COLLECTIONS;
  console.log(`Exporting collections: ${collectionsToExport.join(', ')}`);
  console.log(`Filter: personDocId = ${personDocId}`);
  console.log('');

  for (const collection of collectionsToExport) {
    await exportCollection(db, collection, personDocId, outputDir);
  }

  // Export sprintAssignments subcollection if sprints is included
  if (collectionsToExport.includes('sprints')) {
    await exportSprintAssignments(db, personDocId, outputDir);
  }

  console.log('');
  console.log(`Export complete! Files saved to: ${outputDir}`);
  process.exit(0);
}

// ============================================================================
// Argument Parsing
// ============================================================================

function parseArgs(args) {
  const config = {
    useEmulator: false,
    useProduction: false,
    email: null,
    personDocId: null,
    collections: null,
    outputDir: './exports',
    showHelp: false,
  };

  for (const arg of args) {
    if (arg === '--emulator') {
      config.useEmulator = true;
    } else if (arg === '--production') {
      config.useProduction = true;
    } else if (arg === '--help' || arg === '-h') {
      config.showHelp = true;
    } else if (arg.startsWith('--email=')) {
      config.email = arg.substring('--email='.length);
    } else if (arg.startsWith('--person-doc-id=')) {
      config.personDocId = arg.substring('--person-doc-id='.length);
    } else if (arg.startsWith('--collections=')) {
      config.collections = arg.substring('--collections='.length).split(',');
    } else if (arg.startsWith('--output=')) {
      config.outputDir = arg.substring('--output='.length);
    }
  }

  return config;
}

function printUsage() {
  console.log(`
Firestore Export Tool
=====================

Exports Firestore collections to CSV files for analysis.

Usage:
  node bin/firestore-export.js --emulator
  node bin/firestore-export.js --emulator --email=user@example.com
  node bin/firestore-export.js --emulator --collections=tasks,taskRecurrences

Options:
  --emulator            Connect to Firestore emulator (127.0.0.1:8085)
  --production          Connect to production Firestore
  --email=<email>       Filter by user email (looks up personDocId)
  --person-doc-id=<id>  Filter by personDocId directly
  --collections=<list>  Comma-separated list of collections to export
                        Default: ${ALL_COLLECTIONS.join(',')}
  --output=<dir>        Output directory (default: ./exports)
  --help, -h            Show this help message

Default behavior:
  - Uses email: ${DEFAULT_EMAIL} when no filter is specified
  - Exports all collections: ${ALL_COLLECTIONS.join(', ')}

Examples:
  # First time setup
  cd bin && npm install

  # Export from emulator with default email
  node bin/firestore-export.js --emulator

  # Export specific collections
  node bin/firestore-export.js --emulator --collections=tasks,taskRecurrences

  # Export by specific email
  node bin/firestore-export.js --emulator --email=other@example.com
`);
}

async function lookupPersonDocId(db, email) {
  const snapshot = await db.collection('persons')
    .where('email', '==', email)
    .limit(1)
    .get();

  if (snapshot.empty) return null;
  return snapshot.docs[0].id;
}

// ============================================================================
// Export Functions
// ============================================================================

async function exportCollection(db, collectionName, personDocId, outputDir) {
  console.log(`Exporting ${collectionName}...`);

  let snapshot;

  if (collectionName === 'persons' && personDocId) {
    // For persons, get by doc ID
    const doc = await db.collection('persons').doc(personDocId).get();
    if (doc.exists) {
      const data = doc.data();
      data.docId = doc.id;
      const rows = convertToRows([data]);
      await writeCsv(outputDir, collectionName, rows);
      console.log('  -> Exported 1 document');
      return;
    } else {
      console.log('  -> No documents found');
      return;
    }
  }

  // Apply personDocId filter if available
  let query = db.collection(collectionName);
  if (personDocId && collectionName !== 'persons') {
    query = query.where('personDocId', '==', personDocId);
  }

  snapshot = await query.get();
  console.log(`  -> Found ${snapshot.docs.length} documents`);

  if (snapshot.docs.length === 0) {
    console.log('  -> Skipping (no data)');
    return;
  }

  const data = snapshot.docs.map(doc => {
    const json = doc.data();
    json.docId = doc.id;
    return json;
  });

  const rows = convertToRows(data);
  await writeCsv(outputDir, collectionName, rows);
}

async function exportSprintAssignments(db, personDocId, outputDir) {
  console.log('Exporting sprintAssignments (subcollection)...');

  // First get all sprints for this person
  let sprintQuery = db.collection('sprints');
  if (personDocId) {
    sprintQuery = sprintQuery.where('personDocId', '==', personDocId);
  }

  const sprintsSnapshot = await sprintQuery.get();
  console.log(`  -> Found ${sprintsSnapshot.docs.length} sprints to scan`);

  const allAssignments = [];

  for (const sprintDoc of sprintsSnapshot.docs) {
    const assignmentsSnapshot = await db
      .collection('sprints')
      .doc(sprintDoc.id)
      .collection('sprintAssignments')
      .get();

    for (const assignmentDoc of assignmentsSnapshot.docs) {
      const json = assignmentDoc.data();
      json.docId = assignmentDoc.id;
      json.sprintDocId = sprintDoc.id;
      allAssignments.push(json);
    }
  }

  console.log(`  -> Found ${allAssignments.length} total assignments`);

  if (allAssignments.length === 0) {
    console.log('  -> Skipping (no data)');
    return;
  }

  const rows = convertToRows(allAssignments);
  await writeCsv(outputDir, 'sprintAssignments', rows);
}

// ============================================================================
// CSV Conversion
// ============================================================================

function convertToRows(data) {
  if (data.length === 0) return [];

  // Collect all unique keys across all documents
  const allKeys = new Set();
  for (const doc of data) {
    Object.keys(doc).forEach(key => allKeys.add(key));
  }

  // Sort keys for consistent column order
  const sortedKeys = Array.from(allKeys).sort();

  // Create header row
  const rows = [sortedKeys];

  // Create data rows
  for (const doc of data) {
    const row = sortedKeys.map(key => formatValue(doc[key]));
    rows.push(row);
  }

  return rows;
}

function formatValue(value) {
  if (value === null || value === undefined) return '';

  // Firebase Timestamp
  if (value && typeof value.toDate === 'function') {
    return value.toDate().toISOString();
  }

  // Date object
  if (value instanceof Date) {
    return value.toISOString();
  }

  // Arrays and objects
  if (typeof value === 'object') {
    return JSON.stringify(value);
  }

  return String(value);
}

async function writeCsv(outputDir, collectionName, rows) {
  const csv = rowsToCsv(rows);
  const timestamp = new Date().toISOString().replace(/:/g, '-').split('.')[0];
  const filename = `${collectionName}_${timestamp}.csv`;
  const filePath = path.join(outputDir, filename);

  fs.writeFileSync(filePath, csv, 'utf8');
  console.log(`  -> Written to: ${filePath}`);
}

function rowsToCsv(rows) {
  return rows.map(row => {
    return row.map(cell => {
      const str = String(cell);
      // Escape cells that contain comma, quote, or newline
      if (str.includes(',') || str.includes('"') || str.includes('\n')) {
        return `"${str.replace(/"/g, '""')}"`;
      }
      return str;
    }).join(',');
  }).join('\n');
}

// Run main
main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
