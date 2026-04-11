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
String _$completeTaskHash() => r'68ab83bee7cdf2bc91b86d887d5671df1cb37216';

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
String _$deleteTaskHash() => r'fe81d4e0f8a6893bece8275924cdd340c9349da3';

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
String _$addTaskHash() => r'829d107b756acadae687ed3c267d4a7c99fec2dd';

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
String _$updateTaskHash() => r'c7e01426cd2f17ace3b4ce4b2273c50e20620a2d';

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
String _$snoozeTaskHash() => r'4fa3a36948d1e331c794f5b7a1dff897d924868b';

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
