import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _assignmentSubs = {};
  ProviderSubscription<AsyncValue<bool>>? _connectivitySub;

  String? _currentPersonDocId;
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

  Future<void> start(String personDocId) async {
    if (_currentPersonDocId == personDocId) return;
    await stop();
    _currentPersonDocId = personDocId;
    _initialPullCompleter = Completer<void>();
    _initialSnapshotsReceived = 0;
    _startTime = DateTime.now();
    _syncLog('[SyncService] start() — personDocId=$personDocId');

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
    _connectivitySub?.close();
    _tasksSub = null;
    _recurrencesSub = null;
    _sprintsSub = null;
    _connectivitySub = null;
    _currentPersonDocId = null;
    _tasksInitialReceived = false;
    _recurrencesInitialReceived = false;
    _sprintsInitialReceived = false;
    if (_initialPullCompleter != null && !_initialPullCompleter!.isCompleted) {
      _initialPullCompleter!.complete();
    }
    _initialPullCompleter = null;
    _initialSnapshotsReceived = 0;
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
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.taskDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
        json['docId'] = change.doc.id;
        final task = serializers.deserializeWith(m.TaskItem.serializer, json);
        if (task != null) toUpsert.add(taskItemToCompanion(task));
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

    _syncLog('[SyncService] +${_ms()}ms tasks transaction done');
    if (isInitial) _markInitialSnapshotReceived();
    _syncLog('[SyncService] +${_ms()}ms tasks initial complete');
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
      // docs were already removed from Drift in the loop above.
      final remoteIds = snapshot.docs
          .where((d) => d.data()['retired'] == null)
          .map((d) => d.id)
          .toSet();
      await db.taskRecurrenceDao.deleteSyncedNotIn(remoteIds);
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
