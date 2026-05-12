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
import 'package:taskmaestro/features/areas/services/area_service.dart';
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

/// AreaService subclass whose `createArea` always throws the supplied
/// exception. Used to simulate the service-rejection race where the
/// in-memory validator passes (no cached collision) but the canonical
/// `AreaService.createArea` rejects after a Firestore round-trip
/// (DuplicateAreaNameException) or because the requested name is a
/// reserved sentinel that the validator's reserved-list check missed
/// (ReservedAreaNameException — defensive coverage of the second catch
/// branch in `_createAreaInline`).
class _ThrowingAreaService extends AreaService {
  _ThrowingAreaService({
    required super.db,
    required super.firestore,
    required super.ref,
    required this.exceptionToThrow,
  });

  final Exception exceptionToThrow;

  @override
  Future<Area> createArea({
    required String name,
    required String personDocId,
    bool skipInitialPullWait = false,
  }) async {
    throw exceptionToThrow;
  }
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
  Exception? createAreaThrows,
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
      if (createAreaThrows != null)
        areaServiceProvider.overrideWith((ref) => _ThrowingAreaService(
              db: ref.watch(databaseProvider),
              firestore: ref.watch(firestoreProvider),
              ref: ref,
              exceptionToThrow: createAreaThrows,
            )),
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

    testWidgets(
      'duplicate-name exception from service displays inline and preserves typed text',
      (tester) async {
        // Covers the DuplicateAreaNameException catch branch in
        // _createAreaInline (area_picker.dart:297-301). This is the race
        // where the in-memory validator (against cached `areasProvider`)
        // passes — because the cache hasn't seen the conflicting area —
        // but `AreaService.createArea` rejects after the Firestore
        // round-trip. The user's typed text must be preserved so they can
        // edit-and-retry without re-typing.
        String? captured;
        await tester.pumpWidget(_buildHarness(
          db: db,
          firestore: firestore,
          // Seed only 'Home' so the in-memory validator passes for
          // 'Workshop'. The throwing service then provides the rejection.
          areas: [_area(docId: 'home', name: 'Home')],
          valueSetter: (v) => captured = v,
          createAreaThrows: DuplicateAreaNameException('Workshop'),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('area_picker_button')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Workshop');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        // The service-rejection message renders inline below the input.
        expect(find.text('Area "Workshop" already exists.'), findsOneWidget,
            reason:
                'Inline error must display the DuplicateAreaNameException message.');

        // Typed text preserved — InlineAddField only clears the controller
        // on success, so the user can edit-and-retry.
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller!.text, 'Workshop',
            reason:
                'Typed text must NOT be cleared when the service rejects.');

        expect(captured, isNull,
            reason: 'valueSetter must NOT fire on service rejection.');
      },
    );

    testWidgets(
      'reserved-name exception from service displays inline',
      (tester) async {
        // Covers the ReservedAreaNameException catch branch in
        // _createAreaInline (area_picker.dart:302-304). The in-memory
        // validator already checks kReservedAreaNames, but the service
        // re-checks defensively against the canonical reserved list (which
        // could diverge in future refactors). This test exercises that
        // second branch even though it's not reachable via the validator
        // today — making the contract explicit if either side changes.
        String? captured;
        await tester.pumpWidget(_buildHarness(
          db: db,
          firestore: firestore,
          areas: [_area(docId: 'home', name: 'Home')],
          valueSetter: (v) => captured = v,
          // 'Workshop' is NOT in kReservedAreaNames — the in-memory
          // validator passes — but our throwing service unconditionally
          // throws ReservedAreaNameException to drive the second catch.
          createAreaThrows: ReservedAreaNameException('Workshop'),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('area_picker_button')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Workshop');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(find.text('Area name "Workshop" is reserved.'), findsOneWidget,
            reason:
                'Inline error must display the ReservedAreaNameException message.');
        expect(captured, isNull,
            reason: 'valueSetter must NOT fire on reserved-name rejection.');
      },
    );
  });
}
