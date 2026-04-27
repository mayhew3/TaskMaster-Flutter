// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_conflict_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskConflictsHash() => r'e997490a7751d43711ca5be49339443cd14f2905';

/// Stream of task conflicts for the current user. Emits empty list when no
/// conflicts exist.
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

/// Stream of recurrence conflicts for the current user.
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
String _$allConflictsCountHash() => r'479241182d2ccae1be17ccfd3d68291b106ad326';

/// Combined count across task + recurrence conflicts for the banner. Returns
/// 0 unless BOTH underlying streams have emitted at least once — partial
/// loading would otherwise flash the banner with a wrong (under-)count
/// before the second stream lands.
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
String _$keepLocalConflictHash() => r'ba28201b1700599eb574d52d258483cb5803c5c2';

/// Resolution: keep the local pending edit, restore the prior pending state,
/// and trigger another push (which will win because clearConflictAndRestorePending
/// refreshes lastModified).
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
