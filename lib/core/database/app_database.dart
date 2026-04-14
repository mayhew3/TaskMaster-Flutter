import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/sprint_dao.dart';
import 'daos/task_dao.dart';
import 'daos/task_recurrence_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Tasks, TaskRecurrences, Sprints, SprintAssignments],
  daos: [TaskDao, TaskRecurrenceDao, SprintDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for tests to inject an in-memory executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'taskmaster');
  }
}
