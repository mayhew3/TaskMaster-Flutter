// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_dao.dart';

// ignore_for_file: type=lint
mixin _$FamilyDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  FamilyDaoManager get managers => FamilyDaoManager(this);
}

class FamilyDaoManager {
  final _$FamilyDaoMixin _db;
  FamilyDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
}
