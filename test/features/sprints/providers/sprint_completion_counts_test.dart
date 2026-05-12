// TM-361 + TM-366 follow-up: regression test for
// `sprintCompletionCountsProvider`'s end-to-end emission flow. Covers the
// three behaviors the provider's combineLatest design needs to deliver:
//
//   1. An immediate denominator-only emission before the Firestore roster
//      fetch resolves, so the banner doesn't render `0/0` on slow networks.
//   2. A fresh count emission when the Firestore roster lands (folding in
//      cold completions written by other devices).
//   3. A fresh count emission when a local Drift change toggles a task's
//      completion, *after* the Firestore roster has already resolved —
//      i.e. the Drift watch keeps emitting once the Firestore side closes.
//
// All three were broken at one point on TM-361: the original implementation
// blocked the Drift watch behind the Firestore await, so the banner read
// `0/0` until the network round-trip completed.

import 'package:built_collection/built_collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/database/app_database.dart'
    hide Task, TaskRecurrence, Sprint, SprintAssignment;
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/core/providers/firebase_providers.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';

const _personDocId = 'test-person';

Sprint _sprintWith(List<String> taskDocIds) {
  final now = DateTime.utc(2026, 1, 1);
  return Sprint((b) => b
    ..docId = 'sprint-1'
    ..dateAdded = now
    ..startDate = now.subtract(const Duration(days: 1))
    ..endDate = now.add(const Duration(days: 6))
    ..numUnits = 1
    ..unitName = 'week'
    ..personDocId = _personDocId
    ..sprintNumber = 1
    ..sprintAssignments = ListBuilder<SprintAssignment>(
      taskDocIds.asMap().entries.map(
            (e) => SprintAssignment((sb) => sb
              ..docId = 'assign-${e.key}'
              ..taskDocId = e.value
              ..sprintDocId = 'sprint-1'),
          ),
    ));
}

TasksCompanion _taskRow(String docId, {DateTime? completionDate}) {
  return TasksCompanion(
    docId: Value(docId),
    name: Value('Task $docId'),
    personDocId: const Value(_personDocId),
    dateAdded: Value(DateTime.utc(2026, 1, 1)),
    completionDate: Value(completionDate),
    syncState: const Value('synced'),
    offCycle: const Value(false),
  );
}

void main() {
  group('sprintCompletionCountsProvider end-to-end emission flow', () {
    late AppDatabase db;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      firestore = FakeFirebaseFirestore();
    });

    tearDown(() async {
      await db.close();
    });

    test(
        're-emits a fresh count when Drift toggles a task after the '
        'Firestore roster resolves', () async {
      // Seed Drift with three sprint tasks: one already completed locally,
      // two incomplete. The sprint's roster references all three.
      await db.taskDao.upsertFromRemote(_taskRow('t-1'));
      await db.taskDao.upsertFromRemote(_taskRow('t-2'));
      await db.taskDao.upsertFromRemote(
        _taskRow('t-3', completionDate: DateTime.utc(2026, 1, 2)),
      );
      // Seed Firestore with the same three so the roster fetch returns a
      // realistic payload (the provider serialises these via TaskItem.fromJson).
      for (final docId in ['t-1', 't-2']) {
        await firestore.collection('tasks').doc(docId).set({
          'docId': docId,
          'name': 'Task $docId',
          'personDocId': _personDocId,
          'dateAdded': DateTime.utc(2026, 1, 1),
          'offCycle': false,
          'pendingCompletion': false,
        });
      }
      await firestore.collection('tasks').doc('t-3').set({
        'docId': 't-3',
        'name': 'Task t-3',
        'personDocId': _personDocId,
        'dateAdded': DateTime.utc(2026, 1, 1),
        'offCycle': false,
        'pendingCompletion': false,
        'completionDate': DateTime.utc(2026, 1, 2),
      });

      final sprint = _sprintWith(['t-1', 't-2', 't-3']);

      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        firestoreProvider.overrideWithValue(firestore),
        personDocIdProvider.overrideWith((ref) => _personDocId),
      ]);
      addTearDown(container.dispose);

      // Collect every emission so we can assert on the sequence.
      final emissions = <SprintCounts>[];
      final sub = container.listen<AsyncValue<SprintCounts>>(
        sprintCompletionCountsProvider(sprint),
        (_, next) {
          if (next.hasValue && !next.isLoading) {
            emissions.add(next.requireValue);
          }
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Let the initial denominator-only yield, the Drift watch's first
      // emission, and the Firestore roster resolution all flow through.
      // A few event-loop turns covers all three since the Firestore fake
      // resolves on a microtask boundary.
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(emissions, isNotEmpty,
          reason: 'provider must emit at least once');
      // The first emission is the explicit `SprintCounts(0, total)` so the
      // banner never reads `0/0` while the network roster fetch is in
      // flight — every emission after that has the correct denominator.
      expect(emissions.first.total, 3,
          reason: 'denominator must be visible from the first emission');
      // The most recent emission, after Drift + Firestore have both
      // settled, should reflect t-3's existing completion.
      expect(emissions.last.total, 3);
      expect(emissions.last.completed, 1,
          reason: 't-3 is the only completed task pre-toggle');

      final emissionsBeforeToggle = emissions.length;

      // Toggle t-1 to completed locally — this is the third behavior under
      // test. The Firestore side of combineLatest has already emitted its
      // resolved roster (and the stream closed); the Drift watch must
      // still trigger a fresh combined emission.
      await db.taskDao.markUpdatePending(
        't-1',
        TasksCompanion(completionDate: Value(DateTime.utc(2026, 1, 3))),
      );

      // Give Drift's emission a chance to propagate through the
      // combineLatest selector.
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(emissions.length, greaterThan(emissionsBeforeToggle),
          reason: 'Drift toggle after Firestore resolution must produce a '
              'fresh combineLatest emission (regression for the closed-'
              'Firestore-side keeps-Drift-side-alive contract)');
      expect(emissions.last.total, 3);
      expect(emissions.last.completed, 2,
          reason: 't-1 and t-3 are now completed (t-1 just toggled, t-3 '
              'already was)');
    });
  });
}
