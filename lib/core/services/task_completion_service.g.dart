// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for completing tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke these
/// mutation notifiers via `ref.read(.notifier).call(...)` (no active
/// listener), so auto-dispose could fire between the first `await` and a
/// subsequent `ref.read(...)` inside `call()` → "Cannot use ref after
/// disposal" mid-mutation. The Category C "case-by-case" note in TM-368's
/// plan flagged this risk; the audit didn't catch every site, so Copilot
/// did. Applies to all six mutation notifiers in this file.

@ProviderFor(CompleteTask)
final completeTaskProvider = CompleteTaskProvider._();

/// Controller for completing tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke these
/// mutation notifiers via `ref.read(.notifier).call(...)` (no active
/// listener), so auto-dispose could fire between the first `await` and a
/// subsequent `ref.read(...)` inside `call()` → "Cannot use ref after
/// disposal" mid-mutation. The Category C "case-by-case" note in TM-368's
/// plan flagged this risk; the audit didn't catch every site, so Copilot
/// did. Applies to all six mutation notifiers in this file.
final class CompleteTaskProvider
    extends $AsyncNotifierProvider<CompleteTask, void> {
  /// Controller for completing tasks.
  /// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke these
  /// mutation notifiers via `ref.read(.notifier).call(...)` (no active
  /// listener), so auto-dispose could fire between the first `await` and a
  /// subsequent `ref.read(...)` inside `call()` → "Cannot use ref after
  /// disposal" mid-mutation. The Category C "case-by-case" note in TM-368's
  /// plan flagged this risk; the audit didn't catch every site, so Copilot
  /// did. Applies to all six mutation notifiers in this file.
  CompleteTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeTaskHash();

  @$internal
  @override
  CompleteTask create() => CompleteTask();
}

String _$completeTaskHash() => r'276e8a5a922267bc0be2bbc625b8e415f457d591';

/// Controller for completing tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true`. Callers invoke these
/// mutation notifiers via `ref.read(.notifier).call(...)` (no active
/// listener), so auto-dispose could fire between the first `await` and a
/// subsequent `ref.read(...)` inside `call()` → "Cannot use ref after
/// disposal" mid-mutation. The Category C "case-by-case" note in TM-368's
/// plan flagged this risk; the audit didn't catch every site, so Copilot
/// did. Applies to all six mutation notifiers in this file.

abstract class _$CompleteTask extends $AsyncNotifier<void> {
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

/// Controller for skipping a recurring task instance.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

@ProviderFor(SkipTask)
final skipTaskProvider = SkipTaskProvider._();

/// Controller for skipping a recurring task instance.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
final class SkipTaskProvider extends $AsyncNotifierProvider<SkipTask, void> {
  /// Controller for skipping a recurring task instance.
  /// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
  SkipTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skipTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skipTaskHash();

  @$internal
  @override
  SkipTask create() => SkipTask();
}

String _$skipTaskHash() => r'0ce20d77e64c67a98e85885df6557d1f9c6ad102';

/// Controller for skipping a recurring task instance.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

abstract class _$SkipTask extends $AsyncNotifier<void> {
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

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

@ProviderFor(DeleteTask)
final deleteTaskProvider = DeleteTaskProvider._();

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
final class DeleteTaskProvider
    extends $AsyncNotifierProvider<DeleteTask, void> {
  /// Controller for deleting tasks.
  ///
  /// Notifier `state` is intentionally NOT mutated from `call`. With a sync
  /// `FutureOr<void> build()` the AsyncNotifier's internal future completer
  /// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
  /// re-completes it and throws "Bad state: Future already completed". UI
  /// loading state is handled locally by callers (e.g. `_busy` flags).
  /// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
  DeleteTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteTaskHash();

  @$internal
  @override
  DeleteTask create() => DeleteTask();
}

String _$deleteTaskHash() => r'd2f97e71481efe7b87aae46d7415269289bdc295';

/// Controller for deleting tasks.
///
/// Notifier `state` is intentionally NOT mutated from `call`. With a sync
/// `FutureOr<void> build()` the AsyncNotifier's internal future completer
/// is settled at construction; subsequent `state = AsyncLoading/AsyncData`
/// re-completes it and throws "Bad state: Future already completed". UI
/// loading state is handled locally by callers (e.g. `_busy` flags).
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

abstract class _$DeleteTask extends $AsyncNotifier<void> {
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

/// Controller for adding new tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

@ProviderFor(AddTask)
final addTaskProvider = AddTaskProvider._();

/// Controller for adding new tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
final class AddTaskProvider extends $AsyncNotifierProvider<AddTask, void> {
  /// Controller for adding new tasks.
  /// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
  AddTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addTaskHash();

