import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/family.dart' as m;
import '../../models/family_invitation.dart' as m;
import '../../models/person.dart' as m;
import '../../models/serializers.dart';
import '../../models/sprint.dart' as m;
import '../../models/sprint_assignment.dart' as m;
import '../../models/task_item.dart' as m;
import '../../models/task_recurrence.dart' as m;
import '../database/app_database.dart';
import '../database/converters.dart';
import '../database/tables.dart';
import '../providers/connectivity_provider.dart';
import '../providers/database_provider.dart';
import '../providers/firebase_providers.dart';
import '../providers/notification_providers.dart';
import '../providers/sync_status_provider.dart';
import 'crash_reporter.dart';
import 'notification_helper_impl.dart';

part 'sync_service.g.dart';

/// Debug-only log helper — no-ops in release/profile builds so the on-device
/// log file and console aren't flooded with sync diagnostics in production.
void _syncLog(String message) {
  if (kDebugMode) debugPrint(message);
}

/// Bridges Firestore and the local Drift database.
///
/// - On [start], subscribes to Firestore collections and mirrors snapshots
///   into Drift, applying pending-local-wins conflict resolution.
/// - On [stop], cancels subscriptions (called on sign-out).
/// - [pushPendingWrites] flushes locally-pending rows to Firestore. Triggered
///   automatically when connectivity flips from offline to online.
class SyncService {
  SyncService({
    required this.db,
    required this.firestore,
    required this.ref,
  });

  final AppDatabase db;
  final FirebaseFirestore firestore;
  final Ref ref;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _recurrencesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sprintsSub;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _assignmentSubs = {};
  // Family-feature subscriptions (TM-335).
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _personSelfSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _invitationsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _familyDocSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _familyMembersSub;
  // Last set of member docIds this listener is watching, so we can skip
  // tearing down + rebuilding the Firestore listener on family-doc snapshots
  // that didn't actually change membership.
  Set<String>? _familyMembersWatchedSet;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _familyTasksSub;
  ProviderSubscription<AsyncValue<bool>>? _connectivitySub;

  String? _currentPersonDocId;
  String? _currentEmail;
  String? _currentFamilyDocId;
  bool _wasOnline = true;
  DateTime? _startTime;

  // Track whether we've received the first snapshot for each collection.
  // On the initial snapshot we reconcile: purge synced local rows absent from
  // Firestore (handles emulator reset / server-side bulk deletes).
  bool _isPushing = false;
  // Set when a push is requested while one is already in flight; the
  // in-flight push checks this flag in its `finally` and re-runs itself so
  // callers never get silently dropped.
  bool _pushRequestedWhilePushing = false;
  bool _tasksInitialReceived = false;
  bool _recurrencesInitialReceived = false;
  bool _sprintsInitialReceived = false;
  bool _familyTasksInitialReceived = false;

  // Completes once all 3 collections have delivered their first snapshot.
  // The UI awaits this to show a loading screen on cold start.
  Completer<void>? _initialPullCompleter;
  int _initialSnapshotsReceived = 0;

  /// Future that completes when the first snapshot for every synced collection
  /// has been processed. Await this (with a timeout) to block the UI until
  /// Firestore has confirmed current state, falling back to local cache if
  /// offline.
  Future<void> get initialPullComplete =>
      _initialPullCompleter?.future ?? Future.value();

  void _markInitialSnapshotReceived() {
    _initialSnapshotsReceived++;
    _syncLog('[SyncService] +${_ms()}ms initialSnapshots=$_initialSnapshotsReceived/3');
    if (_initialSnapshotsReceived >= 3 &&
        _initialPullCompleter != null &&
        !_initialPullCompleter!.isCompleted) {
      _syncLog('[SyncService] +${_ms()}ms ALL initial snapshots received — unblocking UI');
      _initialPullCompleter!.complete();
    }
  }

