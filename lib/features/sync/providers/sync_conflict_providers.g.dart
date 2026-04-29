// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_conflict_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskConflictRowsHash() => r'33df9ac2d0a911dca8d632adb1329731df742a2f';

/// Raw stream of Drift rows currently in `pendingConflict` for the user.
/// Powers the banner count (so a row with an undecodable envelope still
/// contributes to the count and doesn't silently disappear from the UI).
///
/// Copied from [taskConflictRows].
@ProviderFor(taskConflictRows)
final taskConflictRowsProvider =
    AutoDisposeStreamProvider<List<drift.Task>>.internal(
      taskConflictRows,
      name: r'taskConflictRowsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskConflictRowsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskConflictRowsRef = AutoDisposeStreamProviderRef<List<drift.Task>>;
String _$recurrenceConflictRowsHash() =>
    r'a0eba5635c26f18d7b19f18f380ab9a4da140dd9';

/// Same as [taskConflictRowsProvider] but for recurrences.
///
/// Copied from [recurrenceConflictRows].
@ProviderFor(recurrenceConflictRows)
final recurrenceConflictRowsProvider =
    AutoDisposeStreamProvider<List<drift.TaskRecurrence>>.internal(
      recurrenceConflictRows,
      name: r'recurrenceConflictRowsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recurrenceConflictRowsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurrenceConflictRowsRef =
    AutoDisposeStreamProviderRef<List<drift.TaskRecurrence>>;
String _$taskConflictsHash() => r'e997490a7751d43711ca5be49339443cd14f2905';

/// Stream of task conflicts for the current user — only entries whose
/// `conflictRemoteJson` envelope decodes cleanly. Use [taskConflictRowsProvider]
/// for the count (which includes rows that fail to decode and would otherwise
/// hide from the UI).
///
/// Copied from [taskConflicts].
@ProviderFor(taskConflicts)
final taskConflictsProvider =
    AutoDisposeStreamProvider<List<TaskConflict>>.internal(
      taskConflicts,
      name: r'taskConflictsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskConflictsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskConflictsRef = AutoDisposeStreamProviderRef<List<TaskConflict>>;
String _$recurrenceConflictsHash() =>
    r'a01d93718b308dae72b1e0142e6a88e80b464c7d';

/// Stream of recurrence conflicts for the current user. Same caveat as
/// [taskConflictsProvider] re: rows with undecodable envelopes.
///
/// Copied from [recurrenceConflicts].
@ProviderFor(recurrenceConflicts)
final recurrenceConflictsProvider =
    AutoDisposeStreamProvider<List<RecurrenceConflict>>.internal(
      recurrenceConflicts,
      name: r'recurrenceConflictsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recurrenceConflictsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurrenceConflictsRef =
    AutoDisposeStreamProviderRef<List<RecurrenceConflict>>;
String _$allConflictsCountHash() => r'3f3437a9f81e776955052f542023b30e53efbb5c';

/// Combined count across task + recurrence conflicts for the banner. Returns
/// 0 unless BOTH underlying streams have emitted at least once.
///
/// **Drives the count from raw DAO row counts**, not from the decoded list
/// length, so a row whose envelope fails to decode still contributes to the
/// count. Otherwise the banner would silently disappear and the user would
/// have no way to clear the stuck row.
///
/// Copied from [allConflictsCount].
@ProviderFor(allConflictsCount)
final allConflictsCountProvider = AutoDisposeProvider<int>.internal(
  allConflictsCount,
  name: r'allConflictsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allConflictsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllConflictsCountRef = AutoDisposeProviderRef<int>;
String _$stuckConflictsCountHash() =>
    r'5e3c1832d85ec79d5c992209ea6e455bc9c144c9';

/// Count of pendingConflict rows whose envelope did NOT decode (so they
/// don't appear in the typed conflicts lists). When non-zero the screen
/// surfaces a "force clear stuck" recovery action.
///
/// Copied from [stuckConflictsCount].
@ProviderFor(stuckConflictsCount)
final stuckConflictsCountProvider = AutoDisposeProvider<int>.internal(
  stuckConflictsCount,
  name: r'stuckConflictsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stuckConflictsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StuckConflictsCountRef = AutoDisposeProviderRef<int>;
String _$keepLocalConflictHash() => r'b67b5ba5370803a26c993d33b77b2f30080f1481';

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which must win the next conflict-detection
/// comparison so the user's intent isn't bounced right back into a conflict).
///
/// Copied from [KeepLocalConflict].
@ProviderFor(KeepLocalConflict)
final keepLocalConflictProvider =
    AutoDisposeAsyncNotifierProvider<KeepLocalConflict, void>.internal(
      KeepLocalConflict.new,
      name: r'keepLocalConflictProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$keepLocalConflictHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$KeepLocalConflict = AutoDisposeAsyncNotifier<void>;
String _$acceptRemoteConflictHash() =>
    r'90de3893a0de4ab05c06698b7776943069da19bb';

/// Resolution: accept the remote version, overwriting the local pending edit.
///
/// Copied from [AcceptRemoteConflict].
@ProviderFor(AcceptRemoteConflict)
final acceptRemoteConflictProvider =
    AutoDisposeAsyncNotifierProvider<AcceptRemoteConflict, void>.internal(
      AcceptRemoteConflict.new,
      name: r'acceptRemoteConflictProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$acceptRemoteConflictHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AcceptRemoteConflict = AutoDisposeAsyncNotifier<void>;
String _$forceClearStuckConflictsHash() =>
    r'ea9290b15767eeb1678f48eee6a0613365e49191';

/// Force-clear pendingConflict rows whose envelope failed to decode (the
/// "stuck" set). Resets them to pendingUpdate with refreshed `lastModified`
/// and triggers a push so the next sync can resolve them.
///
/// Copied from [ForceClearStuckConflicts].
@ProviderFor(ForceClearStuckConflicts)
final forceClearStuckConflictsProvider =
    AutoDisposeAsyncNotifierProvider<ForceClearStuckConflicts, void>.internal(
      ForceClearStuckConflicts.new,
      name: r'forceClearStuckConflictsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$forceClearStuckConflictsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ForceClearStuckConflicts = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