  @$internal
  @override
  AddTask create() => AddTask();
}

String _$addTaskHash() => r'50ae61da56cfc6746bbd628a749f31948809b8cf';

/// Controller for adding new tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

abstract class _$AddTask extends $AsyncNotifier<void> {
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

/// Controller for updating tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

@ProviderFor(UpdateTask)
final updateTaskProvider = UpdateTaskProvider._();

/// Controller for updating tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
final class UpdateTaskProvider
    extends $AsyncNotifierProvider<UpdateTask, void> {
  /// Controller for updating tasks.
  /// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
  UpdateTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTaskHash();

  @$internal
  @override
  UpdateTask create() => UpdateTask();
}

String _$updateTaskHash() => r'9aaa89b631f83962d54ac6621b8fa911792da575';

/// Controller for updating tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

abstract class _$UpdateTask extends $AsyncNotifier<void> {
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

/// Controller for snoozing tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

@ProviderFor(SnoozeTask)
final snoozeTaskProvider = SnoozeTaskProvider._();

/// Controller for snoozing tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
final class SnoozeTaskProvider
    extends $AsyncNotifierProvider<SnoozeTask, void> {
  /// Controller for snoozing tasks.
  /// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.
  SnoozeTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snoozeTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snoozeTaskHash();

  @$internal
  @override
  SnoozeTask create() => SnoozeTask();
}

String _$snoozeTaskHash() => r'8f582f90888a9ee2239d0d431b25b7f39e4216af';

/// Controller for snoozing tasks.
/// TM-368 + Copilot R8: kept `keepAlive: true` — see `CompleteTask` above.

abstract class _$SnoozeTask extends $AsyncNotifier<void> {
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

/// Provider for legacy TaskRepository (for snooze functionality)

@ProviderFor(legacyTaskRepository)
final legacyTaskRepositoryProvider = LegacyTaskRepositoryProvider._();

/// Provider for legacy TaskRepository (for snooze functionality)

final class LegacyTaskRepositoryProvider
    extends
        $FunctionalProvider<
          legacy.TaskRepository,
          legacy.TaskRepository,
          legacy.TaskRepository
        >
    with $Provider<legacy.TaskRepository> {
  /// Provider for legacy TaskRepository (for snooze functionality)
  LegacyTaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legacyTaskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legacyTaskRepositoryHash();

  @$internal
  @override
  $ProviderElement<legacy.TaskRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  legacy.TaskRepository create(Ref ref) {
    return legacyTaskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(legacy.TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<legacy.TaskRepository>(value),
    );
  }
}

String _$legacyTaskRepositoryHash() =>
    r'736796d2f328e43cc027ff968fc453ada26d05d4';

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first

@ProviderFor(TimezoneHelperNotifier)
final timezoneHelperProvider = TimezoneHelperNotifierProvider._();

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first
final class TimezoneHelperNotifierProvider
    extends $AsyncNotifierProvider<TimezoneHelperNotifier, TimezoneHelper> {
  /// Provider for TimezoneHelper
  /// Must be initialized before use - call configureLocalTimeZone() first
  TimezoneHelperNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timezoneHelperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timezoneHelperNotifierHash();

  @$internal
  @override
  TimezoneHelperNotifier create() => TimezoneHelperNotifier();
}

String _$timezoneHelperNotifierHash() =>
    r'38eced5cb9614d50d30a7b1c818fbc59981d6b30';

/// Provider for TimezoneHelper
/// Must be initialized before use - call configureLocalTimeZone() first

abstract class _$TimezoneHelperNotifier extends $AsyncNotifier<TimezoneHelper> {
  FutureOr<TimezoneHelper> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TimezoneHelper>, TimezoneHelper>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TimezoneHelper>, TimezoneHelper>,
              AsyncValue<TimezoneHelper>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
