import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaestro/date_util.dart';
import 'package:taskmaestro/features/sprints/providers/create_sprint_draft_provider.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/models/sprint.dart';

/// Mutable source for `lastCompletedSprint` so a test can change it
/// AFTER first read — re-running the draft's `build()` on the SAME
/// notifier (the late-load scenario), not a dispose+recreate.
class _LastSprintSource extends Notifier<Sprint?> {
  @override
  Sprint? build() => null;
  void set(Sprint? value) => state = value;
}

final _lastSprintSource =
    NotifierProvider<_LastSprintSource, Sprint?>(_LastSprintSource.new);

/// TM-388 — the create-sprint cadence draft. Seeding mirrors the
/// pre-TM-388 `NewSprintScreen._updateDatesOnInit` logic (inherit the
/// last completed sprint's cadence; start at the next scheduled
/// boundary), and once the user edits a field that value is pinned.
void main() {
  Sprint lastCompleted({
    required int numUnits,
    required String unitName,
    required DateTime endDate,
  }) {
    final added = DateTime.utc(2020, 1, 1);
    return Sprint((b) => b
      ..docId = 'last'
      ..dateAdded = added
      ..startDate = added
      ..endDate = endDate
      ..numUnits = numUnits
      ..unitName = unitName
      ..personDocId = 'p'
      ..sprintNumber = 1
      ..sprintAssignments = ListBuilder([]));
  }

  test('no last completed sprint → defaults {1, Weeks, ~now}', () {
    final c = ProviderContainer(overrides: [
      lastCompletedSprintProvider.overrideWith((ref) => null),
    ]);
    addTearDown(c.dispose);

    final draft = c.read(createSprintDraftProvider);
    expect(draft.numUnits, 1);
    expect(draft.unitName, 'Weeks');
    // Default start is "now" — within a small window of the test clock.
    expect(
        draft.sprintStart.difference(DateTime.now()).abs() <
            const Duration(minutes: 1),
        isTrue);
  });

  test('last completed sprint → inherits cadence + starts at next boundary',
      () {
    // End two weeks ago so the roll-forward advances past "now".
    final end = DateTime.now().subtract(const Duration(days: 14));
    final c = ProviderContainer(overrides: [
      lastCompletedSprintProvider.overrideWith(
          (ref) => lastCompleted(numUnits: 2, unitName: 'Weeks', endDate: end)),
    ]);
    addTearDown(c.dispose);

    final draft = c.read(createSprintDraftProvider);
    expect(draft.numUnits, 2);
    expect(draft.unitName, 'Weeks');
    // Next scheduled start rolls forward from the last end, never before it.
    expect(draft.sprintStart.isBefore(end), isFalse);
  });

  test('createSprintEndDate = start advanced by the cadence', () {
    final c = ProviderContainer(overrides: [
      lastCompletedSprintProvider.overrideWith((ref) => null),
    ]);
    addTearDown(c.dispose);

    c.read(createSprintDraftProvider.notifier).setNumUnits(3);
    c.read(createSprintDraftProvider.notifier).setUnitName('Days');

    final draft = c.read(createSprintDraftProvider);
    final end = c.read(createSprintEndDateProvider);
    expect(end, DateUtil.adjustToDate(draft.sprintStart, 3, 'Days'));
  });

  test('untouched draft re-seeds when the sprints stream resolves late', () {
    final c = ProviderContainer(overrides: [
      lastCompletedSprintProvider
          .overrideWith((ref) => ref.watch(_lastSprintSource)),
    ]);
    addTearDown(c.dispose);

    // Initially no last sprint → defaults.
    expect(c.read(createSprintDraftProvider).numUnits, 1);

    // Sprint loads late → untouched draft re-seeds to inherit cadence.
    c.read(_lastSprintSource.notifier).set(
        lastCompleted(numUnits: 4, unitName: 'Days', endDate: DateTime.now()));
    expect(c.read(createSprintDraftProvider).numUnits, 4);
    expect(c.read(createSprintDraftProvider).unitName, 'Days');
  });

  test('user edits are pinned against a late re-seed', () {
    final c = ProviderContainer(overrides: [
      lastCompletedSprintProvider
          .overrideWith((ref) => ref.watch(_lastSprintSource)),
    ]);
    addTearDown(c.dispose);

    c.read(createSprintDraftProvider.notifier).setNumUnits(5);
    c.read(createSprintDraftProvider.notifier).setUnitName('Months');
    expect(c.read(createSprintDraftProvider).numUnits, 5);

    // A late-arriving last sprint must NOT clobber the user's edits.
    c.read(_lastSprintSource.notifier).set(
        lastCompleted(numUnits: 2, unitName: 'Weeks', endDate: DateTime.now()));
    expect(c.read(createSprintDraftProvider).numUnits, 5);
    expect(c.read(createSprintDraftProvider).unitName, 'Months');
  });

  test('setStartDate preserves time-of-day; setStartTime preserves date', () {
    final c = ProviderContainer(overrides: [
      lastCompletedSprintProvider.overrideWith((ref) => null),
    ]);
    addTearDown(c.dispose);

    final notifier = c.read(createSprintDraftProvider.notifier);
    notifier.setStartDate(DateTime(2026, 3, 15, 0, 0));
    notifier.setStartTime(DateTime(2000, 1, 1, 14, 30));

    final s = c.read(createSprintDraftProvider).sprintStart;
    expect(s.year, 2026);
    expect(s.month, 3);
    expect(s.day, 15);
    expect(s.hour, 14);
    expect(s.minute, 30);
  });

  group('CreateSprintStep (TM-388)', () {
    test('default = form; mutators round-trip through every step', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final notifier = c.read(createSprintStepProvider.notifier);
      expect(c.read(createSprintStepProvider), CreateSprintStepValue.form);

      notifier.toPicker();
      expect(c.read(createSprintStepProvider), CreateSprintStepValue.picking);

      notifier.toCreating();
      expect(c.read(createSprintStepProvider), CreateSprintStepValue.creating);

      notifier.toForm();
      expect(c.read(createSprintStepProvider), CreateSprintStepValue.form);

      notifier.toAddingToSprint();
      expect(c.read(createSprintStepProvider),
          CreateSprintStepValue.addingToSprint);

      notifier.toForm();
      expect(c.read(createSprintStepProvider), CreateSprintStepValue.form);
    });
  });
}
