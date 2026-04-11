// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sprintServiceHash() => r'ce065f9f3dbc412d74350423619f50b5753a92ec';

/// See also [sprintService].
@ProviderFor(sprintService)
final sprintServiceProvider = AutoDisposeProvider<SprintService>.internal(
  sprintService,
  name: r'sprintServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sprintServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SprintServiceRef = AutoDisposeProviderRef<SprintService>;
String _$createSprintHash() => r'b6c6af83ceff1c3ff15f0ca62edf01f050f18730';

/// Controller for creating sprints
///
/// Copied from [CreateSprint].
@ProviderFor(CreateSprint)
final createSprintProvider =
    AutoDisposeAsyncNotifierProvider<CreateSprint, void>.internal(
      CreateSprint.new,
      name: r'createSprintProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createSprintHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateSprint = AutoDisposeAsyncNotifier<void>;
String _$addTasksToSprintHash() => r'30de5a8666989e062fa3b2f4cbcd4c3a4cfc6d45';

/// Controller for adding tasks to existing sprint
///
/// Copied from [AddTasksToSprint].
@ProviderFor(AddTasksToSprint)
final addTasksToSprintProvider =
    AutoDisposeAsyncNotifierProvider<AddTasksToSprint, void>.internal(
      AddTasksToSprint.new,
      name: r'addTasksToSprintProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addTasksToSprintHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddTasksToSprint = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
