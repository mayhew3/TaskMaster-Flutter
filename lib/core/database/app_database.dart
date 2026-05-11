import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/area_dao.dart';
import 'daos/context_dao.dart';
import 'daos/family_dao.dart';
import 'daos/family_invitation_dao.dart';
import 'daos/person_dao.dart';
import 'daos/sprint_dao.dart';
import 'daos/task_dao.dart';
import 'daos/task_recurrence_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Tasks,
    TaskRecurrences,
    Sprints,
    SprintAssignments,
    Areas,
    Contexts,
    Families,
    FamilyInvitations,
    Persons,
  ],
  daos: [
    TaskDao,
    TaskRecurrenceDao,
    SprintDao,
    AreaDao,
    ContextDao,
    FamilyDao,
    FamilyInvitationDao,
    PersonDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for tests to inject an in-memory executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tasks, tasks.skipped);
      }
      if (from < 3) {
        await m.addColumn(tasks, tasks.familyDocId);
        await m.createTable(families);
        await m.createTable(familyInvitations);
        await m.createTable(persons);
      }
      if (from < 4) {
        // TM-342: conflict detection columns.
        await m.addColumn(tasks, tasks.lastModified);
        await m.addColumn(tasks, tasks.conflictRemoteJson);
        await m.addColumn(taskRecurrences, taskRecurrences.lastModified);
        await m.addColumn(taskRecurrences, taskRecurrences.conflictRemoteJson);
        // Backfill lastModified from dateAdded so existing rows have a
        // best-effort baseline timestamp; the next push or remote snapshot
        // will overwrite with the authoritative server value.
        await customStatement(
          'UPDATE tasks SET last_modified = date_added WHERE last_modified IS NULL',
        );
        await customStatement(
          'UPDATE task_recurrences SET last_modified = date_added WHERE last_modified IS NULL',
        );
      }
      if (from < 5) {
        // TM-345: areas collection (replaces hard-coded project list).
        await m.createTable(areas);
      }
      if (from < 6) {
        // TM-345: rename tasks.project → tasks.area. The Phase 0 server-side
        // migration script handles the Firestore-side rename before deploy;
        // this preserves any locally-cached project values during the upgrade
        // (the next remote snapshot will overwrite anyway).
        // SQLite supports RENAME COLUMN since 3.25; the project's drift
        // dependency is well above that minimum.
        await customStatement('ALTER TABLE tasks RENAME COLUMN project TO area');
      }
      if (from < 7) {
        // TM-358: per-task `priorityScaleVersion` so cards and the redesigned
        // edit screen can disambiguate legacy 1-10 priorities from the new
        // 1-5 scale. Existing rows default to scale version 1 (legacy);
        // a row's scale version flips to 2 the next time the user saves
        // that task from the edit screen.
        await m.addColumn(tasks, tasks.priorityScaleVersion);
      }
      if (from < 8) {
        // TM-181: per-user contexts collection (replaces hard-coded picker
        // list); rename `tasks.taskContext` (single string) → `taskContexts`
        // (JSON `List<TaskContext>`). Existing single-string values survive
        // the rename intact; the converter's bare-string fallback wraps each
        // legacy value as `[{name: <value>, value: null}]` on first read.
        await m.createTable(contexts);
        await customStatement(
          'ALTER TABLE tasks RENAME COLUMN task_context TO task_contexts',
        );
      }
      if (from < 9) {
        // TM-361: per-row `lastSyncedRemoteVersion` so the conflict check
        // can compare the current remote `lastModified` against the server
        // timestamp we last synced *for this row*, instead of against our
        // own local clock. Without it, an offline edit's local-clock-stamped
        // `lastModified` reads as "newer" than a remote that updated while
        // we were disconnected, and the push silently overwrites that
        // remote — exactly the data-loss case TM-361 manual-test #15
        // surfaced.
        await m.addColumn(tasks, tasks.lastSyncedRemoteVersion);
        await m.addColumn(
            taskRecurrences, taskRecurrences.lastSyncedRemoteVersion);
        // Seed from `lastModified` for rows currently in `synced` state —
        // those are by definition the last value we observed from the
        // server. Pending rows can't safely backfill (their `lastModified`
        // is the local edit time, not a server stamp); they'll get the
        // right value on the next successful push / listener fire.
        await customStatement(
          'UPDATE tasks SET last_synced_remote_version = last_modified '
          "WHERE sync_state = 'synced' AND last_synced_remote_version IS NULL",
        );
        await customStatement(
          'UPDATE task_recurrences SET last_synced_remote_version = '
          "last_modified WHERE sync_state = 'synced' "
          'AND last_synced_remote_version IS NULL',
        );
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'taskmaestro');
  }
}
