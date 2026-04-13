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
    debugPrint('[SyncService] +${_ms()}ms initialSnapshots=$_initialSnapshotsReceived/3');
    if (_initialSnapshotsReceived >= 3 &&
        _initialPullCompleter != null &&
        !_initialPullCompleter!.isCompleted) {
      debugPrint('[SyncService] +${_ms()}ms ALL initial snapshots received — unblocking UI');
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
    debugPrint('[SyncService] start() — personDocId=$personDocId');

    _tasksSub = firestore
        .collection('tasks')
        .where('personDocId', isEqualTo: personDocId)
        .where('completionDate', isNull: true)
        .where('retired', isNull: true)
        .snapshots()
        .listen(_onTasksSnapshot, onError: _logSyncError);

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

    debugPrint('[SyncService] +${_ms()}ms tasks snapshot arrived: ${snapshot.docs.length} docs, ${snapshot.docChanges.length} changes, isInitial=$isInitial');

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

    // On the first snapshot, purge any synced local rows that Firestore no
    // longer has (covers emulator reset and server-side bulk deletes).
    if (isInitial) {
      final remoteIds = snapshot.docs.map((d) => d.id).toSet();
      await db.taskDao.deleteSyncedNotIn(remoteIds);
    }

    debugPrint('[SyncService] +${_ms()}ms tasks transaction done');
    if (isInitial) _markInitialSnapshotReceived();
    debugPrint('[SyncService] +${_ms()}ms tasks initial complete');
  }

  Future<void> _onRecurrencesSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_recurrencesInitialReceived;
    _recurrencesInitialReceived = true;

    debugPrint('[SyncService] +${_ms()}ms recurrences snapshot arrived: ${snapshot.docs.length} docs, isInitial=$isInitial');

    final toUpsert = <TaskRecurrencesCompanion>[];
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await db.taskRecurrenceDao.deleteFromRemote(change.doc.id);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(change.doc.data()!);
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
      final remoteIds = snapshot.docs.map((d) => d.id).toSet();
      await db.taskRecurrenceDao.deleteSyncedNotIn(remoteIds);
    }

    debugPrint('[SyncService] +${_ms()}ms recurrences transaction done');
    if (isInitial) _markInitialSnapshotReceived();
    debugPrint('[SyncService] +${_ms()}ms recurrences initial complete');
  }

  Future<void> _onSprintsSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final isInitial = !_sprintsInitialReceived;
    _sprintsInitialReceived = true;

    debugPrint('[SyncService] +${_ms()}ms sprints snapshot arrived: ${snapshot.docs.length} docs, ${snapshot.docChanges.length} changes, isInitial=$isInitial');
    for (final doc in snapshot.docs) {
      final data = doc.data();
      debugPrint('  sprint ${doc.id}: sprintNumber=${data['sprintNumber']}, '
          'start=${data['startDate']}, end=${data['endDate']}');
    }

    final seenIds = <String>{};
    for (final change in snapshot.docChanges) {
      final doc = change.doc;

      if (change.type == DocumentChangeType.removed) {
        // Sprint removed from Firestore — cancel its assignment listener and
        // remove the local synced row.
        await _assignmentSubs.remove(doc.id)?.cancel();
        await db.sprintDao.deleteSprintFromRemote(doc.id);
        continue;
      }

      seenIds.add(doc.id);
      try {
        final json = Map<String, dynamic>.from(doc.data()!);
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
    if (isInitial) {
      final remoteIds = snapshot.docs.map((d) => d.id).toSet();
      await db.sprintDao.deleteSyncedSprintsNotIn(remoteIds);
      await db.sprintDao.deleteSyncedOrphanAssignments();
      _markInitialSnapshotReceived();
      debugPrint('[SyncService] +${_ms()}ms sprints initial complete');
    }

    // Cancel listeners for sprints no longer in the snapshot.
    final stale = _assignmentSubs.keys.where((id) => !seenIds.contains(id)).toList();
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
      debugPrint('[SyncService] pushPendingWrites blocked (already pushing) — caller: $caller');
      return;
    }
    final online = ref.read(connectivityProvider).valueOrNull ?? false;
    if (!online) return;

    debugPrint('[SyncService] pushPendingWrites START — caller: $caller');
    _isPushing = true;
    final statusController = ref.read(syncStatusControllerProvider.notifier);
    statusController.set(SyncStatus.syncing);
    try {
      await _pushPendingTasks();
      await _pushPendingRecurrences();
      await _pushPendingSprints();
      await _pushPendingAssignments();
      statusController.set(SyncStatus.idle);
    } catch (e, s) {
      statusController.set(SyncStatus.error);
      _logSyncError(e, s);
    } finally {
      debugPrint('[SyncService] pushPendingWrites END — caller: $caller');
      _isPushing = false;
    }
  }

  Future<void> _pushPendingTasks() async {
    final pending = await db.taskDao.pendingWrites();
    debugPrint('[SyncService] _pushPendingTasks: ${pending.length} pending');
    for (final row in pending) {
      debugPrint('  task ${row.docId} state=${row.syncState}');
      try {
        final docRef = firestore.collection('tasks').doc(row.docId);
        if (row.syncState == SyncState.pendingDelete.name) {
          await docRef.delete();
          await db.taskDao.hardDelete(row.docId);
          debugPrint('  → deleted ${row.docId}');
        } else {
          final task = taskItemFromRow(row);
          final json = task.toJson() as Map<String, dynamic>;
          json.remove('docId');
          debugPrint('  → calling set() for ${row.docId}');
          await docRef.set(json);
          debugPrint('  → set() complete, calling markSynced');
          await db.taskDao.markSynced(row.docId);
          debugPrint('  → markSynced complete for ${row.docId}');
        }
      } catch (e, s) {
        debugPrint('  → ERROR for ${row.docId}: $e');
        _logSyncError(e, s);
      }
    }
  }

  Future<void> _pushPendingRecurrences() async {
    final pending = await db.taskRecurrenceDao.pendingWrites();
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
        _logSyncError(e, s);
      }
    }
  }

  Future<void> _pushPendingSprints() async {
    final pending = await db.sprintDao.pendingSprintWrites();
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
        _logSyncError(e, s);
      }
    }
  }

  Future<void> _pushPendingAssignments() async {
    final pending = await db.sprintDao.pendingAssignmentWrites();
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
        _logSyncError(e, s);
      }
    }
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
