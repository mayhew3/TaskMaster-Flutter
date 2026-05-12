// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_dao.dart';

// ignore_for_file: type=lint
mixin _$SprintDaoMixin on DatabaseAccessor<AppDatabase> {
  $SprintsTable get sprints => attachedDatabase.sprints;
  $SprintAssignmentsTable get sprintAssignments =>
      attachedDatabase.sprintAssignments;
  SprintDaoManager get managers => SprintDaoManager(this);
}

class SprintDaoManager {
  final _$SprintDaoMixin _db;
  SprintDaoManager(this._db);
  $$SprintsTableTableManager get sprints =>
      $$SprintsTableTableManager(_db.attachedDatabase, _db.sprints);
  $$SprintAssignmentsTableTableManager get sprintAssignments =>
      $$SprintAssignmentsTableTableManager(
        _db.attachedDatabase,
        _db.sprintAssignments,
      );
}
