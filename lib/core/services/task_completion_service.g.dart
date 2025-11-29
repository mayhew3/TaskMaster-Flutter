// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskCompletionServiceHash() =>
    r'61166b994cae7b931b47b3d3d1c6451e302e51c1';

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
    r'40ba386668fcee58eef4e670913409e98bf1e889';

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
String _$completeTaskHash() => r'0d04326929cb41108cd9853aacf818f6a8279a81';

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
String _$deleteTaskHash() => r'a6fc238b8a706c9ff3f097a310f39f8913bba796';

/// Controller for deleting tasks
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
String _$addTaskHash() => r'4fdc26b07bcb6c239e388733922ee8fc5af62dfc';

/// Controller for adding new tasks
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
String _$updateTaskHash() => r'be3105f321431a44b5e31fe119cb7ea6fb1b3ed4';

/// Controller for updating tasks
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
String _$snoozeTaskHash() => r'0824f34d84345eacdbd8fbaeec0da085ac102ad6';

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
