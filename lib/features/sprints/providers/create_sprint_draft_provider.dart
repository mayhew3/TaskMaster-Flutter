import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../date_util.dart';
import '../../../models/sprint.dart';
import 'sprint_providers.dart';

part 'create_sprint_draft_provider.g.dart';

/// Immutable draft of the create-sprint cadence form (TM-388).
///
/// Lifts the form state that used to live only in `_NewSprintScreenState`
/// (`numUnits` / `unitName` / `sprintStart`) into Riverpod so that BOTH
/// the wide in-shell task picker AND `planBasePool` (sidebar faceted
/// counts) can read the same canonical values the form is showing.
class CreateSprintDraftState {
  const CreateSprintDraftState({
    required this.numUnits,
    required this.unitName,
    required this.sprintStart,
  });

  final int numUnits;
  final String unitName;
  final DateTime sprintStart;

  CreateSprintDraftState copyWith({
    int? numUnits,
    String? unitName,
    DateTime? sprintStart,
  }) {
    return CreateSprintDraftState(
      numUnits: numUnits ?? this.numUnits,
      unitName: unitName ?? this.unitName,
      sprintStart: sprintStart ?? this.sprintStart,
    );
  }
}

/// Holds the create-sprint cadence draft (TM-388).
///
/// Seeding mirrors the pre-TM-388 `NewSprintScreen._updateDatesOnInit` /
/// `_getNextScheduledStart`: inherit the last completed sprint's cadence
/// and start at the next scheduled boundary; otherwise default to a
/// 1-week sprint starting now.
///
/// `build()` `watch`es `lastCompletedSprintProvider` so an untouched
/// draft re-seeds if the sprints stream resolves after first read. Once
/// the user edits any field, `_userEdited` pins their values so a later
/// stream tick can't clobber them.
@Riverpod(keepAlive: true)
class CreateSprintDraft extends _$CreateSprintDraft {
  CreateSprintDraftState? _userEdited;

  @override
  CreateSprintDraftState build() {
    if (_userEdited != null) return _userEdited!;
    return _seedFrom(ref.watch(lastCompletedSprintProvider));
  }

  CreateSprintDraftState _seedFrom(Sprint? lastCompleted) {
    final nextStart = _nextScheduledStart(lastCompleted);
    if (lastCompleted != null && nextStart != null) {
      return CreateSprintDraftState(
        numUnits: lastCompleted.numUnits,
        unitName: lastCompleted.unitName,
        sprintStart: nextStart,
      );
    }
    return CreateSprintDraftState(
      numUnits: 1,
      unitName: 'Weeks',
      sprintStart: DateTime.now(),
    );
  }

  /// Walk forward from the last completed sprint's end by its cadence
  /// until the candidate window is no longer in the past — the same
  /// roll-forward `NewSprintScreen._getNextScheduledStart` did.
  DateTime? _nextScheduledStart(Sprint? lastCompleted) {
    if (lastCompleted == null) return null;
    final now = DateTime.now();
    DateTime nextStart;
    DateTime nextEnd = lastCompleted.endDate;
    do {
      nextStart = nextEnd;
      nextEnd = DateUtil.adjustToDate(
        nextStart,
        lastCompleted.numUnits,
        lastCompleted.unitName,
      );
    } while (nextEnd.isBefore(now));
    return nextStart;
  }

  void _set(CreateSprintDraftState next) {
    _userEdited = next;
    state = next;
  }

  void setNumUnits(int numUnits) => _set(state.copyWith(numUnits: numUnits));

  void setUnitName(String unitName) => _set(state.copyWith(unitName: unitName));

  /// Updates the date portion, preserving the existing time-of-day.
  void setStartDate(DateTime date) =>
      _set(state.copyWith(
          sprintStart: DateUtil.combineDateAndTime(date, state.sprintStart)));

  /// Updates the time portion, preserving the existing date.
  void setStartTime(DateTime time) =>
      _set(state.copyWith(
          sprintStart: DateUtil.combineDateAndTime(state.sprintStart, time)));
}

/// Derived end date for the create-sprint draft (TM-388): the single
/// canonical formula (`startDate` advanced by the cadence) read by both
/// the wide task picker and `planBasePool`, so sidebar counts can't drift
/// from the rendered list.
@riverpod
DateTime createSprintEndDate(Ref ref) {
  final draft = ref.watch(createSprintDraftProvider);
  return DateUtil.adjustToDate(
      draft.sprintStart, draft.numUnits, draft.unitName);
}

/// Which step of the wide in-shell plan flow is showing (TM-388). On the
/// wide layout `PlanningHome` swaps these in place (no `Navigator.push`,
/// so the sidebar stays visible); compact keeps the full-screen routes
/// and ignores this.
///
/// No active sprint (create-sprint flow):
///   - `form` — cadence form
///   - `picking` — new-sprint task picker
///   - `creating` — transient spinner covering the gap between a
///     successful submit and the Drift sprints stream emitting the new
///     sprint (without it the form flashes back for ~1s). `PlanningHome`
///     drops it back to `form` on the next sprints emission (so a
///     future-dated sprint, which never becomes "active", returns to the
///     form rather than spinning forever).
///
/// Active sprint (add-to-existing flow):
///   - `addingToSprint` — the "Add More..." task picker; any other value
///     shows the sprint's task list.
enum CreateSprintStepValue { form, picking, creating, addingToSprint }

@riverpod
class CreateSprintStep extends _$CreateSprintStep {
  @override
  CreateSprintStepValue build() => CreateSprintStepValue.form;

  void toPicker() => state = CreateSprintStepValue.picking;

  void toForm() => state = CreateSprintStepValue.form;

  void toCreating() => state = CreateSprintStepValue.creating;

  void toAddingToSprint() => state = CreateSprintStepValue.addingToSprint;
}
