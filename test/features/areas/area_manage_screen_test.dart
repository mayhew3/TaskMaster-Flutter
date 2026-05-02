import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart' hide Area;
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/services/sync_service.dart';
import 'package:taskmaster/features/areas/presentation/area_manage_screen.dart';
import 'package:taskmaster/features/areas/providers/area_providers.dart';
import 'package:taskmaster/models/area.dart';

/// Same SyncService stub used in area_picker_test — bypasses the real push
/// loop and resolves the areas-initial-pull future immediately.
class _FakeSyncService extends SyncService {
  _FakeSyncService({
    required super.db,
    required super.firestore,
    required super.ref,
  });

  @override
  Future<void> pushPendingWrites({String caller = 'unknown'}) async {}

  @override
  Future<void> get areasInitialPullComplete => Future.value();
}

/// Synchronous AsyncValue.data stub for areasWithDefaultsProvider so the
/// screen never watches Drift's stream (which would trip flutter_test's
/// `!timersPending` invariant — see MEMORY.md).
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
  required List<Area> areas,
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
      areasWithDefaultsProvider
          .overrideWith(() => _StubAreasWithDefaults(areas)),
      // Also stub areasProvider — the manage screen's add/rename dialogs
      // call `ref.read(areasProvider)` for the duplicate-name check, which
      // would otherwise instantiate the real Drift-backed provider and
      // leak stream timers (MEMORY.md "Drift streams fail flutter_test
      // invariants").
      areasProvider.overrideWith((ref) => Stream.value(areas)),
    ],
    child: const MaterialApp(home: AreaManageScreen()),
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

  group('AreaManageScreen', () {
    testWidgets('renders the user\'s areas in sortOrder', (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: [
          _area(docId: 'a-1', name: 'Home', sortOrder: 0),
          _area(docId: 'a-2', name: 'Work', sortOrder: 1),
          _area(docId: 'a-3', name: 'Health', sortOrder: 2),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Manage Areas'), findsOneWidget);
    });

    testWidgets('empty state copy when the list is empty', (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: const [],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('No areas yet'), findsOneWidget);
    });

    testWidgets('FAB opens the add dialog with the area-name field',
        (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: [_area(docId: 'a-1', name: 'Home')],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('New area'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('add dialog rejects duplicate names with validation error',
        (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: [_area(docId: 'a-1', name: 'Home')],
      ));
      await tester.pumpAndSettle();

      // Pre-touch areasProvider so its stream emits before the dialog reads
      // it. In production the screen's `areasWithDefaultsProvider` listener
      // (which watches `areasProvider` internally) drives this — but the
      // test stub for `areasWithDefaultsProvider` bypasses that path, so
      // we have to trigger it manually for the dup check to see the seeded
      // areas.
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(areasProvider);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'home');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Already in your list'), findsOneWidget);
      // Dialog stays open since validation failed.
      expect(find.text('New area'), findsOneWidget);
    });

    testWidgets('add dialog rejects reserved sentinel names', (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: const [],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '(none)');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Reserved'), findsOneWidget);
    });

    testWidgets('delete confirmation dialog renders with the area name',
        (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: [_area(docId: 'a-1', name: 'Home')],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete "Home"?'), findsOneWidget);
      expect(find.textContaining('keep the value'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('rename dialog opens pre-populated with the current name',
        (tester) async {
      await tester.pumpWidget(_buildHarness(
        db: db,
        firestore: firestore,
        areas: [_area(docId: 'a-1', name: 'Home')],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Rename area'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);
      // The TextFormField should have 'Home' as its initial text.
      expect(find.widgetWithText(TextFormField, 'Home'), findsOneWidget);
    });
  });
}
