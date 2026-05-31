// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sprint_draft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the create-sprint cadence draft (TM-388).
///
/// Seeding mirrors the pre-TM-388 `NewSprintScreen._updateDatesOnInit` /
/// `_getNextScheduledStart`: inherit the last completed sprint's cadence
/// and start at the next scheduled boundary; otherwise default to a
/// 1-week sprint starting now.
///
/// `build()` `watch`es `personDocIdProvider` and `lastCompletedSprintProvider`:
///   - **`_cachedSeed`** stops `DateTime.now()` inside `_seedFrom` from
///     drifting on no-op stream re-emissions (Drift can re-emit when an
///     unrelated watched table touches). Recomputed only when an input
///     actually changes.
///   - **`_userEdited`** pins user edits against late stream emissions
///     so a sprints arrival doesn't clobber what the user typed.
///   - **Reset on user switch only** (`personDocId` change → cross-user
///     pin leak). A late-arriving `lastCompleted` sprint just refreshes
///     the cached seed — user edits are preserved either way.

@ProviderFor(CreateSprintDraft)
final createSprintDraftProvider = CreateSprintDraftProvider._();

/// Holds the create-sprint cadence draft (TM-388).
///
/// Seeding mirrors the pre-TM-388 `NewSprintScreen._updateDatesOnInit` /
/// `_getNextScheduledStart`: inherit the last completed sprint's cadence
/// and start at the next scheduled boundary; otherwise default to a
/// 1-week sprint starting now.
///
/// `build()` `watch`es `personDocIdProvider` and `lastCompletedSprintProvider`:
///   - **`_cachedSeed`** stops `DateTime.now()` inside `_seedFrom` from
///     drifting on no-op stream re-emissions (Drift can re-emit when an
///     unrelated watched table touches). Recomputed only when an input
///     actually changes.
///   - **`_userEdited`** pins user edits against late stream emissions
///     so a sprints arrival doesn't clobber what the user typed.
///   - **Reset on user switch only** (`personDocId` change → cross-user
///     pin leak). A late-arriving `lastCompleted` sprint just refreshes
///     the cached seed — user edits are preserved either way.
final class CreateSprintDraftProvider
    extends $NotifierProvider<CreateSprintDraft, CreateSprintDraftState> {
  /// Holds the create-sprint cadence draft (TM-388).
  ///
  /// Seeding mirrors the pre-TM-388 `NewSprintScreen._updateDatesOnInit` /
  /// `_getNextScheduledStart`: inherit the last completed sprint's cadence
  /// and start at the next scheduled boundary; otherwise default to a
  /// 1-week sprint starting now.
  ///
  /// `build()` `watch`es `personDocIdProvider` and `lastCompletedSprintProvider`:
  ///   - **`_cachedSeed`** stops `DateTime.now()` inside `_seedFrom` from
  ///     drifting on no-op stream re-emissions (Drift can re-emit when an
  ///     unrelated watched table touches). Recomputed only when an input
  ///     actually changes.
  ///   - **`_userEdited`** pins user edits against late stream emissions
  ///     so a sprints arrival doesn't clobber what the user typed.
  ///   - **Reset on user switch only** (`personDocId` change → cross-user
  ///     pin leak). A late-arriving `lastCompleted` sprint just refreshes
  ///     the cached seed — user edits are preserved either way.
  CreateSprintDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSprintDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSprintDraftHash();

  @$internal
  @override
  CreateSprintDraft create() => CreateSprintDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSprintDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSprintDraftState>(value),
    );
  }
}

String _$createSprintDraftHash() => r'b3a949918297656fe3a83b11efb28da6caad8a6a';

/// Holds the create-sprint cadence draft (TM-388).
///
/// Seeding mirrors the pre-TM-388 `NewSprintScreen._updateDatesOnInit` /
/// `_getNextScheduledStart`: inherit the last completed sprint's cadence
/// and start at the next scheduled boundary; otherwise default to a
/// 1-week sprint starting now.
///
/// `build()` `watch`es `personDocIdProvider` and `lastCompletedSprintProvider`:
///   - **`_cachedSeed`** stops `DateTime.now()` inside `_seedFrom` from
///     drifting on no-op stream re-emissions (Drift can re-emit when an
///     unrelated watched table touches). Recomputed only when an input
///     actually changes.
///   - **`_userEdited`** pins user edits against late stream emissions
///     so a sprints arrival doesn't clobber what the user typed.
///   - **Reset on user switch only** (`personDocId` change → cross-user
///     pin leak). A late-arriving `lastCompleted` sprint just refreshes
///     the cached seed — user edits are preserved either way.

abstract class _$CreateSprintDraft extends $Notifier<CreateSprintDraftState> {
  CreateSprintDraftState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<CreateSprintDraftState, CreateSprintDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateSprintDraftState, CreateSprintDraftState>,
              CreateSprintDraftState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Derived end date for the create-sprint draft (TM-388): the single
/// canonical formula (`startDate` advanced by the cadence) read by both
/// the wide task picker and `planBasePool`, so sidebar counts can't drift
/// from the rendered list.

@ProviderFor(createSprintEndDate)
final createSprintEndDateProvider = CreateSprintEndDateProvider._();

/// Derived end date for the create-sprint draft (TM-388): the single
/// canonical formula (`startDate` advanced by the cadence) read by both
/// the wide task picker and `planBasePool`, so sidebar counts can't drift
/// from the rendered list.

final class CreateSprintEndDateProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// Derived end date for the create-sprint draft (TM-388): the single
  /// canonical formula (`startDate` advanced by the cadence) read by both
  /// the wide task picker and `planBasePool`, so sidebar counts can't drift
  /// from the rendered list.
  CreateSprintEndDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSprintEndDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSprintEndDateHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return createSprintEndDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$createSprintEndDateHash() =>
    r'b926fcab04812194993055979c48042b90b57219';

@ProviderFor(CreateSprintStep)
final createSprintStepProvider = CreateSprintStepProvider._();

final class CreateSprintStepProvider
    extends $NotifierProvider<CreateSprintStep, CreateSprintStepValue> {
  CreateSprintStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSprintStepProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSprintStepHash();

  @$internal
  @override
  CreateSprintStep create() => CreateSprintStep();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSprintStepValue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSprintStepValue>(value),
    );
  }
}

String _$createSprintStepHash() => r'6b15b0f682155ab76cc066e233413ffa5c9b8552';

abstract class _$CreateSprintStep extends $Notifier<CreateSprintStepValue> {
  CreateSprintStepValue build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CreateSprintStepValue, CreateSprintStepValue>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateSprintStepValue, CreateSprintStepValue>,
              CreateSprintStepValue,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
