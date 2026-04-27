import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/core/database/tables.dart';
import 'package:taskmaster/core/providers/connectivity_provider.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/providers/notification_providers.dart';
import 'package:taskmaster/core/services/notification_helper_impl.dart';
import 'package:taskmaster/core/services/sync_service.dart';
import 'package:taskmaster/models/task_item.dart';

/// Test stub for [NotificationHelperImpl] that no-ops so SyncService snapshot
/// handlers don't trip the FlutterLocalNotifications platform interface (which
/// is uninitialized in the unit-test environment). Overrides every method
/// SyncService currently calls — `updateNotificationsForTasks` (snapshot push
/// path) and `cancelNotificationsForTaskId` (TM-342 delete-confirmed path).
class _NoopNotificationHelper extends NotificationHelperImpl {
  _NoopNotificationHelper() : super(plugin: FlutterLocalNotificationsPlugin());

  @override
  Future<void> updateNotificationsForTasks(List<TaskItem> taskItems) async {}

  @override
  Future<void> cancelNotificationsForTaskId(String taskId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testPersonDocId = 'person-123';

  late AppDatabase db;
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late SyncService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      firestoreProvider.overrideWithValue(firestore),
      // SyncService listens to connectivityProvider; force-online in tests.
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      // Replace the real notification helper with a no-op so snapshot handlers
      // don't crash on the uninitialized FlutterLocalNotifications platform.
      notificationHelperProvider.overrideWithValue(_NoopNotificationHelper()),
    ]);
    // Use the real provider so SyncService gets a proper Ref.
    service = container.read(syncServiceProvider);
  });

  tearDown(() async {
    await service.stop();
    container.dispose();
    await db.close();
  });

  Map<String, Object?> _recurrenceData({
    required String name,
    bool includeRetired = false,
    Object? retired,
  }) {
    final data = <String, Object?>{
      'name': name,
      'personDocId': testPersonDocId,
      'dateAdded': DateTime.utc(2024, 1, 1),
      'recurNumber': 1,
      'recurUnit': 'Weeks',
      'recurWait': false,
      'recurIteration': 1,
      'anchorDate': {
        'dateValue': DateTime.utc(2024, 1, 1),
        'dateType': 'Due',
      },
    };
    if (includeRetired) {
      data['retired'] = retired;
      data['retiredDate'] = retired == null ? null : DateTime.utc(2024, 1, 1);
    }
    return data;
  }

  group('SyncService recurrences listener (TM-343)', () {
    test('upserts recurrences with explicit retired:null', () async {
      await firestore
          .collection('taskRecurrences')
          .doc('with-null-retired')
          .set(_recurrenceData(
              name: 'Active', includeRetired: true, retired: null));

      await service.start(testPersonDocId);
      await service.initialPullComplete;

      final stored =
          await db.taskRecurrenceDao.watchActive(testPersonDocId).first;
      expect(stored.map((r) => r.docId), contains('with-null-retired'));
    });

    test('upserts recurrences whose Firestore doc is missing the retired field',
        () async {
      // The bug: this doc was previously excluded by the server-side
      // where('retired', isNull: true) filter. Verify it now reaches Drift.
      await firestore
          .collection('taskRecurrences')
          .doc('missing-retired-field')
          .set(_recurrenceData(name: 'Legacy'));

      await service.start(testPersonDocId);
      await service.initialPullComplete;

      final stored =
          await db.taskRecurrenceDao.watchActive(testPersonDocId).first;
      expect(stored.map((r) => r.docId), contains('missing-retired-field'),
          reason:
              'Recurrence docs missing the retired field must still sync to Drift');
    });

    test('skips recurrences whose retired field is set to a non-null value',
        () async {
      await firestore
          .collection('taskRecurrences')
          .doc('retired-recurrence')
          .set(_recurrenceData(
              name: 'Retired',
              includeRetired: true,
              retired: 'someTaskDocId'));

      await service.start(testPersonDocId);
      await service.initialPullComplete;

      final stored =
          await db.taskRecurrenceDao.watchActive(testPersonDocId).first;
      expect(stored.map((r) => r.docId).contains('retired-recurrence'), false,
          reason:
              'Retired recurrences must not be synced into Drift (watchActive cannot filter them locally because the converter does not write the retired column)');
    });
  });

  // ── TM-335: family listeners ───────────────────────────────────────────────

  Map<String, Object?> _familyMemberTask({
    required String name,
    required String familyDocId,
    required String personDocId,
  }) {
    return <String, Object?>{
      'name': name,
      'personDocId': personDocId,
      'familyDocId': familyDocId,
      'dateAdded': DateTime.utc(2024, 1, 1),
      'completionDate': null,
      'retired': null,
      'offCycle': false,
      'pendingCompletion': false,
    };
  }

  Future<void> _settleSnapshots() async {
    // Give fake_cloud_firestore listeners + Drift writes a few microtask
    // cycles to settle. `pumpEventQueue` works under flutter_test bindings.
    for (var i = 0; i < 4; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('SyncService family-tasks listener (TM-335)', () {
    const familyDocId = 'fam-1';
    const otherMemberDocId = 'pB';

    setUp(() async {
      // My persons doc with familyDocId set so the family listeners attach.
      await firestore.collection('persons').doc(testPersonDocId).set({
        'email': 'me@x.com',
        'familyDocId': familyDocId,
        'dateAdded': DateTime.utc(2024, 1, 1),
        'retired': null,
      });
      // The other family member's persons doc.
      await firestore.collection('persons').doc(otherMemberDocId).set({
        'email': 'other@x.com',
        'familyDocId': familyDocId,
        'dateAdded': DateTime.utc(2024, 1, 1),
        'retired': null,
      });
      // The family doc.
      await firestore.collection('families').doc(familyDocId).set({
        'ownerPersonDocId': testPersonDocId,
        'members': [testPersonDocId, otherMemberDocId],
        'dateAdded': DateTime.utc(2024, 1, 1),
        'retired': null,
      });
    });

    test("syncs another family member's task into local Drift", () async {
      await firestore.collection('tasks').doc('shared-task').set(
            _familyMemberTask(
              name: "Other member's task",
              familyDocId: familyDocId,
              personDocId: otherMemberDocId,
            ),
          );

      await service.start(testPersonDocId);
      await service.initialPullComplete;
      await _settleSnapshots();

      final familyTasks =
          await db.taskDao.watchFamilyActiveTasks(familyDocId).first;
      expect(familyTasks.map((t) => t.docId), contains('shared-task'));
    });

    test('reconciles stale family-task rows on initial snapshot', () async {
      // Seed Drift with a synced family-task row that is NOT present in
      // Firestore (simulating a removed/retired task that the previous
      // session cached).
      await db.taskDao.upsertFromRemote(_taskCompanion(
        docId: 'stale-task',
        familyDocId: familyDocId,
        personDocId: otherMemberDocId,
      ));

      await service.start(testPersonDocId);
      await service.initialPullComplete;
      await _settleSnapshots();

      final familyTasks =
          await db.taskDao.watchFamilyActiveTasks(familyDocId).first;
      expect(familyTasks.map((t) => t.docId).contains('stale-task'), false,
          reason:
              'Stale family-task rows must be reconciled out on initial snapshot');
    });
  });

  // ── TM-342: cross-device completion (Edge Case 1) ─────────────────────────

  Map<String, Object?> _personalTask({
    required String name,
    DateTime? completionDate,
    String? retired,
  }) {
    return <String, Object?>{
      'name': name,
      'personDocId': testPersonDocId,
      'familyDocId': null,
      'dateAdded': DateTime.utc(2024, 1, 1),
      'completionDate': completionDate,
      'retired': retired,
      'offCycle': false,
      'pendingCompletion': false,
    };
  }

  group('SyncService TM-342 cross-device completion', () {
    test('removed event with completionDate set → upserts (no delete)',
        () async {
      // Seed an incomplete task so it lands in Drift via the personal
      // listener.
      await firestore
          .collection('tasks')
          .doc('completed-elsewhere')
          .set(_personalTask(name: 'Mow lawn'));

      await service.start(testPersonDocId);
      await service.initialPullComplete;
      await _settleSnapshots();

      // Confirm it's in Drift before the simulated remote completion.
      final beforeRow =
          await db.taskDao.getByDocId('completed-elsewhere');
      expect(beforeRow, isNotNull, reason: 'precondition: task synced to Drift');

      // Simulate Device B completing the task: set completionDate. This
      // moves the doc out of the personal listener's `completionDate isNull`
      // filter, triggering a removed event on Device A.
      await firestore.collection('tasks').doc('completed-elsewhere').update({
        'completionDate': DateTime.utc(2024, 6, 1),
      });
      await _settleSnapshots();

      // The fix: the row must remain in Drift, with completionDate set.
      final afterRow =
          await db.taskDao.getByDocId('completed-elsewhere');
      expect(afterRow, isNotNull,
          reason:
              'TM-342: task must NOT be deleted from Drift on cross-device completion');
      expect(afterRow!.completionDate, isNotNull,
          reason: 'completionDate must be propagated to Drift');
    });

    test('removed event with retired set → upserts (no delete)', () async {
      await firestore
          .collection('tasks')
          .doc('retired-elsewhere')
          .set(_personalTask(name: 'Old task'));

      await service.start(testPersonDocId);
      await service.initialPullComplete;
      await _settleSnapshots();

      // Simulate retire on another device.
      await firestore.collection('tasks').doc('retired-elsewhere').update({
        'retired': 'manual',
        'retiredDate': DateTime.utc(2024, 6, 1),
      });
      await _settleSnapshots();

      // Row must remain in Drift; retired field propagated.
      final afterRow =
          await db.taskDao.getByDocId('retired-elsewhere');
      expect(afterRow, isNotNull,
          reason: 'TM-342: retired-on-other-device must not delete from Drift');
      expect(afterRow!.retired, 'manual');
    });

    test(
        'removed event for hard-deleted task with no cached data → server '
        'fetch confirms absent → deletes from Drift', () async {
      await firestore
          .collection('tasks')
          .doc('truly-deleted')
          .set(_personalTask(name: 'About to delete'));

      await service.start(testPersonDocId);
      await service.initialPullComplete;
      await _settleSnapshots();

      // Hard-delete from Firestore.
      await firestore.collection('tasks').doc('truly-deleted').delete();
      await _settleSnapshots();

      final afterRow =
          await db.taskDao.getByDocId('truly-deleted');
      expect(afterRow, isNull,
          reason: 'truly-deleted Firestore docs must be removed from Drift');
    });
  });

  // ── TM-342: offline conflict resolution (Edge Case 2) ─────────────────────

  TasksCompanion _pendingTaskRow({
    required String docId,
    required String name,
    required DateTime lastModified,
    SyncState syncState = SyncState.pendingUpdate,
  }) {
    return TasksCompanion(
      docId: Value(docId),
      name: Value(name),
      personDocId: const Value(testPersonDocId),
      dateAdded: Value(DateTime.utc(2024, 1, 1)),
      offCycle: const Value(false),
      lastModified: Value(lastModified),
      syncState: Value(syncState.name),
    );
  }

  group('SyncService TM-342 conflict detection on push', () {
    setUp(() async {
      // pushPendingWrites short-circuits when no person is set; start() the
      // listener so _currentPersonDocId is populated. The listeners attach to
      // an empty Firestore so they don't churn over our pending rows.
      await service.start(testPersonDocId);
      await service.initialPullComplete;
      await _settleSnapshots();
    });

    test('push with no remote doc → set() called, row marked synced',
        () async {
      // Insert a pending task with no remote counterpart yet.
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'fresh',
              name: 'Brand new',
              lastModified: DateTime.utc(2024, 6, 1),
              syncState: SyncState.pendingCreate,
            ),
          );

      await service.pushPendingWrites(caller: 'test');

      final row = await db.taskDao.getByDocId('fresh');
      expect(row, isNotNull);
      expect(row!.syncState, SyncState.synced.name,
          reason: 'fresh inserts have no remote → push proceeds');

      final remote = await firestore.collection('tasks').doc('fresh').get();
      expect(remote.exists, isTrue);
    });

    test(
        'push with remote lastModified null → push proceeds (legacy '
        'compat)', () async {
      // Insert local pending FIRST so the Firestore listener doesn't
      // overwrite it on its way through bulkUpsertFromRemote (it skips
      // rows already in pending state).
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'legacy',
              name: 'My new name',
              lastModified: DateTime.utc(2024, 6, 1),
            ),
          );
      // Remote doc exists but has no lastModified field (a pre-TM-342 client
      // wrote it).
      await firestore.collection('tasks').doc('legacy').set(
            _personalTask(name: 'Legacy remote'),
          );
      await _settleSnapshots();

      await service.pushPendingWrites(caller: 'test');

      final row = await db.taskDao.getByDocId('legacy');
      expect(row!.syncState, SyncState.synced.name,
          reason:
              'remote without lastModified is treated as legacy → local push wins');
    });

    test(
        'push with remote lastModified <= local → push proceeds and clears '
        'pending', () async {
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'older',
              name: 'My fresher name',
              lastModified: DateTime.utc(2024, 6, 1), // newer
            ),
          );
      await firestore.collection('tasks').doc('older').set({
        ..._personalTask(name: 'Old remote'),
        'lastModified': DateTime.utc(2024, 5, 1),
      });
      await _settleSnapshots();

      await service.pushPendingWrites(caller: 'test');

      final row = await db.taskDao.getByDocId('older');
      expect(row!.syncState, SyncState.synced.name,
          reason: 'local newer than remote → push proceeds');
    });

    test(
        'push with remote lastModified > local → conflict recorded, no set()',
        () async {
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'contested',
              name: 'My version',
              lastModified: DateTime.utc(2024, 6, 1),
            ),
          );
      await firestore.collection('tasks').doc('contested').set({
        ..._personalTask(name: 'Their version'),
        'lastModified': DateTime.utc(2024, 8, 1), // newer than local
      });
      await _settleSnapshots();

      await service.pushPendingWrites(caller: 'test');

      final row = await db.taskDao.getByDocId('contested');
      expect(row!.syncState, SyncState.pendingConflict.name,
          reason:
              'remote newer than local → push aborts and conflict is recorded');
      expect(row.conflictRemoteJson, isNotNull,
          reason: 'remote envelope must be stashed for resolution UI');
      // Local edit is preserved.
      expect(row.name, 'My version');

      // Firestore was NOT overwritten by our local push.
      final remote =
          await firestore.collection('tasks').doc('contested').get();
      expect(remote.data()?['name'], 'Their version',
          reason: 'remote must NOT be overwritten when conflict detected');
    });

    test(
        'pendingDelete + newer remote → conflict recorded, no Firestore '
        'delete', () async {
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'to-delete',
              name: 'Local before delete',
              lastModified: DateTime.utc(2024, 6, 1),
              syncState: SyncState.pendingDelete,
            ),
          );
      await firestore.collection('tasks').doc('to-delete').set({
        ..._personalTask(name: 'They edited it'),
        'lastModified': DateTime.utc(2024, 8, 1),
      });
      await _settleSnapshots();

      await service.pushPendingWrites(caller: 'test');

      final row = await db.taskDao.getByDocId('to-delete');
      expect(row, isNotNull,
          reason: 'pendingDelete with conflict must NOT hard-delete locally');
      expect(row!.syncState, SyncState.pendingConflict.name);

      final remote =
          await firestore.collection('tasks').doc('to-delete').get();
      expect(remote.exists, isTrue,
          reason: 'Firestore doc must NOT be deleted when conflict detected');
    });

    test('upsertFromRemote skips pendingConflict rows (TM-342 invariant)',
        () async {
      // Seed a pendingConflict row.
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'in-conflict',
              name: 'My pending edit',
              lastModified: DateTime.utc(2024, 6, 1),
              syncState: SyncState.pendingConflict,
            ),
          );

      // A new remote upsert arrives.
      await db.taskDao.upsertFromRemote(TasksCompanion(
        docId: const Value('in-conflict'),
        name: const Value('Newer remote'),
        personDocId: const Value(testPersonDocId),
        dateAdded: Value(DateTime.utc(2024, 1, 1)),
        offCycle: const Value(false),
      ));

      final row = await db.taskDao.getByDocId('in-conflict');
      expect(row!.name, 'My pending edit',
          reason: 'remote upsert must NOT overwrite a pendingConflict row');
      expect(row.syncState, SyncState.pendingConflict.name);
    });
  });

  // ── TM-342: DAO conflict-state methods ────────────────────────────────────

  group('TaskDao TM-342 conflict-state methods', () {
    test('markPendingConflict writes envelope and preserves local data',
        () async {
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'd1',
              name: 'Local edit',
              lastModified: DateTime.utc(2024, 6, 1),
            ),
          );

      const envelope = '{"priorSyncState":"pendingUpdate","remote":{"x":1}}';
      await db.taskDao.markPendingConflict('d1', envelope);

      final row = await db.taskDao.getByDocId('d1');
      expect(row!.syncState, SyncState.pendingConflict.name);
      expect(row.conflictRemoteJson, envelope);
      expect(row.name, 'Local edit',
          reason: 'local data must remain intact for the resolution UI');
    });

    test('clearConflictAndAcceptRemote replaces row and clears conflict',
        () async {
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'd2',
              name: 'My edit',
              lastModified: DateTime.utc(2024, 6, 1),
              syncState: SyncState.pendingConflict,
            ),
          );

      await db.taskDao.clearConflictAndAcceptRemote(
        'd2',
        TasksCompanion(
          docId: const Value('d2'),
          name: const Value('Their version'),
          personDocId: const Value(testPersonDocId),
          dateAdded: Value(DateTime.utc(2024, 1, 1)),
          offCycle: const Value(false),
        ),
      );

      final row = await db.taskDao.getByDocId('d2');
      expect(row!.name, 'Their version');
      expect(row.syncState, SyncState.synced.name);
      expect(row.conflictRemoteJson, isNull);
    });

    test('clearConflictAndRestorePending restores prior state and refreshes ts',
        () async {
      final earlier = DateTime.utc(2024, 6, 1);
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'd3',
              name: 'My edit',
              lastModified: earlier,
              syncState: SyncState.pendingConflict,
            ),
          );

      final later = DateTime.utc(2024, 9, 1);
      await db.taskDao.clearConflictAndRestorePending(
        'd3',
        SyncState.pendingUpdate,
        now: later,
      );

      final row = await db.taskDao.getByDocId('d3');
      expect(row!.syncState, SyncState.pendingUpdate.name);
      expect(row.conflictRemoteJson, isNull);
      // Drift returns local-time DateTimes; compare via toUtc().
      expect(row.lastModified!.toUtc(), later,
          reason:
              'lastModified must be refreshed so the next push wins against '
              'the remote that previously beat us');
    });

    test('watchTasksWithConflicts emits only pendingConflict rows', () async {
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'normal',
              name: 'Normal',
              lastModified: DateTime.utc(2024, 6, 1),
              syncState: SyncState.pendingUpdate,
            ),
          );
      await db.into(db.tasks).insertOnConflictUpdate(
            _pendingTaskRow(
              docId: 'conflicted',
              name: 'In conflict',
              lastModified: DateTime.utc(2024, 6, 1),
              syncState: SyncState.pendingConflict,
            ),
          );

      final rows =
          await db.taskDao.watchTasksWithConflicts(testPersonDocId).first;
      expect(rows.map((r) => r.docId), ['conflicted']);
    });
  });
}

TasksCompanion _taskCompanion({
  required String docId,
  required String familyDocId,
  required String personDocId,
}) {
  return TasksCompanion(
    docId: Value(docId),
    name: const Value('Stale'),
    personDocId: Value(personDocId),
    familyDocId: Value(familyDocId),
    dateAdded: Value(DateTime.utc(2024, 1, 1)),
    offCycle: const Value(false),
    syncState: Value(SyncState.synced.name),
  );
}
