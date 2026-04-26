// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyFilteredTasksHash() =>
    r'c9257a3319b9f3cb86c24fec1b20c45a2de6952e';

/// Family tasks after applying the Family-tab filter toggles. Tasks completed
/// in the current session (tracked by [recentlyCompletedTasksProvider]) are
/// always included so the just-completed task stays visible — the grouping
/// step keeps it in its original section until the user navigates away.
///
/// Copied from [familyFilteredTasks].
@ProviderFor(familyFilteredTasks)
final familyFilteredTasksProvider =
    AutoDisposeProvider<List<TaskItem>>.internal(
      familyFilteredTasks,
      name: r'familyFilteredTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyFilteredTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyFilteredTasksRef = AutoDisposeProviderRef<List<TaskItem>>;
String _$familyGroupedTasksHash() =>
    r'd2aea6084832c12aa84cbd637d06993d13636997';

/// Family tasks grouped into Past Due / Urgent / Target / Tasks / Scheduled /
/// Completed buckets. Mirrors the Tasks-tab grouping shape, including the
/// TM-323 "recently completed stays in its original group" behavior so the
/// just-completed task doesn't visibly jump to the Completed section until
/// after the user navigates away and back.
///
/// Copied from [familyGroupedTasks].
@ProviderFor(familyGroupedTasks)
final familyGroupedTasksProvider =
    AutoDisposeProvider<List<TaskGroup>>.internal(
      familyGroupedTasks,
      name: r'familyGroupedTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyGroupedTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyGroupedTasksRef = AutoDisposeProviderRef<List<TaskGroup>>;
String _$familyShowCompletedHash() =>
    r'47639aacfddb5bd94d2fb124a62eeabe78e380d8';

/// Filter state for the Family tab. Kept separate from the Tasks tab's filter
/// providers so toggling on one tab doesn't affect the other (TM-335).
///
/// Copied from [FamilyShowCompleted].
@ProviderFor(FamilyShowCompleted)
final familyShowCompletedProvider =
    NotifierProvider<FamilyShowCompleted, bool>.internal(
      FamilyShowCompleted.new,
      name: r'familyShowCompletedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyShowCompletedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FamilyShowCompleted = Notifier<bool>;
String _$familyShowScheduledHash() =>
    r'2c58b267d17f3538a776ef556b58ea5b6608fa58';

/// See also [FamilyShowScheduled].
@ProviderFor(FamilyShowScheduled)
final familyShowScheduledProvider =
    NotifierProvider<FamilyShowScheduled, bool>.internal(
      FamilyShowScheduled.new,
      name: r'familyShowScheduledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyShowScheduledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FamilyShowScheduled = Notifier<bool>;
String _$familySearchQueryHash() => r'45080988144a6101204328a7ce67f7bdfa812a51';

/// See also [FamilySearchQuery].
@ProviderFor(FamilySearchQuery)
final familySearchQueryProvider =
    NotifierProvider<FamilySearchQuery, String>.internal(
      FamilySearchQuery.new,
      name: r'familySearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familySearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FamilySearchQuery = Notifier<String>;
String _$familyMemberFilterHash() =>
    r'403e2a10fcfcad29ee468160e52f7a7a55b6717e';

/// Optional per-member filter chip — null means "all members".
///
/// Copied from [FamilyMemberFilter].
@ProviderFor(FamilyMemberFilter)
final familyMemberFilterProvider =
    NotifierProvider<FamilyMemberFilter, String?>.internal(
      FamilyMemberFilter.new,
      name: r'familyMemberFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyMemberFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FamilyMemberFilter = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
