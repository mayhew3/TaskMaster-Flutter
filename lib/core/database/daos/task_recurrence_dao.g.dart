// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_recurrence_dao.dart';

// ignore_for_file: type=lint
mixin _$TaskRecurrenceDaoMixin on DatabaseAccessor<AppDatabase> {
  $TaskRecurrencesTable get taskRecurrences => attachedDatabase.taskRecurrences;
  TaskRecurrenceDaoManager get managers => TaskRecurrenceDaoManager(this);
}

class TaskRecurrenceDaoManager {
  final _$TaskRecurrenceDaoMixin _db;
  TaskRecurrenceDaoManager(this._db);
  $$TaskRecurrencesTableTableManager get taskRecurrences =>
      $$TaskRecurrencesTableTableManager(
        _db.attachedDatabase,
        _db.taskRecurrences,
      );
}
