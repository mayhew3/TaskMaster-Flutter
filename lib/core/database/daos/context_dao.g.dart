// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_dao.dart';

// ignore_for_file: type=lint
mixin _$ContextDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContextsTable get contexts => attachedDatabase.contexts;
  ContextDaoManager get managers => ContextDaoManager(this);
}

class ContextDaoManager {
  final _$ContextDaoMixin _db;
  ContextDaoManager(this._db);
  $$ContextsTableTableManager get contexts =>
      $$ContextsTableTableManager(_db.attachedDatabase, _db.contexts);
}
