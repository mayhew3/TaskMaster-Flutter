// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_dao.dart';

// ignore_for_file: type=lint
mixin _$AreaDaoMixin on DatabaseAccessor<AppDatabase> {
  $AreasTable get areas => attachedDatabase.areas;
  AreaDaoManager get managers => AreaDaoManager(this);
}

class AreaDaoManager {
  final _$AreaDaoMixin _db;
  AreaDaoManager(this._db);
  $$AreasTableTableManager get areas =>
      $$AreasTableTableManager(_db.attachedDatabase, _db.areas);
}
