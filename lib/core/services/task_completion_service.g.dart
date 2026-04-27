// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskCompletionServiceHash() =>
    r'ad60561ea8cd39ea6765a3272a5776df358497a7';

/// See also [taskCompletionService].
@ProviderFor(taskCompletionService)
final taskCompletionServiceProvider =
    AutoDisposeProvider<TaskCompletionService>.internal(
      taskCompletionService,
      name: r'taskCompletionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskCompletionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskCompletionServiceRef =
    AutoDisposeProviderRef<TaskCompletionService>;
String _$legacyTaskRepositoryHash() =>
    r'b8092e425e6000371e0635584509e6e293b20da3';

/// Provider for legacy TaskRepository (for snooze functionality)
///
/// Copied from [legacyTaskRepository].
@ProviderFor(legacyTaskRepository)
final legacyTaskRepositoryProvider =
    AutoDisposeProvider<legacy.TaskRepository>.internal(
      legacyTaskRepository,
      name: r'legacyTaskRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$legacyTaskRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LegacyTaskRepositoryRef = AutoDisposeProviderRef<legacy.TaskRepository>;
String _$completeTaskHash() => r'3fd182ac744139a005094da91cbecccfb0c13580';

/// Controller for completing tasks
///
/// Copied from [CompleteTask].
@ProviderFor(CompleteTask)
final completeTaskProvider =
    AutoDisposeAsyncNotifierProvider<CompleteTask, void>.internal(
      CompleteTask.new,
      name: r'completeTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$completeTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompleteTask = AutoDisposeAsyncNotifier<void>;
String _$skipTaskHash() => r'34b2b385586596c1dc8432a42ede8b18439b2c43';

/// Controller for skipping a recurring task instance
///
/// Copied from [SkipTask].
@ProviderFor(SkipTask)
final skipTaskProvider =
    AutoDisposeAsyncNotifierProvider<SkipTask, void>.internal(
      SkipTask.new,
      name: r'skipTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$skipTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SkipTask = AutoDisposeAsyncNotifier<void>;
String _$deleteTaskHash() => r'75b5d13720fc5386dfd53999721eda028959ab36';

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
///
/// Copied from [DeleteTask].
@ProviderFor(DeleteTask)
final deleteTaskProvider =
    AutoDisposeAsyncNotifierProvider<DeleteTask, void>.internal(
      DeleteTask.new,
      name: r'deleteTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeleteTask = AutoDisposeAsyncNotifier<void>;
String _$addTaskHash() => r'0f96b22cf04235abe274be4d8869d6fca3010a9a';

/// Controller for adding new tasks.
///
/// Copied from [AddTask].
@ProviderFor(AddTask)
final addTaskProvider =
    AutoDisposeAsyncNotifierProvider<AddTask, void>.internal(
      AddTask.new,
      name: r'addTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddTask = AutoDisposeAsyncNotifier<void>;
String _$updateTaskHash() => r'8bb8c502dd05d7a2830670163db55a44686aed94';

/// Controller for updating tasks.
///
/// Copied from [UpdateTask].
@ProviderFor(UpdateTask)
final updateTaskProvider =
    AutoDisposeAsyncNotifierProvider<UpdateTask, void>.internal(
      UpdateTask.new,
      name: r'updateTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UpdateTask = AutoDisposeAsyncNotifier<void>;
String _$snoozeTaskHash() => r'7fc6c953aa372c8d82d62fdc567d699324f57a09';

/// Controller for snoozing tasks
///
/// Copied from [SnoozeTask].
@ProviderFor(SnoozeTask)
final snoozeTaskProvider =
    AutoDisposeAsyncNotifierProvider<SnoozeTask, void>.internal(
      SnoozeTask.new,
      name: r'snoozeTaskProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$snoozeTaskHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SnoozeTask = AutoDisposeAsyncNotifier<void>;
String _$timezoneHelperNotifierHash() =>
    r'38eced5cb9614d50d30a7b1c818fbc59981d6b30';

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first
///
/// Copied from [TimezoneHelperNotifier].
@ProviderFor(TimezoneHelperNotifier)
final timezoneHelperNotifierProvider =
    AsyncNotifierProvider<TimezoneHelperNotifier, TimezoneHelper>.internal(
      TimezoneHelperNotifier.new,
      name: r'timezoneHelperNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timezoneHelperNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimezoneHelperNotifier = AsyncNotifier<TimezoneHelper>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
