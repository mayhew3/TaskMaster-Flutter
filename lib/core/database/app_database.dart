import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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
    Families,
    FamilyInvitations,
    Persons,
  ],
  daos: [
    TaskDao,
    TaskRecurrenceDao,
    SprintDao,
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
  int get schemaVersion => 4;

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
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'taskmaster');
  }
}
