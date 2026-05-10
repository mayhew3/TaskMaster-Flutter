import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:taskmaestro/core/database/app_database.dart';
import 'package:taskmaestro/core/database/converters.dart';

/// Verifies the TM-181 v7 → v8 migration preserves legacy `tasks.task_context`
/// values under the renamed `tasks.task_contexts` column and creates the new
/// `contexts` table (TM-181).
///
/// Drift's full `verifySelf` migration framework requires a frozen-schema
/// codegen step (`drift_dev schema dump/generate`) that this repo doesn't
/// currently set up. Instead we directly simulate the v7 layout via raw
/// SQLite, run the same DDL the migration block emits, and assert on the
/// outcome — caught a regression if the SQL ever drifts from the docs.

void main() {
  group('v7 → v8 migration (raw SQL simulation)', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    void createV7TasksTable() {
      // Subset of the v7 `tasks` table. We only care about the columns the
      // migration touches (`task_context` → `task_contexts`); the rest are
      // immaterial and omitted to keep the synthetic schema tight.
      db.execute('''
        CREATE TABLE tasks (
          doc_id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          task_context TEXT,
          person_doc_id TEXT
        )
      ''');
    }

    void runV7ToV8Migration() {
      // The two statements the v7→v8 block emits, in the same order.
      // (Drift's `m.createTable(contexts)` expands to a CREATE TABLE on the
      // contexts schema; we mirror its essential shape here.)
      db.execute('''
        CREATE TABLE contexts (
          doc_id TEXT NOT NULL PRIMARY KEY,
          date_added INTEGER NOT NULL,
          name TEXT NOT NULL,
          sort_order INTEGER NOT NULL,
          icon_name TEXT,
          color TEXT,
          person_doc_id TEXT NOT NULL,
          retired TEXT,
          retired_date INTEGER,
          sync_state TEXT NOT NULL DEFAULT 'synced'
        )
      ''');
      db.execute(
          'ALTER TABLE tasks RENAME COLUMN task_context TO task_contexts');
    }

    test('contexts table is created', () {
      createV7TasksTable();
      runV7ToV8Migration();

      final rows = db.select(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='contexts'");
      expect(rows, hasLength(1));
    });

    test('tasks.task_context column is renamed to task_contexts', () {
      createV7TasksTable();
      runV7ToV8Migration();

      final cols = db.select('PRAGMA table_info(tasks)');
      final names = cols.map((r) => r['name'] as String).toSet();
      expect(names, contains('task_contexts'));
      expect(names, isNot(contains('task_context')));
    });

    test(
        'a v7 row with task_context = "Phone" survives the rename intact, '
        'and parseTaskContexts wraps it as a single-element list', () {
      createV7TasksTable();
      // Pre-migration: insert a legacy row with the singular column.
      db.execute(
          'INSERT INTO tasks (doc_id, name, task_context, person_doc_id) '
          "VALUES ('t1', 'Test', 'Phone', 'me')");

      runV7ToV8Migration();

      // Post-migration: same row, value now under task_contexts.
      final after = db.select(
          "SELECT task_contexts FROM tasks WHERE doc_id = 't1'");
      expect(after, hasLength(1));
      final raw = after.first['task_contexts'] as String;
      expect(raw, 'Phone');

      // The Drift converter wraps it as a single-element TaskContext list
      // with `name: "Phone"` and `value: null`. This is the legacy fallback
      // path — without it, the v7 row's value would be lost on the first
      // post-migration read.
      final parsed = parseTaskContexts(raw);
      expect(parsed, hasLength(1));
      expect(parsed.first.name, 'Phone');
      expect(parsed.first.value, isNull);
    });

    test('a v7 row with NULL task_context still reads as empty list', () {
      createV7TasksTable();
      db.execute(
          'INSERT INTO tasks (doc_id, name, person_doc_id) '
          "VALUES ('t-empty', 'Untagged', 'me')");

      runV7ToV8Migration();

      final after = db.select(
          "SELECT task_contexts FROM tasks WHERE doc_id = 't-empty'");
      expect(after.first['task_contexts'], isNull);

      // parseTaskContexts(null) → empty list. No spurious entries.
      expect(parseTaskContexts(null), isEmpty);
    });
  });

  group('v8 fresh schema (Drift)', () {
    // Sanity check that Drift's runtime declaration of v8 lands the way the
    // migration expects when booting a fresh in-memory DB. This catches
    // drift between the migration's manual statements and what the table
    // declaration in `tables.dart` would produce on a clean install.
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('contexts table exists; tasks has task_contexts (not task_context)',
        () async {
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
          .get();
      final names = tables.map((r) => r.read<String>('name')).toSet();
      expect(names, contains('contexts'));
      expect(names, contains('tasks'));

      final cols = await db.customSelect('PRAGMA table_info(tasks)').get();
      final colNames = cols.map((r) => r.read<String>('name')).toSet();
      expect(colNames, contains('task_contexts'));
      expect(colNames, isNot(contains('task_context')));
    });

    test('contexts table carries iconName + color columns (TM-181)',
        () async {
      final cols =
          await db.customSelect('PRAGMA table_info(contexts)').get();
      final colNames = cols.map((r) => r.read<String>('name')).toSet();
      expect(colNames, contains('icon_name'));
      expect(colNames, contains('color'));
      expect(colNames, contains('sort_order'));
      expect(colNames, contains('person_doc_id'));
    });
  });
}
