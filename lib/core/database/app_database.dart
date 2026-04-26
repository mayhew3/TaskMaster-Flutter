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
  int get schemaVersion => 3;

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
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'taskmaster');
  }
}
