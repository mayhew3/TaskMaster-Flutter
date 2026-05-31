import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/connectivity_provider.dart';
import 'package:taskmaestro/core/providers/sync_status_provider.dart';
import 'package:built_collection/built_collection.dart';
import 'package:taskmaestro/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaestro/features/sprints/providers/create_sprint_draft_provider.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_assignment.dart';

/// Mutable source for `lastCompletedSprint` so a test can change it
/// AFTER first render — simulates a late Drift stream arrival.
class _LastSprintSource extends Notifier<Sprint?> {
  @override
  Sprint? build() => null;
  void set(Sprint? value) => state = value;
}

final _lastSprintSource =
    NotifierProvider<_LastSprintSource, Sprint?>(_LastSprintSource.new);

/// TM-388 — `NewSprintScreen` lifted its form state into
/// `createSprintDraftProvider`. The local `TextEditingController`s for
/// date and time are derived FROM the watched draft (sync-on-rebuild),
/// so the displayed text must always reflect the current draft.
///
/// Two contracts:
///   1. Initial render → controllers show the draft's seeded
///      `sprintStart` (date + time).
///   2. Draft mutated externally (e.g. wide-shell init code, sprint
///      stream landing late) → controllers re-sync without losing the
///      Scaffold (no remount).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    required DateTime initialStart,
  }) async {
    final container = ProviderContainer(overrides: [
      lastCompletedSprintProvider.overrideWith((ref) => null),
      personDocIdProvider.overrideWith((ref) => 'p'),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
    ]);
    addTearDown(container.dispose);

    // Seed the draft with a deterministic start so the formatted strings
    // are stable across the date/time format expectations below.
    container
        .read(createSprintDraftProvider.notifier)
        .setStartDate(initialStart);
    container
        .read(createSprintDraftProvider.notifier)
        .setStartTime(initialStart);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NewSprintScreen()),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets(
      'initial render: date + time controllers reflect the draft '
      'sprintStart (TM-388)', (tester) async {
    final start = DateTime(2026, 3, 15, 9, 30);
    await pumpScreen(tester, initialStart: start);

    expect(find.text(DateFormat('MM-dd-yyyy').format(start)), findsOneWidget);
    expect(find.text(DateFormat('hh:mm a').format(start)), findsOneWidget);
  });

  testWidgets(
      'external draft mutation re-syncs the controllers (TM-388)',
      (tester) async {
    final start = DateTime(2026, 3, 15, 9, 30);
    final container = await pumpScreen(tester, initialStart: start);

    final later = DateTime(2026, 7, 4, 14, 0);
    container
        .read(createSprintDraftProvider.notifier)
        .setStartDate(later);
    container
        .read(createSprintDraftProvider.notifier)
        .setStartTime(later);
    await tester.pump();

    expect(find.text(DateFormat('MM-dd-yyyy').format(later)), findsOneWidget);
    expect(find.text(DateFormat('hh:mm a').format(later)), findsOneWidget);
    expect(find.text(DateFormat('MM-dd-yyyy').format(start)), findsNothing);
  });

  testWidgets(
      'late lastCompletedSprint arrival re-seeds Num/Unit fields '
      '(TM-388 R1) — the field ValueKey tied to the seed identity '
      'forces a remount with the new initial value', (tester) async {
    final container = ProviderContainer(overrides: [
      lastCompletedSprintProvider
          .overrideWith((ref) => ref.watch(_lastSprintSource)),
      personDocIdProvider.overrideWith((ref) => 'p'),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      syncStatusControllerProvider.overrideWith(_FakeSyncStatus.new),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: NewSprintScreen()),
      ),
    );
    await tester.pump();

    // Default seed → Num=1, Unit=Weeks.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Weeks'), findsOneWidget);

    // Late-arriving last completed sprint with a different cadence.
    container.read(_lastSprintSource.notifier).set(Sprint((b) => b
      ..docId = 'last-sprint'
      ..dateAdded = DateTime.utc(2026, 1, 1)
      ..startDate = DateTime.utc(2026, 1, 1)
      ..endDate = DateTime.utc(2026, 3, 1)
      ..numUnits = 2
      ..unitName = 'Months'
      ..personDocId = 'p'
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder<SprintAssignment>()));
    await tester.pump();

    // The form must now show the re-seeded values — NOT the stale
    // pre-seed ones.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Months'), findsOneWidget);
    expect(find.text('Weeks'), findsNothing);
  });
}

class _FakeSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => SyncStatus.idle;
}