  Future<void> start(String personDocId, {String? email}) async {
    if (_currentPersonDocId == personDocId) {
      // Same user — but the email may have arrived after the original
      // start() (e.g. auth resolved later). If we never attached the
      // invitations listener, attach it now without tearing down the
      // already-running listeners. If the email actually changed, restart
      // the invitations listener to point at the new address.
      if (email != null &&
          email.isNotEmpty &&
          email != _currentEmail) {
        _currentEmail = email;
        await _invitationsSub?.cancel();
        _invitationsSub = firestore
            .collection('familyInvitations')
            .where('inviteeEmail', isEqualTo: email)
            .snapshots()
            .listen(_onInvitationsSnapshot, onError: _logSyncError);
        _syncLog('[SyncService] reattached invitations listener (email=$email)');
      }
      return;
    }
    await stop();
    _currentPersonDocId = personDocId;
    _currentEmail = email;
    _initialPullCompleter = Completer<void>();
    _initialSnapshotsReceived = 0;
    _startTime = DateTime.now();
    _syncLog('[SyncService] start() — personDocId=$personDocId email=$email');

    _tasksSub = firestore
        .collection('tasks')
        .where('personDocId', isEqualTo: personDocId)
        .where('completionDate', isNull: true)
        .where('retired', isNull: true)
        .snapshots()
        .listen(_onTasksSnapshot, onError: _logSyncError);

    // Filter `retired` client-side rather than server-side: Firestore's
    // `isNull: true` excludes documents that lack the field entirely, and we
    // have legacy recurrence docs without a `retired` field (TM-343). Filtering
    // client-side after fetch ensures those reach Drift.
    _recurrencesSub = firestore
        .collection('taskRecurrences')
        .where('personDocId', isEqualTo: personDocId)
        .snapshots()
        .listen(_onRecurrencesSnapshot, onError: _logSyncError);

    _sprintsSub = firestore
        .collection('sprints')
        .where('personDocId', isEqualTo: personDocId)
        .orderBy('sprintNumber', descending: true)
        .limit(3)
        .snapshots()
        .listen(_onSprintsSnapshot, onError: _logSyncError);

    // Family feature (TM-335): listen to my own Person doc to detect family
    // membership changes; listen to invitations addressed to my email.
    _personSelfSub = firestore
        .collection('persons')
        .doc(personDocId)
        .snapshots()
        .listen(_onPersonSelfSnapshot, onError: _logSyncError);

    if (email != null && email.isNotEmpty) {
      _invitationsSub = firestore
          .collection('familyInvitations')
          .where('inviteeEmail', isEqualTo: email)
          .snapshots()
          .listen(_onInvitationsSnapshot, onError: _logSyncError);
    }

    _connectivitySub = ref.listen<AsyncValue<bool>>(
      connectivityProvider,
      (prev, next) {
        final online = next.valueOrNull ?? false;
        if (online && !_wasOnline) {
          // Just came back online — flush queue.
          pushPendingWrites(caller: 'connectivity');
        }
        _wasOnline = online;
      },
      fireImmediately: true,
    );
  }

  Future<void> stop() async {
    await _tasksSub?.cancel();
    await _recurrencesSub?.cancel();
    await _sprintsSub?.cancel();
    for (final sub in _assignmentSubs.values) {
      await sub.cancel();
    }
    _assignmentSubs.clear();
    await _detachFamilyListeners();
    await _personSelfSub?.cancel();
    await _invitationsSub?.cancel();
    _connectivitySub?.close();
    _tasksSub = null;
    _recurrencesSub = null;
    _sprintsSub = null;
    _personSelfSub = null;
    _invitationsSub = null;
    _connectivitySub = null;
    _currentPersonDocId = null;
    _currentEmail = null;
    _currentFamilyDocId = null;
    _tasksInitialReceived = false;
    _recurrencesInitialReceived = false;
    _sprintsInitialReceived = false;
    if (_initialPullCompleter != null && !_initialPullCompleter!.isCompleted) {
      _initialPullCompleter!.complete();
    }
    _initialPullCompleter = null;
    _initialSnapshotsReceived = 0;
  }

