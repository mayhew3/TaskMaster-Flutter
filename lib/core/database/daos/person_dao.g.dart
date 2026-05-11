// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_dao.dart';

// ignore_for_file: type=lint
mixin _$PersonDaoMixin on DatabaseAccessor<AppDatabase> {
  $PersonsTable get persons => attachedDatabase.persons;
  PersonDaoManager get managers => PersonDaoManager(this);
}

class PersonDaoManager {
  final _$PersonDaoMixin _db;
  PersonDaoManager(this._db);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db.attachedDatabase, _db.persons);
}
