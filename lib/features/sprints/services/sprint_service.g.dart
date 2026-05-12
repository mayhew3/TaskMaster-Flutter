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
/// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke via
/// `ref.read(.notifier).call(...)` (no active listener), so auto-dispose
/// could fire between `await`s and break a subsequent `ref.read(...)`
/// mid-mutation. Applies to both notifiers in this file.

@ProviderFor(CreateSprint)
final createSprintProvider = CreateSprintProvider._();

/// Controller for creating sprints.
/// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke via
/// `ref.read(.notifier).call(...)` (no active listener), so auto-dispose
/// could fire between `await`s and break a subsequent `ref.read(...)`
/// mid-mutation. Applies to both notifiers in this file.
final class CreateSprintProvider
    extends $AsyncNotifierProvider<CreateSprint, void> {
  /// Controller for creating sprints.
  /// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke via
  /// `ref.read(.notifier).call(...)` (no active listener), so auto-dispose
  /// could fire between `await`s and break a subsequent `ref.read(...)`
  /// mid-mutation. Applies to both notifiers in this file.
  CreateSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSprintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSprintHash();

  @$internal
  @override
  CreateSprint create() => CreateSprint();
}

String _$createSprintHash() => r'2e6e2d6e5da51229f3503c502b51f5a0d70336fb';

/// Controller for creating sprints.
/// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke via
/// `ref.read(.notifier).call(...)` (no active listener), so auto-dispose
/// could fire between `await`s and break a subsequent `ref.read(...)`
/// mid-mutation. Applies to both notifiers in this file.

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
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CreateSprint` above.

@ProviderFor(AddTasksToSprint)
final addTasksToSprintProvider = AddTasksToSprintProvider._();

/// Controller for adding tasks to existing sprint.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CreateSprint` above.
final class AddTasksToSprintProvider
    extends $AsyncNotifierProvider<AddTasksToSprint, void> {
  /// Controller for adding tasks to existing sprint.
  /// TM-368 + Copilot R8: kept `keepAlive: true` — see `CreateSprint` above.
  AddTasksToSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTasksToSprintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTasksToSprintHash();

  @$internal
  @override
  AddTasksToSprint create() => AddTasksToSprint();
}

String _$addTasksToSprintHash() => r'6eea1ad300e77129664e9a47b9562ceea8d26f54';

/// Controller for adding tasks to existing sprint.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CreateSprint` above.

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
