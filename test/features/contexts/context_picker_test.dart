import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/database/app_database.dart' hide Context;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/core/providers/firebase_providers.dart';
import 'package:taskmaestro/core/services/sync_service.dart';
import 'package:taskmaestro/features/contexts/presentation/context_picker.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/pill.dart';
import 'package:taskmaestro/models/context.dart';
import 'package:taskmaestro/models/task_context.dart';

/// Tests for the multi-select [ContextPicker] (TM-181).
///
/// Mirrors the AreaPicker test pattern (see area_picker_test.dart) — uses a
/// `_StubContextsWithDefaults` to avoid spinning up a real Drift stream
/// (cleanup-timers-after-finalizeTree invariant per MEMORY.md).

class _FakeSyncService extends SyncService {
  _FakeSyncService({
    required super.db,
    required super.firestore,
    required super.ref,
  });

  @override
  Future<void> pushPendingWrites({String caller = 'unknown'}) async {}

  @override
  Future<void> get contextsInitialPullComplete => Future.value();
}

class _StubContextsWithDefaults extends ContextsWithDefaults {
  _StubContextsWithDefaults(this._contexts);
  final List<Context> _contexts;

  @override
  AsyncValue<List<Context>> build() => AsyncValue.data(_contexts);
}

Context _ctx({
  required String docId,
  required String name,
  String? iconName,
  int sortOrder = 0,
}) {
  return Context((b) => b
    ..docId = docId
    ..dateAdded = DateTime.utc(2026, 1, 1)
    ..name = name
    ..sortOrder = sortOrder
    ..iconName = iconName
    ..personDocId = 'me');
}

Widget _buildHarness({
  required AppDatabase db,
  required FakeFirebaseFirestore firestore,
  required List<TaskContext> selected,
  required ValueChanged<List<TaskContext>> onChanged,
  required List<Context> catalog,
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
      contextsWithDefaultsProvider
          .overrideWith(() => _StubContextsWithDefaults(catalog)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ContextPicker(selected: selected, onChanged: onChanged),
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

  testWidgets('renders a pill for each selected context plus an AddPill',
      (tester) async {
    final catalog = [
      _ctx(docId: 'c1', name: 'Phone', iconName: 'phone'),
      _ctx(docId: 'c2', name: 'Computer', iconName: 'computer'),
    ];
    final selected = [TaskContext.named('Phone')];
    await tester.pumpWidget(_buildHarness(
      db: db,
      firestore: firestore,
      selected: selected,
      onChanged: (_) {},
      catalog: catalog,
    ));

    expect(find.byType(Pill), findsOneWidget);
    expect(find.byType(AddPill), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
  });

  testWidgets('tapping × on a pill emits onChanged without that context',
      (tester) async {
    final catalog = [
      _ctx(docId: 'c1', name: 'Phone', iconName: 'phone'),
    ];
    var selected = [TaskContext.named('Phone')];
    List<TaskContext>? lastChange;
    await tester.pumpWidget(_buildHarness(
      db: db,
      firestore: firestore,
      selected: selected,
      onChanged: (next) => lastChange = next,
      catalog: catalog,
    ));

    // The remove button is the close icon on the Pill.
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(lastChange, isNotNull);
    expect(lastChange, isEmpty);
  });

  testWidgets('AddPill opens a sheet listing only REMAINING contexts',
      (tester) async {
    final catalog = [
      _ctx(docId: 'c1', name: 'Phone', iconName: 'phone'),
      _ctx(docId: 'c2', name: 'Computer', iconName: 'computer'),
      _ctx(docId: 'c3', name: 'Home', iconName: 'home'),
    ];
    final selected = [TaskContext.named('Phone')];
    await tester.pumpWidget(_buildHarness(
      db: db,
      firestore: firestore,
      selected: selected,
      onChanged: (_) {},
      catalog: catalog,
    ));

    await tester.tap(find.byType(AddPill));
    await tester.pumpAndSettle();

    // Phone is already selected → not in the sheet's grid; Computer + Home
    // are. The pill in the body still shows Phone's name.
    final inSheet = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Computer'),
    );
    expect(inSheet, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Home'),
      ),
      findsOneWidget,
    );
    // Phone should NOT appear in the sheet (already selected).
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Phone'),
      ),
      findsNothing,
    );
  });

  testWidgets('empty-state message when nothing remains', (tester) async {
    final catalog = [
      _ctx(docId: 'c1', name: 'Phone'),
    ];
    final selected = [TaskContext.named('Phone')];
    await tester.pumpWidget(_buildHarness(
      db: db,
      firestore: firestore,
      selected: selected,
      onChanged: (_) {},
      catalog: catalog,
    ));

    await tester.tap(find.byType(AddPill));
    await tester.pumpAndSettle();

    expect(find.text('All contexts are already selected.'), findsOneWidget);
  });

  testWidgets('tapping a remaining cell appends it to the selection',
      (tester) async {
    final catalog = [
      _ctx(docId: 'c1', name: 'Phone', iconName: 'phone'),
      _ctx(docId: 'c2', name: 'Computer', iconName: 'computer'),
    ];
    final selected = <TaskContext>[];
    List<TaskContext>? lastChange;
    await tester.pumpWidget(_buildHarness(
      db: db,
      firestore: firestore,
      selected: selected,
      onChanged: (next) => lastChange = next,
      catalog: catalog,
    ));

    await tester.tap(find.byType(AddPill));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Phone'));
    await tester.pumpAndSettle();

    expect(lastChange, isNotNull);
    expect(lastChange!.map((c) => c.name).toList(), ['Phone']);
  });
}
