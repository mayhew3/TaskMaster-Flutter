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
  TextColumn get area => text().nullable()();
  // TM-181: was a single string `taskContext`, now a JSON-encoded
  // `List<TaskContext>` (`{name, value?}`). The Drift converter handles
  // serialization and a legacy bare-string fallback wraps a v7 string value
  // as `[{name: <value>, value: null}]` on first read.
  TextColumn get taskContexts => text().nullable()();
  IntColumn get urgency => integer().nullable()();
  IntColumn get priority => integer().nullable()();
  // Scale version for `priority`. 1 = legacy 1-10; cards and the edit
  // screen normalize via `TaskItem.displayPriority`, which applies
  // `(priority/2).round().clamp(1,5)` and returns null for priority <= 0.
  // 2 = TM-358 onwards, priority is already on a 1-5 scale and rendered
  // as-is. Migration is per-task and happens lazily the next time a task
  // is opened in the edit screen.
  IntColumn get priorityScaleVersion =>
      integer().withDefault(const Constant(1))();
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

  // TM-361: server timestamp this row was last synced against — i.e. the
  // most recent `lastModified` we observed from a server-confirmed listener
  // fire or a successful "Use latest" resolution. Used by the conflict
  // detector to compare against the *current* remote `lastModified` so a
  // device editing offline can detect that another device's push landed
  // while it was disconnected. Was previously inferred from `lastModified`,
  // but that field tracks LOCAL clock for pending edits — comparing against
  // it can't distinguish "I edited the latest version" from "I edited an
  // old version while offline."
  DateTimeColumn get lastSyncedRemoteVersion => dateTime().nullable()();

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
  // TM-361: see `Tasks.lastSyncedRemoteVersion`.
  DateTimeColumn get lastSyncedRemoteVersion => dateTime().nullable()();
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

/// Local mirror of Firestore `areas` collection (TM-345).
///
/// Per-user customizable list of categories/areas-of-responsibility that
/// replaces the previously hard-coded `project` list. Tasks reference areas
/// by [Areas.name], not by [Areas.docId], so this table is loosely coupled
/// to the tasks table.
class Areas extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get name => text()();

  /// Lower values sort earlier in the picker / management screen.
  /// User-defined drag-to-reorder rewrites the entire list's sortOrder.
  IntColumn get sortOrder => integer()();

  TextColumn get personDocId => text()();

  TextColumn get retired => text().nullable()();
  DateTimeColumn get retiredDate => dateTime().nullable()();

  TextColumn get syncState =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {docId};
}

/// Local mirror of Firestore `contexts` collection (TM-181).
///
/// Per-user customizable list of contexts (e.g. "Phone", "Computer") that
/// replaces the previously hard-coded picker list. Tasks reference contexts
/// by name (not docId) just like Areas, so a deleted context doesn't orphan
/// any tagged task. [iconName] keys into the closed `ContextIcon` set;
/// [color] is reserved for the Tier-2 color picker.
class Contexts extends Table {
  TextColumn get docId => text()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get iconName => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get personDocId => text()();

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
