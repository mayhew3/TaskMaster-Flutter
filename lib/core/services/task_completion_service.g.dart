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
String _$completeTaskHash() => r'9743e657e2db2272fbc2ded57a663c92a5b50e88';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