  /// Cancel all family-scoped listeners. Called when [_currentFamilyDocId]
  /// changes (or becomes null) and on [stop].
  Future<void> _detachFamilyListeners() async {
    await _familyDocSub?.cancel();
    await _familyMembersSub?.cancel();
    await _familyTasksSub?.cancel();
    _familyDocSub = null;
    _familyMembersSub = null;
    _familyTasksSub = null;
    _familyMembersWatchedSet = null;
    // Reset so the next attach treats its first snapshot as initial again.
    _familyTasksInitialReceived = false;
  }

  // ── Snapshot handlers ──────────────────────────────────────────────────────

  int _ms() =>
      _startTime == null ? 0 : DateTime.now().difference(_startTime!).inMilliseconds;

  Future<void> _onTasksSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_tasksInitialReceived;
    _tasksInitialReceived = true;

    _syncLog('[SyncService] +${_ms()}ms tasks snapshot arrived: ${snapshot.docs.length} docs, ${snapshot.docChanges.length} changes, isInitial=$isInitial');

    final toUpsert = <TasksCompanion>[];
    final toRefreshNotifications = <m.TaskItem>[];
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        // The personal listener filters incomplete-only. A doc leaving the
        // view typically means it was completed (not deleted). For
        // family-shared tasks (TM-335), the family listener still keeps the
        // row in sync — deleting here would race with the family listener's
        // upsert and could lose the row entirely. Skip the delete in that
        // case; if the row is truly retired/deleted, the family listener
        // will deliver its own removed event.
        final local = await db.taskDao.getByDocId(change.doc.id);
        if (local != null && local.familyDocId != null) {
          continue;
        }
        await db.taskDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
        json['docId'] = change.doc.id;
        final task = serializers.deserializeWith(m.TaskItem.serializer, json);
        if (task != null) {
          toUpsert.add(taskItemToCompanion(task));
          // Schedule notification refresh post-snapshot. Skip on initial
          // because notificationSyncProvider does a full bulk sync on app
          // startup; per-task updates here would just duplicate work.
          if (!isInitial) toRefreshNotifications.add(task);
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }

    await db.taskDao.bulkUpsertFromRemote(toUpsert);

    // On the first snapshot, purge synced INCOMPLETE rows that Firestore no
    // longer has (covers emulator reset and server-side bulk deletes).
    // Only incomplete rows are scoped to this listener query
    // (completionDate: isNull: true), so only they should be reconciled.
    // Completed rows must not be deleted here — they would be incorrectly
    // purged because the listener never returns them (TM-341).
    if (isInitial) {
      final remoteIds = snapshot.docs.map((d) => d.id).toSet();
      await db.taskDao.deleteSyncedIncompleteNotIn(_currentPersonDocId!, remoteIds);
    }

    _refreshNotificationsForTasks(toRefreshNotifications);

