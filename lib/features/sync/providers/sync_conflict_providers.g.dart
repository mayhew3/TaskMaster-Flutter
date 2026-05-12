// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_conflict_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Raw count of pendingConflict task rows for the user. Powers the banner
/// count and the "stuck-rows" calculation — used by `allConflictsCount`
/// and `stuckConflictsCount` below.
///
/// **Returns just the count rather than the full row list** because
/// riverpod_generator 4.x can't introspect Drift-generated row types
/// (`drift.Task`, `drift.TaskRecurrence`) in a provider's return signature
/// — it bails with `InvalidTypeException` (TM-361). The downstream
/// consumers in this file only need the row counts; surfacing them as
/// `int` avoids the cliff cleanly.

@ProviderFor(taskConflictRowCount)
final taskConflictRowCountProvider = TaskConflictRowCountProvider._();

/// Raw count of pendingConflict task rows for the user. Powers the banner
/// count and the "stuck-rows" calculation — used by `allConflictsCount`
/// and `stuckConflictsCount` below.
///
/// **Returns just the count rather than the full row list** because
/// riverpod_generator 4.x can't introspect Drift-generated row types
/// (`drift.Task`, `drift.TaskRecurrence`) in a provider's return signature
/// — it bails with `InvalidTypeException` (TM-361). The downstream
/// consumers in this file only need the row counts; surfacing them as
/// `int` avoids the cliff cleanly.

final class TaskConflictRowCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Raw count of pendingConflict task rows for the user. Powers the banner
  /// count and the "stuck-rows" calculation — used by `allConflictsCount`
  /// and `stuckConflictsCount` below.
  ///
  /// **Returns just the count rather than the full row list** because
  /// riverpod_generator 4.x can't introspect Drift-generated row types
  /// (`drift.Task`, `drift.TaskRecurrence`) in a provider's return signature
  /// — it bails with `InvalidTypeException` (TM-361). The downstream
  /// consumers in this file only need the row counts; surfacing them as
  /// `int` avoids the cliff cleanly.
  TaskConflictRowCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskConflictRowCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskConflictRowCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return taskConflictRowCount(ref);
  }
}

String _$taskConflictRowCountHash() =>
    r'e29492d5e7ce01df4418733d95d02bda66dbe946';

/// Same as [taskConflictRowCountProvider] but for recurrences.

@ProviderFor(recurrenceConflictRowCount)
final recurrenceConflictRowCountProvider =
    RecurrenceConflictRowCountProvider._();

/// Same as [taskConflictRowCountProvider] but for recurrences.

final class RecurrenceConflictRowCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Same as [taskConflictRowCountProvider] but for recurrences.
  RecurrenceConflictRowCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurrenceConflictRowCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurrenceConflictRowCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return recurrenceConflictRowCount(ref);
  }
}

String _$recurrenceConflictRowCountHash() =>
    r'4f90771b8293bf20a5fc299a4e7c392bc6bf872e';

/// Stream of task conflicts for the current user — only entries whose
/// `conflictRemoteJson` envelope decodes cleanly. Use [taskConflictRowsProvider]
/// for the count (which includes rows that fail to decode and would otherwise
/// hide from the UI).

@ProviderFor(taskConflicts)
final taskConflictsProvider = TaskConflictsProvider._();

/// Stream of task conflicts for the current user — only entries whose
/// `conflictRemoteJson` envelope decodes cleanly. Use [taskConflictRowsProvider]
/// for the count (which includes rows that fail to decode and would otherwise
/// hide from the UI).

final class TaskConflictsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskConflict>>,
          List<TaskConflict>,
          Stream<List<TaskConflict>>
        >
    with
        $FutureModifier<List<TaskConflict>>,
        $StreamProvider<List<TaskConflict>> {
  /// Stream of task conflicts for the current user — only entries whose
  /// `conflictRemoteJson` envelope decodes cleanly. Use [taskConflictRowsProvider]
  /// for the count (which includes rows that fail to decode and would otherwise
  /// hide from the UI).
  TaskConflictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskConflictsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskConflictsHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskConflict>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskConflict>> create(Ref ref) {
    return taskConflicts(ref);
  }
}

String _$taskConflictsHash() => r'ab59ba087e4a3254b981fb3fcc28bcbfd8130e8f';

/// Stream of recurrence conflicts for the current user. Same caveat as
/// [taskConflictsProvider] re: rows with undecodable envelopes.

@ProviderFor(recurrenceConflicts)
final recurrenceConflictsProvider = RecurrenceConflictsProvider._();

/// Stream of recurrence conflicts for the current user. Same caveat as
/// [taskConflictsProvider] re: rows with undecodable envelopes.

final class RecurrenceConflictsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurrenceConflict>>,
          List<RecurrenceConflict>,
          Stream<List<RecurrenceConflict>>
        >
    with
        $FutureModifier<List<RecurrenceConflict>>,
        $StreamProvider<List<RecurrenceConflict>> {
  /// Stream of recurrence conflicts for the current user. Same caveat as
  /// [taskConflictsProvider] re: rows with undecodable envelopes.
  RecurrenceConflictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurrenceConflictsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurrenceConflictsHash();

  @$internal
  @override
  $StreamProviderElement<List<RecurrenceConflict>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecurrenceConflict>> create(Ref ref) {
    return recurrenceConflicts(ref);
  }
}

String _$recurrenceConflictsHash() =>
    r'8475c469206c0573185c34f5c81be4a944c88bab';

