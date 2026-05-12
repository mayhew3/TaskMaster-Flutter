// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filter state for the Family tab. Kept separate from the Tasks tab's filter
/// providers so toggling on one tab doesn't affect the other (TM-335).

@ProviderFor(FamilyShowCompleted)
final familyShowCompletedProvider = FamilyShowCompletedProvider._();

/// Filter state for the Family tab. Kept separate from the Tasks tab's filter
/// providers so toggling on one tab doesn't affect the other (TM-335).
final class FamilyShowCompletedProvider
    extends $NotifierProvider<FamilyShowCompleted, bool> {
  /// Filter state for the Family tab. Kept separate from the Tasks tab's filter
  /// providers so toggling on one tab doesn't affect the other (TM-335).
  FamilyShowCompletedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyShowCompletedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyShowCompletedHash();

  @$internal
  @override
  FamilyShowCompleted create() => FamilyShowCompleted();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$familyShowCompletedHash() =>
    r'47639aacfddb5bd94d2fb124a62eeabe78e380d8';

/// Filter state for the Family tab. Kept separate from the Tasks tab's filter
/// providers so toggling on one tab doesn't affect the other (TM-335).

abstract class _$FamilyShowCompleted extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FamilyShowScheduled)
final familyShowScheduledProvider = FamilyShowScheduledProvider._();

final class FamilyShowScheduledProvider
    extends $NotifierProvider<FamilyShowScheduled, bool> {
  FamilyShowScheduledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyShowScheduledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyShowScheduledHash();

  @$internal
  @override
  FamilyShowScheduled create() => FamilyShowScheduled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$familyShowScheduledHash() =>
    r'2c58b267d17f3538a776ef556b58ea5b6608fa58';

abstract class _$FamilyShowScheduled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FamilySearchQuery)
final familySearchQueryProvider = FamilySearchQueryProvider._();

final class FamilySearchQueryProvider
    extends $NotifierProvider<FamilySearchQuery, String> {
  FamilySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familySearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familySearchQueryHash();

  @$internal
  @override
  FamilySearchQuery create() => FamilySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$familySearchQueryHash() => r'45080988144a6101204328a7ce67f7bdfa812a51';

abstract class _$FamilySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Optional per-member filter chip — null means "all members".

@ProviderFor(FamilyMemberFilter)
final familyMemberFilterProvider = FamilyMemberFilterProvider._();

/// Optional per-member filter chip — null means "all members".
final class FamilyMemberFilterProvider
    extends $NotifierProvider<FamilyMemberFilter, String?> {
  /// Optional per-member filter chip — null means "all members".
  FamilyMemberFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyMemberFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyMemberFilterHash();

  @$internal
  @override
  FamilyMemberFilter create() => FamilyMemberFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$familyMemberFilterHash() =>
    r'403e2a10fcfcad29ee468160e52f7a7a55b6717e';

/// Optional per-member filter chip — null means "all members".

abstract class _$FamilyMemberFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Family tasks after applying the Family-tab filter toggles. Tasks completed
/// in the current session (tracked by [recentlyCompletedTasksProvider]) are
/// always included so the just-completed task stays visible — the grouping
/// step keeps it in its original section until the user navigates away.
///
/// TM-368: pure-derived from upstream filter toggles + tasks stream. Cheap
/// to recompute when the Family tab remounts; auto-dispose is correct.

@ProviderFor(familyFilteredTasks)
final familyFilteredTasksProvider = FamilyFilteredTasksProvider._();

/// Family tasks after applying the Family-tab filter toggles. Tasks completed
/// in the current session (tracked by [recentlyCompletedTasksProvider]) are
/// always included so the just-completed task stays visible — the grouping
/// step keeps it in its original section until the user navigates away.
///
/// TM-368: pure-derived from upstream filter toggles + tasks stream. Cheap
/// to recompute when the Family tab remounts; auto-dispose is correct.

final class FamilyFilteredTasksProvider
    extends $FunctionalProvider<List<TaskItem>, List<TaskItem>, List<TaskItem>>
    with $Provider<List<TaskItem>> {
  /// Family tasks after applying the Family-tab filter toggles. Tasks completed
  /// in the current session (tracked by [recentlyCompletedTasksProvider]) are
  /// always included so the just-completed task stays visible — the grouping
  /// step keeps it in its original section until the user navigates away.
  ///
  /// TM-368: pure-derived from upstream filter toggles + tasks stream. Cheap
  /// to recompute when the Family tab remounts; auto-dispose is correct.
  FamilyFilteredTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyFilteredTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyFilteredTasksHash();

  @$internal
  @override
  $ProviderElement<List<TaskItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskItem> create(Ref ref) {
    return familyFilteredTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskItem>>(value),
    );
  }
}

String _$familyFilteredTasksHash() =>
    r'4166e9fba1fd525a5eabe9366c60c18d1bc3e958';

/// Family tasks grouped into Past Due / Urgent / Target / Tasks / Scheduled /
/// Completed buckets. Mirrors the Tasks-tab grouping shape, including the
/// TM-323 "recently completed stays in its original group" behavior so the
/// just-completed task doesn't visibly jump to the Completed section until
/// after the user navigates away and back.
///
/// TM-368: pure-derived from `familyFilteredTasks` + recently-completed.
/// Cheap iteration; auto-dispose is correct.

@ProviderFor(familyGroupedTasks)
final familyGroupedTasksProvider = FamilyGroupedTasksProvider._();

/// Family tasks grouped into Past Due / Urgent / Target / Tasks / Scheduled /
/// Completed buckets. Mirrors the Tasks-tab grouping shape, including the
/// TM-323 "recently completed stays in its original group" behavior so the
/// just-completed task doesn't visibly jump to the Completed section until
/// after the user navigates away and back.
///
/// TM-368: pure-derived from `familyFilteredTasks` + recently-completed.
/// Cheap iteration; auto-dispose is correct.

final class FamilyGroupedTasksProvider
    extends
        $FunctionalProvider<List<TaskGroup>, List<TaskGroup>, List<TaskGroup>>
    with $Provider<List<TaskGroup>> {
  /// Family tasks grouped into Past Due / Urgent / Target / Tasks / Scheduled /
  /// Completed buckets. Mirrors the Tasks-tab grouping shape, including the
  /// TM-323 "recently completed stays in its original group" behavior so the
  /// just-completed task doesn't visibly jump to the Completed section until
  /// after the user navigates away and back.
  ///
  /// TM-368: pure-derived from `familyFilteredTasks` + recently-completed.
  /// Cheap iteration; auto-dispose is correct.
  FamilyGroupedTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyGroupedTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyGroupedTasksHash();

  @$internal
  @override
  $ProviderElement<List<TaskGroup>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskGroup> create(Ref ref) {
    return familyGroupedTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskGroup> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskGroup>>(value),
    );
  }
}

String _$familyGroupedTasksHash() =>
    r'd2aea6084832c12aa84cbd637d06993d13636997';
