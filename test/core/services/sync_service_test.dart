import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart';
import 'package:taskmaster/core/providers/connectivity_provider.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/services/sync_service.dart';

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
}
