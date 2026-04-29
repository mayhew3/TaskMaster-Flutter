import 'package:drift/drift.dart';

/// Sync state of a local row relative to Firestore.
/// Stored as a TEXT column with one of these string values.
///
/// - [synced] — row matches Firestore; safe to overwrite from remote snapshots
/// - [pendingCreate] — created locally, not yet pushed
/// - [pendingUpdate] — updated locally, not yet pushed
/// - [pendingDelete] — soft-deleted locally, pending remote delete
/// - [pendingConflict] — push detected a newer remote version (TM-342); the
///   local row preserves the user's pending edit, the remote version is
///   stashed in `conflictRemoteJson`, and the user must resolve via the
///   sync conflicts UI before sync resumes for this doc
///
/// Pending-local-wins conflict resolution: remote snapshots must not overwrite
/// a row whose sync_state != synced.
enum SyncState {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  pendingConflict,
}

/// Local mirror of Firestore `tasks` collection.
/// One extra column: [syncState] — the write state of this row.
class Tasks extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get personDocId => text().nullable()();
  TextColumn get familyDocId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get project => text().nullable()();
  // `context` would collide with `BuildContext` imports; use taskContext
  TextColumn get taskContext => text().nullable()();
  IntColumn get urgency => integer().nullable()();
  IntColumn get priority => integer().nullable()();
  IntColumn get duration => integer().nullable()();
  IntColumn get gamePoints => integer().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get urgentDate => dateTime().nullable()();
  DateTimeColumn get completionDate => dateTime().nullable()();
  IntColumn get recurNumber => integer().nullable()();
  TextColumn get recurUnit => text().nullable()();
  BoolColumn get recurWait => boolean().nullable()();
  TextColumn get recurrenceDocId => text().nullable()();
  IntColumn get recurIteration => integer().nullable()();
  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();
  BoolColumn get offCycle => boolean().withDefault(const Constant(false))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  // Last-modified timestamp for conflict detection (TM-342). Populated on
  // every local mutation (insertPending/markUpdatePending/markDeletePending)
  // and overwritten by the server-authoritative value when a remote snapshot
  // is upserted.
  DateTimeColumn get lastModified => dateTime().nullable()();

  // When push detects that the remote was modified after the local edit,
  // the remote version is JSON-stashed here and `syncState` becomes
  // `pendingConflict`. Cleared once the user resolves via the sync conflicts UI.
  TextColumn get conflictRemoteJson => text().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `taskRecurrences` collection.
/// `anchorDate` is stored as a JSON TEXT blob containing
/// `{dateValue: <iso8601>, dateType: <enum name>}`.
class TaskRecurrences extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get personDocId => text()();
  TextColumn get name => text()();
  IntColumn get recurNumber => integer()();
  TextColumn get recurUnit => text()();
  BoolColumn get recurWait => boolean()();
  IntColumn get recurIteration => integer()();
  TextColumn get anchorDateJson => text()();

  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();

  // See `Tasks.lastModified` (TM-342).
  DateTimeColumn get lastModified => dateTime().nullable()();
  TextColumn get conflictRemoteJson => text().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `sprints` collection (top-level fields only).
/// Assignments live in [SprintAssignments] with a foreign key.
class Sprints extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get closeDate => dateTime().nullable()();
  IntColumn get numUnits => integer()();
  TextColumn get unitName => text()();
  TextColumn get personDocId => text()();
  IntColumn get sprintNumber => integer()();
  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `sprints/{id}/sprintAssignments` subcollection.
class SprintAssignments extends Table {
  TextColumn get docId => text()();
  TextColumn get taskDocId => text()();
  TextColumn get sprintDocId => text()();
  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `families` collection.
/// `members` is JSON-encoded as `["personDocId", ...]`.
class Families extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get ownerPersonDocId => text()();
  TextColumn get membersJson => text()();

  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `familyInvitations` collection.
class FamilyInvitations extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get inviterPersonDocId => text()();
  TextColumn get inviterFamilyDocId => text()();
  TextColumn get inviterDisplayName => text().nullable()();
  TextColumn get inviteeEmail => text()();
  TextColumn get status => text()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `persons` collection (subset of fields needed
/// for the Family feature). The full server-side Person doc may have
/// additional fields not surfaced here.
class Persons extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get familyDocId => text().nullable()();

  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}
