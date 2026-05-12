// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sprintService)
final sprintServiceProvider = SprintServiceProvider._();

final class SprintServiceProvider
    extends $FunctionalProvider<SprintService, SprintService, SprintService>
    with $Provider<SprintService> {
  SprintServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sprintServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sprintServiceHash();

  @$internal
  @override
  $ProviderElement<SprintService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SprintService create(Ref ref) {
    return sprintService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SprintService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SprintService>(value),
    );
  }
}

String _$sprintServiceHash() => r'1b6f508815ec93fa67e44a8c041f86796af6582a';

/// Controller for creating sprints.
/// TM-368: fire-and-forget mutation notifier — state is just the last
/// operation's AsyncValue. Auto-dispose is correct; consumers re-attach
/// per invocation.

@ProviderFor(CreateSprint)
final createSprintProvider = CreateSprintProvider._();

/// Controller for creating sprints.
/// TM-368: fire-and-forget mutation notifier — state is just the last
/// operation's AsyncValue. Auto-dispose is correct; consumers re-attach
/// per invocation.
final class CreateSprintProvider
    extends $AsyncNotifierProvider<CreateSprint, void> {
  /// Controller for creating sprints.
  /// TM-368: fire-and-forget mutation notifier — state is just the last
  /// operation's AsyncValue. Auto-dispose is correct; consumers re-attach
  /// per invocation.
  CreateSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSprintProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSprintHash();

  @$internal
  @override
  CreateSprint create() => CreateSprint();
}

String _$createSprintHash() => r'e50a6f5bd03aae791f0fa5cd4126ff7cd09f2e91';

/// Controller for creating sprints.
/// TM-368: fire-and-forget mutation notifier — state is just the last
/// operation's AsyncValue. Auto-dispose is correct; consumers re-attach
/// per invocation.

abstract class _$CreateSprint extends $AsyncNotifier<void> {
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

/// Controller for adding tasks to existing sprint.
/// TM-368: fire-and-forget mutation notifier — see `CreateSprint`.

@ProviderFor(AddTasksToSprint)
final addTasksToSprintProvider = AddTasksToSprintProvider._();

/// Controller for adding tasks to existing sprint.
/// TM-368: fire-and-forget mutation notifier — see `CreateSprint`.
final class AddTasksToSprintProvider
    extends $AsyncNotifierProvider<AddTasksToSprint, void> {
  /// Controller for adding tasks to existing sprint.
  /// TM-368: fire-and-forget mutation notifier — see `CreateSprint`.
  AddTasksToSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTasksToSprintProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTasksToSprintHash();

  @$internal
  @override
  AddTasksToSprint create() => AddTasksToSprint();
}

String _$addTasksToSprintHash() => r'e15560bc6430f0a7868079c045d76c63e963d89a';

/// Controller for adding tasks to existing sprint.
/// TM-368: fire-and-forget mutation notifier — see `CreateSprint`.

abstract class _$AddTasksToSprint extends $AsyncNotifier<void> {
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