    _syncLog('[SyncService] +${_ms()}ms tasks transaction done');
    if (isInitial) _markInitialSnapshotReceived();
    _syncLog('[SyncService] +${_ms()}ms tasks initial complete');
  }

  /// Fire-and-forget per-task notification refresh. Each task is sent through
  /// the helper which decides whether to schedule (active) or cancel
  /// (completed / retired) based on its current state. Errors are logged but
  /// don't affect sync; notifications are best-effort by design.
  void _refreshNotificationsForTasks(List<m.TaskItem> tasks) {
    if (tasks.isEmpty) return;
    final NotificationHelperImpl helper;
    try {
      helper = ref.read(notificationHelperProvider);
    } catch (_) {
      // Helper unavailable (tests, init race) — silently skip.
      return;
    }
    for (final task in tasks) {
      helper.updateNotificationForTask(task).catchError(
          (e) => _syncLog('[SyncService] notification refresh error for ${task.docId}: $e'));
    }
  }

  Future<void> _onRecurrencesSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_recurrencesInitialReceived;
    _recurrencesInitialReceived = true;

    _syncLog('[SyncService] +${_ms()}ms recurrences snapshot arrived: ${snapshot.docs.length} docs, isInitial=$isInitial');

    final toUpsert = <TaskRecurrencesCompanion>[];
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.taskRecurrenceDao.deleteFromRemote(change.doc.id);
        continue;
      }
      final data = change.doc.data();
      // Skip retired recurrences — the local Drift converter does not write
      // the `retired` column, so retired rows would appear active locally.
      if (data == null || data['retired'] != null) {
        // If this row was previously synced as active and is now retired,
        // drop the local copy so watchActive stops emitting it.
        await db.taskRecurrenceDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(data);
        json['docId'] = change.doc.id;
        final recurrence =
            serializers.deserializeWith(m.TaskRecurrence.serializer, json);
        if (recurrence != null) {
          toUpsert.add(taskRecurrenceToCompanion(recurrence));
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }

    await db.taskRecurrenceDao.bulkUpsertFromRemote(toUpsert);

    if (isInitial) {
      // Only consider active (non-retired) docs for reconciliation; retired
      // docs were already removed from Drift in the loop above. Scope by
      // personDocId so a sign-out/sign-in cycle with a different account does
      // not purge the previous user's rows that may still be cached locally.
      final remoteIds = snapshot.docs
          .where((d) => d.data()['retired'] == null)
          .map((d) => d.id)
          .toSet();
      await db.taskRecurrenceDao
          .deleteSyncedNotInForPerson(_currentPersonDocId!, remoteIds);
    }

    _syncLog('[SyncService] +${_ms()}ms recurrences transaction done');
    if (isInitial) _markInitialSnapshotReceived();
    _syncLog('[SyncService] +${_ms()}ms recurrences initial complete');
  }

  Future<void> _onSprintsSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_sprintsInitialReceived;
    _sprintsInitialReceived = true;

    _syncLog('[SyncService] +${_ms()}ms sprints snapshot arrived: ${snapshot.docs.length} docs, ${snapshot.docChanges.length} changes, isInitial=$isInitial');
    for (final doc in snapshot.docs) {
      final data = doc.data();
      _syncLog('  sprint ${doc.id}: sprintNumber=${data['sprintNumber']}, '
          'start=${data['startDate']}, end=${data['endDate']}');
    }

    // Handle removed docs: cancel assignment listeners and delete local rows.
    // Explicitly delete synced assignments for the removed sprint — the
    // per-sprint subcollection listener is cancelled before it can observe
    // the removals, so without this those rows would linger as orphans until
    // the next cold start runs deleteSyncedOrphanAssignments.
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        final doc = change.doc;
        await _assignmentSubs.remove(doc.id)?.cancel();
        await db.sprintDao.deleteSyncedAssignmentsForSprint(doc.id);
        await db.sprintDao.deleteSprintFromRemote(doc.id);
      }
    }

    // Upsert all currently-present sprints and ensure each has an assignment
    // listener. Iterate `snapshot.docs` (not `docChanges`) so unchanged sprints
    // in a no-change snapshot still have their listeners kept alive below.
    for (final doc in snapshot.docs) {
      try {
        final json = Map<String, dynamic>.from(doc.data());
        json['docId'] = doc.id;
        // Sprints in Drift store top-level only; assignments come via
        // per-sprint subcollection listener.
        json['sprintAssignments'] = const <Map<String, dynamic>>[];
        final sprint = serializers.deserializeWith(m.Sprint.serializer, json);
        if (sprint != null) {
          await db.sprintDao.upsertSprintFromRemote(sprintToCompanion(sprint));
        }
        _ensureAssignmentListener(doc.reference);
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }

    // On the first snapshot, purge phantom synced sprints: any synced local
    // sprint absent from the remote snapshot doesn't exist in Firestore.
    // This is safe because only the top-N sprints are ever synced to Drift.
    final remoteIds = snapshot.docs.map((d) => d.id).toSet();
    if (isInitial) {
      await db.sprintDao.deleteSyncedSprintsNotIn(remoteIds);
      await db.sprintDao.deleteSyncedOrphanAssignments();
      _markInitialSnapshotReceived();
      _syncLog('[SyncService] +${_ms()}ms sprints initial complete');
    }

    // Cancel listeners for sprints no longer in the snapshot. Use `remoteIds`
    // (derived from snapshot.docs) rather than a set built from docChanges —
    // on a no-change snapshot, docChanges is empty but the sprints are still
    // live and their listeners must not be cancelled.
    final stale =
        _assignmentSubs.keys.where((id) => !remoteIds.contains(id)).toList();
    for (final id in stale) {
      await _assignmentSubs.remove(id)?.cancel();
    }
  }

  // ── Family snapshot handlers (TM-335) ──────────────────────────────────────

  Future<void> _onPersonSelfSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final data = snapshot.data();
    if (data == null) {
      // Person doc was deleted (or never existed). Detach any family listeners
      // and clear the local row.
      if (_currentPersonDocId != null) {
        await db.personDao.deleteFromRemote(_currentPersonDocId!);
      }
      if (_currentFamilyDocId != null) {
        _currentFamilyDocId = null;
        await _detachFamilyListeners();
      }
      return;
    }
    try {
      final json = Map<String, dynamic>.from(data);
      json['docId'] = snapshot.id;
      final person = serializers.deserializeWith(m.Person.serializer, json);
      if (person != null) {
        await db.personDao.upsertFromRemote(personToCompanion(person));
      }
      final newFamilyDocId = data['familyDocId'] as String?;
      if (newFamilyDocId != _currentFamilyDocId) {
        _currentFamilyDocId = newFamilyDocId;
        await _detachFamilyListeners();
        if (newFamilyDocId != null && newFamilyDocId.isNotEmpty) {
          _attachFamilyListeners(newFamilyDocId);
        }
      }
    } catch (e, s) {
      _logSyncError(e, s);
    }
  }

  void _attachFamilyListeners(String familyDocId) {
    _familyDocSub = firestore
        .collection('families')
        .doc(familyDocId)
        .snapshots()
        .listen(_onFamilyDocSnapshot, onError: _logSyncError);

    // Family-tasks listener intentionally does NOT filter `completionDate`
    // so the "Show Completed" toggle on the Family tab can surface completed
    // family tasks after the user navigates away and back. Cost: every
    // completed family task ever flows into Drift; acceptable at MVP family
    // sizes. Tier 2 (TM-336) can paginate if this becomes an issue.
    _familyTasksSub = firestore
        .collection('tasks')
        .where('familyDocId', isEqualTo: familyDocId)
        .where('retired', isNull: true)
        .snapshots()
        .listen(_onFamilyTasksSnapshot, onError: _logSyncError);
  }

  Future<void> _onFamilyDocSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final data = snapshot.data();
    if (data == null) {
      // Family was deleted server-side (e.g. last member left). Drop the
      // local row and detach every family-scoped listener — leaving the
      // family-tasks listener running here would keep mirroring tasks for a
      // family that no longer exists. _currentFamilyDocId is reset so the
      // next persons-self snapshot can reattach if the user joins another.
      await db.familyDao.deleteFromRemote(snapshot.id);
      await _detachFamilyListeners();
      _currentFamilyDocId = null;
      return;
    }
    try {
      final json = Map<String, dynamic>.from(data);
      json['docId'] = snapshot.id;
      final family = serializers.deserializeWith(m.Family.serializer, json);
      if (family != null) {
        await db.familyDao.upsertFromRemote(familyToCompanion(family));
      }
      final members = (data['members'] as List<dynamic>?)
              ?.cast<String>()
              .where((id) => id.isNotEmpty)
              .toList() ??
          const <String>[];
      await _ensureFamilyMembersListener(members);
    } catch (e, s) {
      _logSyncError(e, s);
    }
  }

  Future<void> _ensureFamilyMembersListener(List<String> memberDocIds) async {
    final newSet = memberDocIds.toSet();
    // Skip when the watched set is unchanged — most family-doc snapshots are
    // unrelated to membership (e.g. ownership transfer or denormalized
    // metadata edits) and recreating the listener on every one causes
    // unnecessary churn + brief gaps in the persons stream.
    if (_familyMembersWatchedSet != null &&
        _familyMembersSub != null &&
        _familyMembersWatchedSet!.length == newSet.length &&
        _familyMembersWatchedSet!.containsAll(newSet)) {
      return;
    }

    await _familyMembersSub?.cancel();
    _familyMembersSub = null;
    _familyMembersWatchedSet = null;

    if (memberDocIds.isEmpty) return;
    // Firestore `whereIn` supports up to 30 elements per query; family size
    // for MVP is well under that. If a future Tier 2 supports larger groups
    // we'll need to chunk.
    _familyMembersSub = firestore
        .collection('persons')
        .where(FieldPath.documentId, whereIn: memberDocIds)
        .snapshots()
        .listen(_onFamilyMembersSnapshot, onError: _logSyncError);
    _familyMembersWatchedSet = newSet;
  }

  Future<void> _onFamilyMembersSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final toUpsert = <PersonsCompanion>[];
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        // Member dropped from the family — its persons doc still exists, but
        // it's no longer reachable through the family lens. Leave the local
        // row alone; the personSelf listener (if any) for that user will
        // refresh it from their side.
        continue;
      }
      try {
        final data = change.doc.data();
        if (data == null) continue;
        final json = Map<String, dynamic>.from(data);
        json['docId'] = change.doc.id;
        final person = serializers.deserializeWith(m.Person.serializer, json);
        if (person != null) {
          toUpsert.add(personToCompanion(person));
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }
    await db.personDao.bulkUpsertFromRemote(toUpsert);
  }

  Future<void> _onFamilyTasksSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final familyDocId = _currentFamilyDocId;
    if (familyDocId == null) return;
    final isInitial = !_familyTasksInitialReceived;
    _familyTasksInitialReceived = true;

    final toUpsert = <TasksCompanion>[];
    final toRefreshNotifications = <m.TaskItem>[];
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.taskDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
        json['docId'] = change.doc.id;
        final task = serializers.deserializeWith(m.TaskItem.serializer, json);
        if (task != null) {
          toUpsert.add(taskItemToCompanion(task));
          // Skip on initial — notificationSyncProvider does the bulk sync at
          // app start. Per-task refresh after the initial snapshot covers
          // family-shared task changes from other devices (TM-335 follow-up).
          if (!isInitial) toRefreshNotifications.add(task);
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }
    await db.taskDao.bulkUpsertFromRemote(toUpsert);

    // Reconcile family tasks against the initial snapshot only — steady-state
    // deletes are already covered by Firestore `removed` docChanges above.
    // Running this on every snapshot turned each modification into an O(N)
    // NOT-IN delete across the whole family-task table, which gets expensive
    // as completed family tasks accumulate. Scoped to familyDocId so a
    // leave/rejoin cycle with a different family doesn't touch the new
    // family's rows.
    if (isInitial) {
      final remoteIds = snapshot.docs.map((d) => d.id).toSet();
      await db.taskDao.deleteSyncedFamilyTasksNotIn(familyDocId, remoteIds);
    }

    _refreshNotificationsForTasks(toRefreshNotifications);
  }

  Future<void> _onInvitationsSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final email = _currentEmail;
    if (email == null) return;
    final toUpsert = <FamilyInvitationsCompanion>[];
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.familyInvitationDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
        json['docId'] = change.doc.id;
        final invitation =
            serializers.deserializeWith(m.FamilyInvitation.serializer, json);
        if (invitation != null) {
          toUpsert.add(familyInvitationToCompanion(invitation));
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }
    await db.familyInvitationDao.bulkUpsertFromRemote(toUpsert);

    final remoteIds = snapshot.docs.map((d) => d.id).toSet();
    await db.familyInvitationDao
        .deleteSyncedNotInForEmail(email, remoteIds);
  }

  void _ensureAssignmentListener(
      DocumentReference<Map<String, dynamic>> sprintDoc) {
    if (_assignmentSubs.containsKey(sprintDoc.id)) return;
    _assignmentSubs[sprintDoc.id] = sprintDoc
        .collection('sprintAssignments')
        .snapshots()
        .listen((snap) async {
      await db.transaction(() async {
        // Handle removals first so deleted Firestore docs are reflected locally.
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.removed) {
            await db.sprintDao.deleteAssignmentFromRemote(change.doc.id);
          }
        }
        // Upsert current assignments.
        for (final assignDoc in snap.docs) {
          try {
            final json = Map<String, dynamic>.from(assignDoc.data());
            json['docId'] = assignDoc.id;
            json['sprintDocId'] = sprintDoc.id;
            final assignment =
                serializers.deserializeWith(m.SprintAssignment.serializer, json);
            if (assignment != null) {
              await db.sprintDao
                  .upsertAssignmentFromRemote(sprintAssignmentToCompanion(assignment));
            }
          } catch (e, s) {
            _logSyncError(e, s);
          }
        }
      });
    }, onError: _logSyncError);
  }

  // ── Push pending writes ────────────────────────────────────────────────────

  Future<void> pushPendingWrites({String caller = 'unknown'}) async {
    if (_isPushing) {
      // Don't drop the request: mark it so the in-flight push re-runs
      // itself once it finishes, picking up any rows this caller just
      // queued.
      _pushRequestedWhilePushing = true;
      _syncLog('[SyncService] pushPendingWrites queued (already pushing) — caller: $caller');
      return;
    }
    final online = ref.read(connectivityProvider).valueOrNull ?? false;
    if (!online) return;

    _syncLog('[SyncService] pushPendingWrites START — caller: $caller');
    _isPushing = true;
    _pushRequestedWhilePushing = false;
    final statusController = ref.read(syncStatusControllerProvider.notifier);
    statusController.set(SyncStatus.syncing);
    try {
      // OR each phase's failure flag — per-row errors are caught and logged
      // inside each phase, so we need this to know whether any row failed.
      var hadFailure = false;
      hadFailure |= await _pushPendingTasks();
      hadFailure |= await _pushPendingRecurrences();
      hadFailure |= await _pushPendingSprints();
      hadFailure |= await _pushPendingAssignments();
      statusController
          .set(hadFailure ? SyncStatus.error : SyncStatus.idle);
    } catch (e, s) {
      statusController.set(SyncStatus.error);
      _logSyncError(e, s);
    } finally {
      _syncLog('[SyncService] pushPendingWrites END — caller: $caller');
      _isPushing = false;
      // If another caller requested a push while we were running, trigger
      // a follow-up push so their rows aren't left pending.
      if (_pushRequestedWhilePushing) {
        _pushRequestedWhilePushing = false;
        // Fire-and-forget: the caller of this pushPendingWrites doesn't
        // wait on the follow-up run.
        pushPendingWrites(caller: 'followup').ignore();
      }
    }
  }

  /// Pushes all pending task rows to Firestore. Returns `true` if any row
  /// failed (the caller uses this to set `SyncStatus.error` rather than
  /// `idle`).
  Future<bool> _pushPendingTasks() async {
    final pending = await db.taskDao.pendingWrites();
    _syncLog('[SyncService] _pushPendingTasks: ${pending.length} pending');
    var hadFailure = false;
    for (final row in pending) {
      _syncLog('  task ${row.docId} state=${row.syncState}');
      try {
        final docRef = firestore.collection('tasks').doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await db.taskDao.hardDelete(row.docId);
          _syncLog('  → deleted ${row.docId}');
        } else {
          final task = taskItemFromRow(row);
          final json = task.toJson() as Map<String, dynamic>;
          json.remove('docId');
          _syncLog('  → calling set() for ${row.docId}');
          await docRef.set(json);
          _syncLog('  → set() complete, calling markSynced');
          await db.taskDao.markSynced(row.docId);
          _syncLog('  → markSynced complete for ${row.docId}');
        }
      } catch (e, s) {
        hadFailure = true;
        _syncLog('  → ERROR for ${row.docId}: $e');
        _logSyncError(e, s);
      }
    }
    return hadFailure;
  }

  Future<bool> _pushPendingRecurrences() async {
    final pending = await db.taskRecurrenceDao.pendingWrites();
    var hadFailure = false;
    for (final row in pending) {
      try {
        final docRef = firestore.collection('taskRecurrences').doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await db.taskRecurrenceDao.hardDelete(row.docId);
        } else {
          final recurrence = taskRecurrenceFromRow(row);
          final json = serializers.serializeWith(
              m.TaskRecurrence.serializer, recurrence) as Map<String, dynamic>;
          json.remove('docId');
          await docRef.set(json);
          await db.taskRecurrenceDao.markSynced(row.docId);
        }
      } catch (e, s) {
        hadFailure = true;
        _logSyncError(e, s);
      }
    }
    return hadFailure;
  }

  Future<bool> _pushPendingSprints() async {
    final pending = await db.sprintDao.pendingSprintWrites();
    var hadFailure = false;
    for (final row in pending) {
      try {
        final docRef = firestore.collection('sprints').doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          // Sprint hard-delete is handled by removing the local row directly.
          await (db.delete(db.sprints)
                ..where((s) => s.docId.equals(row.docId)))
              .go();
        } else {
          // Build a Sprint with empty assignments — assignments are pushed
          // separately and Firestore stores them in a subcollection anyway.
          final sprint = sprintFromRow(row, const []);
          final json =
              serializers.serializeWith(m.Sprint.serializer, sprint)
                  as Map<String, dynamic>;
          json.remove('docId');
          json.remove('sprintAssignments');
          await docRef.set(json);
          await db.sprintDao.markSprintSynced(row.docId);
        }
      } catch (e, s) {
        hadFailure = true;
        _logSyncError(e, s);
      }
    }
    return hadFailure;
  }

  Future<bool> _pushPendingAssignments() async {
    final pending = await db.sprintDao.pendingAssignmentWrites();
    var hadFailure = false;
    for (final row in pending) {
      try {
        final docRef = firestore
            .collection('sprints')
            .doc(row.sprintDocId)
            .collection('sprintAssignments')
            .doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await (db.delete(db.sprintAssignments)
                ..where((a) => a.docId.equals(row.docId)))
              .go();
        } else {
          await docRef.set({
            'taskDocId': row.taskDocId,
            'sprintDocId': row.sprintDocId,
            'retired': row.retired,
            'retiredDate': row.retiredDate?.toUtc(),
            'dateAdded': DateTime.now().toUtc(),
          });
          await db.sprintDao.markAssignmentSynced(row.docId);
        }
      } catch (e, s) {
        hadFailure = true;
        _logSyncError(e, s);
      }
    }
    return hadFailure;
  }

  void _logSyncError(Object error, [StackTrace? stack]) {
    try {
      ref.read(crashReporterProvider).logError(error, stack, context: 'SyncService');
    } catch (_) {
      // Crash reporter optional during tests.
    }
  }
}

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final service = SyncService(
    db: ref.watch(databaseProvider),
    firestore: ref.watch(firestoreProvider),
    ref: ref,
  );
  ref.onDispose(() => service.stop());
  return service;
}
