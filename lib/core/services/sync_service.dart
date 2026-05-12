import 'dart:async';
import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/area.dart' as m;
import '../../models/context.dart' as m;
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _areasSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _contextsSub;
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
  // In-memory set of task docIds currently tracked by the family-tasks
  // listener. Used by _onTasksSnapshot to avoid deleting rows that are still
  // live under the family listener (completing your own family-shared task
  // removes it from the personal incomplete-only query, but the family listener
  // still holds it). Updated on every family-tasks snapshot; cleared on detach.
  Set<String> _familyTaskDocIds = {};
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
  bool _areasInitialReceived = false;
  bool _contextsInitialReceived = false;

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

  // TM-345: areas are NOT part of `initialPullCompleter` (the main UI doesn't
  // block on them) but consumers that DO need to know "have I heard from the
  // server about areas yet?" can await this. Used by AreaService.createArea
  // (so sortOrder isn't computed from a stale empty cache and collide with
  // remote rows) and AreasWithDefaults (so default-seed only fires when the
  // user truly has zero areas server-side).
  Completer<void>? _areasInitialPullCompleter;

  Future<void> get areasInitialPullComplete =>
      _areasInitialPullCompleter?.future ?? Future.value();

  // TM-181: contexts mirror the Areas pattern — they're not part of the
  // blocking `initialPullCompleter` (the main UI doesn't gate on them) but
  // ContextService.createContext (sortOrder) and ContextsWithDefaults
  // (lazy-seed defaults) need to know "have I heard from the server about
  // contexts yet?" before proceeding.
  Completer<void>? _contextsInitialPullCompleter;

  Future<void> get contextsInitialPullComplete =>
      _contextsInitialPullCompleter?.future ?? Future.value();

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
    _areasInitialPullCompleter = Completer<void>();
    _contextsInitialPullCompleter = Completer<void>();
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

    // TM-345: areas (per-user customizable picker values). Filtering `retired`
    // client-side to match the recurrences pattern (Firestore's `isNull: true`
    // excludes docs missing the field, which would skip legacy seeds).
    _areasSub = firestore
        .collection('areas')
        .where('personDocId', isEqualTo: personDocId)
        .snapshots()
        .listen(_onAreasSnapshot, onError: _logSyncError);

    // TM-181: contexts — same client-side `retired` filter rationale as Areas.
    _contextsSub = firestore
        .collection('contexts')
        .where('personDocId', isEqualTo: personDocId)
        .snapshots()
        .listen(_onContextsSnapshot, onError: _logSyncError);

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
        final online = next.value ?? false;
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
    await _areasSub?.cancel();
    await _contextsSub?.cancel();
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
    _areasSub = null;
    _contextsSub = null;
    _personSelfSub = null;
    _invitationsSub = null;
    _connectivitySub = null;
    _currentPersonDocId = null;
    _currentEmail = null;
    _currentFamilyDocId = null;
    _tasksInitialReceived = false;
    _recurrencesInitialReceived = false;
    _sprintsInitialReceived = false;
    _areasInitialReceived = false;
    _contextsInitialReceived = false;
    if (_initialPullCompleter != null && !_initialPullCompleter!.isCompleted) {
      _initialPullCompleter!.complete();
    }
    _initialPullCompleter = null;
    _initialSnapshotsReceived = 0;
    if (_areasInitialPullCompleter != null &&
        !_areasInitialPullCompleter!.isCompleted) {
      _areasInitialPullCompleter!.complete();
    }
    _areasInitialPullCompleter = null;
    if (_contextsInitialPullCompleter != null &&
        !_contextsInitialPullCompleter!.isCompleted) {
      _contextsInitialPullCompleter!.complete();
    }
    _contextsInitialPullCompleter = null;
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
    _familyTaskDocIds = {};
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
        await _resolveRemovedTask(change, isInitial, toRefreshNotifications);
        continue;
      }
      // TM-361: skip the local-cache echo of our own writes. With the default
      // ServerTimestampBehavior, `data()` returns `lastModified: null` for an
      // unresolved `FieldValue.serverTimestamp()`. If we upserted that into
      // Drift we would demote the row's `lastModified` to null, then the
      // *next* edit on this device would stamp a fresh local-clock value
      // with nothing to be monotonic against — re-introducing the clock-skew
      // false-positive conflict. The server-acked listener fire (with
      // hasPendingWrites=false and the real server timestamp) is the one we
      // want.
      //
      // Use `metadata.hasPendingWrites` rather than `lastModified == null`:
      // production behaviour is identical (an unresolved server timestamp
      // always coincides with a pending write), and this avoids dropping
      // remote docs that legitimately lack a lastModified field (legacy
      // rows, test fixtures, cross-device writes that predate TM-342).
      // FakeFirebaseFirestore resolves FieldValue.serverTimestamp() inline,
      // so its snapshot data carries a non-null lastModified anyway — no
      // need to special-case the test path.
      if (change.doc.metadata.hasPendingWrites) {
        _syncLog(
            '[SyncService] listener: skipping ${change.doc.id} — local-cache echo (hasPendingWrites)');
        continue;
      }
      final cachedLastModified = change.doc.data()?['lastModified'];
      _syncLog(
          '[SyncService] listener: server-confirmed ${change.doc.id} lastModified=$cachedLastModified');
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
        json['docId'] = change.doc.id;
        final task = m.TaskItem.fromFirestoreJson(json);
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

  /// TM-342: handle a `DocumentChangeType.removed` event on the personal
  /// tasks listener. The personal listener filters `completionDate isNull`
  /// (and `retired isNull`), so a doc leaving its view usually means the task
  /// was completed or retired on another device — NOT hard-deleted. Without
  /// this, completing a task on Device B would cause Device A to delete the
  /// row from Drift and lose it from the Sprint Completed view.
  ///
  /// Decision tree:
  ///   - cached `change.doc.data()` shows `completionDate` or `retired` set →
  ///     upsert from cached data (fast path; no server fetch needed).
  ///   - cached data missing or has neither set → ambiguous; do a server
  ///     `get()` to confirm:
  ///       - doc exists → upsert from fetched data.
  ///       - doc absent → true delete; remove from Drift.
  ///       - fetch throws (offline / transient error) → fail closed: leave
  ///         the Drift row alone. The next snapshot will retry.
  Future<void> _resolveRemovedTask(
    DocumentChange<Map<String, dynamic>> change,
    bool isInitial,
    List<m.TaskItem> toRefreshNotifications,
  ) async {
    // Family-shared tasks: the family listener owns this row's lifecycle.
    // Skip everything; the family listener will deliver its own removed event
    // when the task is truly retired/deleted (TM-335).
    if (_familyTaskDocIds.contains(change.doc.id)) return;

    m.TaskItem? cachedTask;
    try {
      final data = change.doc.data();
      if (data != null) {
        final json = Map<String, dynamic>.from(data);
        json['docId'] = change.doc.id;
        cachedTask = m.TaskItem.fromFirestoreJson(json);
      }
    } catch (e, s) {
      _logSyncError(e, s);
    }

    // Notifications are refreshed only AFTER the final state is known —
    // never with the pre-change cached snapshot, because the helper would
    // see completionDate/retired still null and reschedule notifications
    // for a task that has actually been completed (TM-342 round 1).

    // Fast path: cached data already shows this is a completion or retire.
    // Upsert with the new state instead of deleting so it remains visible
    // in Sprint Completed view (TM-342).
    if (cachedTask != null &&
        (cachedTask.completionDate != null || cachedTask.retired != null)) {
      await db.taskDao.upsertFromRemote(taskItemToCompanion(cachedTask));
      if (!isInitial) toRefreshNotifications.add(cachedTask);
      return;
    }

    // Ambiguous: cached data unavailable or pre-completion. Confirm via
    // server fetch. Fail-closed on error — preserve Drift row, let the next
    // snapshot retry.
    try {
      final snap = await change.doc.reference.get(
          const GetOptions(source: Source.server));
      if (!snap.exists) {
        await db.taskDao.deleteFromRemote(change.doc.id);
        // Cancel any local notifications scheduled for the now-deleted task.
        // We don't have a final TaskItem to feed the bulk helper, so go
        // direct to cancelNotificationsForTaskId.
        if (!isInitial) {
          try {
            ref
                .read(notificationHelperProvider)
                .cancelNotificationsForTaskId(change.doc.id)
                .catchError((e) => _syncLog(
                    '[SyncService] cancel-on-delete failed for ${change.doc.id}: $e'));
          } catch (_) {
            // Helper unavailable (tests, init race) — silently skip.
          }
        }
        return;
      }
      final data = snap.data();
      if (data == null) return; // defensive
      final json = Map<String, dynamic>.from(data);
      json['docId'] = snap.id;
      final task = m.TaskItem.fromFirestoreJson(json);
      if (task != null) {
        await db.taskDao.upsertFromRemote(taskItemToCompanion(task));
        // Use the server-fetched task — its state is authoritative — rather
        // than the (possibly pre-change) cached one.
        if (!isInitial) toRefreshNotifications.add(task);
      }
    } catch (e, s) {
      _syncLog(
          '[SyncService] _resolveRemovedTask server fetch failed for ${change.doc.id}: $e — deferring');
      _logSyncError(e, s);
      // Fail closed — do not delete.
    }
  }

  /// Fire-and-forget per-task notification refresh. Each task is sent through
  /// the helper which decides whether to schedule (active) or cancel
  /// (completed / retired) based on its current state. Errors are logged but
  /// don't affect sync; notifications are best-effort by design.
  void _refreshNotificationsForTasks(List<m.TaskItem> tasks) {
    if (tasks.isEmpty) return;
    try {
      final helper = ref.read(notificationHelperProvider);
      helper.updateNotificationsForTasks(tasks).catchError(
          (e) => _syncLog('[SyncService] notification batch refresh error: $e'));
    } catch (e) {
      // Helper unavailable (tests, init race) or synchronous throw from the
      // helper's method — silently skip; notifications are best-effort.
      _syncLog('[SyncService] notification refresh skipped: $e');
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
      // TM-361: skip the local-cache echo of our own writes — same
      // rationale as _onTasksSnapshot. Use hasPendingWrites (not
      // lastModified==null) so legacy/test docs lacking the field still sync.
      if (change.doc.metadata.hasPendingWrites) continue;
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

  /// TM-345: areas snapshot. Simpler than tasks/recurrences/sprints — areas
  /// have no conflict detection (they're list-management items, not data with
  /// rich edit history) and no subcollections. Retired areas are filtered
  /// out client-side; matching retired entries in Drift are deleted.
  ///
  /// Not counted toward [_initialPullCompleter] — areas are not blocking for
  /// the main UI. But we DO complete a separate [_areasInitialPullCompleter]
  /// on the first snapshot so AreaService.createArea (sortOrder) and
  /// AreasWithDefaults (lazy-seed defaults) can wait for server confirmation
  /// of the user's true area set before computing values from local cache.
  Future<void> _onAreasSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_areasInitialReceived;
    _areasInitialReceived = true;

    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.areaDao.deleteAreaFromRemote(change.doc.id);
        continue;
      }
      final data = change.doc.data();
      if (data == null) continue;
      // Treat retired remotely as a delete locally so the watch stream stops
      // emitting it (matches the recurrences pattern).
      if (data['retired'] != null) {
        await db.areaDao.deleteAreaFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(data);
        json['docId'] = change.doc.id;
        final area = serializers.deserializeWith(m.Area.serializer, json);
        if (area != null) {
          await db.areaDao.upsertAreaFromRemote(areaToCompanion(area));
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }

    // Reconcile every snapshot: prune synced rows whose docId is no longer
    // present (covers emulator reset / bulk server-side delete). Pending rows
    // are preserved. Scope by personDocId so a sign-out/sign-in cycle with a
    // different account does not purge the previous user's cached areas.
    final remoteIds = snapshot.docs
        .where((d) => d.data()['retired'] == null)
        .map((d) => d.id)
        .toSet();
    await db.areaDao
        .deleteSyncedAreasNotInForPerson(_currentPersonDocId!, remoteIds);

    if (isInitial &&
        _areasInitialPullCompleter != null &&
        !_areasInitialPullCompleter!.isCompleted) {
      _areasInitialPullCompleter!.complete();
    }
  }

  /// TM-181: contexts snapshot. Mirrors the Areas listener exactly — no
  /// conflict detection, no subcollections, retired filtered client-side,
  /// completes a separate `_contextsInitialPullCompleter` rather than
  /// blocking `initialPullCompleter`.
  Future<void> _onContextsSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_contextsInitialReceived;
    _contextsInitialReceived = true;

    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.contextDao.deleteContextFromRemote(change.doc.id);
        continue;
      }
      final data = change.doc.data();
      if (data == null) continue;
      if (data['retired'] != null) {
        await db.contextDao.deleteContextFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(data);
        json['docId'] = change.doc.id;
        final context =
            serializers.deserializeWith(m.Context.serializer, json);
        if (context != null) {
          await db.contextDao
              .upsertContextFromRemote(contextToCompanion(context));
        }
      } catch (e, s) {
        _logSyncError(e, s);
      }
    }

    final remoteIds = snapshot.docs
        .where((d) => d.data()['retired'] == null)
        .map((d) => d.id)
        .toSet();
    await db.contextDao
        .deleteSyncedContextsNotInForPerson(_currentPersonDocId!, remoteIds);

    if (isInitial &&
        _contextsInitialPullCompleter != null &&
        !_contextsInitialPullCompleter!.isCompleted) {
      _contextsInitialPullCompleter!.complete();
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

    // Identify members that just left the family. Their local persons row
    // still has familyDocId set (the personsListener's whereIn no longer
    // includes them, so the clearing update from FamilyRepository.removeMember
    // never reaches this device through the regular persons stream). Clear
    // familyDocId locally so PersonDao.watchByFamily stops surfacing them in
    // the manage-screen roster + "Added by" lookup.
    final removed = (_familyMembersWatchedSet ?? const <String>{})
        .difference(newSet);
    final familyDocId = _currentFamilyDocId;
    if (removed.isNotEmpty && familyDocId != null) {
      await db.personDao.clearFamilyForRemovedMembers(familyDocId, removed);
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
        // Deserialize the last-known doc data so the notification helper can
        // cancel any scheduled alerts for this task (e.g. when a task is
        // retired, un-shared, or the member leaves the family).
        try {
          final data = change.doc.data();
          if (data != null && !isInitial) {
            final json = Map<String, dynamic>.from(data);
            json['docId'] = change.doc.id;
            final task = m.TaskItem.fromFirestoreJson(json);
            if (task != null) toRefreshNotifications.add(task);
          }
        } catch (e, s) {
          _logSyncError(e, s);
        }
        await db.taskDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
        json['docId'] = change.doc.id;
        final task = m.TaskItem.fromFirestoreJson(json);
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

    // Keep the in-memory family-task ID set up to date so the personal-tasks
    // listener can skip deleting rows that are still live here.
    _familyTaskDocIds = snapshot.docs.map((d) => d.id).toSet();

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
    final online = ref.read(connectivityProvider).value ?? false;
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
      hadFailure |= await _pushPendingAreas();
      hadFailure |= await _pushPendingContexts();
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

  /// TM-342: encode a conflict envelope for storage in
  /// `conflictRemoteJson`. The envelope captures the remote version (so the
  /// UI can render local-vs-remote) plus the priorSyncState so "Keep mine"
  /// knows whether to restore pendingUpdate or pendingDelete.
  ///
  /// `remoteJsonMap` is the built_value-serialized form of the remote model,
  /// which still contains DateTime objects — `toEncodable` converts them to
  /// ISO strings so the result is `jsonEncode`-able. On read, the
  /// DatePassThroughSerializer handles String → DateTime round-trips
  /// transparently.
  String _encodeConflictEnvelope({
    required String priorSyncState,
    required Map<String, Object?> remoteJsonMap,
  }) {
    return jsonEncode({
      'priorSyncState': priorSyncState,
      'remote': remoteJsonMap,
    }, toEncodable: (obj) {
      if (obj is DateTime) return obj.toUtc().toIso8601String();
      if (obj is Timestamp) return obj.toDate().toUtc().toIso8601String();
      throw UnsupportedError(
          'Cannot encode ${obj.runtimeType} in conflict envelope');
    });
  }

  /// TM-361: compare two `lastModified` values at second precision, matching
  /// Drift's epoch-seconds storage. Returns `true` iff [a] is strictly after
  /// [b] when both are floored to whole seconds. See [_checkAndRecordConflict]
  /// for why this is necessary.
  static bool _isStrictlyAfterAtSecondPrecision(DateTime a, DateTime b) {
    final aSec = a.millisecondsSinceEpoch ~/ 1000;
    final bSec = b.millisecondsSinceEpoch ~/ 1000;
    return aSec > bSec;
  }

  /// TM-361: read back the server-stamped `lastModified` for the doc we
  /// just pushed, so the row's `lastSyncedRemoteVersion` reflects the
  /// actual server timestamp instead of going stale.
  ///
  /// Tries the server first (authoritative), falls back to the local cache
  /// (which the SDK updates with the resolved value after `set()` acks),
  /// and as a last resort returns local UTC time. Returning *something* is
  /// critical: a null return leaves `lastSyncedRemoteVersion` at the
  /// pre-push value, and the very next push's conflict check would compare
  /// the freshly-stamped remote against that stale anchor and false-positive.
  /// Local time is imperfect under clock skew but strictly better than the
  /// stale anchor — and matches what the listener-driven path eventually
  /// converges to anyway.
  // ignore: unused_element
  Future<DateTime?> _readServerLastModified(
      DocumentReference<Map<String, dynamic>> docRef) async {
    // Each source is wrapped in a tight timeout because FakeFirebaseFirestore
    // (used in widget tests) silently hangs `Source.server` reads, which
    // would deadlock `pumpAndSettle` on any test that exercises a push.
    // Production Firestore acks server reads in tens of ms; 2s is generous
    // enough that we don't false-fall-back under real latency.
    const perSourceTimeout = Duration(seconds: 2);
    for (final source in const [Source.server, Source.cache]) {
      try {
        final snap = await docRef
            .get(GetOptions(source: source))
            .timeout(perSourceTimeout);
        final raw = snap.data()?['lastModified'];
        if (raw is Timestamp) {
          final result = raw.toDate().toUtc();
          _syncLog(
              '[SyncService] post-push anchor for ${docRef.path}: $result (via $source)');
          return result;
        }
        if (raw is DateTime) {
          final result = raw.toUtc();
          _syncLog(
              '[SyncService] post-push anchor for ${docRef.path}: $result (via $source as DateTime)');
          return result;
        }
        _syncLog(
            '[SyncService] post-push fetch via $source for ${docRef.path}: lastModified field was ${raw?.runtimeType ?? "null"} — trying next source');
      } on TimeoutException {
        _syncLog(
            '[SyncService] post-push fetch via $source for ${docRef.path} timed out after ${perSourceTimeout.inSeconds}s');
      } catch (e) {
        _syncLog(
            '[SyncService] post-push fetch via $source failed for ${docRef.path}: $e');
      }
    }
    final fallback = DateTime.now().toUtc();
    _syncLog(
        '[SyncService] post-push lastModified unreadable for ${docRef.path}; '
        'anchoring lastSyncedRemoteVersion to local time ($fallback)');
    return fallback;
  }

  /// TM-342: server-source `get()` with backoff retry on transient
  /// `unavailable` / `deadline-exceeded` errors. The Firestore SDK can
  /// briefly reject server reads while reconnecting after a connectivity
  /// flip; Firestore's own error message recommends a backoff-and-retry,
  /// which is what this does. Total worst-case wait is ~6s across 3
  /// retries (500ms / 1500ms / 4000ms).
  Future<DocumentSnapshot<Map<String, dynamic>>> _serverGetWithRetry(
      DocumentReference<Map<String, dynamic>> docRef) async {
    const delays = <Duration>[
      Duration(milliseconds: 500),
      Duration(milliseconds: 1500),
      Duration(milliseconds: 4000),
    ];
    for (var attempt = 0;; attempt++) {
      try {
        return await docRef.get(const GetOptions(source: Source.server));
      } on FirebaseException catch (e) {
        final isTransient =
            e.code == 'unavailable' || e.code == 'deadline-exceeded';
        if (!isTransient || attempt >= delays.length) rethrow;
        _syncLog(
            '[SyncService] conflict-check transient ${e.code} on ${docRef.path} (attempt ${attempt + 1}); retrying after ${delays[attempt].inMilliseconds}ms');
        await Future<void>.delayed(delays[attempt]);
      }
    }
  }

  /// TM-342 / TM-361: pre-push conflict check. Reads the remote doc and
  /// compares `remote.lastModified` against [localLastSyncedRemoteVersion]
  /// — the server timestamp this row was last synced from. Returns `true` if
  /// the remote has been modified since we last observed it (i.e. another
  /// device pushed during our offline / unsynced window) and a conflict was
  /// recorded; `false` if the push should proceed.
  ///
  /// Comparing against `lastSyncedRemoteVersion` rather than the local
  /// `lastModified` is what makes this correct for offline edits: an offline
  /// device's local clock advances during the disconnect, so its
  /// `lastModified` ends up *later* than any remote push that landed while
  /// it was offline. The lastSynced anchor doesn't drift with the local
  /// clock — it's only updated when a server-authoritative timestamp lands
  /// (listener fire or Use-latest resolution), so it correctly detects the
  /// "the remote moved while I wasn't looking" case.
  ///
  /// The push proceeds if: doc absent (insert), both anchors are null
  /// (legacy / never-anchored row with no usable comparison), remote
  /// lastModified is null (legacy remote), or remote is not strictly newer
  /// than the chosen anchor.
  ///
  /// TM-361 follow-up: when `localLastSyncedRemoteVersion` is null we fall
  /// back to `localLastModified` as the anchor. This catches the
  /// first-write-conflict case — a pending row that has never been anchored
  /// (e.g. its remote update landed during the local pending window so the
  /// listener's bulkUpsert skipped it) still needs to detect "remote
  /// advanced past what we have." The fallback is less precise than
  /// lastSynced (subject to local clock drift) but still correct: if remote
  /// is newer than even the local clock's view, there is a real conflict.
  Future<bool> _checkAndRecordConflict<TModel>({
    required DocumentReference<Map<String, dynamic>> docRef,
    required String localDocId,
    required DateTime? localLastSyncedRemoteVersion,
    required DateTime? localLastModified,
    required String localSyncState,
    required Serializer<TModel> serializer,
    required DateTime? Function(TModel model) extractLastModified,
    required Future<void> Function(String envelopeJson) markConflict,
  }) async {
    // Conflict detection must use a server-authoritative snapshot — a stale
    // cached snapshot could falsely indicate "no conflict" and let this
    // device overwrite a newer remote change.
    //
    // Connectivity flips can trigger a push before the Firestore SDK has
    // finished reconnecting (TM-342 manual testing): Source.server then
    // throws `cloud_firestore/unavailable`. Firestore's own error message
    // says "may be corrected by retrying with a backoff" — so we do.
    // After the retries exhaust, rethrow so the per-row catch in the
    // calling _pushPending* records a failure (and logs once) and the row
    // stays pending for retry on the next push. We don't log here too —
    // that would double-report a single transient failure.
    final remoteSnap = await _serverGetWithRetry(docRef);
    if (!remoteSnap.exists) return false;
    final remoteData = remoteSnap.data();
    if (remoteData == null) return false;

    // Choose the anchor: prefer the server-authoritative lastSynced when
    // available; fall back to local lastModified for unanchored rows.
    //
    // TM-367: the lastModified fallback is imprecise under local clock skew
    // (a device whose clock is ahead can have lastModified > a fresh remote
    // even when the remote is the newer truth, leading to a missed
    // conflict). The proper fix — anchoring lastSyncedRemoteVersion at
    // listener time for pending rows — is tracked in TM-367 and is too
    // large for this PR. Until then this is strictly better than the
    // pre-TM-361 behaviour (which treated null anchors as "push wins"
    // unconditionally).
    final localAnchor =
        localLastSyncedRemoteVersion ?? localLastModified;
    if (localAnchor == null) {
      // No anchor at all (pendingCreate that has never seen any remote).
      // Push — the post-push listener fire will anchor going forward.
      _syncLog(
          '[SyncService] conflict-check $localDocId: no local anchor → no conflict (legacy / unanchored)');
      return false;
    }
    final anchorSource =
        localLastSyncedRemoteVersion != null ? 'lastSynced' : 'lastModified';

    final json = Map<String, dynamic>.from(remoteData);
    json['docId'] = localDocId;
    // TM-181: Firestore-side legacy `context: "Phone"` → `contexts: [{name}]`.
    // No-op for non-TaskItem serializers (their JSON has no `context` key).
    m.TaskItem.applyLegacyContextFallback(json);
    final TModel? remoteModel;
    try {
      remoteModel = serializers.deserializeWith(serializer, json);
    } catch (e, s) {
      // If we can't deserialize the remote (schema drift, bad data), don't
      // block the push — log and proceed.
      _logSyncError(e, s);
      return false;
    }
    if (remoteModel == null) return false;

    final remoteLastModified = extractLastModified(remoteModel);
    if (remoteLastModified == null) {
      // Remote was written by a pre-TM-342 client without a timestamp.
      // Push wins — the next push from any TM-342 client will populate it.
      _syncLog(
          '[SyncService] conflict-check $localDocId: remote.lastModified=null → no conflict (legacy remote)');
      return false;
    }
    _syncLog(
        '[SyncService] conflict-check $localDocId: remote=$remoteLastModified vs $anchorSource=$localAnchor');
    // TM-361: Drift's `dateTime()` columns store as Unix epoch *seconds*, so
    // the local anchor round-trips at second precision while
    // `remoteLastModified` carries full millisecond precision from the
    // Firestore Timestamp. Comparing them directly with `isAfter` would
    // false-positive a conflict for the very row we just synced, since the
    // truncated local copy is always `≤ 999ms` behind the un-truncated
    // remote. Equalize precision before comparing.
    if (!_isStrictlyAfterAtSecondPrecision(remoteLastModified, localAnchor)) {
      // Remote hasn't advanced past our anchor — push wins.
      _syncLog('[SyncService] conflict-check $localDocId: no conflict (push wins)');
      return false;
    }

    // Remote is newer → record conflict.
    // built_value's StandardJsonPlugin returns Map<String, dynamic>; Dart's
    // generic invariance means a direct `as Map<String, Object?>` cast can
    // throw at runtime. Use Map.from to copy safely (and bail with a log if
    // the serializer somehow didn't produce a Map at all).
    final serializedRemote = serializers.serializeWith(serializer, remoteModel);
    if (serializedRemote is! Map) {
      _syncLog(
          '[SyncService] conflict NOT recorded for $localDocId: serialized remote was ${serializedRemote.runtimeType}, not a Map');
      return false;
    }
    final remoteJsonMap = Map<String, Object?>.from(serializedRemote);
    final envelope = _encodeConflictEnvelope(
      priorSyncState: localSyncState,
      remoteJsonMap: remoteJsonMap,
    );
    await markConflict(envelope);
    _syncLog(
        '[SyncService] conflict recorded for $localDocId: remote=$remoteLastModified > $anchorSource=$localAnchor');
    return true;
  }

  /// Pushes all pending task rows to Firestore. Returns `true` if any row
  /// failed (the caller uses this to set `SyncStatus.error` rather than
  /// `idle`).
  Future<bool> _pushPendingTasks() async {
    final pending = await db.taskDao.pendingWrites();
    _syncLog('[SyncService] _pushPendingTasks: ${pending.length} pending');
    var hadFailure = false;
    for (final row in pending) {
      _syncLog(
          '  task ${row.docId} state=${row.syncState} lastModified=${row.lastModified} lastSynced=${row.lastSyncedRemoteVersion}');
      try {
        final docRef = firestore.collection('tasks').doc(row.docId);

        // TM-342 / TM-361: pre-push conflict check against the last-synced
        // remote version, not local clock.
        final conflicted = await _checkAndRecordConflict<m.TaskItem>(
          docRef: docRef,
          localDocId: row.docId,
          localLastSyncedRemoteVersion: row.lastSyncedRemoteVersion,
          localLastModified: row.lastModified,
          localSyncState: row.syncState,
          serializer: m.TaskItem.serializer,
          extractLastModified: (t) => t.lastModified,
          markConflict: (envelope) =>
              db.taskDao.markPendingConflict(row.docId, envelope),
        );
        if (conflicted) {
          _syncLog('  → conflict for ${row.docId}, skipping push');
          continue;
        }

        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await db.taskDao.hardDelete(row.docId);
          _syncLog('  → deleted ${row.docId}');
        } else {
          final task = taskItemFromRow(row);
          final json = task.toJson() as Map<String, dynamic>;
          json.remove('docId');
          // TM-342: server-authoritative timestamp.
          json['lastModified'] = FieldValue.serverTimestamp();
          _syncLog('  → calling set() for ${row.docId}');
          await docRef.set(json);
          _syncLog('  → set() complete, calling markSynced');
          // TM-361: just mark synced. The server-confirmed listener event
          // (hasPendingWrites=false) will follow shortly and run
          // `bulkUpsertFromRemote`, which anchors `lastSyncedRemoteVersion`
          // to the freshly-stamped `lastModified`. Doing an explicit
          // post-push `Source.server` fetch here deadlocked
          // `pumpAndSettle` under `FakeFirebaseFirestore`, and the listener
          // path already covers the common case. The rapid-edit-after-push
          // race window is documented as a known limitation.
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

        // TM-342 / TM-361: pre-push conflict check against last-synced
        // remote version.
        final conflicted = await _checkAndRecordConflict<m.TaskRecurrence>(
          docRef: docRef,
          localDocId: row.docId,
          localLastSyncedRemoteVersion: row.lastSyncedRemoteVersion,
          localLastModified: row.lastModified,
          localSyncState: row.syncState,
          serializer: m.TaskRecurrence.serializer,
          extractLastModified: (r) => r.lastModified,
          markConflict: (envelope) =>
              db.taskRecurrenceDao.markPendingConflict(row.docId, envelope),
        );
        if (conflicted) continue;

        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await db.taskRecurrenceDao.hardDelete(row.docId);
        } else {
          final recurrence = taskRecurrenceFromRow(row);
          final json = serializers.serializeWith(
              m.TaskRecurrence.serializer, recurrence) as Map<String, dynamic>;
          json.remove('docId');
          // TM-342: server-authoritative timestamp.
          json['lastModified'] = FieldValue.serverTimestamp();
          await docRef.set(json);
          // TM-361: rely on the listener anchor — see _pushPendingTasks.
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

  /// TM-345: push pending area writes. No conflict detection — areas don't
  /// carry a lastModified timestamp; last-write-wins is acceptable for list
  /// management items.
  Future<bool> _pushPendingAreas() async {
    final pending = await db.areaDao.pendingAreaWrites();
    var hadFailure = false;
    for (final row in pending) {
      try {
        final docRef = firestore.collection('areas').doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await (db.delete(db.areas)..where((a) => a.docId.equals(row.docId)))
              .go();
        } else {
          final area = areaFromRow(row);
          final json =
              serializers.serializeWith(m.Area.serializer, area)
                  as Map<String, dynamic>;
          json.remove('docId');
          await docRef.set(json);
          await db.areaDao.markAreaSynced(row.docId);
        }
      } catch (e, s) {
        hadFailure = true;
        _logSyncError(e, s);
      }
    }
    return hadFailure;
  }

  /// TM-181: push pending contexts to Firestore. Mirrors `_pushPendingAreas`
  /// — same last-write-wins handling, no conflict detection (contexts are
  /// list-management items without rich edit history).
  Future<bool> _pushPendingContexts() async {
    final pending = await db.contextDao.pendingContextWrites();
    var hadFailure = false;
    for (final row in pending) {
      try {
        final docRef = firestore.collection('contexts').doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await (db.delete(db.contexts)
                ..where((c) => c.docId.equals(row.docId)))
              .go();
        } else {
          final context = contextFromRow(row);
          final json =
              serializers.serializeWith(m.Context.serializer, context)
                  as Map<String, dynamic>;
          json.remove('docId');
          await docRef.set(json);
          await db.contextDao.markContextSynced(row.docId);
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
