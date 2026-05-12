// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_invitation_dao.dart';

// ignore_for_file: type=lint
mixin _$FamilyInvitationDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamilyInvitationsTable get familyInvitations =>
      attachedDatabase.familyInvitations;
  FamilyInvitationDaoManager get managers => FamilyInvitationDaoManager(this);
}

class FamilyInvitationDaoManager {
  final _$FamilyInvitationDaoMixin _db;
  FamilyInvitationDaoManager(this._db);
  $$FamilyInvitationsTableTableManager get familyInvitations =>
      $$FamilyInvitationsTableTableManager(
        _db.attachedDatabase,
        _db.familyInvitations,
      );
}