/// Combined count across task + recurrence conflicts for the banner. Returns
/// 0 unless BOTH underlying streams have emitted at least once.
///
/// **Drives the count from raw DAO row counts**, not from the decoded list
/// length, so a row whose envelope fails to decode still contributes to the
/// count. Otherwise the banner would silently disappear and the user would
/// have no way to clear the stuck row.

@ProviderFor(allConflictsCount)
final allConflictsCountProvider = AllConflictsCountProvider._();

/// Combined count across task + recurrence conflicts for the banner. Returns
/// 0 unless BOTH underlying streams have emitted at least once.
///
/// **Drives the count from raw DAO row counts**, not from the decoded list
/// length, so a row whose envelope fails to decode still contributes to the
/// count. Otherwise the banner would silently disappear and the user would
/// have no way to clear the stuck row.

final class AllConflictsCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Combined count across task + recurrence conflicts for the banner. Returns
  /// 0 unless BOTH underlying streams have emitted at least once.
  ///
  /// **Drives the count from raw DAO row counts**, not from the decoded list
  /// length, so a row whose envelope fails to decode still contributes to the
  /// count. Otherwise the banner would silently disappear and the user would
  /// have no way to clear the stuck row.
  AllConflictsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allConflictsCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allConflictsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return allConflictsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$allConflictsCountHash() => r'c03c39e64a0fe622d1cf31e535bd0565d4d690d4';

/// Count of pendingConflict rows whose envelope did NOT decode (so they
/// don't appear in the typed conflicts lists). When non-zero the screen
/// surfaces a "force clear stuck" recovery action.

@ProviderFor(stuckConflictsCount)
final stuckConflictsCountProvider = StuckConflictsCountProvider._();

/// Count of pendingConflict rows whose envelope did NOT decode (so they
/// don't appear in the typed conflicts lists). When non-zero the screen
/// surfaces a "force clear stuck" recovery action.

final class StuckConflictsCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Count of pendingConflict rows whose envelope did NOT decode (so they
  /// don't appear in the typed conflicts lists). When non-zero the screen
  /// surfaces a "force clear stuck" recovery action.
  StuckConflictsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stuckConflictsCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stuckConflictsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return stuckConflictsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$stuckConflictsCountHash() =>
    r'd04f6a955be260083487af763ed52db36abf8b4b';

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which must win the next conflict-detection
/// comparison so the user's intent isn't bounced right back into a conflict).

@ProviderFor(KeepLocalConflict)
final keepLocalConflictProvider = KeepLocalConflictProvider._();

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which must win the next conflict-detection
/// comparison so the user's intent isn't bounced right back into a conflict).
final class KeepLocalConflictProvider
    extends $AsyncNotifierProvider<KeepLocalConflict, void> {
  /// Resolution: keep the local pending edit, restore the prior pending state,
  /// and trigger another push (which must win the next conflict-detection
  /// comparison so the user's intent isn't bounced right back into a conflict).
  KeepLocalConflictProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keepLocalConflictProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keepLocalConflictHash();

  @$internal
  @override
  KeepLocalConflict create() => KeepLocalConflict();
}

String _$keepLocalConflictHash() => r'8726c448102d3560fb274fad905707b48fdb4c74';

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which must win the next conflict-detection
/// comparison so the user's intent isn't bounced right back into a conflict).

abstract class _$KeepLocalConflict extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Resolution: accept the remote version, overwriting the local pending edit.

@ProviderFor(AcceptRemoteConflict)
final acceptRemoteConflictProvider = AcceptRemoteConflictProvider._();

/// Resolution: accept the remote version, overwriting the local pending edit.
final class AcceptRemoteConflictProvider
    extends $AsyncNotifierProvider<AcceptRemoteConflict, void> {
  /// Resolution: accept the remote version, overwriting the local pending edit.
  AcceptRemoteConflictProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'acceptRemoteConflictProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$acceptRemoteConflictHash();

  @$internal
  @override
  AcceptRemoteConflict create() => AcceptRemoteConflict();
}

String _$acceptRemoteConflictHash() =>
    r'c576cec17649d3e732e6549bb448ae918299d505';

/// Resolution: accept the remote version, overwriting the local pending edit.

abstract class _$AcceptRemoteConflict extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Force-clear pendingConflict rows whose envelope failed to decode (the
/// "stuck" set). Resets them to pendingUpdate with refreshed `lastModified`
/// and triggers a push so the next sync can resolve them.

@ProviderFor(ForceClearStuckConflicts)
final forceClearStuckConflictsProvider = ForceClearStuckConflictsProvider._();

/// Force-clear pendingConflict rows whose envelope failed to decode (the
/// "stuck" set). Resets them to pendingUpdate with refreshed `lastModified`
/// and triggers a push so the next sync can resolve them.
final class ForceClearStuckConflictsProvider
    extends $AsyncNotifierProvider<ForceClearStuckConflicts, void> {
  /// Force-clear pendingConflict rows whose envelope failed to decode (the
  /// "stuck" set). Resets them to pendingUpdate with refreshed `lastModified`
  /// and triggers a push so the next sync can resolve them.
  ForceClearStuckConflictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forceClearStuckConflictsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forceClearStuckConflictsHash();

  @$internal
  @override
  ForceClearStuckConflicts create() => ForceClearStuckConflicts();
}

String _$forceClearStuckConflictsHash() =>
    r'4a54ee8cb757d4de4c385e797846be86b3ac47f5';

/// Force-clear pendingConflict rows whose envelope failed to decode (the
/// "stuck" set). Resets them to pendingUpdate with refreshed `lastModified`
/// and triggers a push so the next sync can resolve them.

abstract class _$ForceClearStuckConflicts extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
