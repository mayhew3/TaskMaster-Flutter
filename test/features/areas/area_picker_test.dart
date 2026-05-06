import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/database/app_database.dart' hide Area;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/core/providers/firebase_providers.dart';
import 'package:taskmaestro/core/services/sync_service.dart';
import 'package:taskmaestro/features/areas/presentation/area_picker.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/models/area.dart';

class _FakeSyncService extends SyncService {
  _FakeSyncService({
    required super.db,
    required super.firestore,
    required super.ref,
  });

  @override
  Future<void> pushPendingWrites({String caller = 'unknown'}) async {}

  // Resolves immediately so AreaService.createArea doesn't park on its
  // 5s timeout.
  @override
  Future<void> get areasInitialPullComplete => Future.value();
}

/// Stubbed AreasWithDefaults that returns a fixed in-memory list and does
/// NOT touch Drift. The real provider's `ref.watch(areasProvider)` keeps a
/// Drift stream alive, whose cleanup timers fire after `finalizeTree` and
/// trip flutter_test's `!timersPending` invariant — see MEMORY.md
/// "Drift streams fail flutter_test invariants". Bypassing the stream
/// entirely lets the picker test execute in milliseconds.
class _StubAreasWithDefaults extends AreasWithDefaults {
  _StubAreasWithDefaults(this._areas);
  final List<Area> _areas;

  @override
  AsyncValue<List<Area>> build() => AsyncValue.data(_areas);
}

Area _area({required String docId, required String name, int sortOrder = 0}) {
  return Area((b) => b
    ..docId = docId
    ..dateAdded = DateTime.utc(2026, 1, 1)
    ..name = name
    ..sortOrder = sortOrder
    ..personDocId = 'me');
}

Widget _buildHarness({
  required AppDatabase db,
  required FakeFirebaseFirestore firestore,
  required void Function(String?) valueSetter,
  required List<Area> areas,
  String? initialValue,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      firestoreProvider.overrideWithValue(firestore),
      personDocIdProvider.overrideWith((ref) => 'me'),
      syncServiceProvider.overrideWith((ref) => _FakeSyncService(
            db: ref.watch(databaseProvider),
            firestore: ref.watch(firestoreProvider),
            ref: ref,
          )),
      // Stub AreasWithDefaults so the picker doesn't watch a Drift stream.
      areasWithDefaultsProvider
          .overrideWith(() => _StubAreasWithDefaults(areas)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: AreaPicker(
          initialValue: initialValue,
          valueSetter: valueSetter,
        ),
      ),
    ),
  );
}

void main() {
  late AppDatabase db;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
  });

  tearDown(() async {
    await db.close();
  });

  group('AreaPicker inline + Add new area…', () {
    testWidgets(
      'submitting the inline field calls valueSetter with the new name',
      (tester) async {
        // The picker must invoke valueSetter with the new area name so the
        // parent task blueprint is updated. The inline field replaces the
        // old AlertDialog flow (TM-358).
        String? captured;
        await tester.pumpWidget(_buildHarness(
          db: db,
          firestore: firestore,
          areas: [_area(docId: 'home', name: 'Home')],
          valueSetter: (v) => captured = v,
        ));
        await tester.pumpAndSettle();

        // Open the bottom sheet via the chevron button.
        await tester.tap(find.byKey(const Key('area_picker_button')));
        await tester.pumpAndSettle();

        // The inline TextField at the bottom of the sheet uses the sentinel
        // string ("+ Add new area…") as its hint. Type a real name and
        // tap Add.
        await tester.enterText(find.byType(TextField), 'Workshop');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(captured, 'Workshop',
            reason:
                'valueSetter must be called with the new area name so the parent task blueprint is updated.');
      },
    );

    testWidgets(
      'sentinel string typed into the inline field is rejected and never persisted',
      (tester) async {
        // Negative contract: the literal sentinel ("+ Add new area…") must
        // never round-trip through valueSetter. The inline validator
        // rejects it via the kReservedAreaNames check.
        final captured = <String?>[];
        await tester.pumpWidget(_buildHarness(
          db: db,
          firestore: firestore,
          areas: [_area(docId: 'home', name: 'Home')],
          initialValue: 'Home',
          valueSetter: captured.add,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('area_picker_button')));
        await tester.pumpAndSettle();

        // Type the sentinel literally and try to submit.
        await tester.enterText(find.byType(TextField), '+ Add new area…');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(find.text('Reserved name; choose another'), findsOneWidget);
        expect(captured, isNot(contains('+ Add new area…')),
            reason: 'Sentinel string must NEVER be persisted as the area.');
      },
    );

    testWidgets(
      'duplicate name rejected inline; valueSetter is not called',
      (tester) async {
        // Typing a duplicate name and tapping Add must surface an inline
        // error without touching valueSetter. Belts the service-side
        // DuplicateAreaNameException check with an upfront UX signal.
        String? captured;
        await tester.pumpWidget(_buildHarness(
          db: db,
          firestore: firestore,
          areas: [_area(docId: 'home', name: 'Home')],
          valueSetter: (v) => captured = v,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('area_picker_button')));
        await tester.pumpAndSettle();

        // Try to add "home" — case-insensitive collision with seeded "Home".
        await tester.enterText(find.byType(TextField), 'home');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(find.text('Already in your list'), findsOneWidget);
        expect(captured, isNull,
            reason:
                'valueSetter must NOT fire when the inline validator rejects the name.');
      },
    );
  });
}
